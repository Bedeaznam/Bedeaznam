package com.ecrino.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val EcrinoColors = darkColorScheme(
    primary = Gold,
    onPrimary = CharcoalBackground,
    secondary = Blush,
    background = CharcoalBackground,
    onBackground = Cream,
    surface = CharcoalSurface,
    onSurface = Cream,
    surfaceVariant = CharcoalSurfaceVariant,
    onSurfaceVariant = CreamMuted,
    outline = GoldDark,
)

@Composable
fun EcrinoTheme(
    @Suppress("UNUSED_PARAMETER") darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    // The brand is a dark, warm palette regardless of system setting.
    MaterialTheme(
        colorScheme = EcrinoColors,
        typography = EcrinoTypography,
        content = content
    )
}
