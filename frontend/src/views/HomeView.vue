<template>
  <main>
    <section class="hero-section" id="top">
      <div class="hero-copy">
        <p class="eyebrow"><span class="eyebrow-dot"></span> Prevention is powerful</p>
        <h1>Your health<br /><em>deserves a voice.</em></h1>
        <p class="hero-text">
          Cervical cancer is preventable. Learn the simple steps that help you protect your future
          and the women you love.
        </p>
        <div class="hero-actions">
          <a href="#learn" class="button button-primary">Start learning <span>↗</span></a>
          <a href="#stats" class="text-link">See the numbers <span>↓</span></a>
        </div>
      </div>
      <div class="hero-art" aria-label="Abstract illustration of a flower and sun">
        <div class="sun"></div>
        <div class="art-orbit orbit-one"></div>
        <div class="art-orbit orbit-two"></div>
        <div class="stem"></div>
        <div class="leaf leaf-left"></div>
        <div class="leaf leaf-right"></div>
        <div class="flower"><i></i><i></i><i></i><i></i><i></i></div>
        <div class="art-note note-one">Know your<br /><strong>options</strong></div>
        <div class="art-note note-two">Small steps<br /><strong>matter</strong></div>
      </div>
    </section>

    <section class="intro-section" id="learn">
      <div class="section-label">01 / The essentials</div>
      <div class="intro-grid">
        <h2>A little knowledge<br /><em>goes a long way.</em></h2>
        <div>
          <p class="lead">
            Cervical cancer starts in the cervix, but with regular screening and HPV vaccination, it
            can often be prevented before it starts.
          </p>
          <a class="arrow-link" href="#steps">Explore the essentials <span>→</span></a>
        </div>
      </div>
      <div class="steps-grid" id="steps">
        <article class="step-card">
          <span class="step-number">01</span>
          <div class="step-icon icon-shield">♡</div>
          <h3>HPV vaccination</h3>
          <p>Protects against the HPV types that cause most cervical cancers.</p>
        </article>
        <article class="step-card featured">
          <span class="step-number">02</span>
          <div class="step-icon">◌</div>
          <h3>Regular screening</h3>
          <p>Finds cell changes early, when they are easier to treat and manage.</p>
        </article>
        <article class="step-card">
          <span class="step-number">03</span>
          <div class="step-icon">✦</div>
          <h3>Know your body</h3>
          <p>Talk to a healthcare professional about anything that feels unusual.</p>
        </article>
      </div>
    </section>

    <section class="stats-section" id="stats">
      <div class="stats-heading">
        <div>
          <div class="section-label light">02 / The bigger picture</div>
          <h2>Progress is<br /><em>possible.</em></h2>
        </div>
        <p>
          When we make prevention accessible, communities become healthier. Here’s what collective
          action can do.
        </p>
      </div>
      <div class="stats-layout">
        <div class="big-stat">
          <strong>90<span>%</span></strong>
          <p>of cervical cancer cases are linked to HPV.</p>
          <div class="stat-rule"></div>
          <small>World Health Organization</small>
        </div>
        <div class="chart-card">
          <div class="chart-top">
            <h3>Prevention impact</h3>
            <span>2020 — 2030</span>
          </div>
          <svg
            viewBox="0 0 560 220"
            role="img"
            aria-label="Line chart showing prevention impact increasing over time"
          >
            <path class="grid-line" d="M0 180H560M0 125H560M0 70H560M0 15H560" />
            <path
              class="chart-area"
              d="M0 180 C70 175 80 155 140 160 S210 130 270 138 S345 80 405 91 S470 44 560 20 V180Z"
            />
            <path
              class="chart-line"
              d="M0 180 C70 175 80 155 140 160 S210 130 270 138 S345 80 405 91 S470 44 560 20"
            />
            <circle cx="560" cy="20" r="6" class="chart-dot" />
          </svg>
          <div class="chart-labels">
            <span>2020</span><span>2023</span><span>2026</span><span>2030</span>
          </div>
        </div>
      </div>
    </section>

    <section class="closing-section">
      <div class="closing-bloom"></div>
      <div class="section-label">03 / Your next step</div>
      <h2>Care for yourself.<br /><em>Share what you know.</em></h2>
      <p>Every conversation can help someone take their next step toward prevention.</p>
      <a href="#learn" class="button button-dark">Keep exploring <span>↗</span></a>
    </section>
  </main>
</template>

