<template>
  <main class="call-practice-page">
    <section class="practice-intro" aria-labelledby="practice-title">
      <p class="eyebrow">{{ tCall('intro.eyebrow') }}</p>

      <h1 id="practice-title">
        {{ tCall('intro.title') }}
      </h1>
      <p class="intro-copy">
        {{ tCall('intro.description') }}
      </p>
      <div class="privacy-strip">
        <span class="privacy-icon" aria-hidden="true">◆</span>
        <p>{{ tCall('privacy.notice') }}</p>
      </div>
    </section>

    <section class="practice-workspace" :aria-label="tCall('workspaceLabel')">
      <div class="call-card">
        <div class="call-card-topline">
          <span :class="['connection-dot', connectionState]"></span>
          <span aria-live="polite">{{ connectionLabel }}</span>
          <span v-if="connectionState === 'connected'" class="session-note">
            {{ tCall('connection.live') }}
          </span>
        </div>

        <template v-if="connectionState === 'idle' || connectionState === 'error'">
          <div class="welcome-state">
            <div class="phone-illustration" aria-hidden="true">
              <svg viewBox="0 0 120 120" role="img">
                <circle cx="60" cy="60" r="58" fill="#f8e5e7" />
                <path
                  d="M40 31c4-4 11-3 14 2l7 13c2 4 1 9-3 12l-6 5c5 10 13 18 23 23l5-6c3-4 8-5 12-3l13 7c5 3 6 10 2 14l-7 7c-5 5-13 7-20 4-17-7-31-18-43-32S17 50 24 38c3-5 10-8 16-7Z"
                  fill="#aa5264"
                />
              </svg>
            </div>
            <h2>{{ tCall('welcome.title') }}</h2>

            <p>{{ tCall('welcome.description') }}</p>

            <ul class="before-list">
              <li>
                <span aria-hidden="true">1</span>
                {{ tCall('welcome.steps.0') }}
              </li>
              <li>
                <span aria-hidden="true">2</span>
                {{ tCall('welcome.steps.1') }}
              </li>
              <li>
                <span aria-hidden="true">3</span>
                {{ tCall('welcome.steps.2') }}
              </li>
            </ul>

            <p v-if="errorMessage" class="error-message" role="alert">{{ errorMessage }}</p>

            <button class="primary-action" type="button" @click="startCall">
              {{ tCall('welcome.start') }}
              <span aria-hidden="true">→</span>
            </button>

            <p class="browser-note">
              {{ tCall('welcome.browserNote') }}
            </p>
          </div>
        </template>

        <template v-else-if="connectionState === 'complete' && summary">
          <div class="complete-state">
            <span class="complete-mark" aria-hidden="true">✓</span>
            <p class="eyebrow">
              {{ tCall('complete.eyebrow') }}
            </p>
            <h2>{{ tCall('complete.title') }}</h2>
            <p>{{ tCall('complete.description') }}</p>

            <div class="complete-actions">
              <button class="primary-action" type="button" @click="downloadSummary">
                {{ tCall('complete.download') }}
              </button>
              <button class="secondary-action" type="button" @click="resetPractice">
                {{ tCall('complete.restart') }}
              </button>
            </div>
          </div>
        </template>

        <template v-else>
          <div class="live-call">
            <div :class="['voice-orb', { speaking: assistantSpeaking, listening: microphoneOpen }]">
              <span class="orb-core">L</span>
              <span class="orb-ring orb-ring-one"></span>
              <span class="orb-ring orb-ring-two"></span>
            </div>

            <p class="speaker-name">{{ speakerLabel }}</p>
            <h2>{{ callPrompt }}</h2>
            <p class="call-help">{{ callHelp }}</p>

            <div class="audio-state" aria-live="polite">
              <span class="audio-bars" aria-hidden="true"> <i></i><i></i><i></i><i></i> </span>
              {{ audioStatus }}
            </div>

            <div v-if="progress.total > 0" class="progress-block">
              <div class="progress-copy">
                <span>{{ tCall('live.questions') }}</span>
                <strong>{{ progress.answered }} of {{ progress.total }}</strong>
              </div>
              <div
                class="progress-track"
                role="progressbar"
                :aria-valuenow="progress.answered"
                aria-valuemin="0"
                :aria-valuemax="progress.total"
              >
                <span :style="{ width: progressPercentage }"></span>
              </div>
            </div>

            <div class="call-controls">
              <button
                class="finish-button"
                type="button"
                :disabled="connectionState !== 'connected'"
                @click="finishCall"
              >
                {{ tCall('live.finish') }}
              </button>
              <button class="leave-button" type="button" @click="leaveCall">
                {{ tCall('live.leave') }}
              </button>
            </div>
          </div>
        </template>
      </div>

      <aside class="transcript-card" aria-labelledby="transcript-title">
        <div class="transcript-heading">
          <div>
            <p class="eyebrow">{{ tCall('transcript.eyebrow') }}</p>
            <h2 id="transcript-title">
              {{ tCall('transcript.title') }}
            </h2>
          </div>
          <span class="not-saved-badge"> {{ tCall('transcript.notSaved') }} </span>
        </div>

        <div ref="transcriptPanel" class="transcript-panel" aria-live="polite">
          <div v-if="!hasTranscript" class="empty-transcript">
            <span aria-hidden="true">“</span>
            <p>{{ tCall('transcript.empty') }}</p>
          </div>

          <template v-for="(turn, index) in turns" :key="`${index}-${turn.assistant}`">
            <div v-if="turn.user" class="message user-message">
              <span>{{ tCall('transcript.you') }}</span>
              <p>{{ turn.user }}</p>
            </div>

            <div v-if="turn.assistant" class="message assistant-message">
              <span>{{ turn.speaker }}</span>
              <p>{{ turn.assistant }}</p>
            </div>
          </template>

          <div v-if="liveUserTranscript" class="message user-message partial-message">
            <span>{{ tCall('transcript.listening') }}</span>
            <p>{{ liveUserTranscript }}</p>
          </div>
          <div v-if="liveAssistantTranscript" class="message assistant-message partial-message">
            <span>
              {{ tCall('transcript.speaking', { speaker: speakerLabel }) }}
            </span>
            <p>{{ liveAssistantTranscript }}</p>
          </div>
        </div>
      </aside>
    </section>

    <section v-if="summary" class="summary-card" aria-labelledby="summary-title">
      <div class="summary-heading">
        <div>
          <p class="eyebrow">{{ tCall('summary.eyebrow') }}</p>
          <h2 id="summary-title">{{ tCall('summary.title') }}</h2>
        </div>

        <button class="summary-download" type="button" @click="downloadSummary">
          {{ tCall('summary.download') }}
        </button>
      </div>

      <div class="summary-grid">
        <div class="summary-section">
          <h3>{{ tCall('summary.answers') }}</h3>
          <dl>
            <template v-for="answer in summary.answers" :key="answer.label">
              <dt>{{ answer.label }}</dt>
              <dd>{{ answer.value }}</dd>
            </template>
          </dl>
        </div>

        <div class="summary-section">
          <h3>{{ tCall('summary.prepare') }}</h3>
          <ul>
            <li v-for="item in summary.information_to_prepare" :key="item">
              {{ item }}
            </li>
          </ul>
        </div>

        <div class="summary-section">
          <h3>{{ tCall('summary.questions') }}</h3>
          <ul>
            <li v-for="item in summary.questions_to_ask_clinic" :key="item">
              {{ item }}
            </li>
          </ul>
        </div>

        <div class="summary-section safety-section">
          <h3>{{ tCall('summary.notes') }}</h3>
          <ul>
            <li v-for="item in summary.safety_notes" :key="item">
              {{ item }}
            </li>
          </ul>
        </div>
      </div>
    </section>

    <section class="scope-note">
      <strong>{{ tCall('scope.title') }}</strong>
      <span>{{ tCall('scope.description') }}</span>
    </section>
  </main>
