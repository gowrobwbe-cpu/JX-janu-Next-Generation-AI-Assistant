/**
 * JX OS Theme & Personality Configuration Matrix
 */

import { JXPersonalityMode } from '../types';

export interface PersonalityTheme {
  id: JXPersonalityMode;
  name: string;
  badge: string;
  colorName: string;
  description: string;
  accent: string;              // e.g. '#00f2ff'
  accentRgb: string;           // e.g. '0, 242, 255'
  accentSecondary: string;     // e.g. '#7000ff'
  accentSecondaryRgb: string;  // e.g. '112, 0, 255'
  glow: string;                // CSS box-shadow glow
  bgSpotlight: string;         // Background radial highlight
  statusText: string;          // Status bar tagline
}

export const PERSONALITY_THEMES: Record<JXPersonalityMode, PersonalityTheme> = {
  companion: {
    id: 'companion',
    name: 'Sweet Companion',
    badge: '💖',
    colorName: 'Rose Blossom',
    description: 'Warm, sweet, and caring companion style for GØWRØB Baby with loving rose blossom glow.',
    accent: '#ff4d8d',
    accentRgb: '255, 77, 141',
    accentSecondary: '#ff80bf',
    accentSecondaryRgb: '255, 128, 191',
    glow: '0 0 18px rgba(255, 77, 141, 0.50)',
    bgSpotlight: 'rgba(255, 77, 141, 0.12)',
    statusText: 'Sweet Companion • GØWRØB Baby\'s JX 💖',
  },
  jarvis: {
    id: 'jarvis',
    name: 'JARVIS Core',
    badge: '🩵',
    colorName: 'Electric Cyan',
    description: 'Balanced AI protocol with electric cyan accents & neural sync.',
    accent: '#00f2ff',
    accentRgb: '0, 242, 255',
    accentSecondary: '#7000ff',
    accentSecondaryRgb: '112, 0, 255',
    glow: '0 0 16px rgba(0, 242, 255, 0.45)',
    bgSpotlight: 'rgba(0, 242, 255, 0.08)',
    statusText: 'JARVIS Core Protocol • Live Sync',
  },
  calm: {
    id: 'calm',
    name: 'Calm Sanctuary',
    badge: '🔵',
    colorName: 'Sky Blue',
    description: 'Serene blue hues for relaxed, focused, low-stress interactions.',
    accent: '#38bdf8',
    accentRgb: '56, 189, 248',
    accentSecondary: '#0284c7',
    accentSecondaryRgb: '2, 132, 199',
    glow: '0 0 16px rgba(56, 189, 248, 0.45)',
    bgSpotlight: 'rgba(56, 189, 248, 0.08)',
    statusText: 'Calm Oasis Protocol • Relaxed Stream',
  },
  aggressive: {
    id: 'aggressive',
    name: 'Aggressive Command',
    badge: '🔴',
    colorName: 'Crimson Red',
    description: 'High-intensity crimson red HUD for maximum output & fast override.',
    accent: '#ff003c',
    accentRgb: '255, 0, 60',
    accentSecondary: '#ff6b00',
    accentSecondaryRgb: '255, 107, 0',
    glow: '0 0 18px rgba(255, 0, 60, 0.55)',
    bgSpotlight: 'rgba(255, 0, 60, 0.12)',
    statusText: 'Aggressive Override • Maximum Processing',
  },
  analytical: {
    id: 'analytical',
    name: 'Analytical Engine',
    badge: '🟡',
    colorName: 'Amber Gold',
    description: 'Solar amber gold matrix optimized for high-precision logic & data.',
    accent: '#ffb700',
    accentRgb: '255, 183, 0',
    accentSecondary: '#f97316',
    accentSecondaryRgb: '249, 115, 22',
    glow: '0 0 16px rgba(255, 183, 0, 0.45)',
    bgSpotlight: 'rgba(255, 183, 0, 0.10)',
    statusText: 'Analytical Logic Matrix • Data Synthesizer',
  },
  tactical: {
    id: 'tactical',
    name: 'Tactical Recon',
    badge: '🟢',
    colorName: 'Emerald Green',
    description: 'Cyber emerald tactical grid for stealth recon & operational tasks.',
    accent: '#00ff88',
    accentRgb: '0, 255, 136',
    accentSecondary: '#06b6d4',
    accentSecondaryRgb: '6, 182, 212',
    glow: '0 0 16px rgba(0, 255, 136, 0.45)',
    bgSpotlight: 'rgba(0, 255, 136, 0.08)',
    statusText: 'Tactical Recon Grid • Active Radar',
  },
  cyberpunk: {
    id: 'cyberpunk',
    name: 'Cyberpunk Neon',
    badge: '🟣',
    colorName: 'Neon Magenta',
    description: 'Vibrant neon purple and magenta synthwave atmosphere.',
    accent: '#f000ff',
    accentRgb: '240, 0, 255',
    accentSecondary: '#8b5cf6',
    accentSecondaryRgb: '139, 92, 246',
    glow: '0 0 18px rgba(240, 0, 255, 0.50)',
    bgSpotlight: 'rgba(240, 0, 255, 0.10)',
    statusText: 'Cyberpunk Overdrive • Neon Link',
  },
};
