package com.fusio3d.app

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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.fusio3d.app.ui.theme.Fusio3DTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            Fusio3DTheme {
                OrderFormScreen()
            }
        }
    }
}

private val MATERIALS = listOf("PLA", "PETG", "ABS", "ASA", "TPU", "Друг / не съм сигурен")

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OrderFormScreen() {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val snackbar = remember { SnackbarHostState() }

    var name by remember { mutableStateOf("") }
    var contact by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var material by remember { mutableStateOf(MATERIALS.first()) }
    var materialExpanded by remember { mutableStateOf(false) }
    var color by remember { mutableStateOf("") }
    var quantity by remember { mutableStateOf("1") }
    var referenceLink by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var submitting by remember { mutableStateOf(false) }

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
            Text("Fusio3D", style = MaterialTheme.typography.headlineMedium, color = MaterialTheme.colorScheme.primary)
            Text(
                "Заявка за 3D печат. Опиши какво искаш да принтираме — свързваме се с теб за детайли и цена.",
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
                value = description,
                onValueChange = { description = it },
                label = { Text("Какво да принтираме? *") },
                minLines = 3,
                modifier = Modifier.fillMaxWidth()
            )

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                ExposedDropdownMenuBox(
                    expanded = materialExpanded,
                    onExpandedChange = { materialExpanded = it },
                    modifier = Modifier.weight(1f)
                ) {
                    OutlinedTextField(
                        value = material,
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Материал") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = materialExpanded) },
                        modifier = Modifier
                            .menuAnchor()
                            .fillMaxWidth()
                    )
                    ExposedDropdownMenu(
                        expanded = materialExpanded,
                        onDismissRequest = { materialExpanded = false }
                    ) {
                        MATERIALS.forEach { option ->
                            DropdownMenuItem(
                                text = { Text(option) },
                                onClick = {
                                    material = option
                                    materialExpanded = false
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
                value = referenceLink,
                onValueChange = { referenceLink = it },
                label = { Text("Линк към модел/снимка (по желание)") },
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
                        description.isBlank() -> "Моля, опиши какво да принтираме."
                        else -> null
                    }
                    if (missing != null) {
                        scope.launch { snackbar.showMessage(missing) }
                        return@Button
                    }
                    val order = OrderRequest(
                        name = name.trim(),
                        contact = contact.trim(),
                        description = description.trim(),
                        material = material,
                        color = color.trim(),
                        quantity = quantity.toIntOrNull()?.coerceAtLeast(1) ?: 1,
                        referenceLink = referenceLink.trim(),
                        notes = notes.trim(),
                    )
                    submitting = true
                    scope.launch {
                        val result = OrderSubmitter.submit(context, order)
                        submitting = false
                        val msg = when (result) {
                            is SubmitResult.WebhookOk -> "Заявката е изпратена. Благодарим!"
                            is SubmitResult.ShareOpened -> "Избери приложение, за да изпратиш заявката."
                            is SubmitResult.Error -> "Грешка: ${result.message}"
                        }
                        snackbar.showMessage(msg)
                    }
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
                    Text("Изпрати заявка")
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
    Fusio3DTheme {
        OrderFormScreen()
    }
}