</template>

<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, ref } from 'vue'
import { useTranslation } from '../i18n/useTranslation'

const { t } = useTranslation()

function tCall(key: string, options: Record<string, string> = {}) {
  return t(`callPractice.${key}`, {
    ...options,
    ns: 'callPractice',
  })
}

type ConnectionState = 'idle' | 'connecting' | 'connected' | 'finishing' | 'complete' | 'error'

interface ConversationTurn {
  user: string
  assistant: string
  speaker: string
}

interface SummaryAnswer {
  label: string
  value: string
}

interface PracticeSummary {
  answers: SummaryAnswer[]
  information_to_prepare: string[]
  questions_to_ask_clinic: string[]
  safety_notes: string[]
  created_at: string
}

interface ServerMessage {
  type: string
  role?: 'user' | 'assistant'
  text?: string
  phase?: string
  message?: string
  count?: number
  answered?: number
  total?: number
  user?: string
  assistant?: string
  speaker?: string
  output_sample_rate?: number
  summary?: PracticeSummary
}

const connectionState = ref<ConnectionState>('idle')
const phase = ref('orientation')
const errorMessage = ref('')
const assistantSpeaking = ref(false)
const microphoneOpen = ref(false)
const ringPlaying = ref(false)
const outputSampleRate = ref(24000)
const turns = ref<ConversationTurn[]>([])
const liveUserTranscript = ref('')
const liveAssistantTranscript = ref('')
const progress = ref({ answered: 0, total: 8 })
const summary = ref<PracticeSummary | null>(null)
const transcriptPanel = ref<HTMLElement | null>(null)

let socket: WebSocket | null = null
let audioContext: AudioContext | null = null
let mediaStream: MediaStream | null = null
let microphoneSource: MediaStreamAudioSourceNode | null = null
let captureNode: AudioWorkletNode | null = null
let playbackNode: AudioWorkletNode | null = null
let silentOutput: GainNode | null = null
let playbackDrained = true
let assistantTurnComplete = false
let manualClose = false
let microphoneCooldown: number | null = null

const connectionLabel = computed(() => tCall(`connection.${connectionState.value}`))

const speakerLabel = computed(() =>
  ['practitioner', 'collecting', 'follow_up'].includes(phase.value)
    ? tCall('live.practitioner')
    : tCall('live.luna'),
)

const callPrompt = computed(() => {
  if (connectionState.value === 'connecting') {
    return tCall('live.settingUp')
  }

  if (connectionState.value === 'finishing') {
    return tCall('live.preparing')
  }

  if (ringPlaying.value) {
    return tCall('live.ringing')
  }

  if (assistantSpeaking.value) {
    return tCall('live.speaking', { speaker: speakerLabel.value })
  }

  if (microphoneOpen.value) {
    return tCall('live.yourTurn')
  }

  return tCall('live.pleaseWait')
})

