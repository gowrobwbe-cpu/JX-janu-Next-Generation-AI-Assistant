/**
 * JX Web Audio Engine: 16kHz PCM Mic Recording & 24kHz PCM Streaming Playback with FFT Analyser
 */

export class AudioEngine {
  private inputAudioCtx: AudioContext | null = null;
  private outputAudioCtx: AudioContext | null = null;
  private mediaStream: MediaStream | null = null;
  private scriptProcessor: ScriptProcessorNode | null = null;

  private outputAnalyser: AnalyserNode | null = null;
  private inputAnalyser: AnalyserNode | null = null;

  private nextStartTime: number = 0;
  private activeSources: AudioBufferSourceNode[] = [];

  private isRecording: boolean = false;
  private onAudioChunkCallback: ((base64Pcm: string) => void) | null = null;

  // Initialize contexts
  public async init() {
    if (!this.outputAudioCtx) {
      // 24kHz sample rate for Gemini Live output
      const AudioCtxClass = window.AudioContext || (window as any).webkitAudioContext;
      this.outputAudioCtx = new AudioCtxClass({ sampleRate: 24000 });
      this.outputAnalyser = this.outputAudioCtx.createAnalyser();
      this.outputAnalyser.fftSize = 64;
      this.outputAnalyser.connect(this.outputAudioCtx.destination);
    }

    if (this.outputAudioCtx.state === 'suspended') {
      await this.outputAudioCtx.resume();
    }
  }

  // Start Mic Capture (16kHz PCM)
  public async startMicrophone(onChunk: (base64Pcm: string) => void) {
    await this.init();
    this.onAudioChunkCallback = onChunk;

    const AudioCtxClass = window.AudioContext || (window as any).webkitAudioContext;
    this.inputAudioCtx = new AudioCtxClass({ sampleRate: 16000 });
    if (this.inputAudioCtx.state === 'suspended') {
      await this.inputAudioCtx.resume();
    }

    this.mediaStream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const source = this.inputAudioCtx.createMediaStreamSource(this.mediaStream);

    this.inputAnalyser = this.inputAudioCtx.createAnalyser();
    this.inputAnalyser.fftSize = 64;
    source.connect(this.inputAnalyser);

    this.scriptProcessor = this.inputAudioCtx.createScriptProcessor(4096, 1, 1);
    this.inputAnalyser.connect(this.scriptProcessor);
    this.scriptProcessor.connect(this.inputAudioCtx.destination);

    this.scriptProcessor.onaudioprocess = (e) => {
      if (!this.isRecording) return;
      const inputData = e.inputBuffer.getChannelData(0);
      const base64Pcm = this.float32ToInt16Base64(inputData);
      if (this.onAudioChunkCallback && base64Pcm) {
        this.onAudioChunkCallback(base64Pcm);
      }
    };

    this.isRecording = true;
  }

  // Stop Microphone Recording
  public stopMicrophone() {
    this.isRecording = false;
    if (this.mediaStream) {
      this.mediaStream.getTracks().forEach((track) => track.stop());
      this.mediaStream = null;
    }
    if (this.scriptProcessor) {
      this.scriptProcessor.disconnect();
      this.scriptProcessor = null;
    }
    if (this.inputAudioCtx) {
      this.inputAudioCtx.close();
      this.inputAudioCtx = null;
    }
  }

  // Play PCM 24kHz audio chunk received from server
  public playAudioChunk(base64Pcm: string) {
    if (!this.outputAudioCtx) return;

    try {
      const pcmData = this.base64ToInt16Array(base64Pcm);
      const float32Data = new Float32Array(pcmData.length);
      for (let i = 0; i < pcmData.length; i++) {
        float32Data[i] = pcmData[i] / 32768.0;
      }

      const buffer = this.outputAudioCtx.createBuffer(1, float32Data.length, 24000);
      buffer.getChannelData(0).set(float32Data);

      const source = this.outputAudioCtx.createBufferSource();
      source.buffer = buffer;

      if (this.outputAnalyser) {
        source.connect(this.outputAnalyser);
      } else {
        source.connect(this.outputAudioCtx.destination);
      }

      const currentTime = this.outputAudioCtx.currentTime;
      if (this.nextStartTime < currentTime) {
        this.nextStartTime = currentTime + 0.05; // small buffer padding
      }

      source.start(this.nextStartTime);
      this.nextStartTime += buffer.duration;

      this.activeSources.push(source);
      source.onended = () => {
        const idx = this.activeSources.indexOf(source);
        if (idx !== -1) this.activeSources.splice(idx, 1);
      };
    } catch (err) {
      console.error('Error playing PCM chunk:', err);
    }
  }

  // Stop playback / Barge-in support
  public stopPlayback() {
    this.activeSources.forEach((source) => {
      try {
        source.stop();
      } catch (e) {}
    });
    this.activeSources = [];
    if (this.outputAudioCtx) {
      this.nextStartTime = this.outputAudioCtx.currentTime;
    }
  }

  // Get current volume & FFT frequencies for visualizer
  public getAudioVolumeAndFFT(type: 'output' | 'input' = 'output'): { volume: number; frequencies: Uint8Array } {
    const analyser = type === 'output' ? this.outputAnalyser : this.inputAnalyser;
    if (!analyser) return { volume: 0, frequencies: new Uint8Array(0) };

    const dataArray = new Uint8Array(analyser.frequencyBinCount);
    analyser.getByteFrequencyData(dataArray);

    let sum = 0;
    for (let i = 0; i < dataArray.length; i++) {
      sum += dataArray[i];
    }
    const volume = sum / (dataArray.length * 255);

    return { volume, frequencies: dataArray };
  }

  // Convert Float32Array to PCM 16-bit little endian base64
  private float32ToInt16Base64(float32Array: Float32Array): string {
    const buffer = new ArrayBuffer(float32Array.length * 2);
    const view = new DataView(buffer);
    for (let i = 0; i < float32Array.length; i++) {
      const s = Math.max(-1, Math.min(1, float32Array[i]));
      view.setInt16(i * 2, s < 0 ? s * 0x8000 : s * 0x7fff, true);
    }
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }

  // Convert Base64 back to Int16Array
  private base64ToInt16Array(base64: string): Int16Array {
    const binary = atob(base64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return new Int16Array(bytes.buffer);
  }
}

export const globalAudioEngine = new AudioEngine();
