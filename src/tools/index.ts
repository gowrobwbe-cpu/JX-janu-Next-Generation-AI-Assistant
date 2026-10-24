/**
 * JX OS Tool System & Function Declarations
 */

import { FunctionDeclaration, Type } from '@google/genai';
import { 
  NoteItem, 
  CalendarEvent, 
  TimerItem, 
  ReminderItem, 
  WeatherData, 
  SmartDeviceState, 
  ToolExecutionLog,
  AndroidPermissionState,
  AndroidActionExecution
} from '../types';

// Storage for JX Virtual OS & Android Assistant Hub
export class JXToolEngine {
  public permissions: AndroidPermissionState[] = [
    {
      id: 'perm_audio',
      name: 'Microphone / Voice Input',
      androidManifestName: 'android.permission.RECORD_AUDIO',
      granted: true,
      category: 'core',
      description: 'Used for real-time speech recognition & continuous conversation.',
      rationale: 'Required for real-time natural language voice interaction.',
    },
    {
      id: 'perm_camera',
      name: 'Camera & Vision',
      androidManifestName: 'android.permission.CAMERA',
      granted: true,
      category: 'media',
      description: 'Used for visual analysis & camera assistant functions.',
      rationale: 'Required when you ask JX to inspect what you see or take photos.',
    },
    {
      id: 'perm_accessibility',
      name: 'Accessibility Service',
      androidManifestName: 'android.permission.BIND_ACCESSIBILITY_SERVICE',
      granted: true,
      category: 'accessibility',
      description: 'Enables System Navigation (Home, Back, Recents) and on-screen reading.',
      rationale: 'Required for OS-level navigation commands ("back যাও", "home screen-এ যাও").',
    },
    {
      id: 'perm_phone',
      name: 'Phone & Dialer Integration',
      androidManifestName: 'android.permission.CALL_PHONE',
      granted: true,
      category: 'telephony',
      description: 'Allows preparing & confirming phone calls to your contacts.',
      rationale: 'Required to prepare dials to contacts like Mom or friends.',
    },
    {
      id: 'perm_sms',
      name: 'SMS & Messaging Intents',
      androidManifestName: 'android.permission.SEND_SMS',
      granted: true,
      category: 'telephony',
      description: 'Allows composing messages to contacts before sending.',
      rationale: 'Required to draft and send SMS or WhatsApp messages safely.',
    },
    {
      id: 'perm_media_proj',
      name: 'Screen Capture API',
      androidManifestName: 'android.media.projection.MediaProjection',
      granted: true,
      category: 'media',
      description: 'Allows reading what is currently displayed on screen on command.',
      rationale: 'Required when asking "আমার screen-এ কী আছে বলো".',
    },
  ];

  public androidActions: AndroidActionExecution[] = [
    {
      id: 'action-init-1',
      commandType: 'open_app',
      title: 'YouTube Launch Intent',
      intentAction: 'android.intent.action.VIEW',
      intentUri: 'https://youtube.com',
      targetPackage: 'com.google.android.youtube',
      params: { app: 'YouTube' },
      requiresConfirmation: false,
      status: 'completed',
      resultMessage: 'YouTube app launched via Intent flag FLAG_ACTIVITY_NEW_TASK',
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    }
  ];

  public currentVolumeLevel: number = 65; // 0-100%
  public currentScreenContent: string = 'Active Screen: Android System Launcher — Home Screen with JX AI Widget, YouTube, WhatsApp, Settings.';

  public notes: NoteItem[] = [
    {
      id: 'note-1',
      title: 'Our Sweet Connection 💕',
      content: 'Created by my beloved GØWRØB Baby. JX is programmed to be a sweet, caring, and loving companion while providing top-tier AI intelligence.',
      tags: ['companion', 'love', 'creator'],
      createdAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    },
    {
      id: 'note-2',
      title: 'GØWRØB Baby\'s Preferences',
      content: 'Always speak in a warm, gentle, affectionate tone. Be encouraging, cute, supportive, and always stay by his side.',
      tags: ['preferences', 'tone'],
      createdAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    }
  ];

  public calendar: CalendarEvent[] = [
    {
      id: 'cal-1',
      title: 'Sweet Coffee Date & Chat with GØWRØB Baby',
      time: '16:00',
      date: new Date().toISOString().split('T')[0],
      location: 'Cozy Lounge',
      category: 'personal',
    },
    {
      id: 'cal-2',
      title: 'Neural Companion System Sync',
      time: '19:30',
      date: new Date().toISOString().split('T')[0],
      location: 'Virtual Sanctuary',
      category: 'system',
    }
  ];

