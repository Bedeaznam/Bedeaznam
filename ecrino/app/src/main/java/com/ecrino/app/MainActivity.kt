package com.ecrino.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.ecrino.app.ui.theme.EcrinoTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            EcrinoTheme {
                OrderFormScreen()
            }
        }
    }
}

private val FINISHES = listOf(
    "Мат",
    "Гланц",
    "Кадифено покритие",
    "Металик / златисто",
    "Дърво-имитация",
    "Друг / по препоръка",
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OrderFormScreen(viewModel: OrderViewModel = viewModel()) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val snackbar = remember { SnackbarHostState() }

    // form values are saved state; the in-flight submission lives in the
    // ViewModel so recreation neither duplicates nor loses it
    var name by rememberSaveable { mutableStateOf("") }
    var contact by rememberSaveable { mutableStateOf("") }
    var style by rememberSaveable { mutableStateOf("") }
    var finish by rememberSaveable { mutableStateOf(FINISHES.first()) }
    var finishExpanded by remember { mutableStateOf(false) }
    var color by rememberSaveable { mutableStateOf("") }
    var quantity by rememberSaveable { mutableStateOf("1") }
    var weddingDate by rememberSaveable { mutableStateOf("") }
    var engraving by rememberSaveable { mutableStateOf("") }
    var referenceLink by rememberSaveable { mutableStateOf("") }
    var notes by rememberSaveable { mutableStateOf("") }
    val submitting by viewModel.submitting.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        viewModel.results.collect { result ->
            snackbar.showMessage(
                when (result) {
                    is SubmitResult.WebhookOk -> "Заявката е изпратена. Благодарим!"
                    is SubmitResult.ShareOpened -> "Избери приложение, за да изпратиш заявката."
                    is SubmitResult.Error -> "Грешка: ${result.message}"
                }
            )
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbar) }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 20.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Spacer(Modifier.height(8.dp))
            Text("Ecrino", style = MaterialTheme.typography.headlineMedium, color = MaterialTheme.colorScheme.primary)
            Text(
                "Луксозни кутийки за годежен и сватбен пръстен, изработени по поръчка. Опиши идеята си — свързваме се с теб за детайли и цена.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(Modifier.height(4.dp))

            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("Име *") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = contact,
                onValueChange = { contact = it },
                label = { Text("Контакт (тел. или имейл) *") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = style,
                onValueChange = { style = it },
                label = { Text("Стил / идея за кутийката *") },
                minLines = 3,
                modifier = Modifier.fillMaxWidth()
            )

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                ExposedDropdownMenuBox(
                    expanded = finishExpanded,
                    onExpandedChange = { finishExpanded = it },
                    modifier = Modifier.weight(1f)
                ) {
                    OutlinedTextField(
                        value = finish,
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Финиш") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = finishExpanded) },
                        modifier = Modifier
                            .menuAnchor()
                            .fillMaxWidth()
                    )
                    ExposedDropdownMenu(
                        expanded = finishExpanded,
                        onDismissRequest = { finishExpanded = false }
                    ) {
                        FINISHES.forEach { option ->
                            DropdownMenuItem(
                                text = { Text(option) },
                                onClick = {
                                    finish = option
                                    finishExpanded = false
                                }
                            )
                        }
                    }
                }
                OutlinedTextField(
                    value = quantity,
                    onValueChange = { new -> quantity = new.filter { it.isDigit() }.take(4) },
                    label = { Text("Брой") },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.width(110.dp)
                )
            }

            OutlinedTextField(
                value = color,
                onValueChange = { color = it },
                label = { Text("Цвят (по желание)") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = weddingDate,
                onValueChange = { weddingDate = it },
                label = { Text("Дата на събитието (по желание)") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = engraving,
                onValueChange = { engraving = it },
                label = { Text("Гравюра / персонализация (по желание)") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = referenceLink,
                onValueChange = { referenceLink = it },
                label = { Text("Линк към снимка/пример (по желание)") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = notes,
                onValueChange = { notes = it },
                label = { Text("Допълнителни бележки (по желание)") },
                minLines = 2,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(Modifier.height(4.dp))
            Button(
                onClick = {
                    val missing = when {
                        name.isBlank() -> "Моля, въведи име."
                        contact.isBlank() -> "Моля, въведи контакт."
                        style.isBlank() -> "Моля, опиши стила/идеята за кутийката."
                        else -> null
                    }
                    if (missing != null) {
                        scope.launch { snackbar.showMessage(missing) }
                        return@Button
                    }
                    val order = OrderRequest(
                        name = name.trim(),
                        contact = contact.trim(),
                        style = style.trim(),
                        finish = finish,
                        color = color.trim(),
                        quantity = quantity.toIntOrNull()?.coerceAtLeast(1) ?: 1,
                        weddingDate = weddingDate.trim(),
                        engraving = engraving.trim(),
                        referenceLink = referenceLink.trim(),
                        notes = notes.trim(),
                    )
                    viewModel.submit(context, order)
                },
                enabled = !submitting,
                modifier = Modifier.fillMaxWidth()
            ) {
                if (submitting) {
                    CircularProgressIndicator(
                        modifier = Modifier.height(20.dp).width(20.dp),
                        strokeWidth = 2.dp,
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                } else {
                    Text("Изпрати запитване")
                }
            }
            Spacer(Modifier.height(24.dp))
        }
    }
}

private suspend fun SnackbarHostState.showMessage(message: String) {
    currentSnackbarData?.dismiss()
    showSnackbar(message)
}

@Preview(showBackground = true)
@Composable
fun OrderFormPreview() {
    EcrinoTheme {
        OrderFormScreen()
    }
}
