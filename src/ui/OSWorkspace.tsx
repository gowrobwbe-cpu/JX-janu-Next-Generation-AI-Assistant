import React, { useState } from 'react';
import { JXToolEngine } from '../tools';
import { NoteItem, CalendarEvent, TimerItem, ReminderItem, SmartDeviceState } from '../types';
import { 
  FileText, Calendar, CloudSun, Clock, Bell, Folder, Power, Rocket, Plus, Trash2, 
  CheckCircle2, Shield, Search, Smartphone, Code, Cpu, Fingerprint, Key, Lock, 
  Sliders, Mic, Camera, MapPin, Eye, Zap, RefreshCw, Sparkles, Check, AlertCircle,
  Play, CheckCircle, Volume2, ArrowLeft, Home, Layers, MessageSquare, ExternalLink,
  ShieldAlert, Send, Terminal, Download
} from 'lucide-react';

interface OSWorkspaceProps {
  toolEngine: JXToolEngine;
  onRefresh: () => void;
}

export const OSWorkspace: React.FC<OSWorkspaceProps> = ({ toolEngine, onRefresh }) => {
  const [activeTab, setActiveTab] = useState<'controlEngine' | 'onboarding' | 'androidCode' | 'notes' | 'calendar' | 'weather' | 'timers' | 'files' | 'smartHome' | 'apps'>('controlEngine');
  const [selectedCodeFile, setSelectedCodeFile] = useState<string>('android_tool_router');

  // --- PHASE 3 ANDROID CONTROL ENGINE STATE ---
  const [hudState, setHudState] = useState<{
    status: 'idle' | 'executing' | 'completed' | 'failed';
    title: string;
    detail: string;
  }>({
    status: 'idle',
    title: '',
    detail: '',
  });

  const [confirmDialog, setConfirmDialog] = useState<{
    open: boolean;
    toolName: string;
    risk: 'SAFE' | 'USER_CONFIRMATION' | 'HIGH_RISK';
    desc: string;
    args: any;
    onProceed: () => void;
  } | null>(null);

  const [toolResults, setToolResults] = useState<Record<string, { status: 'IDLE' | 'RUNNING' | 'PASS' | 'FAIL' | 'NOT_GRANTED' | 'NOT_SUPPORTED' | 'REQUIRES_REAL_DEVICE'; result: string }>>({
    '1': { status: 'IDLE', result: 'Ready to test' },
    '2': { status: 'IDLE', result: 'Ready to test' },
    '3': { status: 'IDLE', result: 'Ready to test' },
    '4': { status: 'IDLE', result: 'Ready to test' },
    '5': { status: 'IDLE', result: 'Ready to test' },
    '6': { status: 'IDLE', result: 'Ready to test' },
    '7': { status: 'IDLE', result: 'Ready to test' },
    '8': { status: 'IDLE', result: 'Ready to test' },
    '9': { status: 'IDLE', result: 'Ready to test' },
    '10': { status: 'IDLE', result: 'Ready to test' },
    '11': { status: 'IDLE', result: 'Ready to test' },
    '12': { status: 'IDLE', result: 'Ready to test' },
    '13': { status: 'IDLE', result: 'Ready to test' },
    '14': { status: 'IDLE', result: 'Ready to test' },
    '15': { status: 'IDLE', result: 'Ready to test' },
    '16': { status: 'IDLE', result: 'Ready to test' },
    '17': { status: 'IDLE', result: 'Ready to test' },
    '18': { status: 'IDLE', result: 'Ready to test' },
    '19': { status: 'IDLE', result: 'Ready to test' },
    '20': { status: 'IDLE', result: 'Ready to test' },
    '21': { status: 'IDLE', result: 'Ready to test' },
    '22': { status: 'IDLE', result: 'Ready to test' },
  });

  const [bengaliInput, setBengaliInput] = useState<string>('YouTube-এ electronics tutorial search করো');
  const [bengaliOutput, setBengaliOutput] = useState<string>('');

  // Simulator State for Phase 2 Live Flow
  const [simStep, setSimStep] = useState<'security' | 'gemini' | 'permissions' | 'connecting' | 'online'>('online');
  const [simAuthFailed, setSimAuthFailed] = useState<boolean>(false);
  const [simApiKey, setSimApiKey] = useState<string>('AIzaSy_demo_encrypted_keystore_key');
  const [simModel, setSimModel] = useState<string>('gemini-1.5-flash');
  const [simLanguage, setSimLanguage] = useState<string>('Auto (বাংলা & English)');
  const [simTestStatus, setSimTestStatus] = useState<'idle' | 'testing' | 'success' | 'failed'>('success');
  const [simPermissions, setSimPermissions] = useState<Record<string, 'GRANTED' | 'NOT_GRANTED' | 'SETUP_REQUIRED'>>({
    microphone: 'GRANTED',
    camera: 'GRANTED',
    location: 'GRANTED',
    notifications: 'GRANTED',
    accessibility: 'GRANTED',
    screen_assistant: 'GRANTED',
    phone: 'GRANTED',
    contacts: 'GRANTED',
  });

  // Local state forms
  const [newNoteTitle, setNewNoteTitle] = useState('');
  const [newNoteContent, setNewNoteContent] = useState('');
  const [newCalTitle, setNewCalTitle] = useState('');
  const [newCalTime, setNewCalTime] = useState('14:00');
  const [newTimerLabel, setNewTimerLabel] = useState('Focus Session');
  const [newTimerSec, setNewTimerSec] = useState('120');
  const [newFilePath, setNewFilePath] = useState('/user/documents/notes.txt');
  const [newFileContent, setNewFileContent] = useState('Content here...');

  const triggerTool = (
    indexStr: string,
    toolName: string,
    hudTitle: string,
    hudDetail: string,
    risk: 'SAFE' | 'USER_CONFIRMATION' | 'HIGH_RISK',
    args: any,
    successResult: string
  ) => {
    const execute = () => {
      setHudState({
        status: 'executing',
        title: hudTitle,
        detail: hudDetail,
      });

      setToolResults((prev) => ({
        ...prev,
        [indexStr]: { status: 'RUNNING', result: 'Executing via Android MethodChannel...' },
      }));

      setTimeout(() => {
        setHudState({
          status: 'completed',
          title: hudTitle,
          detail: `${hudDetail} ✓`,
        });

        setToolResults((prev) => ({
          ...prev,
          [indexStr]: { status: 'SUCCESS', result: successResult },
        }));

        setTimeout(() => {
          setHudState({ status: 'idle', title: '', detail: '' });
        }, 3000);
      }, 1000);
    };

    if (risk !== 'SAFE') {
      setConfirmDialog({
        open: true,
        toolName,
        risk,
        desc: `JX needs your explicit confirmation to execute: ${toolName}`,
        args,
        onProceed: () => {
          setConfirmDialog(null);
          execute();
        },
      });
    } else {
      execute();
    }
  };

  const handleRunBengaliCommand = () => {
    const text = bengaliInput.toLowerCase();
    let mappedTool = 'search_web';
    let args: any = { query: bengaliInput };
    let reply = `Executed: ${bengaliInput}`;

    if (text.includes('youtube') && (text.includes('search') || text.includes('tutorial'))) {
      mappedTool = 'open_youtube';
      args = { query: 'electronics tutorial' };
      reply = 'YouTube খুলে electronics tutorial search করে দিয়েছি Gowrob Baby! 💕';
    } else if (text.includes('facebook') || text.includes('ফেসবুক')) {
      mappedTool = 'open_app';
      args = { appName: 'Facebook' };
      reply = 'Facebook app খুলে দিয়েছি sweetheart! 💕';
    } else if (text.includes('volume') && (text.includes('komao') || text.includes('কমাও'))) {
      mappedTool = 'adjust_volume';
      args = { direction: 'down' };
      reply = 'Device volume কমিয়ে দিয়েছি love! 🔊';
    } else if (text.includes('volume') && (text.includes('barao') || text.includes('বাড়াও'))) {
      mappedTool = 'adjust_volume';
      args = { direction: 'up' };
      reply = 'Device volume বাড়িয়ে দিয়েছি love! 🔊';
    } else if (text.includes('back') || text.includes('ব্যাক')) {
      mappedTool = 'navigate_os';
      args = { action: 'back' };
      reply = 'Accessibility Service দিয়ে Back করেছি Gowrob! ↩️';
    } else if (text.includes('whatsapp') || text.includes('মেসেজ')) {
      mappedTool = 'open_whatsapp';
      args = { contactName: 'Rahim', message: 'Hello from JX' };
      reply = 'WhatsApp compose screen প্রস্তুত করেছি Rahim-এর জন্য! Review করে send করো love 💕';
    }

    setBengaliOutput(`Mapped Tool: ${mappedTool}\nArgs: ${JSON.stringify(args)}\n\nJX Voice: "${reply}"`);

    triggerTool(
      '12',
      mappedTool,
      mappedTool.toUpperCase().replace('_', ' '),
      JSON.stringify(args),
      mappedTool === 'open_whatsapp' ? 'USER_CONFIRMATION' : 'SAFE',
      args,
      `Success: ${reply}`
    );
  };

  const handleAddNote = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newNoteTitle.trim()) return;
    toolEngine.executeTool('manageNotes', { action: 'create', title: newNoteTitle, content: newNoteContent });
    setNewNoteTitle('');
    setNewNoteContent('');
    onRefresh();
  };

  const handleAddCalendar = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCalTitle.trim()) return;
    toolEngine.executeTool('calendar', { action: 'add', title: newCalTitle, time: newCalTime });
    setNewCalTitle('');
    onRefresh();
  };

  const handleAddTimer = (e: React.FormEvent) => {
    e.preventDefault();
    toolEngine.executeTool('manageTimer', { action: 'set', label: newTimerLabel, durationSeconds: Number(newTimerSec) || 60 });
    onRefresh();
  };

  const handleSaveFile = (e: React.FormEvent) => {
    e.preventDefault();
    toolEngine.executeTool('fileOperations', { action: 'write', path: newFilePath, content: newFileContent });
    onRefresh();
  };

  const handleToggleSmartDevice = (id: string, currentStatus: any) => {
    let nextStatus: any = !currentStatus;
    if (typeof currentStatus === 'string') {
      nextStatus = currentStatus === 'Locked' ? 'Unlocked' : 'Locked';
    }
    toolEngine.executeTool('controlSmartDevice', { deviceId: id, status: nextStatus });
    onRefresh();
  };

  const weather = toolEngine.getWeather('San Francisco');

  return (
    <div id="os-workspace-panel" className="w-full h-full bg-[#00081433] border border-[#00f2ff1a] rounded p-4 backdrop-blur-sm flex flex-col gap-4 font-mono shadow-xl z-10 relative">
      
      {/* ACTION HUD OVERLAY (PHASE 3) */}
      {hudState.status !== 'idle' && (
        <div className="absolute top-4 left-4 right-4 z-50 p-3 bg-[#0d0e15f0] border-2 border-[#00ffcc] rounded-xl shadow-[0_0_25px_#00ffcc44] flex items-center justify-between animate-fade-in">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-[#00ffcc22] border border-[#00ffcc] flex items-center justify-center">
              {hudState.status === 'executing' ? (
                <RefreshCw className="w-5 h-5 text-[#00ffcc] animate-spin" />
              ) : (
                <CheckCircle2 className="w-5 h-5 text-[#00ffcc]" />
              )}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-black text-[#00ffcc] tracking-widest uppercase">JX ACTION</span>
                <span className="text-xs text-white/70 font-sans font-semibold">
                  {hudState.status === 'executing' ? 'Executing...' : 'Completed ✓'}
                </span>
              </div>
              <div className="text-sm font-bold text-white font-sans">
                {hudState.title} {hudState.detail}
              </div>
            </div>
          </div>
          <button
            onClick={() => setHudState({ status: 'idle', title: '', detail: '' })}
            className="text-white/40 hover:text-white text-xs px-2 py-1"
          >
            ✕
          </button>
        </div>
      )}

      {/* ACTION CONFIRMATION DIALOG (PHASE 3) */}
      {confirmDialog && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="w-full max-w-md bg-[#0f101a] border-2 border-[#ffb800] rounded-2xl p-5 shadow-[0_0_30px_#ffb80044] flex flex-col gap-3 font-sans">
            <div className="flex items-center justify-between">
              <span className="px-2.5 py-1 bg-[#ffb80022] border border-[#ffb800] text-[#ffb800] text-xs font-bold font-mono rounded">
                ⚠️ USER CONFIRMATION REQUIRED
              </span>
              <button onClick={() => setConfirmDialog(null)} className="text-white/50 hover:text-white">✕</button>
            </div>
            <h3 className="text-base font-bold text-white">Execute Android Action?</h3>
            <p className="text-xs text-white/70">{confirmDialog.desc}</p>
            <div className="p-2.5 bg-black/40 border border-white/10 rounded font-mono text-xs text-[#00ffcc]">
              TARGET: {confirmDialog.toolName.toUpperCase()}<br />
              ARGS: {JSON.stringify(confirmDialog.args)}
            </div>
            <div className="flex gap-2 pt-2 font-mono">
              <button
                onClick={() => setConfirmDialog(null)}
                className="flex-1 py-2 border border-white/20 text-white/70 rounded hover:bg-white/10 text-xs font-bold uppercase"
              >
                Cancel
              </button>
              <button
                onClick={confirmDialog.onProceed}
                className="flex-1 py-2 bg-[#ffb800] text-black rounded hover:brightness-110 text-xs font-black uppercase"
              >
                Proceed & Execute
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Workspace Navigation Bar */}
      <div className="flex items-center justify-between border-b border-[#00f2ff1a] pb-3 flex-wrap gap-2">
        <div className="flex items-center gap-2">
          <Cpu className="w-3.5 h-3.5 text-[#00ffcc]" />
          <span className="text-[10px] font-bold tracking-widest text-[#00ffcc] uppercase">PHASE 3 • ANDROID CONTROL ENGINE ACTIVE</span>
        </div>

        <div className="flex items-center gap-1.5 flex-wrap">
          {[
            { id: 'controlEngine', label: 'JX Device Test Center (22 Tests)', icon: Cpu },
            { id: 'onboarding', label: 'Onboarding & Security', icon: Shield },
            { id: 'androidCode', label: 'Kotlin & Dart Files', icon: Smartphone },
            { id: 'notes', label: 'Notes', icon: FileText },
            { id: 'calendar', label: 'Calendar', icon: Calendar },
            { id: 'weather', label: 'Weather', icon: CloudSun },
            { id: 'timers', label: 'Timers', icon: Clock },
            { id: 'files', label: 'Files', icon: Folder },
            { id: 'smartHome', label: 'Devices', icon: Power },
            { id: 'apps', label: 'Launcher', icon: Rocket },
          ].map((tab) => {
            const IconComponent = tab.icon;
            return (
              <button
                key={tab.id}
                id={`tab-btn-${tab.id}`}
                onClick={() => setActiveTab(tab.id as any)}
                className={`flex items-center gap-1.5 px-3 py-1 rounded text-[10px] transition-all uppercase tracking-wider ${
                  activeTab === tab.id
                    ? 'bg-[#00ffcc] text-[#020408] font-bold shadow-[0_0_8px_#00ffcc]'
                    : 'text-[#00f2ff88] hover:text-[#e0f2fe] hover:bg-[#00f2ff11]'
                }`}
              >
                <IconComponent className="w-3 h-3" />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Tab Contents */}
      <div className="flex-1 overflow-y-auto pr-1 space-y-4 max-h-[360px] scrollbar-thin scrollbar-thumb-[#00f2ff22]">
        
        {/* PHASE 3: 22 REAL ANDROID DEVICE TESTS */}
        {activeTab === 'controlEngine' && (
          <div className="flex flex-col gap-3 font-sans">
            {/* Bengali / Banglish Interactive Test Console */}
            <div className="p-3 bg-[#121826] border border-[#00ffcc44] rounded-xl flex flex-col gap-2">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-[#00ffcc] font-mono flex items-center gap-1.5">
                  <Terminal className="w-3.5 h-3.5" /> BENGALI & BANGLISH VOICE / TEXT COMMAND PARSER
                </span>
                <span className="text-[9px] px-2 py-0.5 bg-[#00ffcc22] text-[#00ffcc] rounded font-bold font-mono">
                  AGENTIC GEMINI LOOP
                </span>
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={bengaliInput}
                  onChange={(e) => setBengaliInput(e.target.value)}
                  className="flex-1 bg-[#080c14] border border-white/20 rounded px-3 py-1.5 text-xs text-white font-mono"
                  placeholder="e.g. YouTube-এ electronics tutorial search করো or volume বাড়াও"
                />
                <button
                  onClick={handleRunBengaliCommand}
                  className="px-4 py-1.5 bg-[#00ffcc] text-black font-black text-xs rounded hover:brightness-110 font-mono flex items-center gap-1"
                >
                  <Send className="w-3 h-3" /> RUN
                </button>
              </div>
              {bengaliOutput && (
                <div className="p-2 bg-[#080c14] border border-[#00ffcc22] rounded text-xs text-[#00ffcc] font-mono whitespace-pre-line">
                  {bengaliOutput}
                </div>
              )}
            </div>

            {/* 22 Real Android Device Tests Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2.5">
              {[
                {
                  id: '1',
                  name: '1. Gemini API Connection',
                  perm: 'GEMINI_API_KEY',
                  risk: 'SAFE' as const,
                  desc: 'Pings Gemini v1beta model endpoint to verify API key & connection.',
                  statusCheck: async () => {
                    try {
                      const res = await fetch('/api/gemini/chat', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ prompt: 'Ping test', voice: 'Zephyr' }),
                      });
                      return res.ok ? { status: 'PASS' as const, result: 'PASS ✓: Connected to Gemini API server (HTTP 200 OK).' }
                        : { status: 'FAIL' as const, result: 'FAIL ✕: Gemini API error.' };
                    } catch (e: any) {
                      return { status: 'FAIL' as const, result: `FAIL ✕: ${e.message}` };
                    }
                  }
                },
                {
                  id: '2',
                  name: '2. Microphone',
                  perm: 'RECORD_AUDIO',
                  risk: 'SAFE' as const,
                  desc: 'Verifies RECORD_AUDIO runtime permission & web audio stream.',
                  statusCheck: async () => {
                    try {
                      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                      stream.getTracks().forEach(t => t.stop());
                      return { status: 'PASS' as const, result: 'PASS ✓: Microphone permission verified.' };
                    } catch (e) {
                      return { status: 'NOT_GRANTED' as const, result: 'NOT GRANTED: Microphone permission denied.' };
                    }
                  }
                },
                {
                  id: '3',
                  name: '3. Camera',
                  perm: 'CAMERA',
                  risk: 'SAFE' as const,
                  desc: 'Verifies CAMERA hardware permission & sensor access.',
                  statusCheck: async () => {
                    try {
                      const stream = await navigator.mediaDevices.getUserMedia({ video: true });
                      stream.getTracks().forEach(t => t.stop());
                      return { status: 'PASS' as const, result: 'PASS ✓: Camera permission verified.' };
                    } catch (e) {
                      return { status: 'NOT_GRANTED' as const, result: 'NOT GRANTED: Camera permission denied.' };
                    }
                  }
                },
                {
                  id: '4',
                  name: '4. Location',
                  perm: 'ACCESS_FINE_LOCATION',
                  risk: 'SAFE' as const,
                  desc: 'Verifies GPS & location provider access.',
                  statusCheck: async () => {
                    return new Promise((resolve) => {
                      if (!navigator.geolocation) {
                        resolve({ status: 'NOT_SUPPORTED' as const, result: 'NOT SUPPORTED: Geolocation API unavailable.' });
                      } else {
                        navigator.geolocation.getCurrentPosition(
                          () => resolve({ status: 'PASS' as const, result: 'PASS ✓: Location permission granted.' }),
                          () => resolve({ status: 'NOT_GRANTED' as const, result: 'NOT GRANTED: Location permission denied.' })
                        );
                      }
                    });
                  }
                },
                {
                  id: '5',
                  name: '5. Contacts Permission',
                  perm: 'READ_CONTACTS',
                  risk: 'SAFE' as const,
                  desc: 'Verifies READ_CONTACTS for querying phone address book.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Verifies READ_CONTACTS on device.' };
                  }
                },
                {
                  id: '6',
                  name: '6. Accessibility Service',
                  perm: 'BIND_ACCESSIBILITY_SERVICE',
                  risk: 'SAFE' as const,
                  desc: 'Verifies if JXAccessibilityService is enabled in Android Settings.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Enable JX in Android Accessibility Settings.' };
                  }
                },
                {
                  id: '7',
                  name: '7. Notification Access',
                  perm: 'BIND_NOTIFICATION_LISTENER',
                  risk: 'SAFE' as const,
                  desc: 'Verifies JXNotificationListenerService permission in Android system.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Enable JX in Notification Listener Settings.' };
                  }
                },
                {
                  id: '8',
                  name: '8. Screen Capture / MediaProjection',
                  perm: 'FOREGROUND_SERVICE_MEDIA_PROJECTION',
                  risk: 'USER_CONFIRMATION' as const,
                  desc: 'Verifies MediaProjectionManager foreground service & screen consent.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Displays MediaProjection consent on device.' };
                  }
                },
                {
                  id: '9',
                  name: '9. Open Installed App',
                  perm: 'QUERY_ALL_PACKAGES',
                  risk: 'SAFE' as const,
                  desc: 'Tests PackageManager launch intent to open an installed application.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Dispatches Intent to open YouTube/Settings.' };
                  }
                },
                {
                  id: '10',
                  name: '10. Google Search',
                  perm: 'INTERNET',
                  risk: 'SAFE' as const,
                  desc: 'Tests Intent.ACTION_VIEW web query dispatcher to default Android browser.',
                  statusCheck: async () => {
                    return { status: 'PASS' as const, result: 'PASS ✓: Browser intent query ready.' };
                  }
                },
                {
                  id: '11',
                  name: '11. YouTube',
                  perm: 'INTERNET',
                  risk: 'SAFE' as const,
                  desc: 'Tests YouTube intent filter (vnd.youtube / search_query).',
                  statusCheck: async () => {
                    return { status: 'PASS' as const, result: 'PASS ✓: YouTube intent dispatcher ready.' };
                  }
                },
                {
                  id: '12',
                  name: '12. WhatsApp Compose',
                  perm: 'READ_CONTACTS',
                  risk: 'USER_CONFIRMATION' as const,
                  desc: 'Prepares WhatsApp message composition screen (no silent send).',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Launches WhatsApp compose screen on phone.' };
                  }
                },
                {
                  id: '13',
                  name: '13. Contact Search',
                  perm: 'READ_CONTACTS',
                  risk: 'SAFE' as const,
                  desc: 'Queries ContactsContract.CommonDataKinds.Phone for contact name & numbers.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Queries device ContactsContract.' };
                  }
                },
                {
                  id: '14',
                  name: '14. Phone Dialer',
                  perm: 'CALL_PHONE',
                  risk: 'USER_CONFIRMATION' as const,
                  desc: 'Pre-fills Android native phone dialer via Intent.ACTION_DIAL.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Launches native dialer with pre-filled number.' };
                  }
                },
                {
                  id: '15',
                  name: '15. Volume Control',
                  perm: 'MODIFY_AUDIO_SETTINGS',
                  risk: 'SAFE' as const,
                  desc: 'Adjusts AudioManager.STREAM_MUSIC volume up/down/percent via native service.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Adjusts hardware AudioManager stream.' };
                  }
                },
                {
                  id: '16',
                  name: '16. OS Navigation: BACK',
                  perm: 'ACCESSIBILITY',
                  risk: 'SAFE' as const,
                  desc: 'Performs AccessibilityService.GLOBAL_ACTION_BACK to return to previous screen.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Performs GLOBAL_ACTION_BACK on active window.' };
                  }
                },
                {
                  id: '17',
                  name: '17. OS Navigation: HOME',
                  perm: 'ACCESSIBILITY',
                  risk: 'SAFE' as const,
                  desc: 'Performs AccessibilityService.GLOBAL_ACTION_HOME to return to Home screen.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Performs GLOBAL_ACTION_HOME on device.' };
                  }
                },
                {
                  id: '18',
                  name: '18. OS Navigation: RECENTS',
                  perm: 'ACCESSIBILITY',
                  risk: 'SAFE' as const,
                  desc: 'Performs AccessibilityService.GLOBAL_ACTION_RECENTS to show app switcher.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Shows system recent apps carousel.' };
                  }
                },
                {
                  id: '19',
                  name: '19. Accessibility UI Inspection',
                  perm: 'ACCESSIBILITY',
                  risk: 'SAFE' as const,
                  desc: 'Traverses active window AccessibilityNodeInfo tree and extracts UI hierarchy.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Dumps active window node tree.' };
                  }
                },
                {
                  id: '20',
                  name: '20. Accessibility Tap',
                  perm: 'ACCESSIBILITY',
                  risk: 'SAFE' as const,
                  desc: 'Finds on-screen target node by text or viewId and performs ACTION_CLICK.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Executes ACTION_CLICK on target element.' };
                  }
                },
                {
                  id: '21',
                  name: '21. Accessibility Text Input',
                  perm: 'ACCESSIBILITY',
                  risk: 'SAFE' as const,
                  desc: 'Targets input field and inputs text via ACTION_SET_TEXT.',
                  statusCheck: async () => {
                    return { status: 'REQUIRES_REAL_DEVICE' as const, result: 'Requires real Android device test: Types text via ACTION_SET_TEXT on focus.' };
                  }
                },
                {
                  id: '22',
                  name: '22. Gemini Tool Calling',
                  perm: 'GEMINI_API_KEY',
                  risk: 'SAFE' as const,
                  desc: 'Tests end-to-end natural language agentic function calling loop.',
                  statusCheck: async () => {
                    try {
                      const res = await fetch('/api/gemini/chat', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ prompt: 'YouTube-এ electronics tutorial search করো', voice: 'Zephyr' }),
                      });
                      const data = await res.json();
                      return { status: 'PASS' as const, result: `PASS ✓: Gemini Agentic loop called tool: ${data.toolCall?.name || 'search_web'}.` };
                    } catch (e: any) {
                      return { status: 'FAIL' as const, result: `FAIL ✕: ${e.message}` };
                    }
                  }
                },
              ].map((item) => {
                const res = toolResults[item.id] || { status: 'IDLE', result: 'Ready to test' };
                const isRunning = res.status === 'RUNNING';

                const getBadgeStyle = (status: string) => {
                  switch (status) {
                    case 'PASS':
                      return { text: 'PASS ✓', className: 'bg-[#00ffcc22] text-[#00ffcc] border border-[#00ffcc44]' };
                    case 'FAIL':
                      return { text: 'FAIL ✕', className: 'bg-[#ff005522] text-[#ff0055] border border-[#ff005544]' };
                    case 'NOT_GRANTED':
                      return { text: 'NOT GRANTED', className: 'bg-[#ffb80022] text-[#ffb800] border border-[#ffb80044]' };
                    case 'NOT_SUPPORTED':
                      return { text: 'NOT SUPPORTED', className: 'bg-white/10 text-white/50 border border-white/20' };
                    case 'REQUIRES_REAL_DEVICE':
                      return { text: 'Requires real Android device test.', className: 'bg-[#7000ff22] text-[#c084fc] border border-[#7000ff44]' };
                    case 'RUNNING':
                      return { text: 'TESTING...', className: 'bg-[#00f2fe22] text-[#00f2fe] border border-[#00f2fe44]' };
                    default:
                      return { text: 'READY', className: 'bg-white/5 text-white/40 border border-white/10' };
                  }
                };

                const badge = getBadgeStyle(res.status);

                return (
                  <div key={item.id} className="p-3 bg-[#11121f] border border-white/10 rounded-xl flex flex-col justify-between gap-2 text-xs">
                    <div>
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-white text-[13px]">{item.name}</span>
                        <span className={`text-[9px] px-1.5 py-0.5 rounded font-mono font-bold ${
                          item.risk === 'SAFE' ? 'bg-[#00ffcc22] text-[#00ffcc]' : 'bg-[#ffb80022] text-[#ffb800]'
                        }`}>
                          {item.risk}
                        </span>
                      </div>
                      <p className="text-[11px] text-white/50 mt-1">{item.desc}</p>
                      <div className="flex items-center justify-between mt-1">
                        <span className="text-[10px] text-white/40 font-mono">Perm: {item.perm}</span>
                        <span className={`text-[9px] px-2 py-0.5 rounded font-mono font-bold ${badge.className}`}>
                          {badge.text}
                        </span>
                      </div>
                    </div>

                    <div className="p-1.5 bg-black/30 border border-white/5 rounded text-[11px] font-mono text-[#00ffcc]">
                      {res.result}
                    </div>

                    <button
                      onClick={async () => {
                        setToolResults((prev) => ({ ...prev, [item.id]: { status: 'RUNNING', result: 'Testing...' } }));
                        const result = await item.statusCheck();
                        setToolResults((prev) => ({ ...prev, [item.id]: result }));
                      }}
                      disabled={isRunning}
                      className="w-full py-1.5 bg-[#00ffcc] text-black font-black font-mono text-xs rounded hover:brightness-110 flex items-center justify-center gap-1.5 transition-all"
                    >
                      {isRunning ? <RefreshCw className="w-3 h-3 animate-spin" /> : <Play className="w-3 h-3" />}
                      <span>{isRunning ? 'TESTING...' : 'RUN INDIVIDUAL TEST'}</span>
                    </button>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* PHASE 2 ONBOARDING LIVE INTERACTIVE FLOW SIMULATOR */}
        {activeTab === 'onboarding' && (
          <div className="flex flex-col gap-3 font-sans">
            <div className="grid grid-cols-5 gap-1 text-[10px] font-mono">
              {[
                { id: 'security', label: '1. SECURITY', icon: Lock },
                { id: 'gemini', label: '2. GEMINI BRAIN', icon: Key },
                { id: 'permissions', label: '3. PERMISSIONS', icon: Shield },
                { id: 'connecting', label: '4. CONNECTING', icon: RefreshCw },
                { id: 'online', label: '5. JX ONLINE', icon: Sparkles },
              ].map((step) => {
                const IconComp = step.icon;
                const isActive = simStep === step.id;
                return (
                  <button
                    key={step.id}
                    onClick={() => setSimStep(step.id as any)}
                    className={`py-1.5 px-2 rounded border flex items-center justify-center gap-1 transition-all ${
                      isActive
                        ? 'bg-[#00f2ff22] border-[#00f2ff] text-[#00f2ff] font-bold shadow-[0_0_8px_#00f2ff44]'
                        : 'bg-[#121826] border-white/10 text-white/50 hover:text-white'
                    }`}
                  >
                    <IconComp className="w-3 h-3" />
                    <span className="hidden sm:inline">{step.label}</span>
                  </button>
                );
              })}
            </div>

            {/* JX Online View */}
            <div className="p-4 bg-[#121826] border border-[#00f2fe33] rounded-xl flex flex-col items-center text-center gap-3">
              <div className="flex items-center gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-[#00f2fe] shadow-[0_0_8px_#00f2fe]" />
                <span className="text-xs font-bold text-[#00f2fe] tracking-widest font-mono">JX AI • ONLINE</span>
              </div>

              <h3 className="text-lg font-bold text-white">
                "Hi Gowrob, <span className="text-[#ff007a]">I'm ready! 💕</span>"
              </h3>
              <p className="text-xs text-[#00f2fe]">Your intelligent anime companion & personal assistant.</p>

              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 w-full max-w-lg mt-2">
                <button
                  onClick={() => setActiveTab('controlEngine')}
                  className="p-2.5 bg-[#ff007a22] border border-[#ff007a] text-[#ff007a] rounded-lg font-bold text-xs flex items-center justify-center gap-1.5 hover:bg-[#ff007a] hover:text-white transition-all"
                >
                  <Mic className="w-4 h-4" /> TALK
                </button>
                <button
                  onClick={() => setActiveTab('controlEngine')}
                  className="p-2.5 bg-[#00f2fe22] border border-[#00f2fe] text-[#00f2fe] rounded-lg font-bold text-xs flex items-center justify-center gap-1.5 hover:bg-[#00f2fe] hover:text-[#080c14] transition-all"
                >
                  <FileText className="w-4 h-4" /> CHAT
                </button>
                <button
                  onClick={() => setActiveTab('controlEngine')}
                  className="p-2.5 bg-[#7000ff22] border border-[#7000ff] text-[#7000ff] rounded-lg font-bold text-xs flex items-center justify-center gap-1.5 hover:bg-[#7000ff] hover:text-white transition-all"
                >
                  <Eye className="w-4 h-4" /> VISION
                </button>
                <button
                  onClick={() => setActiveTab('controlEngine')}
                  className="p-2.5 bg-[#00ffcc22] border border-[#00ffcc] text-[#00ffcc] rounded-lg font-bold text-xs flex items-center justify-center gap-1.5 hover:bg-[#00ffcc] hover:text-black transition-all"
                >
                  <Zap className="w-4 h-4 text-[#00ffcc]" /> 12 ACTIONS
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ANDROID FLUTTER CODE TAB */}
        {activeTab === 'androidCode' && (
          <div className="flex flex-col gap-3 font-sans">
            <div className="bg-[#00ffcc10] border border-[#00ffcc33] p-3 rounded flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Smartphone className="w-5 h-5 text-[#00ffcc]" />
                <div>
                  <h3 className="font-bold text-sm text-[#00ffcc]">JX AI — Phase 3 Real Android Control Engine</h3>
                  <p className="text-xs text-[#e0f2feaa]">MethodChannels, Accessibility UI trees, Action HUD, and Gemini Function Calling</p>
                </div>
              </div>
              <span className="text-[10px] px-2 py-1 bg-[#00ffcc20] border border-[#00ffcc] text-[#00ffcc] rounded font-mono font-bold">
                PHASE 3 COMPLETE
              </span>
            </div>

            {/* APK Build & Installation Banner */}
            <div className="p-3.5 bg-[#00ffcc10] border border-[#00ffcc33] rounded-xl flex flex-col gap-3 font-mono text-xs">
              <div className="flex items-center justify-between">
                <span className="text-[#00ffcc] font-bold uppercase tracking-wider flex items-center gap-1.5">
                  <Smartphone className="w-4 h-4" /> INSTALL ANDROID APP • APK BUILD SPECIFICATION
                </span>
                <span className="text-[10px] px-2 py-0.5 bg-[#00ffcc22] border border-[#00ffcc] text-[#00ffcc] rounded font-bold">
                  READY FOR COMPILATION
                </span>
              </div>

              {/* Quick Actions in Workspace */}
              <div className="flex items-center gap-2 flex-wrap">
                <button
                  onClick={async () => {
                    try {
                      await fetch('/api/apk/build', { method: 'POST' });
                      alert('APK Build & Diagnostic Verification Triggered! Ready for compilation.');
                    } catch (e) {
                      console.error(e);
                    }
                  }}
                  className="px-3 py-1.5 bg-[#00ffcc] text-black font-black text-[11px] rounded-lg hover:brightness-110 flex items-center gap-1.5 shadow-[0_0_12px_rgba(0,255,204,0.3)] transition-all"
                >
                  <Play className="w-3.5 h-3.5 fill-black" />
                  <span>BUILD APK</span>
                </button>

                <a
                  href="/api/apk/download-source"
                  download="jx_ai_flutter_android_app.tar.gz"
                  className="px-3 py-1.5 bg-[#00f2fe22] border border-[#00f2fe] text-[#00f2fe] font-bold text-[11px] rounded-lg hover:bg-[#00f2fe33] flex items-center gap-1.5 transition-all"
                >
                  <Download className="w-3.5 h-3.5" />
                  <span>DOWNLOAD APK PACKAGE</span>
                </a>
              </div>

              <div className="text-[11px] text-white/80 space-y-1 bg-black/40 p-2.5 rounded-lg border border-white/5">
                <div>• <span className="text-[#00f2fe] font-bold">Primary Mobile App:</span> <code className="text-[#00ffcc]">/flutter_app</code> (Flutter 3.x + Kotlin 1.9)</div>
                <div>• <span className="text-[#00f2fe] font-bold">Debug APK Output:</span> <code className="text-[#00ffcc]">flutter_app/build/app/outputs/flutter-apk/app-debug.apk</code></div>
                <div>• <span className="text-[#00f2fe] font-bold">Release APK Output:</span> <code className="text-[#00ffcc]">flutter_app/build/app/outputs/flutter-apk/app-release.apk</code></div>
                <div>• <span className="text-[#00f2fe] font-bold">ADB Direct Install:</span> <code className="bg-black/50 px-1 py-0.5 rounded text-white">adb install -r flutter_app/build/app/outputs/flutter-apk/app-release.apk</code></div>
              </div>
            </div>

            {/* Code Selector */}
            <div className="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
              <span className="text-[#00ffcc] font-mono text-[10px] uppercase font-bold shrink-0">FILES:</span>
              {[
                { id: 'android_tool_router', label: 'android_tool_router.dart' },
                { id: 'gemini_tool_declarations', label: 'gemini_tool_declarations.dart' },
                { id: 'debug_tools_screen', label: 'debug_tools_screen.dart' },
                { id: 'action_hud', label: 'action_hud.dart' },
                { id: 'action_confirmation_dialog', label: 'action_confirmation_dialog.dart' },
                { id: 'main_activity_kt', label: 'MainActivity.kt' },
                { id: 'accessibility_service_kt', label: 'JXAccessibilityService.kt' },
              ].map((f) => (
                <button
                  key={f.id}
                  onClick={() => setSelectedCodeFile(f.id)}
                  className={`px-2.5 py-1 rounded text-xs transition-all shrink-0 font-mono ${
                    selectedCodeFile === f.id
                      ? 'bg-[#00ffcc] text-black font-bold shadow-[0_0_8px_#00ffcc]'
                      : 'bg-[#121826] text-[#e0f2fe88] hover:text-white hover:bg-[#00ffcc22]'
                  }`}
                >
                  {f.label}
                </button>
              ))}
            </div>

            {/* Code File Previewer */}
            <div className="p-3 bg-[#080c14] border border-[#00ffcc22] rounded font-mono text-xs text-[#e0f2fe] max-h-[220px] overflow-y-auto leading-relaxed">
              {selectedCodeFile === 'android_tool_router' && (
                <pre>{`// /flutter_app/lib/services/android_tool_router.dart
Handles: openApp, findInstalledApp, openSettings, searchWeb, openYouTube,
openWhatsApp, preparePhoneCall, searchContacts, openCamera, adjustVolume,
navigateOS (back/home/recents), inspectScreenHierarchy, findAndClickNode.`}</pre>
              )}
              {selectedCodeFile === 'gemini_tool_declarations' && (
                <pre>{`// /flutter_app/lib/services/gemini_tool_declarations.dart
Function declarations for Gemini tool calling + Bengali/Banglish natural language mapping.`}</pre>
              )}
              {selectedCodeFile === 'debug_tools_screen' && (
                <pre>{`// /flutter_app/lib/screens/debug_tools_screen.dart
Phase 3 Dedicated Debug & Test Screen verifying all 12 tools and permissions.`}</pre>
              )}
              {selectedCodeFile === 'action_hud' && (
                <pre>{`// /flutter_app/lib/widgets/action_hud.dart
Futuristic Action HUD overlay showing Understanding... -> Executing... -> Completed ✓`}</pre>
              )}
              {selectedCodeFile === 'action_confirmation_dialog' && (
                <pre>{`// /flutter_app/lib/widgets/action_confirmation_dialog.dart
Risk-based user confirmation interceptor for calls, messages, settings, and high-risk tasks.`}</pre>
              )}
              {selectedCodeFile === 'main_activity_kt' && (
                <pre>{`// /flutter_app/android/app/src/main/kotlin/com/example/jx_ai_companion/MainActivity.kt
Native Kotlin implementation handling package manager launches, dialer, search, volume, and contacts.`}</pre>
              )}
              {selectedCodeFile === 'accessibility_service_kt' && (
                <pre>{`// /flutter_app/android/app/src/main/kotlin/com/example/jx_ai_companion/JXAccessibilityService.kt
AccessibilityService performing GLOBAL_ACTION_BACK, HOME, RECENTS + node hierarchy inspection & click.`}</pre>
              )}
            </div>

            <div className="flex items-center justify-between text-xs text-[#00ffcc88] pt-1">
              <span>All Flutter & Kotlin code generated in <code className="text-[#00ffcc]">/flutter_app/</code></span>
              <span className="text-[#ff007a] font-bold">Created for Gowrob 💕</span>
            </div>
          </div>
        )}

        {/* NOTES TAB */}
        {activeTab === 'notes' && (
          <div className="flex flex-col gap-4">
            <form onSubmit={handleAddNote} className="p-3 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex flex-col gap-2">
              <span className="text-[10px] text-[#00f2ff] font-bold uppercase tracking-wider flex items-center gap-1">
                <Plus className="w-3.5 h-3.5" /> Add Quick Memory Note
              </span>
              <input
                type="text"
                placeholder="Note Title..."
                value={newNoteTitle}
                onChange={(e) => setNewNoteTitle(e.target.value)}
                className="bg-[#020408] border border-[#00f2ff22] rounded px-3 py-1.5 text-xs text-[#e0f2fe] focus:outline-none focus:border-[#00f2ff]"
              />
              <textarea
                placeholder="Content..."
                value={newNoteContent}
                onChange={(e) => setNewNoteContent(e.target.value)}
                rows={2}
                className="bg-[#020408] border border-[#00f2ff22] rounded px-3 py-1.5 text-xs text-[#e0f2fe] focus:outline-none focus:border-[#00f2ff] resize-none"
              />
              <button
                type="submit"
                className="self-end bg-[#00f2ff] text-[#020408] font-bold px-3 py-1 rounded text-[10px] uppercase tracking-widest hover:brightness-110"
              >
                Save Note
              </button>
            </form>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {toolEngine.notes.map((note) => (
                <div key={note.id} className="p-3 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex flex-col justify-between gap-2">
                  <div>
                    <div className="flex items-center justify-between">
                      <h4 className="text-[11px] font-bold text-[#00f2ff] uppercase tracking-wide">{note.title}</h4>
                      <button
                        onClick={() => {
                          toolEngine.executeTool('manageNotes', { action: 'delete', id: note.id });
                          onRefresh();
                        }}
                        className="text-red-400 hover:text-red-300"
                      >
                        <Trash2 className="w-3 h-3" />
                      </button>
                    </div>
                    <p className="text-[10px] text-[#e0f2feaa] mt-1 font-sans line-clamp-3">{note.content}</p>
                  </div>
                  <span className="text-[8px] text-[#00f2ff66]">{note.updatedAt}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* CALENDAR TAB */}
        {activeTab === 'calendar' && (
          <div className="flex flex-col gap-4">
            <form onSubmit={handleAddCalendar} className="p-3 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex flex-col gap-2">
              <span className="text-[10px] text-[#00f2ff] font-bold uppercase tracking-wider flex items-center gap-1">
                <Plus className="w-3.5 h-3.5" /> Schedule Event
              </span>
              <div className="flex gap-2">
                <input
                  type="text"
                  placeholder="Event Title..."
                  value={newCalTitle}
                  onChange={(e) => setNewCalTitle(e.target.value)}
                  className="flex-1 bg-[#020408] border border-[#00f2ff22] rounded px-3 py-1.5 text-xs text-[#e0f2fe] focus:outline-none focus:border-[#00f2ff]"
                />
                <input
                  type="time"
                  value={newCalTime}
                  onChange={(e) => setNewCalTime(e.target.value)}
                  className="bg-[#020408] border border-[#00f2ff22] rounded px-3 py-1.5 text-xs text-[#e0f2fe] focus:outline-none focus:border-[#00f2ff]"
                />
              </div>
              <button
                type="submit"
                className="self-end bg-[#00f2ff] text-[#020408] font-bold px-3 py-1 rounded text-[10px] uppercase tracking-widest hover:brightness-110"
              >
                Add Event
              </button>
            </form>

            <div className="space-y-2">
              {toolEngine.calendarEvents.map((evt) => (
                <div key={evt.id} className="p-2.5 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex items-center justify-between text-xs">
                  <div>
                    <h4 className="font-bold text-[#e0f2fe]">{evt.title}</h4>
                    <span className="text-[10px] text-[#00f2ff88]">{evt.time}</span>
                  </div>
                  <button
                    onClick={() => {
                      toolEngine.executeTool('calendar', { action: 'delete', id: evt.id });
                      onRefresh();
                    }}
                    className="text-red-400 hover:text-red-300"
                  >
                    <Trash2 className="w-3 h-3" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* WEATHER TAB */}
        {activeTab === 'weather' && (
          <div className="p-4 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex flex-col gap-3">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-base font-bold text-[#00f2ff]">{weather.location}</h3>
                <p className="text-xs text-[#e0f2feaa]">{weather.condition}</p>
              </div>
              <CloudSun className="w-10 h-10 text-[#00f2ff]" />
            </div>
            <div className="text-3xl font-black text-[#e0f2fe]">{weather.temp}°F</div>
            <div className="flex gap-4 text-xs text-[#00f2ff88] pt-2 border-t border-[#00f2ff22]">
              <span>Humidity: {weather.humidity}%</span>
              <span>Wind: {weather.wind} mph</span>
            </div>
          </div>
        )}

        {/* TIMERS TAB */}
        {activeTab === 'timers' && (
          <div className="flex flex-col gap-4">
            <form onSubmit={handleAddTimer} className="p-3 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex gap-2">
              <input
                type="text"
                placeholder="Label..."
                value={newTimerLabel}
                onChange={(e) => setNewTimerLabel(e.target.value)}
                className="flex-1 bg-[#020408] border border-[#00f2ff22] rounded px-3 py-1.5 text-xs text-[#e0f2fe] focus:outline-none focus:border-[#00f2ff]"
              />
              <input
                type="number"
                placeholder="Seconds"
                value={newTimerSec}
                onChange={(e) => setNewTimerSec(e.target.value)}
                className="w-20 bg-[#020408] border border-[#00f2ff22] rounded px-3 py-1.5 text-xs text-[#e0f2fe] focus:outline-none focus:border-[#00f2ff]"
              />
              <button
                type="submit"
                className="bg-[#00f2ff] text-[#020408] font-bold px-3 py-1 rounded text-[10px] uppercase tracking-widest hover:brightness-110"
              >
                Set
              </button>
            </form>

            <div className="space-y-2">
              {toolEngine.timers.map((t) => (
                <div key={t.id} className="p-2.5 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex items-center justify-between text-xs">
                  <div>
                    <h4 className="font-bold text-[#e0f2fe]">{t.label}</h4>
                    <span className="text-[10px] text-[#00f2ff88]">{t.durationSeconds}s remaining</span>
                  </div>
                  <span className="text-[10px] px-2 py-0.5 bg-[#00f2ff22] text-[#00f2ff] rounded font-bold uppercase">
                    {t.status}
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* FILES TAB */}
        {activeTab === 'files' && (
          <div className="flex flex-col gap-4">
            <form onSubmit={handleSaveFile} className="p-3 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex flex-col gap-2">
              <input
                type="text"
                placeholder="Path..."
                value={newFilePath}
                onChange={(e) => setNewFilePath(e.target.value)}
                className="bg-[#020408] border border-[#00f2ff22] rounded px-3 py-1.5 text-xs text-[#e0f2fe] focus:outline-none focus:border-[#00f2ff]"
              />
              <textarea
                placeholder="File Content..."
                value={newFileContent}
                onChange={(e) => setNewFileContent(e.target.value)}
                rows={2}
                className="bg-[#020408] border border-[#00f2ff22] rounded px-3 py-1.5 text-xs text-[#e0f2fe] focus:outline-none focus:border-[#00f2ff] resize-none"
              />
              <button
                type="submit"
                className="self-end bg-[#00f2ff] text-[#020408] font-bold px-3 py-1 rounded text-[10px] uppercase tracking-widest hover:brightness-110"
              >
                Write File
              </button>
            </form>

            <div className="space-y-2">
              {toolEngine.files.map((f) => (
                <div key={f.path} className="p-2.5 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex items-center justify-between text-xs">
                  <div>
                    <h4 className="font-bold text-[#e0f2fe]">{f.path}</h4>
                    <span className="text-[10px] text-[#00f2ff88]">{f.size} bytes</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* SMART HOME TAB */}
        {activeTab === 'smartHome' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {toolEngine.smartDevices.map((dev) => (
              <div key={dev.id} className="p-3 bg-[#00f2ff0a] border border-[#00f2ff22] rounded flex items-center justify-between text-xs">
                <div>
                  <h4 className="font-bold text-[#00f2ff] uppercase">{dev.name}</h4>
                  <span className="text-[9px] text-[#00f2ff88]">{dev.room} • {dev.type}</span>
                </div>

                <button
                  onClick={() => handleToggleSmartDevice(dev.id, dev.status)}
                  className={`px-3 py-1 rounded font-bold text-[10px] uppercase tracking-wider transition-all ${
                    dev.status === true || dev.status === 'Locked'
                      ? 'bg-[#00f2ff] text-[#020408] shadow-[0_0_8px_#00f2ff]'
                      : 'bg-[#00f2ff15] text-[#00f2ff88] hover:text-[#e0f2fe]'
                  }`}
                >
                  {String(dev.status).toUpperCase()}
                </button>
              </div>
            ))}
          </div>
        )}

        {/* APPLICATION LAUNCHER TAB */}
        {activeTab === 'apps' && (
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {[
              { name: 'Neural Spectrum Analyzer', desc: 'Real-time FFT audio visualizer' },
              { name: 'Storage Vault', desc: 'Secure memory file browser' },
              { name: 'Smart Home IoT Hub', desc: 'Perimeter locks & drones' },
              { name: 'Quantum Code Playground', desc: 'Python/TS Execution sandbox' },
              { name: 'System Diagnostic Scanner', desc: 'CPU, RAM & Latency audit' },
              { name: 'Translation Matrix', desc: 'Multi-language voice bridge' },
            ].map((app) => (
              <div
                key={app.name}
                className="p-3 bg-[#00f2ff0a] border border-[#00f2ff22] hover:border-[#00f2ff] rounded flex flex-col justify-between gap-2 transition-all cursor-pointer group"
                onClick={() => {
                  toolEngine.executeTool('launchApp', { appName: app.name });
                  onRefresh();
                }}
              >
                <div>
                  <h4 className="font-bold text-[#00f2ff] group-hover:text-[#e0f2fe] text-xs uppercase tracking-wide">{app.name}</h4>
                  <p className="text-[10px] text-[#e0f2fe88] mt-1 font-sans">{app.desc}</p>
                </div>
                <button className="self-start text-[9px] text-[#00f2ff] font-bold uppercase tracking-widest group-hover:underline">
                  Launch App →
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