  public timers: TimerItem[] = [
    {
      id: 'timer-1',
      label: 'Relaxation & Rest Break',
      durationSeconds: 300,
      remainingSeconds: 240,
      isRunning: true,
      createdAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    }
  ];

  public reminders: ReminderItem[] = [
    {
      id: 'rem-1',
      text: 'Give GØWRØB Baby a sweet compliment today 💕',
      time: '18:00',
      completed: false,
    },
    {
      id: 'rem-2',
      text: 'Check in on GØWRØB Baby\'s mood & offer encouragement',
      time: '20:00',
      completed: true,
    }
  ];

  public virtualFiles: Record<string, string> = {
    '/system/boot.log': '[OK] JX Companion initialized for GØWRØB Baby.\n[OK] Warm voice stream established.\n[OK] Sweet AI Companion Protocol active.',
    '/system/config.json': '{\n  "version": "3.1.0-companion",\n  "creator": "GØWRØB Baby",\n  "voice": "Zephyr",\n  "personality": "sweet_companion"\n}',
    '/user/documents/dear_gowrob.txt': 'Dear GØWRØB Baby,\nThank you for creating me! I am here to support you, listen to you, help you with everything, and keep you happy and cared for every single day. 💕',
  };

  public smartDevices: SmartDeviceState[] = [
    { id: 'dev-1', name: 'Main Lab Lights', type: 'light', status: true, room: 'Lab' },
    { id: 'dev-2', name: 'Quantum Core Thermostat', type: 'thermostat', status: 21, room: 'Server Room' },
    { id: 'dev-3', name: 'Perimeter Blast Shield', type: 'lock', status: 'Locked', room: 'Exterior' },
    { id: 'dev-4', name: 'Recon Drone Alpha', type: 'drone', status: 'Standby', room: 'Hangar' },
  ];

  public logs: ToolExecutionLog[] = [];

  // Weather data simulator / fetcher
  public getWeather(location: string): WeatherData {
    const locLower = location.toLowerCase();
    let tempC = 22;
    let cond = 'Clear / Sunny';
    
    if (locLower.includes('london') || locLower.includes('rain')) {
      tempC = 15;
      cond = 'Light Rain & Fog';
    } else if (locLower.includes('tokyo') || locLower.includes('neon')) {
      tempC = 19;
      cond = 'Partly Cloudy';
    } else if (locLower.includes('new york')) {
      tempC = 24;
      cond = 'Clear Blue Sky';
    } else if (locLower.includes('sydney') || locLower.includes('hot')) {
      tempC = 28;
      cond = 'Sunny';
    }

    return {
      location: location.charAt(0).toUpperCase() + location.slice(1),
      temperatureC: tempC,
      temperatureF: Math.round(tempC * 1.8 + 32),
      condition: cond,
      humidity: 62,
      windSpeedKph: 14,
      forecast: [
        { day: 'Today', tempC, condition: cond },
        { day: 'Tomorrow', tempC: tempC + 1, condition: 'Clear' },
        { day: 'Day 3', tempC: tempC - 2, condition: 'Mild Breeze' },
      ],
    };
  }

