/**
 * JX - Next-Generation AI Assistant Types
 */

export type JXPersonalityMode = 'companion' | 'jarvis' | 'calm' | 'aggressive' | 'analytical' | 'tactical' | 'cyberpunk';

export type VoiceName = 'Zephyr' | 'Kore' | 'Puck' | 'Charon' | 'Fenrir';

export type EmotionType = 'neutral' | 'processing' | 'speaking' | 'listening' | 'happy' | 'focused' | 'alert' | 'energetic';

export type AvatarModelId = 'luna-companion' | 'jx-core' | 'aria-cyber' | 'atlas-titan' | 'vesper-mesh';

export interface AvatarCharacter {
  id: AvatarModelId;
  name: string;
  description: string;
  type: 'hologram' | 'sprite' | 'mesh' | 'live2d';
  primaryColor: string;
  secondaryColor: string;
  avatarUrl?: string;
  spriteSheets?: Record<EmotionType, string>;
}

export interface ToolExecutionLog {
  id: string;
  toolName: string;
  input: Record<string, any>;
  output: any;
  timestamp: string;
  status: 'running' | 'success' | 'error';
  executionTimeMs?: number;
}

export interface SystemTelemetry {
  latencyMs: number;
  inputVolume: number;
  outputVolume: number;
  audioFps: number;
  connectionState: 'disconnected' | 'connecting' | 'connected' | 'error';
  activeModel: string;
  tokensProcessed: number;
  cpuLoad: number;
  memoryUsageMb: number;
}

export interface NoteItem {
  id: string;
  title: string;
  content: string;
  tags: string[];
  createdAt: string;
}

export interface CalendarEvent {
  id: string;
  title: string;
  time: string;
  date: string;
  location?: string;
  category: 'work' | 'personal' | 'system' | 'meeting';
}

export interface TimerItem {
  id: string;
  label: string;
  durationSeconds: number;
  remainingSeconds: number;
  isRunning: boolean;
  createdAt: string;
}

export interface ReminderItem {
  id: string;
  text: string;
  time: string;
  completed: boolean;
}

export interface WeatherData {
  location: string;
  temperatureC: number;
  temperatureF: number;
  condition: string;
  humidity: number;
  windSpeedKph: number;
  forecast: Array<{ day: string; tempC: number; condition: string }>;
}

export interface SmartDeviceState {
  id: string;
  name: string;
  type: 'light' | 'thermostat' | 'lock' | 'security' | 'drone';
  status: boolean | string | number;
  room: string;
}

export interface ChatMessage {
  id: string;
  sender: 'user' | 'jx' | 'system';
  text: string;
  timestamp: string;
  audioUrl?: string;
  toolCall?: {
    name: string;
    args: Record<string, any>;
    result?: any;
  };
}

export type AssistantFlowStep = 
  | 'app_open' 
  | 'security_verification' 
  | 'gemini_setup' 
  | 'permission_center' 
  | 'jx_connecting' 
  | 'jx_online';

export interface AndroidPermissionState {
  id: string;
  name: string;
  androidManifestName: string;
  granted: boolean;
  category: 'core' | 'accessibility' | 'telephony' | 'media';
  description: string;
  rationale: string;
}

export interface AndroidActionExecution {
  id: string;
  commandType: 
    | 'open_app'
    | 'web_search'
    | 'youtube_search'
    | 'phone_call'
    | 'send_message'
    | 'camera_launch'
    | 'screen_read'
    | 'volume_control'
    | 'system_navigation'
    | 'accessibility_action';
  title: string;
  intentAction: string;
  intentUri?: string;
  targetPackage?: string;
  params: Record<string, any>;
  requiresConfirmation: boolean;
  isConfirmed?: boolean;
  status: 'pending_confirmation' | 'executing' | 'completed' | 'denied' | 'failed';
  resultMessage?: string;
  timestamp: string;
}
