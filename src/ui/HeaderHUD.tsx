import React from 'react';
import { VoiceName, JXPersonalityMode, SystemTelemetry } from '../types';
import { Cpu, Radio, Shield, Zap, Sparkles, Activity, Layers, Volume2, Palette, Smartphone } from 'lucide-react';
import { PERSONALITY_THEMES, PersonalityTheme } from '../theme/themeConfig';
import { getPersonalityTheme } from '../theme/ThemeController';

interface HeaderHUDProps {
  telemetry: SystemTelemetry;
  selectedVoice: VoiceName;
  onVoiceChange: (voice: VoiceName) => void;
  personality: JXPersonalityMode;
  onPersonalityChange: (p: JXPersonalityMode) => void;
  isLiveActive: boolean;
  onToggleLive: () => void;
  activeLayer: number;
  onSelectLayer: (layer: number) => void;
  onOpenInstallModal?: () => void;
}

export const HeaderHUD: React.FC<HeaderHUDProps> = ({
  telemetry,
  selectedVoice,
  onVoiceChange,
  personality,
  onPersonalityChange,
  isLiveActive,
  onToggleLive,
  activeLayer,
  onSelectLayer,
  onOpenInstallModal,
}) => {
  const currentTheme = getPersonalityTheme(personality);

  return (
    <header className="w-full bg-[#00081499] border-b border-[var(--accent-border)] px-4 md:px-6 py-2.5 backdrop-blur-md z-20 sticky top-0 transition-colors duration-500">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-3">
        {/* Logo & Assistant Identity */}
        <div className="flex items-center gap-4 w-full md:w-auto justify-between md:justify-start">
          <div className="flex items-center gap-3">
            <div className="relative flex items-center justify-center w-8 h-8 rounded bg-accent-subtle border border-accent-strong shadow-accent-glow transition-all">
              <Sparkles className="w-4 h-4 text-accent animate-pulse" />
              <div className="absolute -top-1 -right-1 w-2 h-2 rounded-full bg-accent shadow-[0_0_6px_var(--accent)]" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-sm font-bold tracking-[0.2em] text-[#e0f2fe] uppercase font-mono">
                  JX / OS_SYSTEM_01
                </span>
                <span className="text-[9px] uppercase font-mono px-1.5 py-0.5 rounded bg-accent-subtle border border-accent text-accent transition-colors">
                  v2.4.0-Stable
                </span>
              </div>
              <p className="text-[10px] text-accent font-mono flex items-center gap-1.5 uppercase tracking-wider opacity-90 transition-colors">
                <Shield className="w-3 h-3 text-accent" />
                {currentTheme.statusText}
              </p>
            </div>
          </div>

          {/* Quick Layer Switcher & Install Button on Mobile */}
          <div className="flex md:hidden items-center gap-1 bg-[#000814] border border-[var(--accent-border)] p-1 rounded">
            {onOpenInstallModal && (
              <button
                onClick={onOpenInstallModal}
                className="px-2 py-1 bg-[#00ffcc] text-black font-bold font-mono text-[10px] rounded flex items-center gap-1 shadow-[0_0_10px_rgba(0,255,204,0.4)]"
              >
                <Smartphone className="w-3 h-3" />
                <span>INSTALL</span>
              </button>
            )}
            {[1, 2, 3, 4].map((l) => (
              <button
                key={l}
                id={`mobile-layer-btn-${l}`}
                onClick={() => onSelectLayer(l)}
                className={`w-7 h-7 rounded text-[10px] font-mono flex items-center justify-center transition-all ${
                  activeLayer === l ? 'bg-accent text-[#020408] font-bold shadow-accent-glow' : 'text-accent opacity-60'
                }`}
              >
                L{l}
              </button>
            ))}
          </div>
        </div>

        {/* HUD Center Telemetry Widgets */}
        <div className="hidden lg:flex items-center gap-6 text-[10px] font-mono text-accent bg-accent-subtle border border-accent px-4 py-1.5 rounded transition-all">
          <div className="flex flex-col items-center">
            <span className="opacity-50 text-[8px]">CONNECTION</span>
            <span className={`font-bold uppercase ${isLiveActive ? 'text-accent shadow-accent-glow' : 'opacity-70'}`}>
              {telemetry.connectionState}
            </span>
          </div>

          <div className="w-px h-5 bg-[var(--accent-border)]" />

          <div className="flex flex-col items-center">
            <span className="opacity-50 text-[8px]">LATENCY</span>
            <span className="font-bold text-accent">{telemetry.latencyMs} MS</span>
          </div>

          <div className="w-px h-5 bg-[var(--accent-border)]" />

          <div className="flex flex-col items-center">
            <span className="opacity-50 text-[8px]">MODEL_ENGINE</span>
            <span className="font-bold text-[#e0f2fe]">{telemetry.activeModel.split('-')[0].toUpperCase()} LIVE</span>
          </div>
        </div>

        {/* HUD Controls & Selectors */}
        <div className="flex items-center gap-2.5 w-full md:w-auto justify-end flex-wrap sm:flex-nowrap">
          {/* Real Install Android App Button */}
          {onOpenInstallModal && (
            <button
              id="install-app-header-btn"
              onClick={onOpenInstallModal}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded bg-[#00ffcc] text-black font-mono font-black text-[10px] tracking-wider uppercase hover:brightness-110 shadow-[0_0_15px_rgba(0,255,204,0.4)] transition-all cursor-pointer"
            >
              <Smartphone className="w-3.5 h-3.5" />
              <span>📱 INSTALL APP</span>
            </button>
          )}

          {/* Personality / Accent Theme Controller */}
          <div className="flex items-center gap-1.5 bg-accent-subtle border border-accent-strong px-2.5 py-1 rounded text-[10px] font-mono shadow-accent-glow transition-all">
            <Palette className="w-3.5 h-3.5 text-accent" />
            <select
              id="personality-theme-select"
              value={personality}
              onChange={(e) => onPersonalityChange(e.target.value as JXPersonalityMode)}
              className="bg-transparent text-accent font-bold focus:outline-none cursor-pointer uppercase tracking-wider"
            >
              {Object.values(PERSONALITY_THEMES).map((t) => (
                <option key={t.id} value={t.id} className="bg-[#020408] text-[#e0f2fe]">
                  {t.badge} {t.name} ({t.colorName})
                </option>
              ))}
            </select>
          </div>

          {/* Layer Selector Bar */}
          <div className="hidden md:flex items-center gap-1 bg-accent-subtle border border-[var(--accent-border)] p-1 rounded">
            <Layers className="w-3.5 h-3.5 text-accent ml-1.5 mr-1" />
            {[
              { id: 1, label: 'L1: CORE' },
              { id: 2, label: 'L2: LOGS' },
              { id: 3, label: 'L3: WORKSPACE' },
              { id: 4, label: 'L4: DUAL' },
            ].map((layer) => (
              <button
                key={layer.id}
                id={`layer-btn-${layer.id}`}
                onClick={() => onSelectLayer(layer.id)}
                className={`px-2.5 py-1 rounded text-[10px] font-mono transition-all uppercase tracking-wider ${
                  activeLayer === layer.id
                    ? 'bg-accent text-[#020408] font-bold shadow-accent-glow'
                    : 'text-accent opacity-70 hover:opacity-100 hover:bg-accent-subtle'
                }`}
              >
                {layer.label}
              </button>
            ))}
          </div>

          {/* Voice Selector */}
          <div className="flex items-center gap-1.5 bg-accent-subtle border border-[var(--accent-border)] px-2.5 py-1 rounded text-[10px] font-mono">
            <Volume2 className="w-3.5 h-3.5 text-accent" />
            <select
              id="voice-select"
              value={selectedVoice}
              onChange={(e) => onVoiceChange(e.target.value as VoiceName)}
              className="bg-transparent text-accent focus:outline-none cursor-pointer uppercase"
            >
              <option value="Zephyr" className="bg-[#020408] text-[#e0f2fe]">VOICE: ZEPHYR</option>
              <option value="Kore" className="bg-[#020408] text-[#e0f2fe]">VOICE: KORE</option>
              <option value="Puck" className="bg-[#020408] text-[#e0f2fe]">VOICE: PUCK</option>
              <option value="Charon" className="bg-[#020408] text-[#e0f2fe]">VOICE: CHARON</option>
              <option value="Fenrir" className="bg-[#020408] text-[#e0f2fe]">VOICE: FENRIR</option>
            </select>
          </div>

          {/* Live Audio Streaming Toggle */}
          <button
            id="toggle-live-ws-btn"
            onClick={onToggleLive}
            className={`flex items-center gap-2 px-4 py-1.5 rounded text-[10px] font-mono font-bold tracking-widest uppercase transition-all shadow-md ${
              isLiveActive
                ? 'bg-accent text-[#020408] shadow-accent-glow'
                : 'bg-accent-subtle border border-accent text-accent hover:bg-accent'
            }`}
          >
            <Activity className="w-3.5 h-3.5" />
            <span>{isLiveActive ? 'LIVE_ACTIVE' : 'CONNECT_LIVE'}</span>
          </button>
        </div>
      </div>
    </header>
  );
};

