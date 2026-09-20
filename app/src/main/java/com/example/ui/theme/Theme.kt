package com.example.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val SpaceColorScheme = darkColorScheme(
    primary = NeonCyan,
    onPrimary = Color(0xFF041017),
    secondary = ShieldAzure,
    onSecondary = Color(0xFF041017),
    tertiary = BonusGold,
    onTertiary = Color(0xFF1E1000),
    background = SpaceBlack,
    onBackground = OffWhite,
    surface = SpaceDarkNavy,
    onSurface = OffWhite,
    error = DangerRed,
    onError = Color.White
)

@Composable
fun SpaceDodgerTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = SpaceColorScheme,
        typography = Typography,
        content = content
    )
}
