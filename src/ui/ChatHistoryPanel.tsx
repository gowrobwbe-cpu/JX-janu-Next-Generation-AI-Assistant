import React, { useEffect, useRef } from 'react';
import { ChatMessage } from '../types';
import { Bot, User, Wrench, Sparkles, Volume2 } from 'lucide-react';

interface ChatHistoryPanelProps {
  messages: ChatMessage[];
  isStreaming?: boolean;
  onPlayAudio?: (url: string) => void;
}

export const ChatHistoryPanel: React.FC<ChatHistoryPanelProps> = ({
  messages,
  isStreaming,
  onPlayAudio,
}) => {
  const scrollRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, isStreaming]);

  return (
    <div id="chat-history-panel" className="w-full h-full min-h-[320px] bg-[#00081433] border border-[var(--accent-border)] rounded p-4 backdrop-blur-sm flex flex-col gap-3 font-mono shadow-xl z-10 transition-colors duration-500">
      <div className="flex items-center justify-between border-b border-[var(--accent-border)] pb-2 text-[10px] font-bold tracking-widest text-accent uppercase transition-colors">
        <div className="flex items-center gap-2">
          <Bot className="w-3.5 h-3.5 text-accent" />
          <span>TRANSCRIBED_STREAM</span>
        </div>
        <span className="text-[9px] opacity-60 text-accent">{messages.length} LOG_ENTRIES</span>
      </div>

      <div
        ref={scrollRef}
        className="flex-1 overflow-y-auto space-y-4 pr-1 max-h-[380px] scrollbar-thin scrollbar-thumb-[var(--accent-border)]"
      >
        {messages.length === 0 ? (
          <div className="h-full flex flex-col items-center justify-center text-accent opacity-50 text-xs py-12 gap-2">
            <Sparkles className="w-8 h-8 text-accent animate-pulse" />
            <span className="tracking-widest uppercase text-[10px]">Neural Stream Ready</span>
          </div>
        ) : (
          messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex flex-col gap-1 text-xs ${
                msg.sender === 'user' ? 'items-end' : 'items-start'
              }`}
            >
              <div className="flex items-center gap-1.5 text-[9px] font-mono uppercase px-1">
                {msg.sender === 'user' ? (
                  <span className="text-accent opacity-80">USER [{msg.timestamp}]</span>
                ) : (
                  <span className="text-accent font-bold">JX [{msg.timestamp}]</span>
                )}
              </div>

              {/* Message Bubble */}
              <div
                className={`max-w-[90%] p-3 rounded ${
                  msg.sender === 'user'
                    ? 'border-l-2 border-accent-color pl-3 py-2 bg-accent-subtle text-[#e0f2fe]'
                    : 'bg-accent-subtle border border-[var(--accent-border)] text-[#e0f2fe]'
                }`}
              >
                <p className="leading-relaxed whitespace-pre-wrap text-[11px] font-sans">{msg.text}</p>

                {/* Tool execution badge if present */}
                {msg.toolCall && (
                  <div className="mt-2 pt-2 border-t border-[var(--accent-border)] flex items-center gap-2 text-[10px] text-accent font-mono">
                    <Wrench className="w-3 h-3 text-accent" />
                    <span>TOOL_EXECUTED: <strong>{msg.toolCall.name}</strong></span>
                  </div>
                )}

                {/* Audio replay button if url present */}
                {msg.audioUrl && onPlayAudio && (
                  <button
                    onClick={() => onPlayAudio(msg.audioUrl!)}
                    className="mt-2 flex items-center gap-1 text-[10px] text-accent hover:underline font-mono uppercase tracking-wider"
                  >
                    <Volume2 className="w-3 h-3" /> [PLAY_SYNTH_AUDIO]
                  </button>
                )}
              </div>
            </div>
          ))
        )}

        {isStreaming && (
          <div className="flex items-center gap-2 text-[10px] text-accent font-mono uppercase tracking-widest animate-pulse py-2">
            <div className="w-1.5 h-1.5 bg-accent rounded-full" />
            <div className="w-1.5 h-1.5 bg-accent rounded-full" />
            <div className="w-1.5 h-1.5 bg-accent rounded-full" />
            <span>Analyzing Context...</span>
          </div>
        )}
      </div>
    </div>
  );
};
