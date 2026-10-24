import React, { useState, useEffect } from 'react';
import { Smartphone, Download, Play, CheckCircle2, AlertTriangle, X, Terminal, Shield, Sparkles, Cpu, RefreshCw } from 'lucide-react';

interface InstallAppModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const InstallAppModal: React.FC<InstallAppModalProps> = ({ isOpen, onClose }) => {
  const [apkStatus, setApkStatus] = useState<'NOT_BUILT' | 'BUILDING' | 'READY' | 'FAILED'>('NOT_BUILT');
  const [logs, setLogs] = useState<string[]>([
    'Primary Android Flutter app ready at /flutter_app',
    'Click [Build APK] or [Download APK] to proceed.',
  ]);
  const [isBuilding, setIsBuilding] = useState<boolean>(false);
  const [isDownloading, setIsDownloading] = useState<boolean>(false);

  // Fetch initial status
  useEffect(() => {
    if (isOpen) {
      fetchStatus();
    }
  }, [isOpen]);

  const fetchStatus = async () => {
    try {
      const res = await fetch('/api/apk/status');
      if (res.ok) {
        const data = await res.json();
        setApkStatus(data.status);
        if (data.logs && data.logs.length > 0) {
          setLogs(data.logs);
        }
      }
    } catch (e) {
      console.error('Failed to fetch APK status:', e);
    }
  };

  const handleBuildApk = async () => {
    setIsBuilding(true);
    setApkStatus('BUILDING');
    try {
      const res = await fetch('/api/apk/build', { method: 'POST' });
      const data = await res.json();
      if (data.success) {
        // Poll status
        setTimeout(async () => {
          await fetchStatus();
          setIsBuilding(false);
        }, 1200);
      }
    } catch (e) {
      setIsBuilding(false);
      setApkStatus('FAILED');
      setLogs((prev) => [...prev, `[Error] Failed to initiate build check: ${e}`]);
    }
  };

  const handleDownloadSource = () => {
    setIsDownloading(true);
    window.location.href = '/api/apk/download-source';
    setTimeout(() => setIsDownloading(false), 2000);
  };

  if (!isOpen) return null;

  const getStatusBadge = () => {
    switch (apkStatus) {
      case 'READY':
        return { text: 'READY', className: 'bg-[#00ffcc22] text-[#00ffcc] border-[#00ffcc]' };
      case 'BUILDING':
        return { text: 'BUILDING', className: 'bg-[#00f2fe22] text-[#00f2fe] border-[#00f2fe] animate-pulse' };
      case 'FAILED':
        return { text: 'FAILED', className: 'bg-[#ff005522] text-[#ff0055] border-[#ff0055]' };
      case 'NOT_BUILT':
      default:
        return { text: 'NOT BUILT', className: 'bg-white/10 text-white/70 border-white/20' };
    }
  };

  const badge = getStatusBadge();

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in font-mono">
      <div className="relative w-full max-w-2xl bg-[#090a14] border border-[#00ffcc]/40 rounded-2xl p-5 md:p-6 shadow-[0_0_50px_rgba(0,255,204,0.15)] flex flex-col gap-4 text-xs">
        
        {/* Header */}
        <div className="flex items-center justify-between border-b border-white/10 pb-3">
          <div className="flex items-center gap-2.5">
            <div className="p-2 bg-[#00ffcc22] border border-[#00ffcc] rounded-lg">
              <Smartphone className="w-5 h-5 text-[#00ffcc]" />
            </div>
            <div>
              <h2 className="text-base font-bold tracking-wider text-white uppercase flex items-center gap-2">
                INSTALL ANDROID APP
              </h2>
              <p className="text-[11px] text-white/50 font-sans">
                Native Flutter Android application with JX Accessibility Service & Gemini Engine
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-1.5 rounded-lg bg-white/5 hover:bg-white/10 text-white/70 hover:text-white transition-all"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* APK Status Bar */}
        <div className="flex items-center justify-between p-3 bg-[#111322] border border-white/10 rounded-xl">
          <div className="flex items-center gap-2">
            <span className="text-white/60 uppercase font-bold text-[11px]">APK Status:</span>
            <span className={`px-2.5 py-0.5 rounded border text-[11px] font-bold ${badge.className}`}>
              {badge.text}
            </span>
          </div>

          <button
            onClick={fetchStatus}
            className="text-[10px] text-[#00ffcc] hover:underline flex items-center gap-1"
          >
            <RefreshCw className="w-3 h-3" /> Refresh
          </button>
        </div>

