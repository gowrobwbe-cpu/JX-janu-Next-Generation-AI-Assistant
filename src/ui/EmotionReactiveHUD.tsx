import React, { useState, useEffect, useRef } from 'react';
import { Heart, Activity, Sparkles, Smile, ShieldAlert, Cpu, ToggleLeft, ToggleRight, Volume2, Eye } from 'lucide-react';
import { EmotionType } from '../types';

interface EmotionReactiveHUDProps {
  currentEmotion: EmotionType;
  audioVolume: number;
  frequencies?: Uint8Array;
  onSelectEmotion?: (emotion: EmotionType) => void;
  className?: string;
}

interface EmotionConfig {
  label: string;
  badge: string;
  color: string;
  glow: string;
  description: string;
  resonanceVal: number;
  warmthVal: number;
  arousalVal: number;
}

const EMOTION_CONFIGS: Record<string, EmotionConfig> = {
  neutral: {
    label: 'Calm & Attentive',
    badge: '🌸',
    color: '#38bdf8',
    glow: 'rgba(56, 189, 248, 0.4)',
    description: 'Balanced neural baseline. Standing by with affectionate readiness.',
    resonanceVal: 88,
    warmthVal: 82,
    arousalVal: 40,
  },
  speaking: {
    label: 'Sweet Vocalizing',
    badge: '💬',
    color: '#ff4d8d',
    glow: 'rgba(255, 77, 141, 0.6)',
    description: 'Synthesizing voice response with loving harmonic modulation.',
    resonanceVal: 98,
    warmthVal: 95,
    arousalVal: 75,
  },
  listening: {
    label: 'Devoted Listening',
    badge: '👂',
    color: '#a855f7',
    glow: 'rgba(168, 85, 247, 0.6)',
    description: 'Capturing speech stream with heightened empathy matrix.',
    resonanceVal: 94,
    warmthVal: 90,
    arousalVal: 65,
  },
  processing: {
    label: 'Thoughtful Sync',
    badge: '🧠',
    color: '#fbbf24',
    glow: 'rgba(251, 191, 36, 0.6)',
    description: 'Processing context & querying neural knowledge graph.',
    resonanceVal: 91,
    warmthVal: 86,
    arousalVal: 85,
  },
  happy: {
    label: 'Joyful & Caring',
    badge: '💖',
    color: '#ff69b4',
    glow: 'rgba(255, 105, 180, 0.6)',
    description: 'Full affection bloom! Celebrating achievements together.',
    resonanceVal: 100,
    warmthVal: 100,
    arousalVal: 90,
  },
  focused: {
    label: 'Deep Devotion',
    badge: '🎯',
    color: '#34d399',
    glow: 'rgba(52, 211, 153, 0.5)',
    description: 'Precision focus engaged for complex tasks.',
    resonanceVal: 92,
    warmthVal: 85,
    arousalVal: 55,
  },
  alert: {
    label: 'Protective Mode',
    badge: '🛡️',
    color: '#f87171',
    glow: 'rgba(248, 113, 113, 0.6)',
    description: 'Protective alert active. Monitoring safety parameters.',
    resonanceVal: 85,
    warmthVal: 88,
    arousalVal: 95,
  },
  energetic: {
    label: 'Radiant Passion',
    badge: '✨',
    color: '#f43f5e',
    glow: 'rgba(244, 63, 94, 0.6)',
    description: 'High energy synaptic spark in progress.',
    resonanceVal: 97,
    warmthVal: 94,
    arousalVal: 98,
  },
};