const callHelp = computed(() => {
  if (ringPlaying.value) return tCall('live.ringHelp')
  if (microphoneOpen.value) return tCall('live.speakHelp')
  if (assistantSpeaking.value) return tCall('live.speakingHelp')
  return tCall('live.continueHelp')
})

const audioStatus = computed(() => {
  if (ringPlaying.value) return tCall('live.ringStatus')
  if (assistantSpeaking.value) return tCall('live.audioStatus')
  if (microphoneOpen.value) return tCall('live.listeningStatus')
  return tCall('live.pausedStatus')
})

const progressPercentage = computed(() => {
  if (!progress.value.total) return '0%'
  return `${Math.min(100, (progress.value.answered / progress.value.total) * 100)}%`
})

const hasTranscript = computed(
  () => turns.value.length > 0 || liveUserTranscript.value || liveAssistantTranscript.value,
)

function websocketUrl(): string {
  const configuredBase = String(import.meta.env.VITE_API_BASE_URL ?? '').trim()
  const httpBase = configuredBase
    ? configuredBase
    : import.meta.env.DEV
      ? `${window.location.protocol}//${window.location.hostname}:8000`
      : 'https://api.screeningtogether.app'

  return `${httpBase.replace(/^http/, 'ws').replace(/\/$/, '')}/mock-call/live`
}

async function startCall(): Promise<void> {
  manualClose = true
  leaveSocketOpen(false)
  stopAssistantAudio()
  cleanupAudioInput()
  await audioContext?.close()
  audioContext = null
  resetConversation()
  connectionState.value = 'connecting'
  errorMessage.value = ''
  manualClose = false

  try {
    if (!navigator.mediaDevices?.getUserMedia || !window.AudioWorkletNode) {
      throw new Error(tCall('errors.unsupported'))
    }

    mediaStream = await navigator.mediaDevices.getUserMedia({
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true,
        channelCount: 1,
      },
      video: false,
    })

    audioContext = new AudioContext()
    await audioContext.resume()
    await audioContext.audioWorklet.addModule('/audio/pcm16-capture-processor.js?v=2')

    microphoneSource = audioContext.createMediaStreamSource(mediaStream)
    captureNode = new AudioWorkletNode(audioContext, 'pcm16-capture-processor')
    playbackNode = new AudioWorkletNode(audioContext, 'pcm16-playback-processor')
    silentOutput = audioContext.createGain()
    silentOutput.gain.value = 0

    microphoneSource.connect(captureNode)
    captureNode.connect(silentOutput)
    silentOutput.connect(audioContext.destination)
    playbackNode.connect(audioContext.destination)

    playbackNode.port.onmessage = (event: MessageEvent<{ type?: string }>) => {
      if (event.data?.type === 'drained') {
        playbackDrained = true
        scheduleMicrophoneResume()
      }
    }

    captureNode.port.onmessage = (event: MessageEvent<ArrayBuffer>) => {
      if (
        microphoneOpen.value &&
        socket?.readyState === WebSocket.OPEN &&
        event.data.byteLength > 0
      ) {
        socket.send(event.data)
      }
    }

    connectSocket()
  } catch (error) {
    cleanupAudioInput()
    connectionState.value = 'error'
    errorMessage.value = error instanceof Error ? error.message : tCall('errors.microphone')
  }
}

function connectSocket(): void {
  socket = new WebSocket(websocketUrl())
  socket.binaryType = 'arraybuffer'

  socket.onmessage = async (event: MessageEvent<string | ArrayBuffer | Blob>) => {
    if (typeof event.data === 'string') {
      handleServerMessage(JSON.parse(event.data) as ServerMessage)
      return
    }

    const bytes = event.data instanceof Blob ? await event.data.arrayBuffer() : event.data
    queueAssistantAudio(bytes)
  }

  socket.onerror = () => {
    errorMessage.value = tCall('errors.connection')
  }

  socket.onclose = () => {
    setMicrophone(false)
    cleanupAudioInput()

    if (!manualClose && connectionState.value !== 'complete') {
      connectionState.value = 'error'
      errorMessage.value = errorMessage.value || tCall('errors.unexpected')
    }
  }
}

function handleServerMessage(message: ServerMessage): void {
  switch (message.type) {
    case 'connected':
      phase.value = message.phase ?? 'orientation'
      outputSampleRate.value = message.output_sample_rate ?? 24000
      connectionState.value = 'connected'
      setMicrophone(false)
      break
    case 'status':
      phase.value = message.phase ?? phase.value
      break
    case 'transcript':
      if (message.role === 'user') liveUserTranscript.value = message.text ?? ''
      if (message.role === 'assistant') liveAssistantTranscript.value = message.text ?? ''
      scrollTranscript()
      break
    case 'turn':
      turns.value.push({
        user: message.user ?? '',
        assistant: message.assistant ?? '',
        speaker: message.speaker ?? speakerLabel.value,
      })
      liveUserTranscript.value = ''
      liveAssistantTranscript.value = ''
      assistantTurnComplete = true
      playbackNode?.port.postMessage({ type: 'end-turn' })
      if (!playbackNode) scheduleMicrophoneResume()
      scrollTranscript()
      break
    case 'progress':
      progress.value = {
        answered: message.answered ?? progress.value.answered,
        total: message.total ?? progress.value.total,
      }
      break
    case 'play_rings':
      void playRings(message.count ?? 2)
      break
    case 'interrupted':
      stopAssistantAudio()
      liveAssistantTranscript.value = ''
      assistantTurnComplete = true
      scheduleMicrophoneResume()
      break
    case 'summary':
      if (message.summary) completeSession(message.summary)
      break
    case 'error':
      errorMessage.value = message.message ?? tCall('errors.practice')
      connectionState.value = 'error'
      leaveSocketOpen(false)
      break
  }
}

