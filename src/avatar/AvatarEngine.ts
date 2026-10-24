/**
 * JX Avatar Engine - Canvas 2D / Holographic / Lip-sync Renderer
 */

import { AvatarCharacter, EmotionType, AvatarModelId } from '../types';

export const AVATAR_CHARACTERS: AvatarCharacter[] = [
  {
    id: 'luna-companion',
    name: 'JX Sweet Luna',
    description: 'Sweet companion avatar with glowing rose blossom aura & audio-reactive heart pulse.',
    type: 'hologram',
    primaryColor: '#ff4d8d',
    secondaryColor: '#ff80bf',
  },
  {
    id: 'jx-core',
    name: 'JX Arc Core',
    description: 'Futuristic JARVIS holographic neural sphere with reactive energy rings.',
    type: 'hologram',
    primaryColor: '#00f0ff',
    secondaryColor: '#7000ff',
  },
  {
    id: 'aria-cyber',
    name: 'Aria Cyber',
    description: 'Cybernetic humanoid assistant with facial expressions & lip-sync.',
    type: 'sprite',
    primaryColor: '#ff00aa',
    secondaryColor: '#00f0ff',
  },
  {
    id: 'atlas-titan',
    name: 'Atlas Sentinel',
    description: 'Armored tactical defense AI with ocular pulse scanner.',
    type: 'mesh',
    primaryColor: '#ffaa00',
    secondaryColor: '#ff3300',
  },
  {
    id: 'vesper-mesh',
    name: 'Vesper Quantum',
    description: 'Abstract particle constellation matrix.',
    type: 'live2d',
    primaryColor: '#00ffaa',
    secondaryColor: '#0088ff',
  },
];

export class AvatarRenderer {
  private canvas: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D;
  private animationFrameId: number | null = null;
  private currentCharacter: AvatarCharacter = AVATAR_CHARACTERS[0];
  private currentEmotion: EmotionType = 'neutral';

  private angle: number = 0;
  private audioVolume: number = 0; // 0 to 1 for lip-sync
  private audioFrequencies: Uint8Array = new Uint8Array(0);
  private blinkState: number = 1; // 1 = open, 0 = closed
  private blinkTimer: number = 0;

  constructor(canvas: HTMLCanvasElement) {
    this.canvas = canvas;
    const context = canvas.getContext('2d');
    if (!context) throw new Error('Could not get 2D canvas context');
    this.ctx = context;
  }

  public setCharacter(charId: AvatarModelId) {
    const found = AVATAR_CHARACTERS.find((c) => c.id === charId);
    if (found) {
      this.currentCharacter = found;
    }
  }

  public setEmotion(emotion: EmotionType) {
    this.currentEmotion = emotion;
  }

  public updateAudioData(volume: number, frequencies?: Uint8Array) {
    this.audioVolume = Math.min(Math.max(volume, 0), 1);
    if (frequencies) {
      this.audioFrequencies = frequencies;
    }
  }

  public start() {
    this.stop();
    const render = () => {
      this.drawFrame();
      this.animationFrameId = requestAnimationFrame(render);
    };
    render();
  }