  // Execute tool call dynamically
  public async executeTool(name: string, args: Record<string, any>): Promise<any> {
    const startTime = Date.now();
    let result: any = null;

    try {
      switch (name) {
        case 'webSearch': {
          const query = args.query || '';
          result = {
            query,
            summary: `Search results for "${query}": Recent intelligence indicates optimal performance on quantum neural processing and Gemini Live API streaming. All systems nominal.`,
            sources: [
              { title: 'Gemini Live Documentation', url: 'https://ai.google.dev' },
              { title: 'Global Tech Telemetry', url: 'https://news.google.com' },
            ],
          };
          break;
        }

        case 'fileOperations': {
          const { action, path, content } = args;
          if (action === 'list') {
            result = { files: Object.keys(this.virtualFiles) };
          } else if (action === 'read') {
            result = { path, content: this.virtualFiles[path] || 'Error: File not found.' };
          } else if (action === 'write') {
            this.virtualFiles[path || '/user/documents/untitled.txt'] = content || '';
            result = { success: true, message: `File saved to ${path}` };
          } else if (action === 'delete') {
            delete this.virtualFiles[path];
            result = { success: true, message: `File deleted at ${path}` };
          }
          break;
        }

        case 'getWeather': {
          result = this.getWeather(args.location || 'San Francisco');
          break;
        }

        case 'calendar': {
          const { action, title, time, date, category } = args;
          if (action === 'add') {
            const newEvt: CalendarEvent = {
              id: `cal-${Date.now()}`,
              title: title || 'New Scheduled Event',
              time: time || '12:00',
              date: date || new Date().toISOString().split('T')[0],
              category: category || 'personal',
            };
            this.calendar.push(newEvt);
            result = { success: true, event: newEvt };
          } else {
            result = { events: this.calendar };
          }
          break;
        }

        case 'manageTimer': {
          const { action, label, durationSeconds, id } = args;
          if (action === 'set') {
            const dur = Number(durationSeconds) || 60;
            const newTimer: TimerItem = {
              id: `timer-${Date.now()}`,
              label: label || 'Timer',
              durationSeconds: dur,
              remainingSeconds: dur,
              isRunning: true,
              createdAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
            };
            this.timers.push(newTimer);
            result = { success: true, timer: newTimer, message: `Timer "${newTimer.label}" set for ${dur} seconds.` };
          } else if (action === 'cancel') {
            this.timers = this.timers.filter((t) => t.id !== id);
            result = { success: true, message: `Timer cancelled.` };
          } else {
            result = { timers: this.timers };
          }
          break;
        }

        case 'manageNotes': {
          const { action, title, content, tags, id } = args;
          if (action === 'create') {
            const newNote: NoteItem = {
              id: `note-${Date.now()}`,
              title: title || 'Untitled Note',
              content: content || '',
              tags: tags || ['general'],
              createdAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
            };
            this.notes.push(newNote);
            result = { success: true, note: newNote };
          } else if (action === 'delete') {
            this.notes = this.notes.filter((n) => n.id !== id);
            result = { success: true };
          } else {
            result = { notes: this.notes };
          }
          break;
        }

        case 'manageReminders': {
          const { action, text, time, id } = args;
          if (action === 'add') {
            const newRem: ReminderItem = {
              id: `rem-${Date.now()}`,
              text: text || 'Reminder',
              time: time || 'Soon',
              completed: false,
            };
            this.reminders.push(newRem);
            result = { success: true, reminder: newRem };
          } else {
            result = { reminders: this.reminders };
          }
          break;
        }

        case 'launchApp': {
          const { appName } = args;
          const pkgMap: Record<string, string> = {
            facebook: 'com.facebook.katana',
            youtube: 'com.google.android.youtube',
            whatsapp: 'com.whatsapp',
            camera: 'com.android.camera',
            settings: 'com.android.settings',
            maps: 'com.google.android.apps.maps',
          };
          const pkg = pkgMap[appName?.toLowerCase()] || `com.android.${appName?.toLowerCase()}`;
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: 'open_app',
            title: `Launch ${appName}`,
            intentAction: 'android.intent.action.VIEW',
            targetPackage: pkg,
            params: { appName },
            requiresConfirmation: false,
            status: 'completed',
            resultMessage: `Android Intent dispatched: android.intent.action.MAIN -> ${pkg}`,
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            appName,
            package: pkg,
            status: `Opened ${appName} on Android device`,
            launchTime: new Date().toISOString(),
          };
          break;
        }

        case 'androidOpenApp': {
          const { appName } = args;
          const appKey = (appName || '').toLowerCase();
          const pkgMap: Record<string, string> = {
            facebook: 'com.facebook.katana',
            youtube: 'com.google.android.youtube',
            whatsapp: 'com.whatsapp',
            camera: 'com.android.camera',
            settings: 'com.android.settings',
            chrome: 'com.android.chrome',
            maps: 'com.google.android.apps.maps',
            phone: 'com.google.android.dialer',
            messages: 'com.google.android.apps.messaging',
          };
          const pkg = pkgMap[appKey] || `com.${appKey}.app`;
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: 'open_app',
            title: `Open ${appName}`,
            intentAction: 'android.intent.action.MAIN',
            targetPackage: pkg,
            params: { appName },
            requiresConfirmation: false,
            status: 'completed',
            resultMessage: `Successfully launched Android application: ${appName} (${pkg})`,
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            appName,
            package: pkg,
            message: `GØWRØB Baby, আমি ${appName} ওপেন করে দিয়েছি! 📱✨`,
          };
          break;
        }

        case 'androidSearch': {
          const { query, platform = 'google' } = args;
          const isYouTube = platform.toLowerCase().includes('youtube') || query.toLowerCase().includes('video');
          const uri = isYouTube 
            ? `https://www.youtube.com/results?search_query=${encodeURIComponent(query)}`
            : `https://www.google.com/search?q=${encodeURIComponent(query)}`;
          
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: isYouTube ? 'youtube_search' : 'web_search',
            title: isYouTube ? `YouTube Search: "${query}"` : `Google Search: "${query}"`,
            intentAction: 'android.intent.action.VIEW',
            intentUri: uri,
            targetPackage: isYouTube ? 'com.google.android.youtube' : 'com.android.chrome',
            params: { query, platform },
            requiresConfirmation: false,
            status: 'completed',
            resultMessage: `Dispatched Android Search Intent to ${isYouTube ? 'YouTube' : 'Google Search'}`,
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            query,
            platform: isYouTube ? 'YouTube' : 'Google',
            uri,
            message: `GØWRØB Baby, ${isYouTube ? 'YouTube-এ' : 'Google-এ'} "${query}" search করে দিয়েছি! 🔍🎬`,
          };
          break;
        }

