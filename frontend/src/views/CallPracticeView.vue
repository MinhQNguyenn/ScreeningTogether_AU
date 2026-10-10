<template>
  <main class="call-practice-page">
    <section class="practice-intro" aria-labelledby="practice-title">
      <p class="eyebrow">Private practice · No account needed</p>
      <h1 id="practice-title">Practise the call before you make it.</h1>
      <p class="intro-copy">
        Rehearse a telehealth conversation about cervical screening self-collection with
        Luna. Speak naturally, hear the practitioner respond, and finish with a simple
        preparation summary.
      </p>
      <div class="privacy-strip">
        <span class="privacy-icon" aria-hidden="true">◆</span>
        <p>
          Use fictional details only. Audio and transcripts stay in this live session and
          are discarded when it ends.
        </p>
      </div>
    </section>

    <section class="practice-workspace" aria-label="Call practice workspace">
      <div class="call-card">
        <div class="call-card-topline">
          <span :class="['connection-dot', connectionState]"></span>
          <span aria-live="polite">{{ connectionLabel }}</span>
          <span v-if="connectionState === 'connected'" class="session-note">Live session</span>
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
            <h2>Ready when you are</h2>
            <p>
              Your browser will ask for microphone access. Luna will explain the practice
              first, and the mock call begins only after you say you are ready.
            </p>

            <ul class="before-list">
              <li><span aria-hidden="true">1</span>Find a quiet, private place.</li>
              <li><span aria-hidden="true">2</span>Use headphones if you have them.</li>
              <li><span aria-hidden="true">3</span>Do not share real identifying details.</li>
            </ul>

            <p v-if="errorMessage" class="error-message" role="alert">{{ errorMessage }}</p>

            <button class="primary-action" type="button" @click="startCall">
              Start call practice
              <span aria-hidden="true">→</span>
            </button>
            <p class="browser-note">Works best in a current version of Chrome or Edge.</p>
          </div>
        </template>

        <template v-else-if="connectionState === 'complete' && summary">
          <div class="complete-state">
            <span class="complete-mark" aria-hidden="true">✓</span>
            <p class="eyebrow">Practice complete</p>
            <h2>Your preparation summary is ready.</h2>
            <p>
              This contains only structured practice answers—not your audio or free-form
              transcript.
            </p>
            <div class="complete-actions">
              <button class="primary-action" type="button" @click="downloadSummary">
                Download summary
              </button>
              <button class="secondary-action" type="button" @click="resetPractice">
                Start again
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
              <span class="audio-bars" aria-hidden="true">
                <i></i><i></i><i></i><i></i>
              </span>
              {{ audioStatus }}
            </div>

            <div v-if="progress.total > 0" class="progress-block">
              <div class="progress-copy">
                <span>Practice questions</span>
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
                Finish &amp; create summary
              </button>
              <button class="leave-button" type="button" @click="leaveCall">
                Leave and discard
              </button>
            </div>
          </div>
        </template>
      </div>

      <aside class="transcript-card" aria-labelledby="transcript-title">
        <div class="transcript-heading">
          <div>
            <p class="eyebrow">Conversation</p>
            <h2 id="transcript-title">Live transcript</h2>
          </div>
          <span class="not-saved-badge">Not saved</span>
        </div>

        <div ref="transcriptPanel" class="transcript-panel" aria-live="polite">
          <div v-if="!hasTranscript" class="empty-transcript">
            <span aria-hidden="true">“</span>
            <p>The conversation will appear here after the practice begins.</p>
          </div>

          <template v-for="(turn, index) in turns" :key="`${index}-${turn.assistant}`">
            <div v-if="turn.user" class="message user-message">
              <span>You</span>
              <p>{{ turn.user }}</p>
            </div>
            <div v-if="turn.assistant" class="message assistant-message">
              <span>{{ turn.speaker }}</span>
              <p>{{ turn.assistant }}</p>
            </div>
          </template>

          <div v-if="liveUserTranscript" class="message user-message partial-message">
            <span>You · listening</span>
            <p>{{ liveUserTranscript }}</p>
          </div>
          <div v-if="liveAssistantTranscript" class="message assistant-message partial-message">
            <span>{{ speakerLabel }} · speaking</span>
            <p>{{ liveAssistantTranscript }}</p>
          </div>
        </div>
      </aside>
    </section>

    <section v-if="summary" class="summary-card" aria-labelledby="summary-title">
      <div class="summary-heading">
        <div>
          <p class="eyebrow">Take into a real call</p>
          <h2 id="summary-title">Practice summary</h2>
        </div>
        <button class="summary-download" type="button" @click="downloadSummary">
          Download .txt
        </button>
      </div>

      <div class="summary-grid">
        <div class="summary-section">
          <h3>Your practice answers</h3>
          <dl>
            <template v-for="answer in summary.answers" :key="answer.label">
              <dt>{{ answer.label }}</dt>
              <dd>{{ answer.value }}</dd>
            </template>
          </dl>
        </div>
        <div class="summary-section">
          <h3>Information to prepare</h3>
          <ul>
            <li v-for="item in summary.information_to_prepare" :key="item">{{ item }}</li>
          </ul>
        </div>
        <div class="summary-section">
          <h3>Questions you could ask</h3>
          <ul>
            <li v-for="item in summary.questions_to_ask_clinic" :key="item">{{ item }}</li>
          </ul>
        </div>
        <div class="summary-section safety-section">
          <h3>Important notes</h3>
          <ul>
            <li v-for="item in summary.safety_notes" :key="item">{{ item }}</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="scope-note">
      <strong>This is rehearsal, not healthcare.</strong>
      <span>
        Luna cannot diagnose, confirm eligibility, order a kit or replace advice from a
        qualified healthcare professional.
      </span>
    </section>
  </main>
