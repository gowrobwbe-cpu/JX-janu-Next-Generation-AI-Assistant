/**
 * Theme Controller for JX OS
 * Dynamically injects CSS variables to update the application's accent colors,
 * borders, glows, and background atmospheres matching the selected personality mode.
 */

import { JXPersonalityMode } from '../types';
import { PERSONALITY_THEMES, PersonalityTheme } from './themeConfig';

/**
 * Apply personality theme CSS variables directly to document.documentElement (:root)
 */
export function applyPersonalityTheme(mode: JXPersonalityMode): PersonalityTheme {
  const theme = PERSONALITY_THEMES[mode] || PERSONALITY_THEMES.companion;

  if (typeof window !== 'undefined' && document.documentElement) {
    const root = document.documentElement;

    root.style.setProperty('--accent', theme.accent);
    root.style.setProperty('--accent-rgb', theme.accentRgb);
    root.style.setProperty('--accent-secondary', theme.accentSecondary);
    root.style.setProperty('--accent-secondary-rgb', theme.accentSecondaryRgb);

    // Alpha / Derivative variables
    root.style.setProperty('--accent-glow', theme.glow);
    root.style.setProperty('--accent-bg', `rgba(${theme.accentRgb}, 0.08)`);
    root.style.setProperty('--accent-bg-hover', `rgba(${theme.accentRgb}, 0.16)`);
    root.style.setProperty('--accent-border', `rgba(${theme.accentRgb}, 0.22)`);
    root.style.setProperty('--accent-border-strong', `rgba(${theme.accentRgb}, 0.45)`);
    root.style.setProperty('--bg-spotlight', theme.bgSpotlight);
  }

  return theme;
}

/**
 * Helper to retrieve theme object by mode
 */
export function getPersonalityTheme(mode: JXPersonalityMode): PersonalityTheme {
  return PERSONALITY_THEMES[mode] || PERSONALITY_THEMES.companion;
}
