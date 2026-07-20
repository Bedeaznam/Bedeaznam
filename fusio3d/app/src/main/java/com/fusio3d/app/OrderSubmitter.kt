package com.fusio3d.app

import android.content.Context
import android.content.Intent
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.OutputStream
import java.net.HttpURLConnection
import java.net.URL

/** Result of trying to deliver an order request. */
sealed interface SubmitResult {
    /** Posted to the configured webhook. */
    data object WebhookOk : SubmitResult
    /** No webhook configured (or it failed) — opened the share sheet instead. */
    data object ShareOpened : SubmitResult
    data class Error(val message: String) : SubmitResult
}

/**
 * Delivers an [OrderRequest]. If a webhook URL is configured it POSTs JSON there;
 * otherwise (or on failure) it falls back to a share sheet (email / WhatsApp /
 * Telegram / SMS), so the app is useful with zero backend infrastructure.
 */
object OrderSubmitter {

    suspend fun submit(context: Context, order: OrderRequest): SubmitResult {
        val webhook = BuildConfig.ORDER_WEBHOOK_URL
        if (webhook.isNotBlank()) {
            val posted = postWebhook(webhook, order.toJson())
            if (posted) return SubmitResult.WebhookOk
        }
        return openShare(context, order)
    }

    private suspend fun postWebhook(urlString: String, json: String): Boolean =
        withContext(Dispatchers.IO) {
            var conn: HttpURLConnection? = null
            try {
                conn = (URL(urlString).openConnection() as HttpURLConnection).apply {
                    requestMethod = "POST"
                    connectTimeout = 10_000
                    readTimeout = 10_000
                    doOutput = true
                    setRequestProperty("Content-Type", "application/json; charset=utf-8")
                }
                conn.outputStream.use { os: OutputStream ->
                    os.write(json.toByteArray(Charsets.UTF_8))
                }
                conn.responseCode in 200..299
            } catch (e: Exception) {
                false
            } finally {
                conn?.disconnect()
            }
        }

    private fun openShare(context: Context, order: OrderRequest): SubmitResult {
        return try {
            val send = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_EMAIL, arrayOf(BuildConfig.ORDER_EMAIL))
                putExtra(Intent.EXTRA_SUBJECT, "Fusio3D — заявка от ${order.name}")
                putExtra(Intent.EXTRA_TEXT, order.toEmailBody())
            }
            val chooser = Intent.createChooser(send, "Изпрати заявка чрез").apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(chooser)
            SubmitResult.ShareOpened
        } catch (e: Exception) {
            SubmitResult.Error(e.message ?: "Неизвестна грешка при изпращане.")
        }
    }
}