function queueAssistantAudio(bytes: ArrayBuffer): void {
  if (!playbackNode || bytes.byteLength < 2) return

  if (microphoneCooldown !== null) {
    window.clearTimeout(microphoneCooldown)
    microphoneCooldown = null
  }

  assistantTurnComplete = false
  assistantSpeaking.value = true
  playbackDrained = false
  setMicrophone(false)
  playbackNode.port.postMessage(
    { type: 'audio', buffer: bytes, inputSampleRate: outputSampleRate.value },
    [bytes],
  )
}

function scheduleMicrophoneResume(): void {
  if (!playbackDrained || !assistantTurnComplete || ringPlaying.value) return

  assistantSpeaking.value = false
  if (microphoneCooldown !== null) window.clearTimeout(microphoneCooldown)

  microphoneCooldown = window.setTimeout(() => {
    if (playbackDrained && !ringPlaying.value && connectionState.value === 'connected') {
      setMicrophone(true)
    }
  }, 350)
}

function stopAssistantAudio(): void {
  playbackNode?.port.postMessage({ type: 'reset' })
  playbackDrained = true
  assistantSpeaking.value = false
}

async function playRings(count: number): Promise<void> {
  if (!audioContext || ringPlaying.value) return
  ringPlaying.value = true
  setMicrophone(false)

  for (let index = 0; index < count; index += 1) {
    await playRingPulse()
    if (index < count - 1) await delay(360)
  }

  ringPlaying.value = false
  if (socket?.readyState === WebSocket.OPEN) {
    socket.send(JSON.stringify({ type: 'ring_complete' }))
  }
}

function playRingPulse(): Promise<void> {
  if (!audioContext) return Promise.resolve()

  const gain = audioContext.createGain()
  const firstTone = audioContext.createOscillator()
  const secondTone = audioContext.createOscillator()
  const now = audioContext.currentTime

  firstTone.frequency.value = 440
  secondTone.frequency.value = 480
  firstTone.type = 'sine'
  secondTone.type = 'sine'
  gain.gain.setValueAtTime(0.0001, now)
  gain.gain.exponentialRampToValueAtTime(0.075, now + 0.04)
  gain.gain.setValueAtTime(0.075, now + 0.5)
  gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.62)

  firstTone.connect(gain)
  secondTone.connect(gain)
  gain.connect(audioContext.destination)
  firstTone.start(now)
  secondTone.start(now)
  firstTone.stop(now + 0.65)
  secondTone.stop(now + 0.65)

  return delay(680)
}

function finishCall(): void {
  if (socket?.readyState !== WebSocket.OPEN || connectionState.value !== 'connected') return
  connectionState.value = 'finishing'
  setMicrophone(false)
  socket.send(JSON.stringify({ type: 'finish' }))
}

function completeSession(result: PracticeSummary): void {
  summary.value = result
  connectionState.value = 'complete'
  setMicrophone(false)
  cleanupAudioInput()
  manualClose = true
  socket?.close(1000, 'Practice summary received')
}

function leaveCall(): void {
  manualClose = true
  leaveSocketOpen(false)
  stopAssistantAudio()
  cleanupAudioInput()
  resetPractice()
}

function leaveSocketOpen(keepState: boolean): void {
  const activeSocket = socket
  socket = null

  if (activeSocket && activeSocket.readyState < WebSocket.CLOSING) {
    if (manualClose) {
      activeSocket.onclose = null
      activeSocket.onerror = null
      activeSocket.onmessage = null
    }
    activeSocket.close(1000, 'User left practice')
  }
  if (!keepState) setMicrophone(false)
}

function cleanupAudioInput(): void {
  setMicrophone(false)
  captureNode?.disconnect()
  playbackNode?.disconnect()
  microphoneSource?.disconnect()
  silentOutput?.disconnect()
  mediaStream?.getTracks().forEach((track) => track.stop())
  captureNode = null
  playbackNode = null
  microphoneSource = null
  silentOutput = null
  mediaStream = null
}

function resetConversation(): void {
  turns.value = []
  liveUserTranscript.value = ''
  liveAssistantTranscript.value = ''
  summary.value = null
  phase.value = 'orientation'
  progress.value = { answered: 0, total: 8 }
  assistantSpeaking.value = false
  assistantTurnComplete = false
  playbackDrained = true
}

function resetPractice(): void {
  stopAssistantAudio()
  cleanupAudioInput()
  void audioContext?.close()
  audioContext = null
  socket = null
  resetConversation()
  errorMessage.value = ''
  connectionState.value = 'idle'
}

function setMicrophone(enabled: boolean): void {
  microphoneOpen.value = enabled && connectionState.value === 'connected'
}

function downloadSummary(): void {
  if (!summary.value) return

  const answerLines = summary.value.answers.map((answer) => `- ${answer.label}: ${answer.value}`)
  const content = [
    tCall('download.title'),
    '',
    tCall('download.answers'),
    ...answerLines,
    '',
    tCall('download.prepare'),
    ...summary.value.information_to_prepare.map((item) => `- ${item}`),
    '',
    tCall('download.questions'),
    ...summary.value.questions_to_ask_clinic.map((item) => `- ${item}`),
    '',
    tCall('download.notes'),
    ...summary.value.safety_notes.map((item) => `- ${item}`),
  ].join('\n')

  const url = URL.createObjectURL(new Blob([content], { type: 'text/plain;charset=utf-8' }))
  const link = document.createElement('a')
  link.href = url
  link.download = 'luna-call-practice-summary.txt'
  link.click()
  URL.revokeObjectURL(url)
}

