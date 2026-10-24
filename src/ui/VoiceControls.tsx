import React, { useState } from 'react';
import { Mic, MicOff, Send, VolumeX, Sparkles, Radio } from 'lucide-react';

interface VoiceControlsProps {
  isRecording: boolean;
  onToggleMic: () => void;
  onSendMessage: (text: string) => void;
  onBargeInStop: () => void;
  isSpeaking: boolean;
}

export const VoiceControls: React.FC<VoiceControlsProps> = ({
  isRecording,
  onToggleMic,
  onSendMessage,
  onBargeInStop,
  isSpeaking,
}) => {
  const [textInput, setTextInput] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!textInput.trim()) return;
    onSendMessage(textInput.trim());
    setTextInput('');
  };

  return (
    <div id="voice-controls-bar" className="w-full bg-[#000814cc] border border-[var(--accent-border-strong)] rounded p-4 backdrop-blur-xl flex flex-col md:flex-row items-center gap-4 font-mono shadow-accent-glow z-30 transition-colors duration-500">
      {/* Mic Record Toggle Button */}
      <button
        id="mic-toggle-btn"
        onClick={onToggleMic}
        className={`flex items-center justify-center gap-2 px-6 py-2.5 rounded text-xs font-bold uppercase tracking-widest transition-all shadow-md min-w-[160px] ${
          isRecording
            ? 'bg-accent-secondary text-white shadow-accent-glow animate-pulse'
            : 'bg-accent text-[#020408] hover:brightness-110 shadow-accent-glow'
        }`}
      >
        {isRecording ? <MicOff className="w-4 h-4" /> : <Mic className="w-4 h-4" />}
        <span>{isRecording ? 'HALT MIC' : 'TALK TO JX 💕'}</span>
      </button>

      {/* Barge-in Stop Speech Button */}
      {isSpeaking && (
        <button
          id="barge-in-btn"
          onClick={onBargeInStop}
          className="flex items-center gap-1.5 px-4 py-2.5 rounded bg-accent-subtle border border-accent text-accent text-xs font-bold uppercase tracking-widest hover:bg-accent hover:text-[#020408] transition-all"
        >
          <VolumeX className="w-4 h-4" />
          <span>INTERRUPT</span>
        </button>
      )}

      {/* Center Waveform Graphic Indicator */}
      <div className="hidden lg:flex flex-col items-center justify-center px-4 border-x border-[var(--accent-border)]">
        <div className="flex items-center justify-center gap-[3px] h-6">
          <div className={`h-[30%] w-[3px] bg-accent rounded-full ${isSpeaking ? 'animate-pulse' : 'opacity-40'}`} />
          <div className={`h-[60%] w-[3px] bg-accent rounded-full ${isSpeaking ? 'animate-pulse' : 'opacity-60'}`} />
          <div className={`h-[90%] w-[3px] bg-white rounded-full ${isSpeaking ? 'animate-pulse shadow-[0_0_8px_white]' : 'opacity-80'}`} />
          <div className={`h-[100%] w-[4px] bg-accent rounded-full ${isSpeaking ? 'animate-pulse shadow-accent-glow' : 'opacity-100'}`} />
          <div className={`h-[60%] w-[3px] bg-accent rounded-full ${isSpeaking ? 'animate-pulse' : 'opacity-60'}`} />
          <div className={`h-[30%] w-[3px] bg-accent rounded-full ${isSpeaking ? 'animate-pulse' : 'opacity-40'}`} />
        </div>
        <span className="text-[8px] font-bold text-accent opacity-80 tracking-[0.3em] uppercase mt-1">BARGE-IN_READY</span>
      </div>

      {/* Fallback Text Command Bar */}
      <form onSubmit={handleSubmit} className="flex-1 w-full flex items-center gap-2">
        <div className="relative flex-1">
          <input
            type="text"
            id="text-command-input"
            placeholder="Type a message or request (e.g., 'How are you babe?', 'Check weather')..."
            value={textInput}
            onChange={(e) => setTextInput(e.target.value)}
            className="w-full bg-[#020408] border border-[var(--accent-border)] focus:border-accent rounded px-4 py-2 text-xs text-[#e0f2fe] placeholder:text-accent placeholder:opacity-40 focus:outline-none transition-all pr-10 font-sans"
          />
          <Sparkles className="absolute right-3 top-2.5 w-4 h-4 text-accent opacity-50 pointer-events-none" />
        </div>

        <button
          type="submit"
          id="send-text-btn"
          className="bg-accent-subtle border border-accent hover:bg-accent hover:text-[#020408] text-accent px-5 py-2 rounded text-xs font-bold flex items-center gap-1.5 transition-all uppercase tracking-widest"
        >
          <Send className="w-3.5 h-3.5" />
          <span className="hidden sm:inline">EXECUTE</span>
        </button>
      </form>
    </div>
  );
};