</template>

<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, ref } from 'vue'

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

const connectionLabel = computed(() => {
  const labels: Record<ConnectionState, string> = {
    idle: 'Not connected',
    connecting: 'Preparing your private session…',
    connected: 'Connected securely',
    finishing: 'Creating your summary…',
    complete: 'Session ended',
    error: 'Could not connect',
  }
  return labels[connectionState.value]
})

const speakerLabel = computed(() =>
  ['practitioner', 'collecting', 'follow_up'].includes(phase.value) ? 'Practitioner' : 'Luna',
)

const callPrompt = computed(() => {
  if (connectionState.value === 'connecting') return 'Setting up your microphone…'
  if (connectionState.value === 'finishing') return 'Preparing your summary…'
  if (ringPlaying.value) return 'Connecting your practice call…'
  if (assistantSpeaking.value) return `${speakerLabel.value} is speaking`
  if (microphoneOpen.value) return 'Your turn to speak'
  return 'Please wait a moment'
})

const callHelp = computed(() => {
  if (ringPlaying.value) return 'You will hear two practice rings before the practitioner answers.'
  if (microphoneOpen.value) return 'Speak naturally. Pause when you have finished your answer.'
  if (assistantSpeaking.value) return 'Your microphone is paused while audio is playing.'
  return 'The session will continue automatically.'
})