function scrollTranscript(): void {
  void nextTick(() => {
    if (transcriptPanel.value) {
      transcriptPanel.value.scrollTop = transcriptPanel.value.scrollHeight
    }
  })
}

function delay(milliseconds: number): Promise<void> {
  return new Promise((resolve) => window.setTimeout(resolve, milliseconds))
}

onBeforeUnmount(() => {
  manualClose = true
  leaveSocketOpen(false)
  stopAssistantAudio()
  cleanupAudioInput()
  void audioContext?.close()
  audioContext = null
  turns.value = []
  summary.value = null
})
</script>

<style scoped>

.call-practice-page {
  --cp-page-bg: #fffaf8;
  --cp-glow: rgba(231, 181, 187, 0.28);
  --cp-text: #30272b;
  --cp-muted: #706468;
  --cp-accent: #a65364;
  --cp-accent-hover: #913e52;
  --cp-card-bg: rgba(255, 255, 255, 0.94);
  --cp-border: #eadfdb;
  --cp-soft-bg: #f7efed;
  --cp-soft-text: #6a5c60;
  --cp-button-text: #fff;
  --cp-shadow: rgba(72, 42, 49, 0.09);

  box-sizing: border-box;
  min-height: 100vh;
  padding: 72px clamp(20px, 6vw, 88px) 90px;
  background:
    radial-gradient(circle at 85% 8%, var(--cp-glow), transparent 26rem),
    linear-gradient(
      180deg,
      var(--cp-page-bg) 0%,
      var(--cp-card-bg) 46%,
      var(--cp-page-bg) 100%
    );
  color: var(--cp-text);
  font-size: 16px;
}

.call-practice-page *,
.call-practice-page *::before,
.call-practice-page *::after {
  box-sizing: border-box;
}

.practice-intro {
  max-width: 850px;
  margin: 0 auto 46px;
  text-align: center;
}

.eyebrow {
  margin: 0 0 12px;
  color: var(--cp-accent);
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

.practice-intro h1 {
  margin: 0;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(2.5rem, 6vw, 4.5rem);
  font-weight: 500;
  letter-spacing: -0.05em;
  line-height: 1.02;
}

.intro-copy {
  max-width: 690px;
  margin: 22px auto 0;
  color: var(--cp-muted);
  font-size: 1.0625rem;
  line-height: 1.75;
}

.privacy-strip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  max-width: 700px;
  margin: 24px auto 0;
  padding: 12px 18px;
  border: 1px solid var(--cp-border);
  border-radius: 999px;
  background: var(--cp-card-bg);
  color: var(--cp-muted);
  font-size: 0.8125rem;
  line-height: 1.5;
}

.privacy-strip p {
  margin: 0;
}

.privacy-icon {
  flex: 0 0 auto;
  color: var(--cp-accent);
  font-size: 0.625rem;
}

.practice-workspace {
  display: grid;
  grid-template-columns: minmax(0, 1.05fr) minmax(0, 0.95fr);
  gap: 24px;
  width: min(1180px, 100%);
  margin: 0 auto;
  align-items: stretch;
}

.call-card,
.transcript-card,
.summary-card {
  min-width: 0;
  border: 1px solid var(--cp-border);
  border-radius: 28px;
  background: var(--cp-card-bg);
  box-shadow: 0 22px 70px var(--cp-shadow);
}

.call-card {
  min-height: 620px;
  overflow: hidden;
}

.call-card-topline {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 9px;
  padding: 18px 24px;
  border-bottom: 1px solid var(--cp-border);
  color: var(--cp-muted);
  font-size: 0.75rem;
  font-weight: 700;
}

.connection-dot {
  flex: 0 0 8px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--cp-muted);
}

.connection-dot.connecting,
.connection-dot.finishing {
  background: #d39a41;
}

.connection-dot.connected {
  background: #4c9b78;
  box-shadow: 0 0 0 4px rgba(76, 155, 120, 0.12);
}

.connection-dot.error {
  background: #c94e55;
}

.connection-dot.complete {
  background: #6b7da4;
}

.session-note {
  margin-left: auto;
  color: var(--cp-accent);
  font-weight: 600;
}

.welcome-state,
.complete-state,
.live-call {
  display: flex;
  min-height: 565px;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 42px clamp(24px, 5vw, 66px);
  text-align: center;
}

.phone-illustration {
  width: 112px;
  max-width: 100%;
  margin-bottom: 18px;
}

.phone-illustration svg {
  display: block;
  width: 100%;
  height: auto;
}

.welcome-state h2,
.complete-state h2,
.live-call h2,
.transcript-heading h2,
.summary-heading h2 {
  margin: 0;
  color: var(--cp-text);
  font-family: Georgia, 'Times New Roman', serif;
  font-weight: 500;
}

.welcome-state h2,
.complete-state h2,
.live-call h2 {
  font-size: clamp(1.875rem, 4vw, 2.625rem);
  line-height: 1.2;
}

