<template>
  <main class="detail-page">
    <section class="detail-hero">
      <div class="detail-hero-inner">
        <RouterLink to="/gpFinder" class="back-link">← Back to search results</RouterLink>
        <div class="hero-copy">
          <p class="eyebrow"><span class="eyebrow-dot"></span> Service detail</p>
          <h1>Monash University Health Service - Clayton</h1>
          <div class="service-meta">
            <span>GP (General Practice)</span>
          </div>
          <p class="opening-status"><strong>Open</strong> · Opens 8:45am tomorrow</p>
        </div>
      </div>
    </section>

    <section class="details-section">
      <div class="details-grid">
        <article class="service-details-panel">
          <p class="section-label">Service details</p>
          <h2>Opening times</h2>
          <dl class="opening-times">
            <div><dt>Today</dt><dd>8:45am–5pm</dd></div>
          </dl>

          <h2>Contact</h2>
          <dl class="contact-list">
            <div><dt>Address</dt><dd>21 Chancellors Walk Clayton VIC 3168</dd></div>
            <div><dt>Phone</dt><dd><a href="tel:0399053175">03 9905 3175</a></dd></div>
            <div><dt>Fax</dt><dd>03 9905 4190</dd></div>
            <div><dt>Email</dt><dd><a href="mailto:health.clayton@monash.edu">health.clayton@monash.edu</a></dd></div>
            <div><dt>Website</dt><dd><a href="https://www.monash.edu/health" target="_blank" rel="noreferrer">Monash University Health Service - Clayton</a></dd></div>
          </dl>
        </article>

        <aside class="about-card">
          <p class="section-label">About this service</p>
          <h2>Access</h2>
          <ul>
            <li><span aria-hidden="true">♿</span> Accessible toilet, wheelchair accessible, accessible parking</li>
            <li><span aria-hidden="true">▣</span> Paid parking</li>
            <li><span aria-hidden="true">⌁</span> Hearing induction loop</li>
            <li><span aria-hidden="true">▦</span> Toilet</li>
            <li><span aria-hidden="true">▥</span> Braille signage</li>
            <li><span aria-hidden="true">◈</span> Appointment needed</li>
          </ul>
          <p class="about-note">You will need to make an appointment to access this service.</p>
        </aside>
      </div>
    </section>

    <section class="practitioner-section">
      <div class="practitioner-inner">
        <p class="section-label">Meet the team</p>
        <h2>Practitioner</h2>
        <div class="practitioner-grid">
          <article v-for="practitioner in practitioners" :key="practitioner.name" class="practitioner-card">
            <span class="practitioner-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" role="presentation">
                <path d="M9.5 4.5h5v5h5v5h-5v5h-5v-5h-5v-5h5z" />
              </svg>
            </span>
            <p><strong>{{ practitioner.name }}</strong><span>{{ practitioner.specialty }}</span></p>
          </article>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup lang="ts">
import { RouterLink } from 'vue-router'
import '../assets/gpFinderDetail.css'

const practitioners = [
  { name: 'Dr Darren So', specialty: 'General practitioner, Male' },
  { name: 'Dr Rimma Medres', specialty: 'General practitioner, Female · Speaks: Russian' },
  { name: 'Dr Angeline Goh', specialty: 'General practitioner, Female' },
  { name: 'Dr Susan Gordon', specialty: 'General practitioner, Female' },
  { name: 'Dr Steven Ho', specialty: 'General practitioner, Male' },
  { name: 'Dr Shraddha Nikathil', specialty: 'General practitioner, Female' },
]
</script>

