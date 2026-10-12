class Pcm16CaptureProcessor extends AudioWorkletProcessor {
  constructor() {
    super()
    this.targetSampleRate = 16000
    this.sourcePosition = 0
    this.carry = new Float32Array(0)
    this.pendingSamples = []
  }

  process(inputs) {
    const input = inputs[0]?.[0]
    if (!input?.length) return true

    const samples = new Float32Array(this.carry.length + input.length)
    samples.set(this.carry)
    samples.set(input, this.carry.length)

    const ratio = sampleRate / this.targetSampleRate

    while (this.sourcePosition + ratio <= samples.length) {
      const start = Math.floor(this.sourcePosition)
      const end = Math.max(start + 1, Math.floor(this.sourcePosition + ratio))
      let total = 0

      for (let index = start; index < end && index < samples.length; index += 1) {
        total += samples[index]
      }

      const average = total / Math.max(1, end - start)
      const clamped = Math.max(-1, Math.min(1, average))
      this.pendingSamples.push(
        clamped < 0 ? Math.round(clamped * 32768) : Math.round(clamped * 32767),
      )
      this.sourcePosition += ratio
    }

    const consumed = Math.floor(this.sourcePosition)
    this.carry = samples.slice(consumed)
    this.sourcePosition -= consumed

    while (this.pendingSamples.length >= 1600) {
      const frame = new Int16Array(
        this.pendingSamples.splice(0, 1600),
      )
      this.port.postMessage(frame.buffer, [frame.buffer])
    }

    return true
  }
}

registerProcessor('pcm16-capture-processor', Pcm16CaptureProcessor)

class Pcm16PlaybackProcessor extends AudioWorkletProcessor {
  constructor() {
    super()
    this.queue = []
    this.queueOffset = 0
    this.bufferedSamples = 0
    this.sourceCarry = new Float32Array(0)
    this.sourcePosition = 0
    this.playing = false
    this.turnEnded = false
    this.drainedSent = false
    this.fadeSamples = Math.max(32, Math.round(sampleRate * 0.003))
    this.fadeInRemaining = 0
    this.lastSample = 0

    this.port.onmessage = ({ data }) => {
      if (data?.type === 'audio' && data.buffer) {
        this.turnEnded = false
        this.drainedSent = false
        this.enqueuePcm(data.buffer, data.inputSampleRate || 24000)
        return
      }

      if (data?.type === 'end-turn') {
        this.flushSourceCarry()
        this.turnEnded = true
        this.notifyIfDrained()
        return
      }

      if (data?.type === 'reset') this.reset()
    }
  }

  enqueuePcm(buffer, inputSampleRate) {
    const pcm = new Int16Array(buffer)
    const incoming = new Float32Array(pcm.length)

    for (let index = 0; index < pcm.length; index += 1) {
      incoming[index] = pcm[index] / 32768
    }

    const source = new Float32Array(this.sourceCarry.length + incoming.length)
    source.set(this.sourceCarry)
    source.set(incoming, this.sourceCarry.length)
    const ratio = inputSampleRate / sampleRate
    const output = []

    while (this.sourcePosition + 1 < source.length) {
      const left = Math.floor(this.sourcePosition)
      const fraction = this.sourcePosition - left
      output.push(source[left] + (source[left + 1] - source[left]) * fraction)
      this.sourcePosition += ratio
    }

    const consumed = Math.floor(this.sourcePosition)
    this.sourceCarry = source.slice(consumed)
    this.sourcePosition -= consumed
    this.enqueueSamples(output)
  }

  enqueueSamples(samples) {
    if (!samples.length) return
    const chunk = Float32Array.from(samples)
    this.queue.push(chunk)
    this.bufferedSamples += chunk.length
  }

  flushSourceCarry() {
    if (this.sourceCarry.length > 0) {
      this.enqueueSamples([this.sourceCarry[this.sourceCarry.length - 1]])
    }
    this.sourceCarry = new Float32Array(0)
    this.sourcePosition = 0
  }

  reset() {
    this.queue = []
    this.queueOffset = 0
    this.bufferedSamples = 0
    this.sourceCarry = new Float32Array(0)
    this.sourcePosition = 0
    this.playing = false
    this.turnEnded = false
    this.drainedSent = false
    this.fadeInRemaining = 0
    this.lastSample = 0
  }

  notifyIfDrained() {
    if (this.turnEnded && this.bufferedSamples === 0 && !this.drainedSent) {
      this.drainedSent = true
      this.playing = false
      this.port.postMessage({ type: 'drained' })
    }
  }

  process(_inputs, outputs) {
    const output = outputs[0]?.[0]
    if (!output) return true
    output.fill(0)

    const startThreshold = Math.round(sampleRate * 0.12)
    if (!this.playing) {
      if (this.bufferedSamples >= startThreshold || (this.turnEnded && this.bufferedSamples > 0)) {
        this.playing = true
        this.fadeInRemaining = this.fadeSamples
      } else {
        this.notifyIfDrained()
        return true
      }
    }

    let outputIndex = 0
    while (outputIndex < output.length && this.bufferedSamples > 0) {
      const chunk = this.queue[0]
      let value = chunk[this.queueOffset]

      if (this.fadeInRemaining > 0) {
        value *= 1 - this.fadeInRemaining / this.fadeSamples
        this.fadeInRemaining -= 1
      }
      if (this.turnEnded && this.bufferedSamples <= this.fadeSamples) {
        value *= this.bufferedSamples / this.fadeSamples
      }

      output[outputIndex] = value
      this.lastSample = value
      outputIndex += 1
      this.queueOffset += 1
      this.bufferedSamples -= 1

      if (this.queueOffset >= chunk.length) {
        this.queue.shift()
        this.queueOffset = 0
      }
    }

    if (outputIndex < output.length) {
      const remaining = output.length - outputIndex
      for (let index = 0; index < remaining; index += 1) {
        output[outputIndex + index] = this.lastSample * (1 - (index + 1) / remaining)
      }
      this.lastSample = 0
      this.playing = false
      this.fadeInRemaining = this.fadeSamples
    }

    this.notifyIfDrained()
    return true
  }
}

registerProcessor('pcm16-playback-processor', Pcm16PlaybackProcessor)