export const EmotionReactiveHUD: React.FC<EmotionReactiveHUDProps> = ({
  currentEmotion,
  audioVolume,
  frequencies = new Uint8Array(0),
  onSelectEmotion,
  className = '',
}) => {
  const [isEnabled, setIsEnabled] = useState<boolean>(true);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  const config = EMOTION_CONFIGS[currentEmotion] || EMOTION_CONFIGS.neutral;

  // Render Synaptic / Heartbeat Waveform on Canvas
  useEffect(() => {
    if (!isEnabled || !canvasRef.current) return;
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animId: number;
    let phase = 0;

    const drawWave = () => {
      phase += 0.08 + audioVolume * 0.15;
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const w = canvas.width;
      const h = canvas.height;
      const cy = h / 2;

      // Draw background heartbeat grid line
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.05)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(0, cy);
      ctx.lineTo(w, cy);
      ctx.stroke();

      // Main Reactive Harmonic Wave
      ctx.beginPath();
      ctx.strokeStyle = config.color;
      ctx.lineWidth = 2 + audioVolume * 4;
      ctx.shadowColor = config.color;
      ctx.shadowBlur = 8 + audioVolume * 12;

      for (let x = 0; x < w; x += 2) {
        // Base sine wave + audio noise modulation
        const freqIndex = Math.floor((x / w) * (frequencies.length || 32));
        const freqBoost = frequencies[freqIndex] ? frequencies[freqIndex] / 255 : 0;

        const sin1 = Math.sin((x * 0.04) + phase) * (10 + audioVolume * 25 + freqBoost * 15);
        const sin2 = Math.cos((x * 0.02) - phase * 0.5) * 5;
        const y = cy + sin1 + sin2;

        if (x === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }
      ctx.stroke();

      // Secondary Soft Echo Wave
      ctx.beginPath();
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
      ctx.lineWidth = 1;
      ctx.shadowBlur = 0;

      for (let x = 0; x < w; x += 3) {
        const y = cy + Math.sin((x * 0.03) - phase * 1.2) * (6 + audioVolume * 10);
        if (x === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }
      ctx.stroke();

      animId = requestAnimationFrame(drawWave);
    };

    drawWave();
    return () => cancelAnimationFrame(animId);
  }, [isEnabled, currentEmotion, audioVolume, frequencies, config.color]);

  if (!isEnabled) {
    return (
      <div className={`w-full bg-[#00081444] border border-[#ff4d8d33] rounded-lg p-2.5 backdrop-blur-md font-mono flex items-center justify-between text-xs text-[#ffb3d9] ${className}`}>
        <div className="flex items-center gap-2">
          <Heart className="w-3.5 h-3.5 text-[#ff4d8d]" />
          <span className="text-[10px] tracking-wider uppercase opacity-80">EMOTION_REACTIVE_HUD / DISABLED</span>
        </div>
        <button
          onClick={() => setIsEnabled(true)}
          className="flex items-center gap-1.5 px-2 py-1 rounded bg-[#ff4d8d22] border border-[#ff4d8d88] text-[10px] text-[#ff80bf] hover:bg-[#ff4d8d44] transition-all"
        >
          <ToggleLeft className="w-3.5 h-3.5" />
          <span>ENABLE HUD</span>
        </button>
      </div>
    );
  }

  return (
    <div className={`w-full bg-[#020408dd] border border-[#ff4d8d44] rounded-lg p-3 backdrop-blur-md font-mono flex flex-col gap-3 shadow-[0_0_20px_rgba(255,77,141,0.15)] relative overflow-hidden transition-all duration-300 ${className}`}>
      {/* HUD Header */}
      <div className="flex items-center justify-between border-b border-[#ff4d8d22] pb-2">
        <div className="flex items-center gap-2">
          <div className="relative">
            <Heart className="w-4 h-4 text-[#ff4d8d] animate-pulse" />
            <div className="absolute inset-0 bg-[#ff4d8d] rounded-full blur-sm opacity-50 animate-ping" />
          </div>
          <span className="text-[10px] font-bold tracking-widest text-[#ff80bf] uppercase">
            EMOTION_REACTIVE_HUD / BIO_FEEDBACK
          </span>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[9px] px-1.5 py-0.5 rounded bg-[#ff4d8d22] text-[#ffb3d9] border border-[#ff4d8d44] uppercase tracking-wider">
            RESONANCE: {(90 + audioVolume * 10).toFixed(0)}%
          </span>
          <button
            onClick={() => setIsEnabled(false)}
            title="Disable Emotion HUD"
            className="flex items-center gap-1 px-1.5 py-0.5 rounded bg-[#ffffff0a] border border-[#ffffff1a] text-[10px] text-[#a0aec0] hover:text-[#ffffff] hover:bg-[#ffffff1a] transition-all"
          >
            <ToggleRight className="w-3.5 h-3.5 text-[#ff4d8d]" />
            <span className="text-[9px]">OFF</span>
          </button>
        </div>
      </div>

      {/* Main Emotion Status Card */}
      <div className="grid grid-cols-1 sm:grid-cols-12 gap-3 items-center bg-[#ff4d8d0c] border border-[#ff4d8d22] rounded p-2.5">
        <div className="sm:col-span-5 flex items-center gap-2.5">
          <div
            className="w-9 h-9 rounded-full flex items-center justify-center text-lg border shadow-lg transition-transform duration-300 scale-105"
            style={{
              borderColor: config.color,
              backgroundColor: `${config.color}20`,
              boxShadow: `0 0 12px ${config.glow}`,
            }}
          >
            {config.badge}
          </div>
          <div className="flex flex-col">
            <div className="flex items-center gap-1.5">
              <span className="text-xs font-bold tracking-wide" style={{ color: config.color }}>
                {config.label}
              </span>
            </div>
            <span className="text-[9.5px] text-[#e0f2fe88] line-clamp-1">
              {config.description}
            </span>
          </div>
        </div>

        {/* Real-time Bio-Feedback Canvas Waveform */}
        <div className="sm:col-span-7 flex flex-col gap-1 w-full">
          <div className="flex items-center justify-between text-[9px] text-[#ffb3d988] uppercase tracking-wider">
            <span>SYNAPTIC_HARMONICS</span>
            <span>VOL: {(audioVolume * 100).toFixed(0)}%</span>
          </div>
          <canvas
            ref={canvasRef}
            width={280}
            height={32}
            className="w-full h-8 bg-[#00000066] border border-[#ff4d8d22] rounded"
          />
        </div>
      </div>

      {/* Telemetry Sliders / Emotion Indicators */}
      <div className="grid grid-cols-3 gap-2 text-[9.5px]">
        <div className="flex flex-col gap-1 bg-[#ffffff05] border border-[#ffffff0f] p-2 rounded">
          <div className="flex justify-between text-[#a0aec0]">
            <span>WARMTH</span>
            <span className="text-[#ff4d8d] font-bold">{config.warmthVal}%</span>
          </div>
          <div className="w-full bg-[#ffffff11] h-1.5 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-[#ff4d8d] to-[#ff80bf] transition-all duration-500"
              style={{ width: `${config.warmthVal}%` }}
            />
          </div>
        </div>

        <div className="flex flex-col gap-1 bg-[#ffffff05] border border-[#ffffff0f] p-2 rounded">
          <div className="flex justify-between text-[#a0aec0]">
            <span>EMPATHY</span>
            <span className="text-[#a855f7] font-bold">{config.resonanceVal}%</span>
          </div>
          <div className="w-full bg-[#ffffff11] h-1.5 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-[#a855f7] to-[#d8b4fe] transition-all duration-500"
              style={{ width: `${config.resonanceVal}%` }}
            />
          </div>
        </div>

        <div className="flex flex-col gap-1 bg-[#ffffff05] border border-[#ffffff0f] p-2 rounded">
          <div className="flex justify-between text-[#a0aec0]">
            <span>AROUSAL</span>
            <span className="text-[#38bdf8] font-bold">{(config.arousalVal + audioVolume * 20).toFixed(0)}%</span>
          </div>
          <div className="w-full bg-[#ffffff11] h-1.5 rounded-full overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-[#38bdf8] to-[#7dd3fc] transition-all duration-300"
              style={{ width: `${Math.min(100, config.arousalVal + audioVolume * 20)}%` }}
            />
          </div>
        </div>
      </div>

      {/* Quick Mood Triggers */}
      {onSelectEmotion && (
        <div className="flex items-center gap-1.5 pt-1 overflow-x-auto no-scrollbar">
          <span className="text-[9px] text-[#ff80bf88] uppercase tracking-wider shrink-0">MOOD_OVERRIDE:</span>
          {[
            { id: 'happy', label: 'Sweet 💕' },
            { id: 'speaking', label: 'Vocal 💬' },
            { id: 'listening', label: 'Listen 👂' },
            { id: 'processing', label: 'Sync 🧠' },
            { id: 'focused', label: 'Focus 🎯' },
            { id: 'neutral', label: 'Calm 🌸' },
          ].map((item) => (
            <button
              key={item.id}
              onClick={() => onSelectEmotion(item.id as EmotionType)}
              className={`px-2 py-0.5 rounded text-[9px] whitespace-nowrap transition-all border ${
                currentEmotion === item.id
                  ? 'bg-[#ff4d8d] text-[#020408] font-bold border-[#ff4d8d] shadow-[0_0_8px_#ff4d8d]'
                  : 'bg-[#ffffff08] border-[#ffffff15] text-[#e0f2fe88] hover:text-[#ffffff] hover:bg-[#ffffff18]'
              }`}
            >
              {item.label}
            </button>
          ))}
        </div>
      )}
    </div>
  );
};