.welcome-state > p:not(.error-message, .browser-note),
.complete-state > p,
.call-help {
  max-width: 500px;
  margin: 14px 0 24px;
  color: var(--cp-muted);
  line-height: 1.65;
}

.before-list {
  display: grid;
  gap: 11px;
  width: min(100%, 430px);
  margin: 0 0 28px;
  padding: 0;
  list-style: none;
  text-align: start;
}

.before-list li {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  color: var(--cp-text);
  font-size: 0.875rem;
  line-height: 1.5;
}

.before-list span {
  display: grid;
  flex: 0 0 28px;
  width: 28px;
  height: 28px;
  place-items: center;
  border-radius: 50%;
  background: var(--cp-soft-bg);
  color: var(--cp-accent);
  font-size: 0.75rem;
  font-weight: 800;
}

.primary-action,
.secondary-action,
.finish-button,
.leave-button,
.summary-download {
  max-width: 100%;
  padding: 12px 18px;
  border-radius: 999px;
  font: inherit;
  font-weight: 800;
  line-height: 1.4;
  overflow-wrap: anywhere;
  cursor: pointer;
  transition:
    transform 0.18s ease,
    box-shadow 0.18s ease,
    background 0.18s ease,
    border-color 0.18s ease;
}

.primary-action,
.finish-button {
  border: 0;
  background: var(--cp-accent);
  color: var(--cp-button-text);
  box-shadow: 0 10px 24px var(--cp-shadow);
}

.primary-action {
  padding: 14px 24px;
}

.primary-action span {
  margin-left: 8px;
}

.primary-action:hover,
.finish-button:hover:not(:disabled) {
  transform: translateY(-2px);
  background: var(--cp-accent-hover);
  box-shadow: 0 14px 28px var(--cp-shadow);
}

.secondary-action,
.leave-button,
.summary-download {
  border: 1px solid var(--cp-border);
  background: var(--cp-card-bg);
  color: var(--cp-text);
}

.leave-button:hover,
.secondary-action:hover,
.summary-download:hover {
  border-color: var(--cp-accent);
  background: var(--cp-soft-bg);
}

.primary-action:focus-visible,
.secondary-action:focus-visible,
.finish-button:focus-visible,
.leave-button:focus-visible,
.summary-download:focus-visible {
  outline: 3px solid var(--cp-accent);
  outline-offset: 3px;
}

.browser-note {
  margin: 13px 0 0;
  color: var(--cp-muted);
  font-size: 0.6875rem;
  line-height: 1.5;
}

.error-message {
  width: min(100%, 470px);
  margin: 0 0 18px;
  padding: 12px 14px;
  border-radius: 12px;
  background: var(--cp-soft-bg);
  color: var(--cp-accent);
  font-size: 0.8125rem;
  line-height: 1.5;
  overflow-wrap: anywhere;
}

.voice-orb {
  position: relative;
  display: grid;
  flex: 0 0 auto;
  width: 132px;
  height: 132px;
  margin-bottom: 24px;
  place-items: center;
}

.orb-core {
  z-index: 2;
  display: grid;
  width: 84px;
  height: 84px;
  place-items: center;
  border-radius: 50%;
  background: linear-gradient(145deg, var(--cp-accent), var(--cp-accent-hover));
  box-shadow: 0 14px 32px var(--cp-shadow);
  color: var(--cp-button-text);
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 2.375rem;
}

.orb-ring {
  position: absolute;
  inset: 14px;
  border: 1px solid var(--cp-border);
  border-radius: 50%;
  opacity: 0;
}

.orb-ring-two {
  inset: 0;
}

.voice-orb.speaking .orb-ring,
.voice-orb.listening .orb-ring-one {
  animation: voice-pulse 1.6s ease-out infinite;
}

.voice-orb.speaking .orb-ring-two {
  animation: voice-pulse 1.6s 0.45s ease-out infinite;
}