<style scoped>
.hero-section {
  height: calc(100dvh - 78px);
  min-height: 0;
  box-sizing: border-box;

  background: #f8e9e9;

  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: center;

  padding: clamp(30px, 5vh, 60px) max(6vw, 40px);
  overflow: hidden;
}
.hero-copy {
  max-width: 570px;
  z-index: 1;
  animation: hero-fade-in 800ms ease-out both;
}
.hero-art {
  animation: hero-fade-in 900ms 120ms ease-out both;
}
@keyframes hero-fade-in {
  from {
    opacity: 0;
    transform: translateY(18px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
@media (prefers-reduced-motion: reduce) {
  .hero-copy,
  .hero-art {
    animation: none;
  }
}
.eyebrow,
.section-label {
  font-size: 11px;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  font-weight: 700;
  color: #b06b70;
}
.eyebrow {
  display: flex;
  gap: 10px;
  align-items: center;
}
.eyebrow-dot {
  height: 8px;
  width: 8px;
  border-radius: 50%;
  background: #d47a82;
}
.hero-copy h1 {
  font-size: clamp(52px, 6vw, 90px);
  line-height: 0.98;
  letter-spacing: -0.065em;
  margin: 24px 0;
  color: #282326;
  font-weight: 700;
}
.hero-copy h1 em,
.intro-grid em,
.stats-heading em,
.closing-section em {
  font-family: Georgia, serif;
  font-weight: 400;
  color: #a75d68;
}
.hero-text {
  max-width: 420px;
  line-height: 1.7;
  color: #6e6263;
  font-size: 16px;
}
.hero-actions {
  display: flex;
  align-items: center;
  gap: 28px;
  margin-top: 34px;
}
.button {
  display: inline-flex;
  align-items: center;
  gap: 18px;
  border-radius: 100px;
  padding: 15px 21px;
  font-size: 13px;
  font-weight: 700;
  transition:
    transform 0.2s,
    box-shadow 0.2s;
}
.button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 18px #0002;
}
.button-primary {
  background: #b9626d;
  color: #fff;
}
.button span {
  font-size: 18px;
}
.text-link,
.arrow-link {
  color: #5c4b4d;
  text-decoration: underline;
  text-underline-offset: 5px;
  font-size: 13px;
  font-weight: 700;
}
.hero-art {
  height: 510px;
  position: relative;
}
.sun {
  position: absolute;
  width: 340px;
  height: 340px;
  background: #e9b9a8;
  border-radius: 50%;
  top: 72px;
  left: 50%;
  transform: translateX(-50%);
}
.art-orbit {
  position: absolute;
  border: 1px solid #c8897d;
  border-radius: 50%;
  left: 50%;
  transform: translateX(-50%) rotate(-25deg);
}
.orbit-one {
  width: 420px;
  height: 210px;
  top: 150px;
}
.orbit-two {
  width: 490px;
  height: 265px;
  top: 122px;
  transform: translateX(-50%) rotate(35deg);
}
.stem {
  position: absolute;
  bottom: 35px;
  left: 50%;
  height: 270px;
  border-left: 4px solid #617b63;
  transform: rotate(7deg);
  transform-origin: bottom;
}
.leaf {
  position: absolute;
  background: #769378;
  width: 100px;
  height: 50px;
  border-radius: 100% 0 100% 0;
}
.leaf-left {
  bottom: 145px;
  left: calc(50% - 92px);
  transform: rotate(18deg);
}
.leaf-right {
  bottom: 205px;
  left: calc(50% + 5px);
  transform: rotate(-38deg) scaleX(-1);
}
.flower {
  position: absolute;
  left: calc(50% - 39px);
  top: 105px;
  width: 78px;
  height: 78px;
}
.flower i {
  position: absolute;
  width: 48px;
  height: 67px;
  border-radius: 100% 0 100% 0;
  background: #b95f6a;
  left: 15px;
  top: 5px;
  transform-origin: 24px 34px;
}
.flower i:nth-child(2) {
  transform: rotate(72deg);
}
.flower i:nth-child(3) {
  transform: rotate(144deg);
}
.flower i:nth-child(4) {
  transform: rotate(216deg);
}
.flower i:nth-child(5) {
  transform: rotate(288deg);
}
.flower:after {
  content: '';
  position: absolute;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: #f5cf9d;
  left: 28px;
  top: 28px;
}
.art-note {
  position: absolute;
  background: #fffaf6;
  padding: 14px 17px;
  color: #997177;
  font-family: Georgia, serif;
  font-size: 15px;
  line-height: 1.15;
  box-shadow: 0 9px 25px #7c555522;
}
.art-note strong {
  font-family: inherit;
  font-size: 20px;
  color: #73484e;
}
.note-one {
  top: 60px;
  right: 7%;
}
.note-two {
  bottom: 60px;
  left: 7%;
}
.intro-section {
  padding: 92px max(6vw, 40px) 100px;
  background: #fffaf8;
}
.intro-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10%;
  margin: 22px 0 62px;
}
.intro-grid h2,
.stats-heading h2,
.closing-section h2 {
  font-size: clamp(38px, 4vw, 60px);
  line-height: 1.04;
  letter-spacing: -0.055em;
  color: #282326;
}
.lead {
  max-width: 410px;
  color: #716567;
  line-height: 1.7;
  font-size: 16px;
}
.arrow-link {
  display: inline-block;
  margin-top: 25px;
  color: #a75d68;
}
.steps-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
}
.step-card {
  border: 1px solid #eadedb;
  padding: 25px;
  background: #fffaf8;
  min-height: 250px;
  position: relative;
}
.step-card.featured {
  background: #f6e1df;
  border-color: #f6e1df;
}
.step-number {
  font-size: 11px;
  color: #bd8385;
  letter-spacing: 0.1em;
}
.step-icon {
  color: #b7626d;
  font-size: 38px;
  margin: 30px 0 18px;
  line-height: 1;
}
.step-card h3 {
  font-size: 19px;
  color: #332a2d;
  font-weight: 700;
}
.step-card p {
  font-size: 13px;
  line-height: 1.6;
  color: #806e70;
  max-width: 230px;
  margin-top: 8px;
}
.stats-section {
  background: #2e292c;
  color: #fffaf8;
  padding: 90px max(6vw, 40px) 105px;
}
.light {
  color: #d39a9a;
}
.stats-heading {
  display: flex;
  justify-content: space-between;
  align-items: end;
  margin-bottom: 65px;
}
.stats-heading h2 {
  color: #fffaf8;
  margin-top: 20px;
}
.stats-heading p {
  max-width: 300px;
  color: #b9adae;
  line-height: 1.6;
  font-size: 14px;
}
.stats-layout {
  display: grid;
  grid-template-columns: 0.75fr 1.5fr;
  gap: 9%;
  align-items: center;
}
.big-stat strong {
  font-size: clamp(82px, 10vw, 145px);
  letter-spacing: -0.08em;
  line-height: 1;
  color: #efc4b7;
}
.big-stat strong span {
  font-size: 0.5em;
  color: #d48c8f;
}
.big-stat p {
  max-width: 180px;
  color: #d4c8c7;
  line-height: 1.5;
  margin: 18px 0 28px;
}
.stat-rule {
  height: 1px;
  background: #695e60;
  max-width: 210px;
}
.big-stat small {
  color: #968b8d;
  font-size: 10px;
}
.chart-card {
  background: #3a3437;
  padding: 26px 28px;
}
.chart-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.chart-top h3 {
  font-size: 15px;
}
.chart-top span {
  font-size: 11px;
  color: #a99c9e;
}
.chart-card svg {
  width: 100%;
  height: auto;
  overflow: visible;
}
.grid-line {
  stroke: #554d50;
  stroke-width: 1;
}
.chart-line {
  fill: none;
  stroke: #e5a69e;
  stroke-width: 4;
  stroke-linecap: round;
}
.chart-area {
  fill: #b56f7540;
}
.chart-dot {
  fill: #f8c7b7;
  stroke: #3a3437;
  stroke-width: 4;
}
.chart-labels {
  display: flex;
  justify-content: space-between;
  color: #918587;
  font-size: 10px;
  margin-top: 10px;
}
.closing-section {
  text-align: center;
  background: #f6e4df;
  padding: 110px 24px 120px;
  position: relative;
  overflow: hidden;
}
.closing-bloom {
  position: absolute;
  width: 260px;
  height: 260px;
  border-radius: 50%;
  background: #efc1b3;
  left: -80px;
  bottom: -100px;
  opacity: 0.55;
}
.closing-section .section-label,
.closing-section h2,
.closing-section p,
.closing-section .button {
  position: relative;
}
.closing-section h2 {
  margin: 20px 0;
}
.closing-section p {
  color: #806f70;
  margin: 20px auto 30px;
  font-size: 15px;
}
.button-dark {
  background: #302a2d;
  color: #fff;
}
@media (max-width: 760px) {
  .hero-section {
    height: auto;
    min-height: calc(100dvh - 78px);

    display: grid;
    grid-template-columns: 1fr;

    padding: 50px 24px 30px;
    overflow: hidden;
  }

  .hero-copy h1 {
    font-size: 58px;
  }

  .hero-art {
    height: 350px;
    margin-top: 10px;
  }

  .sun {
    width: 270px;
    height: 270px;
    top: 45px;
  }

  .orbit-one {
    width: 335px;
    top: 120px;
  }

  .orbit-two {
    width: 385px;
    top: 95px;
  }

  .flower {
    top: 70px;
  }

  .note-one {
    right: 0;
  }

  .note-two {
    left: 0;
  }
}

.site-shell {
  min-height: 100vh;
  background: #fffaf8;
}

.page-content {
  width: 100%;
}
</style>