  public stop() {
    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = null;
    }
  }

  private drawFrame() {
    const width = this.canvas.width;
    const height = this.canvas.height;
    if (width === 0 || height === 0) return;

    this.ctx.clearRect(0, 0, width, height);

    this.angle += 0.02;

    // Handle blinking logic
    this.blinkTimer += 0.02;
    if (this.blinkTimer > 4.0) {
      this.blinkState = Math.max(0, 1 - (this.blinkTimer - 4.0) * 10);
      if (this.blinkTimer > 4.2) {
        this.blinkTimer = 0;
        this.blinkState = 1;
      }
    }

    const centerX = width / 2;
    const centerY = height / 2;

    switch (this.currentCharacter.id) {
      case 'luna-companion':
        this.drawLunaCompanion(centerX, centerY, width, height);
        break;
      case 'jx-core':
        this.drawJXArcCore(centerX, centerY, width, height);
        break;
      case 'aria-cyber':
        this.drawAriaSprite(centerX, centerY, width, height);
        break;
      case 'atlas-titan':
        this.drawAtlasSentinel(centerX, centerY, width, height);
        break;
      case 'vesper-mesh':
        this.drawVesperMatrix(centerX, centerY, width, height);
        break;
      default:
        this.drawJXArcCore(centerX, centerY, width, height);
    }
  }

  // JX Sweet Luna - Warm Rose Companion Sphere with Glowing Heart Orbit
  private drawLunaCompanion(cx: number, cy: number, w: number, h: number) {
    const ctx = this.ctx;
    const baseRadius = Math.min(w, h) * 0.22;
    const pulse = Math.sin(this.angle * 2.5) * 8 + this.audioVolume * 28;

    // Outer warm rose radial glow
    const grad = ctx.createRadialGradient(cx, cy, baseRadius * 0.1, cx, cy, baseRadius * 2.2);
    const colorPrimary = this.getEmotionColor('#ff4d8d');
    grad.addColorStop(0, `${colorPrimary}cc`);
    grad.addColorStop(0.4, '#ff80bf66');
    grad.addColorStop(1, 'transparent');

    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(cx, cy, baseRadius * 2.2 + pulse, 0, Math.PI * 2);
    ctx.fill();

    // Orbital Heart-Like Ring 1
    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(this.angle * 0.8);
    ctx.strokeStyle = colorPrimary;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(0, 0, baseRadius * 1.1 + pulse * 0.4, 0, Math.PI * 2);
    ctx.stroke();

    // Orbiting Sparkle Dots
    for (let i = 0; i < 6; i++) {
      const a = (Math.PI / 3) * i + this.angle;
      const nx = Math.cos(a) * (baseRadius * 1.1 + pulse * 0.4);
      const ny = Math.sin(a) * (baseRadius * 1.1 + pulse * 0.4);
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(nx, ny, 3.5, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.restore();

    // Counter Orbiting Ring 2
    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(-this.angle * 1.2);
    ctx.strokeStyle = '#ffb3d9';
    ctx.lineWidth = 2;
    ctx.setLineDash([6, 10]);
    ctx.beginPath();
    ctx.arc(0, 0, baseRadius * 1.4 + pulse * 0.6, 0, Math.PI * 2);
    ctx.stroke();
    ctx.restore();

    // Center Core Pulse (Reactive to Voice)
    ctx.save();
    ctx.fillStyle = colorPrimary;
    ctx.beginPath();
    ctx.arc(cx, cy, baseRadius * 0.5 + this.audioVolume * 24, 0, Math.PI * 2);
    ctx.fill();

    // Soft highlight
    ctx.fillStyle = '#ffffff';
    ctx.beginPath();
    ctx.arc(cx - baseRadius * 0.12, cy - baseRadius * 0.12, baseRadius * 0.15, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  // JX Core - Holographic JARVIS Arc Sphere
  private drawJXArcCore(cx: number, cy: number, w: number, h: number) {
    const ctx = this.ctx;
    const baseRadius = Math.min(w, h) * 0.22;
    const pulse = Math.sin(this.angle * 2) * 6 + this.audioVolume * 25;

    // Outer glow
    const grad = ctx.createRadialGradient(cx, cy, baseRadius * 0.2, cx, cy, baseRadius * 2);
    const colorPrimary = this.getEmotionColor(this.currentCharacter.primaryColor);
    grad.addColorStop(0, `${colorPrimary}aa`);
    grad.addColorStop(0.5, `${this.currentCharacter.secondaryColor}44`);
    grad.addColorStop(1, 'transparent');

    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(cx, cy, baseRadius * 2 + pulse, 0, Math.PI * 2);
    ctx.fill();

    // Rotating Ring 1
    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(this.angle);
    ctx.strokeStyle = colorPrimary;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(0, 0, baseRadius + pulse * 0.5, 0, Math.PI * 1.5);
    ctx.stroke();

    // Inner Nodes
    for (let i = 0; i < 4; i++) {
      const a = (Math.PI / 2) * i;
      const nx = Math.cos(a) * (baseRadius + pulse * 0.5);
      const ny = Math.sin(a) * (baseRadius + pulse * 0.5);
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(nx, ny, 4, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.restore();

    // Rotating Ring 2 (counter)
    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(-this.angle * 1.5);
    ctx.strokeStyle = this.currentCharacter.secondaryColor;
    ctx.lineWidth = 2;
    ctx.setLineDash([8, 12]);
    ctx.beginPath();
    ctx.arc(0, 0, baseRadius * 1.35 + pulse * 0.8, 0, Math.PI * 2);
    ctx.stroke();
    ctx.restore();

    // Central Core Pulse (Lip-sync & Voice reactivity)
    ctx.save();
    ctx.fillStyle = colorPrimary;
    ctx.beginPath();
    ctx.arc(cx, cy, baseRadius * 0.45 + this.audioVolume * 22, 0, Math.PI * 2);
    ctx.fill();

    // Core Highlight
    ctx.fillStyle = '#ffffff';
    ctx.beginPath();
    ctx.arc(cx - baseRadius * 0.1, cy - baseRadius * 0.1, baseRadius * 0.15, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  // Aria - Cyber Humanoid Vector Avatar with Lip-sync mouth & Eyes
  private drawAriaSprite(cx: number, cy: number, w: number, h: number) {
    const ctx = this.ctx;
    const scale = Math.min(w, h) * 0.0035;
    const breathY = Math.sin(this.angle * 1.5) * 4;

    ctx.save();
    ctx.translate(cx, cy + breathY);

    // Head Base
    ctx.fillStyle = '#111827';
    ctx.strokeStyle = '#ff00aa';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.ellipse(0, -20 * scale, 50 * scale, 65 * scale, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Hair / Cyber Crest
    ctx.fillStyle = '#ff00aa88';
    ctx.beginPath();
    ctx.moveTo(-55 * scale, -40 * scale);
    ctx.lineTo(0, -95 * scale);
    ctx.lineTo(55 * scale, -40 * scale);
    ctx.closePath();
    ctx.fill();

    // Eyes
    const eyeY = -30 * scale;
    const eyeDist = 20 * scale;
    const eyeHeight = 12 * scale * this.blinkState;

    // Left Eye
    ctx.fillStyle = '#00f0ff';
    ctx.beginPath();
    ctx.ellipse(-eyeDist, eyeY, 10 * scale, Math.max(1, eyeHeight), 0, 0, Math.PI * 2);
    ctx.fill();

    // Right Eye
    ctx.beginPath();
    ctx.ellipse(eyeDist, eyeY, 10 * scale, Math.max(1, eyeHeight), 0, 0, Math.PI * 2);
    ctx.fill();

    // Lip-sync Mouth Movement
    const mouthY = 10 * scale;
    const mouthWidth = 16 * scale;
    const mouthOpen = 2 * scale + this.audioVolume * 24 * scale;

    ctx.fillStyle = '#ff00aa';
    ctx.beginPath();
    ctx.ellipse(0, mouthY, mouthWidth, mouthOpen, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = '#ffffff';
    ctx.stroke();

    // Cyber Visor / Audio Spectrum HUD Overlay
    ctx.strokeStyle = '#00f0ff';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(-45 * scale, -10 * scale);
    ctx.lineTo(45 * scale, -10 * scale);
    ctx.stroke();

    ctx.restore();
  }

  // Atlas - Armor Sentinel AI
  private drawAtlasSentinel(cx: number, cy: number, w: number, h: number) {
    const ctx = this.ctx;
    const scale = Math.min(w, h) * 0.0035;

    ctx.save();
    ctx.translate(cx, cy);

    // Armor Shield Hexagon
    ctx.fillStyle = '#0f172a';
    ctx.strokeStyle = '#ffaa00';
    ctx.lineWidth = 4;
    ctx.beginPath();
    const radius = 70 * scale;
    for (let i = 0; i < 6; i++) {
      const a = (Math.PI / 3) * i + this.angle * 0.2;
      const x = Math.cos(a) * radius;
      const y = Math.sin(a) * radius;
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Tactical Eye Scanner Beam
    const eyePulse = 10 * scale + this.audioVolume * 20 * scale;
    ctx.fillStyle = '#ff3300';
    ctx.beginPath();
    ctx.arc(0, 0, eyePulse, 0, Math.PI * 2);
    ctx.fill();

    // Crosshair target
    ctx.strokeStyle = '#ffffff88';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(-80 * scale, 0);
    ctx.lineTo(80 * scale, 0);
    ctx.moveTo(0, -80 * scale);
    ctx.lineTo(0, 80 * scale);
    ctx.stroke();

    ctx.restore();
  }

  // Vesper - Quantum Mesh
  private drawVesperMatrix(cx: number, cy: number, w: number, h: number) {
    const ctx = this.ctx;
    const count = 30;
    const radius = Math.min(w, h) * 0.25;

    ctx.save();
    ctx.translate(cx, cy);

    for (let i = 0; i < count; i++) {
      const a = (Math.PI * 2 / count) * i + this.angle;
      const dist = radius + Math.sin(this.angle * 3 + i) * 15 + this.audioVolume * 30;
      const x = Math.cos(a) * dist;
      const y = Math.sin(a) * dist;

      ctx.fillStyle = i % 2 === 0 ? '#00ffaa' : '#0088ff';
      ctx.beginPath();
      ctx.arc(x, y, 4 + (i % 3), 0, Math.PI * 2);
      ctx.fill();

      // Connect to neighbors
      const nextA = (Math.PI * 2 / count) * ((i + 1) % count) + this.angle;
      const nextX = Math.cos(nextA) * dist;
      const nextY = Math.sin(nextA) * dist;
      ctx.strokeStyle = '#00ffaa33';
      ctx.beginPath();
      ctx.moveTo(x, y);
      ctx.lineTo(nextX, nextY);
      ctx.stroke();
    }

    ctx.restore();
  }

  private getEmotionColor(defaultColor: string): string {
    switch (this.currentEmotion) {
      case 'processing': return '#3b82f6';
      case 'speaking': return '#00f0ff';
      case 'listening': return '#10b981';
      case 'happy': return '#f59e0b';
      case 'alert': return '#ef4444';
      case 'focused': return '#8b5cf6';
      default: return defaultColor;
    }
  }
}