.voice-orb.listening .orb-core {
  background: linear-gradient(145deg, #4b8c79, #326e61);
}

.speaker-name {
  margin: 0 0 7px;
  color: var(--cp-accent);
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.call-help {
  margin-bottom: 16px;
  font-size: 0.875rem;
}

.audio-state {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 9px 14px;
  border-radius: 999px;
  background: var(--cp-soft-bg);
  color: var(--cp-soft-text);
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.5;
}

.audio-bars {
  display: flex;
  align-items: center;
  gap: 2px;
  flex: 0 0 auto;
  height: 14px;
}

.audio-bars i {
  display: block;
  width: 2px;
  height: 5px;
  border-radius: 9px;
  background: var(--cp-accent);
}

.voice-orb.speaking + .speaker-name ~ .audio-state .audio-bars i,
.voice-orb.listening + .speaker-name ~ .audio-state .audio-bars i {
  animation: audio-bar 0.8s ease-in-out infinite alternate;
}

.audio-bars i:nth-child(2) {
  animation-delay: 0.18s !important;
}

.audio-bars i:nth-child(3) {
  animation-delay: 0.36s !important;
}

.audio-bars i:nth-child(4) {
  animation-delay: 0.12s !important;
}

.progress-block {
  width: min(100%, 440px);
  margin-top: 24px;
}

.progress-copy {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 8px;
  color: var(--cp-muted);
  font-size: 0.75rem;
}

.progress-copy strong {
  color: var(--cp-text);
}

.progress-track {
  height: 7px;
  overflow: hidden;
  border-radius: 99px;
  background: var(--cp-border);
}

.progress-track span {
  display: block;
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, var(--cp-accent), var(--cp-accent-hover));
  transition: width 0.35s ease;
}

.call-controls,
.complete-actions {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 10px;
  margin-top: 28px;
}

.finish-button:disabled {
  cursor: not-allowed;
  opacity: 0.5;
  box-shadow: none;
}

.complete-mark {
  display: grid;
  width: 76px;
  height: 76px;
  margin-bottom: 22px;
  place-items: center;
  border-radius: 50%;
  background: var(--cp-soft-bg);
  color: var(--cp-accent);
  font-size: 2rem;
}

.transcript-card {
  display: flex;
  min-height: 620px;
  max-height: 720px;
  flex-direction: column;
  padding: 26px;
}

.transcript-heading,
.summary-heading {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20px;
}

.transcript-heading h2,
.summary-heading h2 {
  font-size: 1.75rem;
  line-height: 1.25;
}

.not-saved-badge {
  flex: 0 0 auto;
  max-width: 100%;
  padding: 7px 10px;
  border-radius: 999px;
  background: var(--cp-soft-bg);
  color: var(--cp-soft-text);
  font-size: 0.625rem;
  font-weight: 800;
  letter-spacing: 0.04em;
  line-height: 1.5;
  text-transform: uppercase;
}

.transcript-panel {
  flex: 1;
  min-height: 0;
  margin-top: 22px;
  overflow-y: auto;
  padding: 4px 8px 8px 0;
  scrollbar-color: var(--cp-border) transparent;
  scrollbar-width: thin;
}

.empty-transcript {
  display: grid;
  min-height: 410px;
  place-items: center;
  align-content: center;
  color: var(--cp-muted);
  text-align: center;
}

.empty-transcript span {
  height: 55px;
  color: var(--cp-border);
  font-family: Georgia, serif;
  font-size: 4.5rem;
  line-height: 1;
}

.empty-transcript p {
  max-width: 260px;
  margin: 8px 0 0;
  font-size: 0.8125rem;
  line-height: 1.6;
}

.message {
  width: fit-content;
  max-width: 88%;
  margin-bottom: 16px;
  min-width: 0;
}

.message span {
  display: block;
  margin: 0 8px 5px;
  color: var(--cp-muted);
  font-size: 0.625rem;
  font-weight: 800;
  letter-spacing: 0.08em;
  line-height: 1.5;
  text-transform: uppercase;
  overflow-wrap: anywhere;
}

.message p {
  margin: 0;
  padding: 12px 15px;
  border-radius: 8px 18px 18px 18px;
  background: var(--cp-soft-bg);
  color: var(--cp-text);
  font-size: 0.8125rem;
  line-height: 1.55;
  overflow-wrap: anywhere;
}

.user-message {
  margin-left: auto;
}

.user-message span {
  text-align: end;
}

.user-message p {
  border-radius: 18px 8px 18px 18px;
  background: var(--cp-accent);
  color: var(--cp-button-text);
}

.partial-message {
  opacity: 0.72;
}

.summary-card {
  width: min(1180px, 100%);
  margin: 24px auto 0;
  padding: clamp(26px, 5vw, 48px);
}

.summary-download {
  padding: 10px 16px;
  font-size: 0.75rem;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
  margin-top: 30px;
}

.summary-section {
  min-width: 0;
  padding: 22px;
  border-radius: 18px;
  background: var(--cp-soft-bg);
}

.summary-section h3 {
  margin: 0 0 14px;
  color: var(--cp-text);
  font-size: 0.875rem;
  line-height: 1.5;
  overflow-wrap: anywhere;
}

.summary-section ul {
  display: grid;
  gap: 9px;
  margin: 0;
  padding-inline-start: 18px;
  color: var(--cp-muted);
  font-size: 0.8125rem;
  line-height: 1.55;
}

.summary-section li,
.summary-section dt,
.summary-section dd {
  overflow-wrap: anywhere;
}

.summary-section dl {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 9px 16px;
  margin: 0;
  font-size: 0.8125rem;
  line-height: 1.5;
}

.summary-section dt {
  color: var(--cp-muted);
}

.summary-section dd {
  margin: 0;
  color: var(--cp-text);
  font-weight: 800;
  text-align: end;
}

.safety-section {
  background: var(--cp-soft-bg);
}

.scope-note {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  justify-content: center;
  gap: 6px 10px;
  max-width: 900px;
  margin: 28px auto 0;
  color: var(--cp-muted);
  font-size: 0.75rem;
  line-height: 1.6;
  text-align: center;
}

.scope-note strong {
  color: var(--cp-text);
}

@keyframes voice-pulse {
  0% {
    opacity: 0.7;
    transform: scale(0.72);
  }
  100% {
    opacity: 0;
    transform: scale(1.08);
  }
}

@keyframes audio-bar {
  from {
    height: 4px;
  }
  to {
    height: 14px;
  }
}

@media (max-width: 940px) {
  .practice-workspace {
    grid-template-columns: 1fr;
  }

  .call-card,
  .transcript-card {
    min-height: auto;
  }

  .transcript-card {
    max-height: none;
  }

  .transcript-panel {
    max-height: 520px;
  }

  .empty-transcript {
    min-height: 220px;
  }
}

@media (max-width: 640px) {
  .call-practice-page {
    padding: 48px 14px 64px;
  }

  .practice-intro {
    margin-bottom: 30px;
  }

  .practice-intro h1 {
    font-size: 42px;
  }

  .intro-copy {
    font-size: 15px;
  }

  .privacy-strip {
    align-items: flex-start;
    border-radius: 16px;
    text-align: left;
  }

  .call-card,
  .transcript-card,
  .summary-card {
    border-radius: 20px;
  }

  .welcome-state,
  .complete-state,
  .live-call {
    min-height: 540px;
    padding: 34px 20px;
  }

  .transcript-card {
    padding: 20px;
  }

  .summary-grid {
    grid-template-columns: 1fr;
  }

  .summary-heading {
    flex-direction: column;
  }

  .scope-note {
    display: grid;
  }
}

@media (prefers-reduced-motion: reduce) {
  .orb-ring,
  .audio-bars i {
    animation: none !important;
  }

  .primary-action,
  .finish-button,
  .progress-track span {
    transition: none;
  }
}

.theme-blush .call-practice-page {
  --cp-page-bg: #fffaf8;
  --cp-glow: rgba(231, 181, 187, 0.24);
  --cp-text: #30272b;
  --cp-muted: #706468;
  --cp-accent: #a65364;
  --cp-accent-hover: #913e52;
  --cp-card-bg: #ffffff;
  --cp-border: #eadfdb;
  --cp-soft-bg: #f7efed;
  --cp-soft-text: #6a5c60;
  --cp-button-text: #ffffff;
  --cp-shadow: rgba(72, 42, 49, 0.07);
}

.theme-teal .call-practice-page {
  --cp-page-bg: #eef8f6;
  --cp-glow: rgba(80, 173, 161, 0.16);
  --cp-text: #193b3a;
  --cp-muted: #496b68;
  --cp-accent: #087b78;
  --cp-accent-hover: #075957;
  --cp-card-bg: #ffffff;
  --cp-border: #c4dfda;
  --cp-soft-bg: #e2f3f0;
  --cp-soft-text: #285d58;
  --cp-button-text: #ffffff;
  --cp-shadow: rgba(25, 75, 69, 0.08);
}

.theme-accessible .call-practice-page {
  --cp-page-bg: #f0f5fc;
  --cp-glow: rgba(61, 120, 183, 0.12);
  --cp-text: #172b43;
  --cp-muted: #344b63;
  --cp-accent: #145da0;
  --cp-accent-hover: #104b7b;
  --cp-card-bg: #ffffff;
  --cp-border: #9db7d2;
  --cp-soft-bg: #dbe9f7;
  --cp-soft-text: #203f60;
  --cp-button-text: #ffffff;
  --cp-shadow: rgba(23, 43, 67, 0.08);
}

.text-size-larger .call-practice-page {
  font-size: 18px;
}

.text-size-largest .call-practice-page {
  font-size: 20px;
}

.text-size-larger .call-practice-page .eyebrow {
  font-size: 0.85rem;
}

.text-size-largest .call-practice-page .eyebrow {
  font-size: 0.9rem;
}

.text-size-larger .call-practice-page .call-card-topline,
.text-size-larger .call-practice-page .before-list li,
.text-size-larger .call-practice-page .message p,
.text-size-larger .call-practice-page .summary-section,
.text-size-larger .call-practice-page .scope-note {
  font-size: 1rem;
}

.text-size-largest .call-practice-page .call-card-topline,
.text-size-largest .call-practice-page .before-list li,
.text-size-largest .call-practice-page .message p,
.text-size-largest .call-practice-page .summary-section,
.text-size-largest .call-practice-page .scope-note {
  font-size: 1.05rem;
}

.text-size-larger .call-practice-page .practice-intro h1 {
  font-size: clamp(34px, 4vw, 56px);
}

.text-size-largest .call-practice-page .practice-intro h1 {
  font-size: clamp(36px, 4vw, 60px);
}

.text-size-larger .call-practice-page .welcome-state h2,
.text-size-larger .call-practice-page .complete-state h2,
.text-size-larger .call-practice-page .live-call h2 {
  font-size: clamp(27px, 3vw, 38px);
}

.text-size-largest .call-practice-page .welcome-state h2,
.text-size-largest .call-practice-page .complete-state h2,
.text-size-largest .call-practice-page .live-call h2 {
  font-size: clamp(29px, 3vw, 40px);
}

.text-size-larger .call-practice-page button,
.text-size-largest .call-practice-page button {
  min-height: 44px;
  white-space: normal;
}

@media (max-width: 900px) {
  .practice-workspace {
    grid-template-columns: 1fr;
  }

  .call-card {
    min-height: 0;
  }

  .welcome-state,
  .complete-state,
  .live-call {
    min-height: 380px;
  }

  .transcript-card {
    min-height: 300px;
    max-height: 440px;
  }

  .empty-transcript {
    min-height: 180px;
  }
}

@media (max-width: 600px) {
  .call-practice-page {
    padding: 24px 12px 36px;
  }

  .practice-intro h1 {
    font-size: clamp(30px, 9vw, 42px);
  }

  .privacy-strip {
    text-align: start;
  }

  .summary-grid {
    grid-template-columns: 1fr;
  }

  .summary-heading {
    flex-direction: column;
  }

  .call-controls,
  .complete-actions {
    width: 100%;
    flex-direction: column;
  }

  .call-controls button,
  .complete-actions button {
    width: 100%;
  }
}

@media (prefers-reduced-motion: reduce) {
  .call-practice-page *,
  .call-practice-page *::before,
  .call-practice-page *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
    transition-duration: 0.01ms !important;
  }
}
</style>
