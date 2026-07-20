package com.fusio3d.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val Fusio3DColors = darkColorScheme(
    primary = OrangePrimary,
    onPrimary = BlueBackground,
    secondary = OrangeDark,
    background = BlueBackground,
    onBackground = TextPrimary,
    surface = BlueSurface,
    onSurface = TextPrimary,
    surfaceVariant = BlueSurfaceVariant,
    onSurfaceVariant = TextSecondary,
)

@Composable
fun Fusio3DTheme(
    @Suppress("UNUSED_PARAMETER") darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    // The brand is a dark, warm palette regardless of system setting.
    MaterialTheme(
        colorScheme = Fusio3DColors,
        typography = Fusio3DTypography,
        content = content
    )
}