const audioStatus = computed(() => {
  if (ringPlaying.value) return 'Practice ringtone playing'
  if (assistantSpeaking.value) return 'Audio playing'
  if (microphoneOpen.value) return 'Microphone listening'
  return 'Microphone paused'
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
      throw new Error('This browser does not support live microphone practice.')
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
    errorMessage.value =
      error instanceof Error
        ? error.message
        : 'Microphone access could not be started. Please try again.'
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
    errorMessage.value = 'The live call could not connect. Check that the backend is running.'
  }

  socket.onclose = () => {
    setMicrophone(false)
    cleanupAudioInput()

    if (!manualClose && connectionState.value !== 'complete') {
      connectionState.value = 'error'
      errorMessage.value = errorMessage.value || 'The live session ended unexpectedly.'
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
      errorMessage.value = message.message ?? 'The practice call encountered an error.'
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
    if (
      playbackDrained &&
      !ringPlaying.value &&
      connectionState.value === 'connected'
    ) {
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

  const answerLines = summary.value.answers.map(
    (answer) => `- ${answer.label}: ${answer.value}`,
  )
  const content = [
    'Luna cervical screening call-practice summary',
    '',
    'Practice answers',
    ...answerLines,
    '',
    'Information to prepare',
    ...summary.value.information_to_prepare.map((item) => `- ${item}`),
    '',
    'Questions to ask the clinic',
    ...summary.value.questions_to_ask_clinic.map((item) => `- ${item}`),
    '',
    'Important notes',
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
  min-height: 100vh;
  padding: 72px clamp(20px, 6vw, 88px) 90px;
  background:
    radial-gradient(circle at 85% 8%, rgba(231, 181, 187, 0.28), transparent 26rem),
    linear-gradient(180deg, #fffaf8 0%, #fff 46%, #fdf6f4 100%);
  color: #30272b;
}

.practice-intro {
  max-width: 850px;
  margin: 0 auto 46px;
  text-align: center;
}

.eyebrow {
  margin: 0 0 12px;
  color: #a65364;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

.practice-intro h1 {
  margin: 0;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(40px, 6vw, 72px);
  font-weight: 500;
  letter-spacing: -0.05em;
  line-height: 1.02;
}

.intro-copy {
  max-width: 690px;
  margin: 22px auto 0;
  color: #706468;
  font-size: 17px;
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
  border: 1px solid #ead7d7;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.72);
  color: #675b5f;
  font-size: 13px;
}

.privacy-strip p {
  margin: 0;
}

.privacy-icon {
  color: #ad5e6d;
  font-size: 10px;
}

.practice-workspace {
  display: grid;
  grid-template-columns: minmax(0, 1.05fr) minmax(340px, 0.95fr);
  gap: 24px;
  width: min(1180px, 100%);
  margin: 0 auto;
}

.call-card,
.transcript-card,
.summary-card {
  border: 1px solid #eadfdb;
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.94);
  box-shadow: 0 22px 70px rgba(72, 42, 49, 0.09);
}

.call-card {
  min-height: 620px;
  overflow: hidden;
}

.call-card-topline {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 18px 24px;
  border-bottom: 1px solid #eee4e1;
  color: #6b6063;
  font-size: 12px;
  font-weight: 700;
}

.connection-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #a89fa1;
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
  color: #9b7f84;
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
  margin-bottom: 18px;
}

.welcome-state h2,
.complete-state h2,
.live-call h2,
.transcript-heading h2,
.summary-heading h2 {
  margin: 0;
  color: #30272b;
  font-family: Georgia, 'Times New Roman', serif;
  font-weight: 500;
}

.welcome-state h2,
.complete-state h2,
.live-call h2 {
  font-size: clamp(30px, 4vw, 42px);
}

.welcome-state > p:not(.error-message, .browser-note),
.complete-state > p,
.call-help {
  max-width: 500px;
  margin: 14px 0 24px;
  color: #73676a;
  line-height: 1.65;
}

.before-list {
  display: grid;
  gap: 11px;
  width: min(100%, 430px);
  margin: 0 0 28px;
  padding: 0;
  list-style: none;
  text-align: left;
}

.before-list li {
  display: flex;
  align-items: center;
  gap: 12px;
  color: #554b4e;
  font-size: 14px;
}

.before-list span {
  display: grid;
  flex: 0 0 28px;
  width: 28px;
  height: 28px;
  place-items: center;
  border-radius: 50%;
  background: #f6e7e8;
  color: #9d4d5e;
  font-size: 12px;
  font-weight: 800;
}

.primary-action,
.secondary-action,
.finish-button,
.leave-button,
.summary-download {
  border-radius: 999px;
  font-weight: 800;
  transition:
    transform 0.18s ease,
    box-shadow 0.18s ease,
    background 0.18s ease;
}

.primary-action,
.finish-button {
  border: 0;
  background: #a94d62;
  color: #fff;
  box-shadow: 0 10px 24px rgba(169, 77, 98, 0.22);
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
  background: #913e52;
  box-shadow: 0 14px 28px rgba(169, 77, 98, 0.28);
}

.browser-note {
  margin: 13px 0 0;
  color: #998d90;
  font-size: 11px;
}

.error-message {
  width: min(100%, 470px);
  margin: 0 0 18px;
  padding: 12px 14px;
  border-radius: 12px;
  background: #fff0f0;
  color: #a13f48;
  font-size: 13px;
}

.voice-orb {
  position: relative;
  display: grid;
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
  background: linear-gradient(145deg, #b75e72, #873b50);
  box-shadow: 0 14px 32px rgba(133, 57, 77, 0.3);
  color: #fff;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 38px;
}

.orb-ring {
  position: absolute;
  border: 1px solid rgba(176, 91, 110, 0.3);
  border-radius: 50%;
  inset: 14px;
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
  color: #a65364;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.call-help {
  margin-bottom: 16px;
  font-size: 14px;
}

.audio-state {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 9px 14px;
  border-radius: 999px;
  background: #f7efed;
  color: #6a5c60;
  font-size: 12px;
  font-weight: 700;
}

.audio-bars {
  display: flex;
  align-items: center;
  gap: 2px;
  height: 14px;
}

.audio-bars i {
  display: block;
  width: 2px;
  height: 5px;
  border-radius: 9px;
  background: #a65364;
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
  margin-bottom: 8px;
  color: #776b6e;
  font-size: 12px;
}

.progress-copy strong {
  color: #4e4346;
}

.progress-track {
  height: 7px;
  overflow: hidden;
  border-radius: 99px;
  background: #eee5e3;
}

.progress-track span {
  display: block;
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, #b6586c, #d28b94);
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

.finish-button,
.leave-button,
.secondary-action {
  padding: 12px 18px;
}

.finish-button:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.leave-button,
.secondary-action,
.summary-download {
  border: 1px solid #d9cbc8;
  background: #fff;
  color: #5f5255;
}

.leave-button:hover,
.secondary-action:hover,
.summary-download:hover {
  border-color: #b97a86;
  background: #fbf1f2;
}

.complete-mark {
  display: grid;
  width: 76px;
  height: 76px;
  margin-bottom: 22px;
  place-items: center;
  border-radius: 50%;
  background: #e3f1eb;
  color: #34765f;
  font-size: 32px;
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
  font-size: 28px;
}

.not-saved-badge {
  padding: 7px 10px;
  border-radius: 999px;
  background: #edf4ef;
  color: #477160;
  font-size: 10px;
  font-weight: 800;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.transcript-panel {
  flex: 1;
  margin-top: 22px;
  overflow-y: auto;
  padding: 4px 8px 8px 0;
  scrollbar-color: #d7c6c5 transparent;
  scrollbar-width: thin;
}

.empty-transcript {
  display: grid;
  min-height: 410px;
  place-items: center;
  align-content: center;
  color: #9a8d90;
  text-align: center;
}

.empty-transcript span {
  height: 55px;
  color: #e3ced1;
  font-family: Georgia, serif;
  font-size: 72px;
  line-height: 1;
}

.empty-transcript p {
  max-width: 260px;
  margin: 8px 0 0;
  font-size: 13px;
  line-height: 1.6;
}

.message {
  width: fit-content;
  max-width: 88%;
  margin-bottom: 16px;
}

.message span {
  display: block;
  margin: 0 8px 5px;
  color: #928589;
  font-size: 10px;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.message p {
  margin: 0;
  padding: 12px 15px;
  border-radius: 8px 18px 18px 18px;
  background: #f5eeec;
  color: #493e42;
  font-size: 13px;
  line-height: 1.55;
}

.user-message {
  margin-left: auto;
}

.user-message span {
  text-align: right;
}

.user-message p {
  border-radius: 18px 8px 18px 18px;
  background: #a65364;
  color: #fff;
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
  font-size: 12px;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
  margin-top: 30px;
}

.summary-section {
  padding: 22px;
  border-radius: 18px;
  background: #faf5f3;
}

.summary-section h3 {
  margin: 0 0 14px;
  color: #514448;
  font-size: 14px;
}

.summary-section ul {
  display: grid;
  gap: 9px;
  margin: 0;
  padding-left: 18px;
  color: #706468;
  font-size: 13px;
  line-height: 1.55;
}

.summary-section dl {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 9px 16px;
  margin: 0;
  font-size: 13px;
}

.summary-section dt {
  color: #766a6d;
}

.summary-section dd {
  margin: 0;
  color: #42373b;
  font-weight: 800;
  text-align: right;
}

.safety-section {
  background: #fff3e8;
}

.scope-note {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 10px;
  max-width: 900px;
  margin: 28px auto 0;
  color: #7c7073;
  font-size: 12px;
  text-align: center;
}

.scope-note strong {
  color: #594c50;
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
</style>