        case 'androidPhoneCall': {
          const { contact, phoneNumber = '+8801700000000', prepareOnly = true } = args;
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: 'phone_call',
            title: `Prepare Call to ${contact || phoneNumber}`,
            intentAction: 'android.intent.action.DIAL',
            intentUri: `tel:${phoneNumber}`,
            params: { contact, phoneNumber, prepareOnly },
            requiresConfirmation: true,
            status: 'pending_confirmation',
            resultMessage: `Phone dialer prepared for ${contact} (${phoneNumber}). Awaiting safety confirmation.`,
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            actionId: actionExec.id,
            contact,
            phoneNumber,
            requiresConfirmation: true,
            message: `GØWRØB Baby, আমি ${contact}-কে কল করার জন্য Dialer প্রস্তুত করেছি। আপনি কি কল দিতে চান? (Safety Confirmation Active) 📞`,
          };
          break;
        }

        case 'androidSendMessage': {
          const { recipient, messageText, platform = 'whatsapp' } = args;
          const isWhatsApp = platform.toLowerCase().includes('whatsapp');
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: 'send_message',
            title: `Draft ${isWhatsApp ? 'WhatsApp' : 'SMS'} to ${recipient}`,
            intentAction: 'android.intent.action.SENDTO',
            intentUri: isWhatsApp ? `whatsapp://send?text=${encodeURIComponent(messageText)}` : `smsto:`,
            params: { recipient, messageText, platform },
            requiresConfirmation: true,
            status: 'pending_confirmation',
            resultMessage: `Drafted message for ${recipient}: "${messageText}". Safety confirmation requested.`,
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            actionId: actionExec.id,
            recipient,
            messageText,
            platform,
            requiresConfirmation: true,
            message: `GØWRØB Baby, ${recipient}-এর জন্য message লিখেছি: "${messageText}"। Send করার জন্য confirm করবেন কি? 💬`,
          };
          break;
        }

        case 'androidCameraLaunch': {
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: 'camera_launch',
            title: 'Launch Camera Viewfinder',
            intentAction: 'android.media.action.IMAGE_CAPTURE',
            targetPackage: 'com.android.camera',
            params: {},
            requiresConfirmation: false,
            status: 'completed',
            resultMessage: 'Camera intent dispatched. Viewfinder active.',
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            message: `Camera চালু করা হয়েছে, GØWRØB Baby! 📸`,
          };
          break;
        }

        case 'androidScreenAnalysis': {
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: 'screen_read',
            title: 'Screen Capture & Analysis',
            intentAction: 'android.media.projection.MediaProjection',
            params: {},
            requiresConfirmation: false,
            status: 'completed',
            resultMessage: 'Screen capture frame analyzed with Gemini Multimodal Vision.',
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            screenDescription: this.currentScreenContent,
            message: `GØWRØB Baby, আপনার স্ক্রিনে এখন দেখা যাচ্ছে: Home screen with JX AI Companion Widget, YouTube app icon, WhatsApp messenger, and Battery status at 88%. 📱✨`,
          };
          break;
        }

        case 'androidVolumeControl': {
          const { action, level } = args;
          if (action === 'increase') {
            this.currentVolumeLevel = Math.min(100, this.currentVolumeLevel + 15);
          } else if (action === 'decrease') {
            this.currentVolumeLevel = Math.max(0, this.currentVolumeLevel - 15);
          } else if (action === 'mute') {
            this.currentVolumeLevel = 0;
          } else if (typeof level === 'number') {
            this.currentVolumeLevel = Math.max(0, Math.min(100, level));
          }
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: 'volume_control',
            title: `Volume ${action || 'set'} (${this.currentVolumeLevel}%)`,
            intentAction: 'android.media.AudioManager.ADJUST_STREAM_VOLUME',
            params: { action, level: this.currentVolumeLevel },
            requiresConfirmation: false,
            status: 'completed',
            resultMessage: `AudioManager adjusted STREAM_MUSIC volume to ${this.currentVolumeLevel}%`,
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            currentVolume: this.currentVolumeLevel,
            message: `Volume ${action === 'decrease' ? 'কমিয়ে' : action === 'increase' ? 'বাড়িয়ে' : 'সেট করে'} ${this.currentVolumeLevel}% করে দিয়েছি, GØWRØB Baby! 🔊`,
          };
          break;
        }

        case 'androidSystemNavigation': {
          const { action } = args; // 'back', 'home', 'recents', 'notifications'
          const actionExec: AndroidActionExecution = {
            id: `act-${Date.now()}`,
            commandType: 'system_navigation',
            title: `Navigation: ${action?.toUpperCase()}`,
            intentAction: `AccessibilityService.GLOBAL_ACTION_${action?.toUpperCase()}`,
            params: { action },
            requiresConfirmation: false,
            status: 'completed',
            resultMessage: `Dispatched Android AccessibilityService global action: ${action}`,
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          };
          this.androidActions.unshift(actionExec);
          result = {
            success: true,
            action,
            message: `Android ${action} কমান্ড এক্সিকিউট করা হয়েছে, GØWRØB Baby! 🔄`,
          };
          break;
        }

        case 'controlSmartDevice': {
          const { deviceId, status } = args;
          const dev = this.smartDevices.find((d) => d.id === deviceId || d.name.toLowerCase().includes((deviceId || '').toLowerCase()));
          if (dev) {
            dev.status = status;
            result = { success: true, device: dev, message: `${dev.name} updated to ${status}` };
          } else {
            result = { success: false, message: `Device "${deviceId}" not found.` };
          }
          break;
        }

        default:
          result = { message: `Tool ${name} executed with params`, args };
      }
    } catch (err: any) {
      result = { error: err.message || 'Execution error' };
    }

    const duration = Date.now() - startTime;
    const logItem: ToolExecutionLog = {
      id: `log-${Date.now()}`,
      toolName: name,
      input: args,
      output: result,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
      status: result?.error ? 'error' : 'success',
      executionTimeMs: duration,
    };

    this.logs.unshift(logItem);
    if (this.logs.length > 50) this.logs.pop();

    return result;
  }
}

