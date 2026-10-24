/**
 * JX — Next-Generation AI Operating System & Assistant
 */

import React, { useState, useEffect, useRef } from 'react';
import { HeaderHUD } from './ui/HeaderHUD';
import { AvatarCanvas } from './avatar/AvatarCanvas';
import { AudioSpectrumHUD } from './ui/AudioSpectrumHUD';
import { EmotionReactiveHUD } from './ui/EmotionReactiveHUD';
import { ToolLogsHUD } from './ui/ToolLogsHUD';
import { OSWorkspace } from './ui/OSWorkspace';
import { VoiceControls } from './ui/VoiceControls';
import { ChatHistoryPanel } from './ui/ChatHistoryPanel';
import { InstallAppModal } from './ui/InstallAppModal';
import { globalAudioEngine } from './audio/AudioEngine';
import { JXToolEngine } from './tools';
import { applyPersonalityTheme } from './theme/ThemeController';
import {
  VoiceName,
  JXPersonalityMode,
  EmotionType,
  AvatarModelId,
  SystemTelemetry,
  ChatMessage,
  ToolExecutionLog,
} from './types';

// Instantiate JX Tool Engine
const toolEngine = new JXToolEngine();

export default function App() {
  // Telemetry state
  const [telemetry, setTelemetry] = useState<SystemTelemetry>({
    latencyMs: 72,
    inputVolume: 0,
    outputVolume: 0,
    audioFps: 60,
    connectionState: 'disconnected',
    activeModel: 'gemini-3.1-flash-live-preview',
    tokensProcessed: 1420,
    cpuLoad: 12,
    memoryUsageMb: 184,
  });

  // Settings state
  const [selectedVoice, setSelectedVoice] = useState<VoiceName>('Zephyr');
  const [personality, setPersonality] = useState<JXPersonalityMode>('companion');
  const [characterId, setCharacterId] = useState<AvatarModelId>('luna-companion');
  const [emotion, setEmotion] = useState<EmotionType>('neutral');
  const [activeLayer, setActiveLayer] = useState<number>(1);
  const [isInstallModalOpen, setIsInstallModalOpen] = useState<boolean>(false);

  // Audio / Live state
  const [isLiveActive, setIsLiveActive] = useState<boolean>(false);
  const [isRecording, setIsRecording] = useState<boolean>(false);
  const [isSpeaking, setIsSpeaking] = useState<boolean>(false);
  const [isStreaming, setIsStreaming] = useState<boolean>(false);

  // Audio spectrum frequency data
  const [frequencies, setFrequencies] = useState<Uint8Array>(new Uint8Array(0));
  const [currentVolume, setCurrentVolume] = useState<number>(0);

  // Chat & Log state
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: 'welcome-1',
      sender: 'jx',
      text: 'Hi GØWRØB Baby! 💕 I\'m JX, your sweet AI companion. I\'m right here with you, fully ready to chat, help you with anything on your mind, or just keep you company. How are you feeling today, babe?',
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    },
  ]);
  const [toolLogs, setToolLogs] = useState<ToolExecutionLog[]>(toolEngine.logs);

  const wsRef = useRef<WebSocket | null>(null);

  // Refresh Tool Engine Logs
  const refreshToolLogs = () => {
    setToolLogs([...toolEngine.logs]);
  };

  // Dynamically update theme CSS variables when personality changes
  useEffect(() => {
    applyPersonalityTheme(personality);
  }, [personality]);

  // Audio Spectrum / FFT Animation Loop
  useEffect(() => {
    let animId: number;
    const updateAudioStats = () => {
      const { volume, frequencies: freqs } = globalAudioEngine.getAudioVolumeAndFFT(
        isSpeaking ? 'output' : 'input'
      );
      setCurrentVolume(volume);
      setFrequencies(freqs);

      if (isSpeaking && volume > 0.05) {
        setEmotion('speaking');
      } else if (isRecording && volume > 0.05) {
        setEmotion('listening');
      }

      animId = requestAnimationFrame(updateAudioStats);
    };

    updateAudioStats();
    return () => cancelAnimationFrame(animId);
  }, [isSpeaking, isRecording]);

  // Connect to Live Audio WebSocket
  const toggleLiveWebSocket = () => {
    if (isLiveActive) {
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
      }
      setIsLiveActive(false);
      setTelemetry((prev) => ({ ...prev, connectionState: 'disconnected' }));
    } else {
      setTelemetry((prev) => ({ ...prev, connectionState: 'connecting' }));

      const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
      const wsUrl = `${wsProtocol}//${window.location.host}/api/live`;

      try {
        const ws = new WebSocket(wsUrl);

        ws.onopen = () => {
          setIsLiveActive(true);
          setTelemetry((prev) => ({ ...prev, connectionState: 'connected' }));
        };

        ws.onmessage = (event) => {
          try {
            const data = JSON.parse(event.data);

            if (data.type === 'audio' && data.audio) {
              setIsSpeaking(true);
              globalAudioEngine.playAudioChunk(data.audio);
              setTimeout(() => setIsSpeaking(false), 800);
            }

            if (data.type === 'text' && data.text) {
              setMessages((prev) => [
                ...prev,
                {
                  id: `msg-${Date.now()}`,
                  sender: 'jx',
                  text: data.text,
                  timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                },
              ]);
            }

            if (data.type === 'toolCall') {
              refreshToolLogs();
              setEmotion('processing');
              setTimeout(() => setEmotion('neutral'), 1200);
            }

            if (data.type === 'interrupted') {
              globalAudioEngine.stopPlayback();
              setIsSpeaking(false);
            }
          } catch (e) {
            console.error('Error parsing WS message:', e);
          }
        };

        ws.onclose = () => {
          setIsLiveActive(false);
          setTelemetry((prev) => ({ ...prev, connectionState: 'disconnected' }));
        };

        ws.onerror = (err) => {
          console.error('WebSocket Error:', err);
          setIsLiveActive(false);
          setTelemetry((prev) => ({ ...prev, connectionState: 'error' }));
        };

        wsRef.current = ws;
      } catch (err) {
        console.error('Failed to open WebSocket:', err);
        setTelemetry((prev) => ({ ...prev, connectionState: 'error' }));
      }
    }
  };

  // Mic Record Toggle
  const handleToggleMic = async () => {
    if (isRecording) {
      globalAudioEngine.stopMicrophone();
      setIsRecording(false);
      setEmotion('neutral');
    } else {
      setEmotion('listening');
      try {
        await globalAudioEngine.startMicrophone((base64Pcm) => {
          if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
            wsRef.current.send(JSON.stringify({ type: 'audio', data: base64Pcm }));
          }
        });
        setIsRecording(true);
      } catch (err) {
        console.error('Microphone error:', err);
        alert('Could not access microphone. Please allow microphone permissions.');
      }
    }
  };

  // Barge-In Stop Audio
  const handleBargeInStop = () => {
    globalAudioEngine.stopPlayback();
    setIsSpeaking(false);
    setEmotion('neutral');
  };

  // Send Text Command (Fallback / REST)
  const handleSendMessage = async (text: string) => {
    const userMsg: ChatMessage = {
      id: `user-${Date.now()}`,
      sender: 'user',
      text,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };

    setMessages((prev) => [...prev, userMsg]);
    setIsStreaming(true);
    setEmotion('processing');

    try {
      const startTime = Date.now();
      const res = await fetch('/api/gemini/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: text, voice: selectedVoice }),
      });

      const data = await res.json();
      const latency = Date.now() - startTime;
      setTelemetry((prev) => ({ ...prev, latencyMs: latency }));

      if (data.text) {
        const jxMsg: ChatMessage = {
          id: `jx-${Date.now()}`,
          sender: 'jx',
          text: data.text,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          toolCall: data.toolCall,
        };
        setMessages((prev) => [...prev, jxMsg]);

        // Synthesize TTS Speech for reply
        fetchTTSAudio(data.text);
      }

      refreshToolLogs();
    } catch (err) {
      console.error('Error sending message:', err);
    } finally {
      setIsStreaming(false);
      setEmotion('neutral');
    }
  };

  // Fetch TTS audio chunk and play (with seamless Web Speech API fallback on rate limits)
  const fetchTTSAudio = async (textToSpeech: string) => {
    try {
      setIsSpeaking(true);
      const res = await fetch('/api/gemini/tts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: textToSpeech, voiceName: selectedVoice }),
      });
      if (res.ok) {
        const data = await res.json();
        if (data.audio) {
          globalAudioEngine.playAudioChunk(data.audio);
          setTimeout(() => setIsSpeaking(false), 1200);
          return;
        }
      }
      speakWithWebSpeechFallback(textToSpeech);
    } catch (err) {
      console.warn('TTS fetch failed, falling back to Web Speech synthesis:', err);
      speakWithWebSpeechFallback(textToSpeech);
    }
  };

  const speakWithWebSpeechFallback = (text: string) => {
    if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
      window.speechSynthesis.cancel();
      const cleanText = text.replace(/[*#_~`]/g, '');
      const utterance = new SpeechSynthesisUtterance(cleanText);
      utterance.rate = 1.0;
      utterance.pitch = 1.15;
      utterance.onstart = () => setIsSpeaking(true);
      utterance.onend = () => setIsSpeaking(false);
      utterance.onerror = () => setIsSpeaking(false);
      window.speechSynthesis.speak(utterance);
    } else {
      setIsSpeaking(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#020408] text-[#e0f2fe] flex flex-col font-sans selection:bg-[#00f2ff] selection:text-[#020408] relative overflow-x-hidden">
      {/* Background Atmosphere - Radial Blurs & Grid */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-[var(--bg-spotlight)] rounded-full blur-[140px] transition-all duration-700" />
        <div className="absolute -top-20 -left-20 w-96 h-96 bg-[var(--accent-bg)] rounded-full blur-[90px] transition-all duration-700" />
        <div className="absolute -bottom-20 -right-20 w-96 h-96 bg-[var(--accent-bg)] rounded-full blur-[90px] transition-all duration-700" />
        <div className="absolute inset-0 bg-[linear-gradient(to_right,var(--accent-bg)_1px,transparent_1px),linear-gradient(to_bottom,var(--accent-bg)_1px,transparent_1px)] bg-[size:36px_36px] opacity-40 transition-all duration-700" />
      </div>

      {/* Overlay UI Corner Frames */}
      <div className="fixed top-0 left-0 w-20 h-20 border-t-2 border-l-2 border-[var(--accent-border-strong)] pointer-events-none z-40 transition-colors duration-500" />
      <div className="fixed top-0 right-0 w-20 h-20 border-t-2 border-r-2 border-[var(--accent-border-strong)] pointer-events-none z-40 transition-colors duration-500" />
      <div className="fixed bottom-0 left-0 w-20 h-20 border-b-2 border-l-2 border-[var(--accent-border-strong)] pointer-events-none z-40 transition-colors duration-500" />
      <div className="fixed bottom-0 right-0 w-20 h-20 border-b-2 border-r-2 border-[var(--accent-border-strong)] pointer-events-none z-40 transition-colors duration-500" />

      {/* Top Header HUD Bar */}
      <HeaderHUD
        telemetry={telemetry}
        selectedVoice={selectedVoice}
        onVoiceChange={setSelectedVoice}
        personality={personality}
        onPersonalityChange={setPersonality}
        isLiveActive={isLiveActive}
        onToggleLive={toggleLiveWebSocket}
        activeLayer={activeLayer}
        onSelectLayer={setActiveLayer}
        onOpenInstallModal={() => setIsInstallModalOpen(true)}
      />

      {/* Main Content Dashboard */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-4 md:p-6 flex flex-col gap-6 relative z-10">
        {/* Layer 1 & 2 Main Presentation Split View */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          {/* Left Column: Holographic Avatar Canvas & Audio Spectrum */}
          <div className="lg:col-span-5 flex flex-col gap-4 w-full">
            <AvatarCanvas
              characterId={characterId}
              emotion={emotion}
              audioVolume={currentVolume}
              audioFrequencies={frequencies}
              onSelectCharacter={setCharacterId}
            />

            <AudioSpectrumHUD
              frequencies={frequencies}
              volume={currentVolume}
              isRecording={isRecording}
              isSpeaking={isSpeaking}
            />

            <EmotionReactiveHUD
              currentEmotion={emotion}
              audioVolume={currentVolume}
              frequencies={frequencies}
              onSelectEmotion={setEmotion}
            />
          </div>

          {/* Right Column: Transcription Log & OS Workspace Layer */}
          <div className="lg:col-span-7 flex flex-col gap-4 w-full h-full">
            {/* Layer Switcher Content */}
            {activeLayer === 1 && (
              <ChatHistoryPanel
                messages={messages}
                isStreaming={isStreaming}
              />
            )}

            {activeLayer === 2 && (
              <ToolLogsHUD
                logs={toolLogs}
                onClearLogs={() => {
                  toolEngine.logs = [];
                  refreshToolLogs();
                }}
              />
            )}

            {activeLayer === 3 && (
              <OSWorkspace
                toolEngine={toolEngine}
                onRefresh={refreshToolLogs}
              />
            )}

            {activeLayer === 4 && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <ToolLogsHUD
                  logs={toolLogs}
                  onClearLogs={() => {
                    toolEngine.logs = [];
                    refreshToolLogs();
                  }}
                />
                <OSWorkspace
                  toolEngine={toolEngine}
                  onRefresh={refreshToolLogs}
                />
              </div>
            )}
          </div>
        </div>

        {/* Bottom Floating Voice Controls Bar */}
        <div className="sticky bottom-4 z-30 w-full">
          <VoiceControls
            isRecording={isRecording}
            onToggleMic={handleToggleMic}
            onSendMessage={handleSendMessage}
            onBargeInStop={handleBargeInStop}
            isSpeaking={isSpeaking}
          />
        </div>
      </main>

      {/* Real Android APK Installation Modal */}
      <InstallAppModal
        isOpen={isInstallModalOpen}
        onClose={() => setIsInstallModalOpen(false)}
      />

      {/* Bottom Footer Info */}
      <footer className="w-full border-t border-[#00f2ff1a] py-3 px-6 text-center text-[10px] font-mono text-[#00f2ff88] bg-[#00081499] backdrop-blur-md relative z-20 uppercase tracking-widest">
        JX / OS_SYSTEM_01 • Build: v2.4.0-Stable • Gemini Multimodal Live API
      </footer>
    </div>
  );
}
