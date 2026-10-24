import React, { useEffect, useRef } from 'react';
import { Activity, Mic, Volume2 } from 'lucide-react';

interface AudioSpectrumHUDProps {
  frequencies: Uint8Array;
  volume: number;
  isRecording: boolean;
  isSpeaking: boolean;
}

export const AudioSpectrumHUD: React.FC<AudioSpectrumHUDProps> = ({
  frequencies,
  volume,
  isRecording,
  isSpeaking,
}) => {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animId: number;

    const render = () => {
      const width = canvas.width;
      const height = canvas.height;
      ctx.clearRect(0, 0, width, height);

      const barCount = 32;
      const barWidth = (width / barCount) - 3;

      // Read current accent color CSS variables dynamically
      const rootStyle = getComputedStyle(document.documentElement);
      const accentColor = rootStyle.getPropertyValue('--accent').trim() || '#00f2ff';
      const secondaryColor = rootStyle.getPropertyValue('--accent-secondary').trim() || '#7000ff';

      for (let i = 0; i < barCount; i++) {
        // Sample frequency value or fallback to volume wave
        const freqVal = frequencies[i] || (Math.sin(Date.now() * 0.005 + i * 0.3) * 0.5 + 0.5) * (volume * 255);
        const barHeight = Math.max(4, (freqVal / 255) * (height - 10));

        const x = i * (barWidth + 3) + 2;
        const y = height - barHeight;

        // Gradient based on state
        const grad = ctx.createLinearGradient(0, height, 0, 0);
        if (isSpeaking) {
          grad.addColorStop(0, accentColor);
          grad.addColorStop(1, secondaryColor);
        } else if (isRecording) {
          grad.addColorStop(0, accentColor);
          grad.addColorStop(1, `${accentColor}88`);
        } else {
          grad.addColorStop(0, `${accentColor}22`);
          grad.addColorStop(1, `${secondaryColor}44`);
        }

        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.roundRect(x, y, barWidth, barHeight, 2);
        ctx.fill();
      }

      animId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animId);
    };
  }, [frequencies, volume, isRecording, isSpeaking]);

  return (
    <div id="audio-spectrum-hud" className="w-full bg-[#00081433] border border-[#00f2ff1a] rounded p-4 backdrop-blur-sm shadow-xl flex flex-col gap-2">
      <div className="flex items-center justify-between text-[10px] font-mono font-bold tracking-widest text-[#00f2ff88] uppercase">
        <div className="flex items-center gap-2">
          <Activity className="w-3.5 h-3.5 text-[#00f2ff] animate-pulse" />
          <span>NEURAL_SPECTRUM_ANALYZER</span>
        </div>
        <div className="flex items-center gap-3 text-[#00f2ffcc]">
          <span className="flex items-center gap-1">
            <Mic className={`w-3.5 h-3.5 ${isRecording ? 'text-[#00f2ff]' : 'opacity-40'}`} />
            {isRecording ? 'REC_ACTIVE' : 'REC_IDLE'}
          </span>
          <span className="flex items-center gap-1">
            <Volume2 className={`w-3.5 h-3.5 ${isSpeaking ? 'text-[#7000ff]' : 'opacity-40'}`} />
            {isSpeaking ? 'AUDIO_OUT' : 'AUDIO_IDLE'}
          </span>
        </div>
      </div>

      <div className="relative w-full h-16 bg-[#00081499] rounded overflow-hidden border border-[#00f2ff22] p-1 flex items-center">
        <canvas
          ref={canvasRef}
          width={600}
          height={64}
          className="w-full h-full object-cover"
        />
      </div>
    </div>
  );
};