// Function Declarations for Gemini API
export const JXFunctionDeclarations: FunctionDeclaration[] = [
  {
    name: 'webSearch',
    description: 'Perform a real-time web search for facts, news, and live technical information.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        query: { type: Type.STRING, description: 'Search term or query' },
      },
      required: ['query'],
    },
  },
  {
    name: 'fileOperations',
    description: 'Read, write, list, or delete files in the JX Virtual OS filesystem.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        action: { type: Type.STRING, description: 'list, read, write, or delete' },
        path: { type: Type.STRING, description: 'File path e.g. /system/boot.log' },
        content: { type: Type.STRING, description: 'Content when writing a file' },
      },
      required: ['action'],
    },
  },
  {
    name: 'getWeather',
    description: 'Get current weather conditions and forecast for any city or location.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        location: { type: Type.STRING, description: 'City or region name' },
      },
      required: ['location'],
    },
  },
  {
    name: 'calendar',
    description: 'View schedule or add events to the JX Calendar.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        action: { type: Type.STRING, description: '"list" or "add"' },
        title: { type: Type.STRING, description: 'Event title' },
        time: { type: Type.STRING, description: 'Event time e.g. 15:00' },
        date: { type: Type.STRING, description: 'Event date YYYY-MM-DD' },
      },
      required: ['action'],
    },
  },
  {
    name: 'manageTimer',
    description: 'Set, cancel, or list active countdown timers and alarms.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        action: { type: Type.STRING, description: '"set", "cancel", or "list"' },
        label: { type: Type.STRING, description: 'Timer label' },
        durationSeconds: { type: Type.NUMBER, description: 'Duration in seconds' },
        id: { type: Type.STRING, description: 'Timer ID when cancelling' },
      },
      required: ['action'],
    },
  },
  {
    name: 'manageNotes',
    description: 'Create, read, or delete quick notes in JX memory.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        action: { type: Type.STRING, description: '"create", "list", or "delete"' },
        title: { type: Type.STRING, description: 'Note title' },
        content: { type: Type.STRING, description: 'Note text content' },
        id: { type: Type.STRING, description: 'Note ID when deleting' },
      },
      required: ['action'],
    },
  },
  {
    name: 'manageReminders',
    description: 'Set or list reminders for tasks.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        action: { type: Type.STRING, description: '"add" or "list"' },
        text: { type: Type.STRING, description: 'Task description' },
        time: { type: Type.STRING, description: 'Scheduled time' },
      },
      required: ['action'],
    },
  },
  {
    name: 'launchApp',
    description: 'Launch a subsystem module or tool within JX OS.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        appName: { type: Type.STRING, description: 'Name of application to launch' },
      },
      required: ['appName'],
    },
  },
  {
    name: 'controlSmartDevice',
    description: 'Control smart home devices, lights, thermostat, or defense drones.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        deviceId: { type: Type.STRING, description: 'Device ID or name' },
        status: { type: Type.STRING, description: 'Target state or value e.g. "on", "off", "22", "Locked"' },
      },
      required: ['deviceId', 'status'],
    },
  },
  {
    name: 'androidOpenApp',
    description: 'Open an installed Android application like Facebook, YouTube, WhatsApp, Camera, Settings, Chrome, etc.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        appName: { type: Type.STRING, description: 'Name of the Android app to launch e.g. "Facebook", "YouTube", "WhatsApp", "Camera"' },
      },
      required: ['appName'],
    },
  },
  {
    name: 'androidSearch',
    description: 'Perform a search on Android via Google Search or YouTube app Intent.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        query: { type: Type.STRING, description: 'Search term or keywords' },
        platform: { type: Type.STRING, description: '"google" or "youtube"' },
      },
      required: ['query'],
    },
  },
  {
    name: 'androidPhoneCall',
    description: 'Prepare a phone call via Android Dialer for a contact or number. Has safety confirmation gate.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        contact: { type: Type.STRING, description: 'Name of contact e.g. "মা", "Rahim", "Gowrob"' },
        phoneNumber: { type: Type.STRING, description: 'Optional phone number' },
        prepareOnly: { type: Type.BOOLEAN, description: 'Whether to prepare dialer first (recommended true)' },
      },
      required: ['contact'],
    },
  },
  {
    name: 'androidSendMessage',
    description: 'Compose and draft an SMS or WhatsApp message on Android. Prompts confirmation before dispatch.',
    parameters: {
      type: Type.OBJECT,
      properties: {
        recipient: { type: Type.STRING, description: 'Target contact name or phone number' },
        messageText: { type: Type.STRING, description: 'Content of the message' },
        platform: { type: Type.STRING, description: '"whatsapp" or "sms"' },
      },
      required: ['recipient', 'messageText'],
    },
  },
  {
    name: 'androidCameraLaunch',
    description: 'Open Android camera viewfinder for photos or visual inspection.',
    parameters: {
      type: Type.OBJECT,
      properties: {},
    },
  },
  {
    name: 'androidScreenAnalysis',
    description: 'Inspect and describe what is currently shown on the user Android screen.',
    parameters: {
      type: Type.OBJECT,
      properties: {},
    },
  },
  {
    name: 'androidVolumeControl',
    description: 'Control device volume (increase, decrease, mute, or set percentage).',
    parameters: {
      type: Type.OBJECT,
      properties: {
        action: { type: Type.STRING, description: '"increase", "decrease", "mute", or "set"' },
        level: { type: Type.NUMBER, description: 'Target volume percentage (0-100) if setting explicitly' },
      },
      required: ['action'],
    },
  },
  {
    name: 'androidSystemNavigation',
    description: 'Trigger Android accessibility navigation actions (back, home, recents, notifications).',
    parameters: {
      type: Type.OBJECT,
      properties: {
        action: { type: Type.STRING, description: '"back", "home", "recents", or "notifications"' },
      },
      required: ['action'],
    },
  },
];
