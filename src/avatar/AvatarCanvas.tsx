import React, { useEffect, useRef } from 'react';
import { AvatarRenderer, AVATAR_CHARACTERS } from './AvatarEngine';
import { EmotionType, AvatarModelId } from '../types';

interface AvatarCanvasProps {
  characterId: AvatarModelId;
  emotion: EmotionType;
  audioVolume: number; // 0..1 for lip-sync
  audioFrequencies?: Uint8Array;
  onSelectCharacter?: (id: AvatarModelId) => void;
}

export const AvatarCanvas: React.FC<AvatarCanvasProps> = ({
  characterId,
  emotion,
  audioVolume,
  audioFrequencies,
  onSelectCharacter,
}) => {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const rendererRef = useRef<AvatarRenderer | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    // Resize canvas
    const updateSize = () => {
      window.requestAnimationFrame(() => {
        if (!canvas) return;
        const rect = canvas.parentElement?.getBoundingClientRect();
        if (rect && rect.width > 0 && rect.height > 0) {
          const w = Math.floor(rect.width * (window.devicePixelRatio || 1));
          const h = Math.floor(rect.height * (window.devicePixelRatio || 1));
          if (canvas.width !== w || canvas.height !== h) {
            canvas.width = w;
            canvas.height = h;
          }
        }
      });
    };

    updateSize();
    const observer = new ResizeObserver(() => updateSize());
    if (canvas.parentElement) observer.observe(canvas.parentElement);

    const renderer = new AvatarRenderer(canvas);
    renderer.setCharacter(characterId);
    renderer.setEmotion(emotion);
    renderer.start();
    rendererRef.current = renderer;

    return () => {
      observer.disconnect();
      renderer.stop();
    };
  }, []);

  useEffect(() => {
    if (rendererRef.current) {
      rendererRef.current.setCharacter(characterId);
    }
  }, [characterId]);

  useEffect(() => {
    if (rendererRef.current) {
      rendererRef.current.setEmotion(emotion);
    }
  }, [emotion]);

  useEffect(() => {
    if (rendererRef.current) {
      rendererRef.current.updateAudioData(audioVolume, audioFrequencies);
    }
  }, [audioVolume, audioFrequencies]);

  const activeChar = AVATAR_CHARACTERS.find((c) => c.id === characterId) || AVATAR_CHARACTERS[0];

  return (
    <div id="avatar-canvas-container" className="relative w-full h-full min-h-[320px] flex flex-col items-center justify-center bg-[#000814cc] rounded border border-[var(--accent-border)] overflow-hidden shadow-accent-glow backdrop-blur-md transition-all duration-500">
      {/* Immersive UI Background Decorative Orbit Rings */}
      <div className="absolute w-[380px] h-[380px] border border-[var(--accent-border)] opacity-30 rounded-full pointer-events-none transition-all duration-500" />
      <div className="absolute w-[290px] h-[290px] border border-[var(--accent-border)] rounded-full border-dashed animate-spin-slow pointer-events-none transition-all duration-500" />
      <div className="absolute w-[220px] h-[220px] border-2 border-[var(--accent-border-strong)] opacity-60 rounded-full pointer-events-none transition-all duration-500" />
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,var(--accent-bg)_0%,transparent_70%)] pointer-events-none transition-all duration-500" />
      <div className="absolute inset-0 bg-[linear-gradient(to_right,var(--accent-bg)_1px,transparent_1px),linear-gradient(to_bottom,var(--accent-bg)_1px,transparent_1px)] bg-[size:24px_24px] opacity-25 pointer-events-none" />

      {/* Top HUD Character Indicator */}
      <div className="absolute top-3 left-4 right-4 flex items-center justify-between z-10 text-[10px] text-accent font-mono tracking-widest uppercase transition-colors">
        <div className="flex items-center gap-2 bg-accent-subtle border border-[var(--accent-border)] px-3 py-1 rounded">
          <span className="w-1.5 h-1.5 rounded-full bg-accent shadow-accent-glow" />
          <span>CORE: {activeChar.name.toUpperCase()}</span>
        </div>

        <div className="flex items-center gap-1.5 bg-accent-subtle border border-[var(--accent-border)] px-3 py-1 rounded">
          <span className="opacity-50">EMOTION:</span>
          <span className="text-accent font-bold">{emotion.toUpperCase()}</span>
        </div>
      </div>

      {/* Canvas Element */}
      <canvas
        ref={canvasRef}
        className="w-full h-full max-h-[360px] object-contain relative z-10"
      />

      {/* Character Swapper Selector Row */}
      <div className="absolute bottom-3 left-1/2 -translate-x-1/2 z-20 flex items-center gap-2 bg-[#000814cc] border border-[var(--accent-border)] p-1 rounded backdrop-blur-md">
        {AVATAR_CHARACTERS.map((char) => (
          <button
            key={char.id}
            id={`avatar-btn-${char.id}`}
            onClick={() => onSelectCharacter?.(char.id)}
            className={`px-3 py-1 rounded text-[10px] font-mono tracking-widest uppercase transition-all ${
              characterId === char.id
                ? 'bg-accent text-[#020408] font-bold shadow-accent-glow'
                : 'text-accent opacity-70 hover:opacity-100 hover:bg-accent-subtle'
            }`}
          >
            {char.name.split(' ')[0]}
          </button>
        ))}
      </div>
    </div>
  );
};
