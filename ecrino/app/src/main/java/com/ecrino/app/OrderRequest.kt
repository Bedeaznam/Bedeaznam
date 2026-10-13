package com.ecrino.app

import org.json.JSONObject

/** A customer request for a bespoke wedding ring box. No pricing yet — this is an inquiry. */
data class OrderRequest(
    val name: String,
    val contact: String,
    val style: String,
    val finish: String,
    val color: String,
    val quantity: Int,
    val weddingDate: String,
    val engraving: String,
    val referenceLink: String,
    val notes: String,
) {
    fun toJson(): String = JSONObject().apply {
        put("name", name)
        put("contact", contact)
        put("style", style)
        put("finish", finish)
        put("color", color)
        put("quantity", quantity)
        put("weddingDate", weddingDate)
        put("engraving", engraving)
        put("referenceLink", referenceLink)
        put("notes", notes)
        put("source", "ecrino-android")
    }.toString()

    /** Human-readable body used for the share/email fallback. */
    fun toEmailBody(): String = buildString {
        appendLine("Нова заявка за сватбена кутийка за пръстен — Ecrino")
        appendLine()
        appendLine("Име: $name")
        appendLine("Контакт: $contact")
        appendLine("Брой: $quantity")
        appendLine("Финиш: $finish")
        if (color.isNotBlank()) appendLine("Цвят: $color")
        if (weddingDate.isNotBlank()) appendLine("Дата на сватбата: $weddingDate")
        if (engraving.isNotBlank()) appendLine("Гравюра/персонализация: $engraving")
        if (referenceLink.isNotBlank()) appendLine("Референтен линк: $referenceLink")
        appendLine()
        appendLine("Стил/идея:")
        appendLine(style)
        if (notes.isNotBlank()) {
            appendLine()
            appendLine("Бележки:")
            appendLine(notes)
        }
    }
}