        {/* Action Buttons: [Build APK] and [Download APK] */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <button
            id="build-apk-modal-btn"
            onClick={handleBuildApk}
            disabled={isBuilding}
            className="py-3 px-4 bg-[#00ffcc] text-black font-black font-mono rounded-xl hover:brightness-110 flex items-center justify-center gap-2 shadow-[0_0_20px_rgba(0,255,204,0.3)] transition-all disabled:opacity-50"
          >
            {isBuilding ? <RefreshCw className="w-4 h-4 animate-spin" /> : <Play className="w-4 h-4 fill-black" />}
            <span>{isBuilding ? 'BUILDING APK...' : 'BUILD APK'}</span>
          </button>

          <button
            id="download-apk-modal-btn"
            onClick={handleDownloadSource}
            disabled={isDownloading}
            className="py-3 px-4 bg-[#00f2fe22] border border-[#00f2fe] text-[#00f2fe] font-bold font-mono rounded-xl hover:bg-[#00f2fe33] flex items-center justify-center gap-2 transition-all"
          >
            <Download className="w-4 h-4" />
            <span>{isDownloading ? 'PACKAGING...' : 'DOWNLOAD FLUTTER APK PACKAGE'}</span>
          </button>
        </div>

        {/* Environment Transparency Notice */}
        <div className="p-3 bg-[#ffb80010] border border-[#ffb80033] rounded-xl flex items-start gap-2.5 text-[11px] text-white/80 font-sans">
          <AlertTriangle className="w-4 h-4 text-[#ffb800] shrink-0 mt-0.5" />
          <div>
            <span className="text-[#ffb800] font-bold">Environment Notice: </span>
            This AI Studio web container hosts the full Flutter & Kotlin codebase. Direct binary APK generation requires the Flutter/Android SDK CLI. You can download the complete package above or compile directly:
          </div>
        </div>

        {/* Build Terminal Logs & Path Specification */}
        <div className="p-3 bg-black/60 border border-white/10 rounded-xl flex flex-col gap-2 font-mono text-[11px]">
          <div className="flex items-center justify-between text-white/50 text-[10px] border-b border-white/5 pb-1">
            <span className="flex items-center gap-1"><Terminal className="w-3 h-3 text-[#00ffcc]" /> APK OUTPUT PATHS & CLI COMMANDS</span>
            <span className="text-[#00ffcc]">FLUTTER 3.x</span>
          </div>

          <div className="space-y-1 text-white/70">
            <div>• <span className="text-[#00f2fe] font-bold">Debug APK Target:</span> <code className="text-[#00ffcc]">flutter_app/build/app/outputs/flutter-apk/app-debug.apk</code></div>
            <div>• <span className="text-[#00f2fe] font-bold">Release APK Target:</span> <code className="text-[#00ffcc]">flutter_app/build/app/outputs/flutter-apk/app-release.apk</code></div>
          </div>

          {/* Quick Step CLI */}
          <div className="mt-1 p-2 bg-[#020408] rounded border border-white/5 text-[10px] text-[#00ffcc] leading-relaxed">
            <div className="text-white/40 font-bold"># Compile and install on physical Android phone:</div>
            <div>cd flutter_app</div>
            <div>flutter pub get</div>
            <div>flutter build apk --release</div>
            <div>adb install -r build/app/outputs/flutter-apk/app-release.apk</div>
          </div>
        </div>

        {/* Preserved Feature Checklist */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-[10px] text-white/60">
          <div className="flex items-center gap-1 text-[#00ffcc]"><CheckCircle2 className="w-3 h-3" /> Gemini AI Brain</div>
          <div className="flex items-center gap-1 text-[#00ffcc]"><CheckCircle2 className="w-3 h-3" /> Real-time Voice</div>
          <div className="flex items-center gap-1 text-[#00ffcc]"><CheckCircle2 className="w-3 h-3" /> 3D VRM Avatar</div>
          <div className="flex items-center gap-1 text-[#00ffcc]"><CheckCircle2 className="w-3 h-3" /> Biometric Security</div>
          <div className="flex items-center gap-1 text-[#00ffcc]"><CheckCircle2 className="w-3 h-3" /> Android Controls</div>
          <div className="flex items-center gap-1 text-[#00ffcc]"><CheckCircle2 className="w-3 h-3" /> Accessibility Svc</div>
          <div className="flex items-center gap-1 text-[#00ffcc]"><CheckCircle2 className="w-3 h-3" /> SQLite Memory</div>
          <div className="flex items-center gap-1 text-[#00ffcc]"><CheckCircle2 className="w-3 h-3" /> 22-Test Test Center</div>
        </div>

      </div>
    </div>
  );
};
