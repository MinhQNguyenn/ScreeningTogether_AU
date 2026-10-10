<template>
  <div class="site-shell" :class="[`theme-${selectedTheme}`, `text-size-${textSize}`]">
    <header class="site-header">
      <RouterLink to="/" class="brand"
        ><span class="brand-mark" aria-hidden="true">
          <span></span>
          <span></span>
          <span></span>
        </span>
        ScreeningTogether AU</RouterLink
      >
      <nav :class="['main-nav', { open: menuOpen }]" aria-label="Main navigation">
        <RouterLink to="/">{{ t('header.home') }}</RouterLink>
        <RouterLink to="/data">{{ t('header.data') }}</RouterLink>
        <RouterLink to="/faq">{{ t('header.faq') }}</RouterLink>

        <RouterLink to="/guide">{{ t('header.guide') }}</RouterLink>
        <RouterLink to="/gpfinder" @click="closeMenu">{{ t('header.gpFinder') }}</RouterLink>
        <RouterLink to="/resourceinfo">{{ t('header.resourceInfo') }}</RouterLink>
        <RouterLink to="/call-practice">{{ t('header.practice') }}</RouterLink>
      </nav>
      <button class="header-cta" type="button" @click="openExplore">
        <span v-if="isMobile">{{ t('header.exploreMobile') }}</span>
        <span v-else>{{ t('header.exploreTogether') }}</span>
      </button>

      <div sclass="dropdown language-control">
        <button
          class="btn btn-dark dropdown-toggle language-button"
          type="button"
          data-bs-toggle="dropdown"
          aria-expanded="false"
        >
          <span class="language-symbol">文A</span>
        </button>

        <ul class="dropdown-menu dropdown-menu-end">
          <li>
            <button class="dropdown-item" @click="changeLanguage('en')">English</button>
          </li>
          <li>
            <button class="dropdown-item" @click="changeLanguage('zh-HK')">廣東話</button>
          </li>
          <li>
            <button class="dropdown-item" @click="changeLanguage('zh-CN')">中文</button>
          </li>
          <li>
            <button class="dropdown-item" @click="changeLanguage('ar')">العربية</button>
          </li>
          <li>
            <button class="dropdown-item" @click="changeLanguage('vi')">Tiếng Việt</button>
          </li>
        </ul>
      </div>

      <button
        class="menu-toggle"
        type="button"
        :aria-label="menuOpen ? 'Close menu' : 'Open menu'"
        :aria-expanded="menuOpen"
        @click="toggleMenu"
      >
        <template v-if="menuOpen">
          <span class="close-icon">×</span>
        </template>

        <template v-else>
          <span></span>
          <span></span>
          <span></span>
        </template>
      </button>
    </header>
    <RouterView v-slot="{ Component }">
      <component :is="Component" v-on="isHomePage ? { 'open-explore': openExplore } : {}" />
    </RouterView>
    <footer class="site-footer">
      <div class="footer-acknowledgement">
        <span class="footer-leaf" aria-hidden="true"
          ><img src="./assets/cervical-cancer-ribbon.png"
        /></span>
        <p>{{ t('footer.acknowledgement') }}</p>
      </div>
      <div class="footer-columns">
        <div class="footer-about">
          <RouterLink to="/" class="brand"
            ><img
              class="footer-brand-logo"
              src="https://cdn.builder.io/api/v1/image/assets%2F9a3562f282554c16b26aa3f121a432bf%2F158611f967d7475c9c8e3f746c8da3e9?format=webp&width=800&height=1200"
              alt=""
            />ScreeningTogether AU</RouterLink
          >
          <p>{{ t('footer.tagline') }}</p>
        </div>
        <div>
          <h2>{{ t('footer.pages') }}</h2>
          <RouterLink to="/">{{ t('header.home') }}</RouterLink>
          <RouterLink to="/data">{{ t('header.data') }}</RouterLink>
          <RouterLink to="/faq">{{ t('header.faq') }}</RouterLink>
          <RouterLink to="/gpfinder">{{ t('header.gpFinder') }}</RouterLink>
          <RouterLink to="/guide">{{ t('header.guide') }}</RouterLink>
          <RouterLink to="/resourceinfo">{{ t('header.resourceInfo') }}</RouterLink>
        </div>
        <div>
          <h2>{{ t('footer.dataSources') }}</h2>
          <a href="https://www.canceraustralia.gov.au/" target="_blank" rel="noreferrer">{{
            t('footer.cancerAustralia')
          }}</a>
          <a href="https://www.health.gov.au/" target="_blank" rel="noreferrer">{{
            t('footer.healthDepartment')
          }}</a>
        </div>
      </div>
      <div class="footer-bottom">{{ t('footer.copyright') }}</div>
    </footer>

    <div v-if="exploreOpen" class="overlay-backdrop" @click.self="closeExplore">
      <section
        class="explore-modal"
        role="dialog"
        aria-modal="true"
        :aria-labelledby="'explore-title'"
      >
        <button
          class="modal-close"
          type="button"
          :aria-label="t('explore.close')"
          @click="closeExplore"
        >
          ×
        </button>
        <p class="modal-eyebrow">{{ t('explore.eyebrow') }}</p>
        <h2 id="explore-title">{{ t('explore.title') }}</h2>
        <p class="explore-intro">{{ t('explore.intro') }}</p>
        <div class="explore-options">
          <button
            v-for="(option, index) in exploreOptions"
            :key="option.title"
            type="button"
            :class="['explore-option', { selected: selectedExploreOption === index }]"
            :aria-pressed="selectedExploreOption === index"
            @click="selectExploreOption(index)"
          >
            <span class="option-icon" aria-hidden="true">{{ option.icon }}</span>
            <span
              ><strong>{{ option.title }}</strong
              ><small>{{ option.description }}</small></span
            >
          </button>
        </div>
        <RouterLink to="/">
          <button class="start-over-link" type="button" @click="closeExplore">
            {{ t('explore.startBeginning') }} <span aria-hidden="true">→</span>
          </button>
        </RouterLink>
      </section>
    </div>

    <div v-if="gameStartOpen" class="overlay-backdrop game-start-backdrop">
      <!-- Game 1 (existing guide, unchanged) -->
      <section
        v-if="currentGameGuide === 'runner'"
        class="game-start-modal"
        role="dialog"
        aria-modal="true"
        :aria-labelledby="'game-start-title'"
      >
        <p class="modal-eyebrow">{{ t('gameStart.eyebrow') }}</p>
        <h2 id="game-start-title">{{ t('gameStart.title') }}</h2>
        <p class="game-start-copy">{{ t('gameStart.description') }}</p>
        <div class="game-start-goal">
          <span aria-hidden="true">🎯</span>{{ t('gameStart.goal') }}
        </div>
        <div class="game-start-controls">
          <strong>{{ t('gameStart.move') }}</strong
          ><kbd>←</kbd><kbd>→</kbd><strong>{{ t('gameStart.jump') }}</strong
          ><kbd>↑</kbd>
        </div>
        <p class="game-start-rule"><span aria-hidden="true">♥</span> {{ t('gameStart.rule') }}</p>
        <button class="game-start-button" type="button" @click="gameStartOpen = false">
          {{ t('gameStart.begin') }} <span aria-hidden="true">→</span>
        </button>
      </section>

      <!-- Game 2 and Game 3 -->
      <section
        v-else-if="extraGuide"
        class="game-start-modal"
        role="dialog"
        aria-modal="true"
        :aria-labelledby="'game-start-title'"
      >
        <p class="modal-eyebrow">{{ extraGuide.eyebrow }}</p>
        <h2 id="game-start-title">{{ extraGuide.title }}</h2>
        <ol class="game-guide-steps">
          <li v-for="step in extraGuide.steps" :key="step.title">
            <span class="guide-step-icon" aria-hidden="true">{{ step.icon }}</span>
            <span>
              <strong>{{ step.title }}</strong>
              <small>{{ step.description }}</small>
            </span>
          </li>
        </ol>
        <button class="game-start-button" type="button" @click="gameStartOpen = false">
          {{ t('gameStart.begin') }} <span aria-hidden="true">→</span>
        </button>
      </section>
    </div>

    <button
      class="accessibility-trigger d-flex align-items-center justify-content-center p-0"
      type="button"
      aria-label="Open display options"
      :aria-expanded="displayOptionsOpen"
      @click="displayOptionsOpen = !displayOptionsOpen"
    >
      <svg
        class="w-75 h-75"
        viewBox="0 0 308 550"
        preserveAspectRatio="xMidYMid meet"
        xmlns="http://www.w3.org/2000/svg"
        aria-hidden="true"
      >
        <g transform="translate(0 550) scale(0.05 -0.05)" fill="#403e3e" stroke="none">
          <path
            d="M2880 9841 c-446 -121 -711 -393 -834 -855 -52 -198 -49 -698 6 -826
75 -177 74 -176 157 -112 453 346 1263 361 1783 32 92 -58 129 -72 142 -54
122 163 140 794 31 1087 -205 555 -763 870 -1285 728z"
          />
          <path
            d="M4530 8860 c75 -437 12 -773 -207 -1100 -166 -246 -758 -1103 -890
-1287 -140 -195 -159 -127 162 -588 151 -217 284 -414 295 -436 43 -88 381
-548 399 -542 11 3 112 145 225 314 114 170 250 372 303 449 352 511 393 1126
140 2090 -97 369 -465 1316 -427 1100z"
          />
          <path
            d="M1621 8686 c-47 -108 -96 -223 -111 -256 -89 -203 -232 -699 -308
-1067 -96 -465 -65 -1158 63 -1423 52 -108 776 -1178 1394 -2060 69 -98 466
-673 605 -876 47 -69 118 -170 156 -224 39 -54 109 -155 157 -224 48 -69 165
-238 261 -376 95 -137 232 -335 304 -440 72 -104 188 -271 258 -370 239 -339
379 -540 463 -665 108 -160 114 -159 194 50 71 185 282 720 496 1260 144 365
144 332 -3 525 -46 61 -119 164 -162 230 -43 66 -83 125 -89 130 -6 6 -61 82
-122 170 -61 88 -231 331 -378 540 -147 209 -313 448 -370 530 -57 83 -233
335 -391 561 -293 419 -408 586 -660 959 -77 116 -170 251 -205 300 -35 50
-182 261 -326 470 -145 209 -295 425 -334 480 -38 55 -129 186 -201 290 -71
105 -168 244 -214 310 -259 368 -286 413 -349 590 -47 131 -70 420 -48 607 24
211 19 209 -80 -21z"
          />
          <path
            d="M1936 4305 c-16 -19 -82 -111 -147 -205 -297 -433 -756 -1089 -1054
-1508 -176 -248 -171 -224 -95 -426 35 -97 77 -203 91 -236 14 -33 66 -163
116 -290 49 -126 138 -356 199 -510 60 -154 134 -345 165 -425 69 -177 57
-177 183 10 57 85 250 364 430 620 830 1182 1096 1573 1096 1608 0 15 -162
261 -359 547 -439 635 -589 850 -592 850 -2 0 -16 -16 -33 -35z"
          />
        </g>
      </svg>
    </button>

    <aside
      v-if="displayOptionsOpen"
      class="display-options"
      :aria-label="t('displayOptions.ariaLabel')"
    >
      <button
        class="display-options-close"
        type="button"
        :aria-label="t('displayOptions.close')"
        @click="displayOptionsOpen = false"
      >
        ×
      </button>
      <p class="display-options-title">{{ t('displayOptions.title') }}</p>
      <p class="display-options-intro">{{ t('displayOptions.intro') }}</p>
      <fieldset>
        <legend>{{ t('displayOptions.appearance') }}</legend>
        <div class="option-grid option-grid-themes">
          <button
            type="button"
            :class="['option-card', { selected: selectedTheme === 'blush' }]"
            @click="setTheme('blush')"
          >
            <span class="theme-swatch swatch-blush"></span> {{ t('displayOptions.themes.blush') }}
          </button>
          <button
            type="button"
            :class="['option-card', { selected: selectedTheme === 'teal' }]"
            @click="setTheme('teal')"
          >
            <span class="theme-swatch swatch-teal"></span> {{ t('displayOptions.themes.teal') }}
          </button>
          <button
            type="button"
            :class="['option-card', { selected: selectedTheme === 'accessible' }]"
            @click="setTheme('accessible')"
          >
            <span class="theme-swatch swatch-accessible"></span>
            {{ t('displayOptions.themes.accessible') }}
          </button>
        </div>
      </fieldset>
      <fieldset>
        <legend>{{ t('displayOptions.textSize.title') }}</legend>
        <div class="option-grid option-grid-text">
          <button
            type="button"
            :class="['option-card', { selected: textSize === 'normal' }]"
            @click="setTextSize('normal')"
          >
            {{ t('displayOptions.textSize.normal') }}
          </button>
          <button
            type="button"
            :class="['option-card', { selected: textSize === 'larger' }]"
            @click="setTextSize('larger')"
          >
            {{ t('displayOptions.textSize.larger') }}
          </button>
          <button
            type="button"
            :class="['option-card', { selected: textSize === 'largest' }]"
            @click="setTextSize('largest')"
          >
            {{ t('displayOptions.textSize.largest') }}
          </button>
        </div>
      </fieldset>
      <button class="reset-display-options" type="button" @click="resetDisplayOptions">
        {{ t('displayOptions.reset') }}
      </button>
    </aside>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref, computed, watch } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import { useTranslation } from './i18n/useTranslation'

const menuOpen = ref(window.innerWidth > 900)
const isMobile = ref(window.innerWidth <= 900)

const route = useRoute()
const router = useRouter()
const isHomePage = computed(() => route.path === '/')

const { t, changeLanguage } = useTranslation()
const exploreOpen = ref(false)
const gameStartOpen = ref(false)
const selectedExploreOption = ref<number | null>(null)
const exploreOptions = computed(() => [
  {
    icon: '〜',
    title: t('explore.options.nervous.title'),
    description: t('explore.options.nervous.description'),
  },
  {
    icon: '🧭',
    title: t('explore.options.new.title'),
    description: t('explore.options.new.description'),
  },
  {
    icon: '▤',
    title: t('explore.options.room.title'),
    description: t('explore.options.room.description'),
  },
  {
    icon: '✓',
    title: t('explore.options.book.title'),
    description: t('explore.options.book.description'),
  },
])

const openExplore = () => {
  selectedExploreOption.value = null
  exploreOpen.value = true
  closeMenu()
}
const closeExplore = () => {
  exploreOpen.value = false
}
type GameGuide = 'runner' | 'game2' | 'game3'

const gameGuideByRoute: Record<string, GameGuide> = {
  '/game': 'runner',
  '/gprunner': 'runner',
  '/iteration1/gprunner': 'runner',
  '/iteration2/game': 'runner',
  '/iteration2/gprunner': 'runner',
  '/game2': 'game2',
  '/iteration2/game2': 'game2',
  '/game3': 'game3',
  '/iteration2/game3': 'game3',
}

const currentGameGuide = ref<GameGuide | null>(null)

watch(
  () => route.path,
  (path) => {
    const guide = gameGuideByRoute[path] ?? null
    currentGameGuide.value = guide
    gameStartOpen.value = guide !== null
  },
  { immediate: true },
)

const game2Ns = { ns: 'game2' }
const game3Ns = { ns: 'game3' }

const extraGuide = computed(() => {
  if (currentGameGuide.value === 'game2') {
    return {
      eyebrow: t('gameStart.eyebrowGame2'),
      title: t('howToPlay.label', game2Ns),
      steps: [
        {
          icon: '👀',
          title: t('howToPlay.steps.watchAndListen.title', game2Ns),
          description: t('howToPlay.steps.watchAndListen.description', game2Ns),
        },
        {
          icon: '⏱',
          title: t('howToPlay.steps.respondInTime.title', game2Ns),
          description: t('howToPlay.steps.respondInTime.description', game2Ns),
        },
        {
          icon: '🔍',
          title: t('howToPlay.steps.exploreWhileWaiting.title', game2Ns),
          description: t('howToPlay.steps.exploreWhileWaiting.description', game2Ns),
        },
      ],
    }
  }

  if (currentGameGuide.value === 'game3') {
    return {
      eyebrow: t('gameStart.eyebrowGame3'),
      title: t('learning.label', game3Ns),
      steps: [
        {
          icon: '💬',
          title: t('learning.choices.title', game3Ns),
          description: t('learning.choices.description', game3Ns),
        },
        {
          icon: '⏱',
          title: t('learning.minutes.title', game3Ns),
          description: t('learning.minutes.animationDescription', game3Ns),
        },
        {
          icon: '📋',
          title: t('learning.after.title', game3Ns),
          description: t('learning.after.description', game3Ns),
        },
      ],
    }
  }

  return null
})
watch([exploreOpen, gameStartOpen], ([explore, game]) => {
  document.body.style.overflow = explore || game ? 'hidden' : ''
})

const selectExploreOption = (index: number) => {
  selectedExploreOption.value = index

  const routes = [
    '/gprunner', // Nervous
    '/game2', // New
    '/game3', // Room
    '/gpfinder', // Book
  ]

  const targetRoute = routes[index]

  if (targetRoute) {
    closeExplore()
    router.push(targetRoute)
  }
}

const toggleMenu = () => {
  menuOpen.value = !menuOpen.value
}

const closeMenu = () => {
  menuOpen.value = false
}

const handleResize = () => {
  isMobile.value = window.innerWidth <= 900

  if (window.innerWidth > 900) {
    menuOpen.value = true
  }
}

type ThemeName = 'blush' | 'teal' | 'accessible'
type TextSize = 'normal' | 'larger' | 'largest'

const displayOptionsOpen = ref(false)

const selectedTheme = ref<ThemeName>('blush')
const textSize = ref<TextSize>('normal')

const applyDisplayOptions = () => {
  localStorage.setItem(
    'screening-together-display-options',
    JSON.stringify({
      theme: selectedTheme.value,
      textSize: textSize.value,
    }),
  )
}

const setTheme = (theme: ThemeName) => {
  selectedTheme.value = theme
  applyDisplayOptions()
}

const setTextSize = (size: TextSize) => {
  textSize.value = size
  applyDisplayOptions()
}

const resetDisplayOptions = () => {
  selectedTheme.value = 'blush'
  textSize.value = 'normal'
  applyDisplayOptions()
}

onMounted(() => {
  const savedOptions = localStorage.getItem('screening-together-display-options')

  if (savedOptions) {
    const options = JSON.parse(savedOptions) as {
      theme?: ThemeName
      textSize?: TextSize
    }

    if (options.theme) {
      selectedTheme.value = options.theme
    }

    if (options.textSize) {
      textSize.value = options.textSize
    }
  }

  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.site-shell {
  min-height: 100vh;
  background: #fffaf8;
}

.site-header {
  height: 78px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 max(6vw, 24px);
  background: #fffaf8;
  position: sticky;
  top: 0;
  z-index: 1050;
  transition: transform 0.25s ease;
}

.site-header.header-hidden {
  transform: translateY(-100%);
}

.brand {
  font-size: 18px;
  letter-spacing: -0.045em;
  color: #302a2d;
  font-weight: 800;
  white-space: nowrap;
}

.brand-mark {
  position: relative;
  display: inline-block;
  width: 22px;
  height: 22px;
  margin-right: 6px;
  vertical-align: -5px;
}

.brand-mark span {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 2px;
  height: 22px;
  border-radius: 999px;
  background: #bd6f76;
  transform-origin: center;
}

.brand-mark span:nth-child(1) {
  transform: translate(-50%, -50%) rotate(0deg);
}

.brand-mark span:nth-child(2) {
  transform: translate(-50%, -50%) rotate(60deg);
}

.brand-mark span:nth-child(3) {
  transform: translate(-50%, -50%) rotate(120deg);
}

.brand-dot {
  color: #be6870;
}

.main-nav {
  position: absolute;
  left: 50%;
  display: flex;
  gap: 34px;
  margin: 0;
  transform: translateX(-50%);
}

.main-nav a {
  color: #796b6c;
  font-size: 12px;
  font-weight: 700;
  text-decoration: none;
}

.main-nav a.router-link-active,
.main-nav a:hover {
  color: #b45f69;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-cta {
  position: absolute;
  right: max(calc(6vw + 72px), 96px);
  z-index: 1;
  background: #302a2d;
  color: #fffaf8;
  border-radius: 100px;
  padding: 12px 17px;
  font-size: 11px;
  font-weight: 700;
}

.header-cta span {
  font-size: 15px;
}

/* Language selector */
.language-control {
  position: absolute;
  top: 50%;
  right: max(6vw, 24px);
  z-index: 1;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin: 0 4px;
  transform: translateY(-50%);
}

.language-button {
  width: 52px;
  height: 38px;
  padding: 0 10px;
  border: 1px solid #6b595c;
  border-radius: 999px;
  background: #302a2d;
  color: #fffaf8;

  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;

  cursor: pointer;
}

.language-button:hover,
.language-button:focus,
.language-button:active,
.language-button.show {
  background: #403538 !important;
  border-color: #6b595c !important;
  color: #fffaf8 !important;
  box-shadow: none !important;
  outline: none !important;
}

.language-button::after {
  margin-left: 3px;
  color: #e9b9a8;
  vertical-align: middle;
}

.language-symbol {
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 0.04em;
  line-height: 1;
}

.language-control .dropdown-menu {
  min-width: 150px;
  margin-top: 8px;
  padding: 6px;
  background: #302a2d;
  border: 1px solid #6b595c;
  border-radius: 12px;
  box-shadow: 0 10px 25px #00000020;
}

.language-control .dropdown-item {
  width: 100%;
  padding: 10px 14px;
  margin: 0;
  border: 0;
  border-radius: 7px;
  background: transparent;
  color: #fffaf8;
  font-size: 13px;
  font-weight: 600;
  text-align: left;
  cursor: pointer;
}

.language-control .dropdown-item:hover,
.language-control .dropdown-item:focus {
  background: #4a3b3e;
  color: #fffaf8;
}

.language-control .dropdown-item:active {
  background: #5a474b;
  color: #fffaf8;
}

/* Menu toggle */
.menu-toggle {
  display: none;
  background: none;
  border: 0;
}

/* Footer */
.site-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 28px max(6vw, 24px);
  font-size: 11px;
  color: #978b8c;
  border-top: 1px solid #eadedb;
}

.site-footer .brand {
  font-size: 20px;
  color: #4a3c3f;
}

/* Tablet / mobile */
@media (max-width: 900px) {
  .site-header {
    padding: 0 20px;
  }

  .main-nav {
    display: none !important;
    position: absolute;
    top: 78px;
    left: 0;
    right: 0;
    width: 100%;
    margin: 0;
    padding: 20px;
    background: #fffaf8;
    flex-direction: column;
    gap: 18px;
    box-shadow: 0 10px 20px #0000000c;
  }

  .main-nav.open {
    display: flex !important;
  }

  .header-cta {
    display: inline-flex;
    align-items: center;
    white-space: nowrap;
    padding: 9px 12px;
    font-size: 10px;
  }

  .header-cta span {
    font-size: 13px;
    margin-left: 6px;
  }

  .language-control {
    margin: 0 4px;
  }

  .language-button {
    width: 46px;
    height: 34px;
    padding: 0 8px;
  }

  .language-control .dropdown-menu {
    min-width: 145px;
  }

  .menu-toggle {
    display: flex;
    flex-direction: column;
    gap: 5px;
    padding: 8px;
    margin-left: 8px;
    background: transparent;
    border: 0;
  }

  .menu-toggle span {
    display: block;
    width: 23px;
    height: 2px;
    background: #302a2d;
  }

  .site-footer {
    flex-direction: column;
    gap: 13px;
    align-items: flex-start;
  }
}

/* Small screens */
@media (max-width: 520px) {
  .site-header {
    padding: 0 14px;
  }

  .brand {
    font-size: 14px;
  }

  .brand-mark {
    font-size: 17px;
    margin-right: 3px;
  }

  .header-cta {
    padding: 8px 9px;
    font-size: 9px;
  }

  .header-cta span {
    font-size: 12px;
    margin-left: 4px;
  }

  .language-control {
    margin: 0 3px;
  }

  .language-button {
    width: 46px;
    height: 34px;
    padding: 0 8px;
  }

  .menu-toggle {
    margin-left: 3px;
  }

  .main-nav {
    padding: 18px 16px;
  }
}

/* Very small screens */
@media (max-width: 420px) {
  .brand {
    font-size: 13px;
  }

  .brand-mark {
    font-size: 16px;
  }

  .header-cta {
    padding: 7px 8px;
  }

  .header-cta span {
    font-size: 11px;
  }

  .language-button {
    width: 44px;
    height: 33px;
  }
}
.accessibility-trigger {
  position: fixed;
  right: 20px;
  bottom: 20px;
  z-index: 1200;
  width: 52px;
  height: 52px;
  display: grid;
  place-items: center;
  padding: 0;
  border: 1px solid #d47a82;
  border-radius: 50%;
  background: #e9a33b;
  color: #302a2d;
  font-size: 24px;
  line-height: 1;
  box-shadow: 0 8px 20px #302a2d26;
  transition:
    transform 0.2s ease,
    box-shadow 0.2s ease;
}
.accessibility-trigger:hover {
  transform: translateY(-2px);
  box-shadow: 0 11px 24px #302a2d35;
}
.display-options {
  position: fixed;
  right: 20px;
  bottom: 84px;
  z-index: 1199;
  width: min(380px, calc(100vw - 32px));
  max-height: calc(100vh - 108px);
  overflow: auto;
  padding: 28px 30px 30px;
  border: 1px solid #6b4f61;
  border-radius: 22px;
  background: #241720;
  color: #fff8f4;
  box-shadow: 0 18px 50px #160d154d;
}
.display-options-close {
  position: absolute;
  top: 14px;
  right: 18px;
  width: 30px;
  height: 30px;
  border: 0;
  background: transparent;
  color: #d8b2bf;
  font-size: 28px;
  line-height: 1;
}
.display-options-title {
  font-family: Georgia, serif;
  font-size: 26px;
  font-weight: 700;
  line-height: 1.1;
  margin: 0 0 8px;
}
.display-options-intro {
  max-width: 310px;
  color: #d9cbd2;
  font-size: 13px;
  line-height: 1.4;
  margin: 0 0 24px;
}
.display-options fieldset {
  border: 0;
  padding: 0;
  margin: 0 0 22px;
}
.display-options legend {
  color: #d690ae;
  font-size: 10px;
  font-weight: 800;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  margin: 0 0 12px;
}
.option-grid {
  display: grid;
  gap: 8px;
}
.option-grid-themes,
.option-grid-text {
  grid-template-columns: repeat(3, 1fr);
}
.option-card {
  min-height: 70px;
  padding: 10px 6px;
  border: 1px solid #5c4559;
  border-radius: 12px;
  background: transparent;
  color: #f6e9ed;
  font-size: 12px;
  font-weight: 700;
  line-height: 1.2;
  transition:
    border-color 0.2s ease,
    background 0.2s ease;
}
.option-card:hover,
.option-card.selected {
  border-color: #e0a0ba;
  background: #3a2636;
}
.option-grid-text .option-card {
  min-height: 52px;
}
.theme-swatch {
  display: block;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  margin: 0 auto 7px;
  border: 1px solid #fff4ee;
}
.swatch-blush {
  background: linear-gradient(135deg, #f8e9e9 50%, #b4c8b0 50%);
}
.swatch-teal {
  background: linear-gradient(135deg, #d9f1ee 50%, #0b7372 50%);
}
.swatch-accessible {
  background: linear-gradient(135deg, #f4c542 50%, #1769aa 50%);
}
.motion-setting {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  padding: 18px 0;
  border-top: 1px solid #593e50;
  border-bottom: 1px solid #593e50;
}
.motion-setting p {
  margin: 0 0 4px;
  font-size: 14px;
}
.motion-setting span {
  color: #d9cbd2;
  font-size: 11px;
}
.motion-toggle {
  position: relative;
  width: 58px;
  height: 30px;
  padding: 3px;
  border: 0;
  border-radius: 100px;
  background: #544052;
  flex: 0 0 auto;
}
.motion-toggle span {
  display: block;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #fffaf8;
  transition: transform 0.2s ease;
}
.motion-toggle.active {
  background: #d47a82;
}
.motion-toggle.active span {
  transform: translateX(28px);
}
.reset-display-options {
  width: 100%;
  margin-top: 20px;
  padding: 11px;
  border: 1px solid #704e61;
  border-radius: 11px;
  background: transparent;
  color: #f6e9ed;
  font-size: 13px;
  font-weight: 700;
  transition:
    background 0.2s ease,
    border-color 0.2s ease,
    color 0.2s ease;
}
.reset-display-options:hover,
.reset-display-options:focus-visible {
  background: #3a2636;
  border-color: #e0a0ba;
}
.reset-display-options:active {
  background: #e0a0ba;
  color: #302a2d;
}
.site-shell.theme-blush .reset-display-options:active {
  background: #e9b9b3;
  border-color: #e9b9b3;
}
.site-shell.theme-teal .reset-display-options:active {
  background: #69c5b8;
  border-color: #69c5b8;
  color: #083f43;
}
.site-shell.theme-accessible .reset-display-options:active {
  background: #f4c542;
  border-color: #f4c542;
  color: #14213d;
}
.site-shell.theme-blush .reset-display-options:hover,
.site-shell.theme-blush .reset-display-options:focus-visible {
  background: #f8e9e9;
  border-color: #d47a82;
  color: #302a2d;
}
.site-shell.theme-teal .reset-display-options:hover,
.site-shell.theme-teal .reset-display-options:focus-visible {
  background: #15595c;
  border-color: #9adbd3;
  color: #effcfb;
}
.site-shell.theme-accessible .reset-display-options:hover,
.site-shell.theme-accessible .reset-display-options:focus-visible {
  background: #214d78;
  border-color: #f4c542;
  color: #fffdf3;
}
.site-shell.theme-blush .display-options {
  background: #241720;
  color: #fff8f4;
  border-color: #6b4f61;
}
.site-shell.theme-blush .accessibility-trigger {
  background: #e9a33b;
  color: #302a2d;
  border-color: #d47a82;
}
.site-shell.theme-teal {
  background: #eaf7f5;
  color: #123b3c;
}
.site-shell.theme-teal .site-header,
.site-shell.theme-teal .site-footer {
  background: #eaf7f5;
  color: #123b3c;
  border-color: #b8ded9;
}
.site-shell.theme-teal .brand,
.site-shell.theme-teal .site-footer .brand,
.site-shell.theme-teal .main-nav a {
  color: #123b3c;
}
.site-shell.theme-teal .display-options {
  background: #083f43;
  color: #effcfb;
  border-color: #55aaa5;
}
.site-shell.theme-teal .display-options-intro,
.site-shell.theme-teal .motion-setting span {
  color: #c5e7e3;
}
.site-shell.theme-teal .display-options legend {
  color: #8ed2cb;
}
.site-shell.theme-teal .option-card {
  border-color: #397b7b;
  color: #effcfb;
}
.site-shell.theme-teal .option-card:hover,
.site-shell.theme-teal .option-card.selected {
  background: #15595c;
  border-color: #9adbd3;
}
.site-shell.theme-teal .reset-display-options {
  border-color: #397b7b;
  color: #effcfb;
}
.site-shell.theme-teal .accessibility-trigger {
  background: #69c5b8;
  color: #083f43;
  border-color: #397b7b;
}
.site-shell.theme-teal :deep(main),
.site-shell.theme-teal :deep(.finder-page),
.site-shell.theme-teal :deep(.detail-page),
.site-shell.theme-teal :deep(.game-page),
.site-shell.theme-teal :deep(.game-play-page),
.site-shell.theme-teal :deep(.login-page) {
  background: #eaf7f5;
  color: #123b3c;
}
.site-shell.theme-teal :deep(.hero-section),
.site-shell.theme-teal :deep(.finder-hero),
.site-shell.theme-teal :deep(.detail-hero),
.site-shell.theme-teal :deep(.closing-section) {
  background: #d9f1ee;
}
.site-shell.theme-teal :deep(.intro-section),
.site-shell.theme-teal :deep(.screening-info) {
  background: #effcfb;
}
.site-shell.theme-teal :deep(.info-card),
.site-shell.theme-teal :deep(.step-card),
.site-shell.theme-teal :deep(.service-card),
.site-shell.theme-teal :deep(.chart-card) {
  background: #e0f2ef;
  border-color: #b8ded9;
  color: #123b3c;
}
.site-shell.theme-teal :deep(.info-card-accent),
.site-shell.theme-teal :deep(.about-card),
.site-shell.theme-teal :deep(.practitioner-section) {
  background: #c7e8e3;
}
.site-shell.theme-teal :deep(.stats-section) {
  background: #123b3c;
}
.site-shell.theme-teal :deep(.button-primary),
.site-shell.theme-teal :deep(.filter-button),
.site-shell.theme-teal :deep(.details-button) {
  background: #0b7372;
  color: #effcfb;
}
.site-shell.theme-teal :deep(.brand-mark),
.site-shell.theme-teal :deep(.eyebrow),
.site-shell.theme-teal :deep(.section-label) {
  color: #0b7372;
}
.site-shell.theme-accessible {
  background: #fffdf3;
  color: #14213d;
}
.site-shell.theme-accessible .site-header,
.site-shell.theme-accessible .site-footer {
  background: #fffdf3;
  color: #14213d;
  border-color: #e4d58b;
}
.site-shell.theme-accessible .brand,
.site-shell.theme-accessible .site-footer .brand,
.site-shell.theme-accessible .main-nav a {
  color: #14213d;
}
.site-shell.theme-accessible .display-options {
  background: #14213d;
  color: #fffdf3;
  border-color: #f4c542;
}
.site-shell.theme-accessible .display-options-intro,
.site-shell.theme-accessible .motion-setting span {
  color: #dbe9f7;
}
.site-shell.theme-accessible .display-options legend {
  color: #f4c542;
}
.site-shell.theme-accessible .option-card {
  border-color: #437ca8;
  color: #fffdf3;
}
.site-shell.theme-accessible .option-card:hover,
.site-shell.theme-accessible .option-card.selected {
  background: #214d78;
  border-color: #f4c542;
}
.site-shell.theme-accessible .reset-display-options {
  border-color: #437ca8;
  color: #fffdf3;
}
.site-shell.theme-accessible .accessibility-trigger {
  background: #f4c542;
  color: #14213d;
  border-color: #14213d;
}
.site-shell.theme-accessible :deep(main),
.site-shell.theme-accessible :deep(.finder-page),
.site-shell.theme-accessible :deep(.detail-page),
.site-shell.theme-accessible :deep(.game-page),
.site-shell.theme-accessible :deep(.game-play-page),
.site-shell.theme-accessible :deep(.login-page) {
  background: #fffdf3;
  color: #14213d;
}
.site-shell.theme-accessible :deep(.hero-section),
.site-shell.theme-accessible :deep(.finder-hero),
.site-shell.theme-accessible :deep(.detail-hero),
.site-shell.theme-accessible :deep(.closing-section) {
  background: #fff1b8;
}
.site-shell.theme-accessible :deep(.intro-section),
.site-shell.theme-accessible :deep(.screening-info) {
  background: #fffdf3;
}
.site-shell.theme-accessible :deep(.info-card),
.site-shell.theme-accessible :deep(.step-card),
.site-shell.theme-accessible :deep(.service-card),
.site-shell.theme-accessible :deep(.chart-card) {
  background: #edf4fb;
  border-color: #a8c7df;
  color: #14213d;
}
.site-shell.theme-accessible :deep(.info-card-accent),
.site-shell.theme-accessible :deep(.about-card),
.site-shell.theme-accessible :deep(.practitioner-section) {
  background: #dbe9f7;
}
.site-shell.theme-accessible :deep(.stats-section) {
  background: #14213d;
}
.site-shell.theme-accessible :deep(.button-primary),
.site-shell.theme-accessible :deep(.filter-button),
.site-shell.theme-accessible :deep(.details-button) {
  background: #1769aa;
  color: #fffdf3;
}
.site-shell.theme-accessible :deep(.brand-mark),
.site-shell.theme-accessible :deep(.eyebrow),
.site-shell.theme-accessible :deep(.section-label) {
  color: #1769aa;
}
/* =========================================
   Accessibility text sizes
   ========================================= */

.site-shell {
  --accessibility-scale: 1;
}

/*
  Do not set font-size directly on page headings here.

  Each page already has its own responsive typography,
  such as clamp(), fixed px values, etc.

  The transform below visually enlarges the text without
  replacing the page's original font-size.
*/

/* Larger */
.site-shell.text-size-larger :deep(h1),
.site-shell.text-size-larger :deep(h2),
.site-shell.text-size-larger :deep(h3) {
  zoom: 1.08;
}

.site-shell.text-size-larger :deep(p),
.site-shell.text-size-larger :deep(a),
.site-shell.text-size-larger :deep(button),
.site-shell.text-size-larger :deep(label),
.site-shell.text-size-larger :deep(select),
.site-shell.text-size-larger :deep(small) {
  zoom: 1.08;
}

/* Largest */
.site-shell.text-size-largest :deep(h1),
.site-shell.text-size-largest :deep(h2),
.site-shell.text-size-largest :deep(h3) {
  zoom: 1.16;
}

.site-shell.text-size-largest :deep(p),
.site-shell.text-size-largest :deep(a),
.site-shell.text-size-largest :deep(button),
.site-shell.text-size-largest :deep(label),
.site-shell.text-size-largest :deep(select),
.site-shell.text-size-largest :deep(small) {
  zoom: 1.16;
}

/* =========================================
   SVG chart text
   ========================================= */

.site-shell.text-size-larger :deep(.chart-axis-label),
.site-shell.text-size-larger :deep(.chart-tooltip-text) {
  font-size: 1.08em;
}

.site-shell.text-size-largest :deep(.chart-axis-label),
.site-shell.text-size-largest :deep(.chart-tooltip-text) {
  font-size: 1.16em;
}

/* =========================================
   Chart labels
   ========================================= */

.site-shell.text-size-larger :deep(.chart-labels span),
.site-shell.text-size-largest :deep(.chart-labels span) {
  zoom: 1.08;
}

/* =========================================
   Chart header
   ========================================= */

.site-shell.text-size-larger :deep(.chart-top h3),
.site-shell.text-size-larger :deep(.chart-top span) {
  zoom: 1.08;
}

.site-shell.text-size-largest :deep(.chart-top h3),
.site-shell.text-size-largest :deep(.chart-top span) {
  zoom: 1.16;
}

/* =========================================
   Trend indicator
   ========================================= */

.site-shell.text-size-larger :deep(.trend-indicator),
.site-shell.text-size-largest :deep(.trend-indicator) {
  zoom: 1.08;
}

.site-shell.text-size-largest :deep(.trend-indicator) {
  zoom: 1.16;
}

/* =========================================
   Stats period
   ========================================= */

.site-shell.text-size-larger :deep(.big-stat small) {
  zoom: 1.08;
}

.site-shell.text-size-largest :deep(.big-stat small) {
  zoom: 1.16;
}

/* =========================================
   Big percentage
   ========================================= */

.site-shell.text-size-larger :deep(.big-stat strong) {
  zoom: 1.08;
}

.site-shell.text-size-largest :deep(.big-stat strong) {
  zoom: 1.16;
}

/* =========================================
   State dropdown
   ========================================= */

.site-shell.text-size-larger :deep(.stats-filters label),
.site-shell.text-size-larger :deep(.stats-filters select) {
  zoom: 1.08;
}

.site-shell.text-size-largest :deep(.stats-filters label),
.site-shell.text-size-largest :deep(.stats-filters select) {
  zoom: 1.16;
}
.site-shell.theme-blush .accessibility-trigger {
  background: #e9b9b3;
  color: #302a2d;
  border-color: #d89591;
}
.site-shell.theme-blush .button-primary {
  background: #e9b9b3;
  color: #302a2d;
}
.site-shell.theme-blush .display-options {
  background: #fff8f6;
  color: #302a2d;
  border-color: #e8c2be;
}
.site-shell.theme-blush .display-options-title,
.site-shell.theme-blush .display-options-close {
  color: #302a2d;
}
.site-shell.theme-blush .display-options-intro,
.site-shell.theme-blush .motion-setting span {
  color: #705f61;
}
.site-shell.theme-blush .display-options legend {
  color: #b06b70;
}
.site-shell.theme-blush .option-card {
  border-color: #e6c3c0;
  color: #302a2d;
}
.site-shell.theme-blush .option-card:hover,
.site-shell.theme-blush .option-card.selected {
  background: #f8e9e9;
  border-color: #d47a82;
}
.site-shell.theme-blush .reset-display-options {
  border-color: #e0b5b0;
  color: #302a2d;
}
.site-shell.theme-teal {
  background: #f3fbfa;
  color: #123b3c;
}
.site-shell.theme-teal .site-header,
.site-shell.theme-teal .site-footer {
  background: #f3fbfa;
}
.site-shell.theme-teal :deep(.hero-section),
.site-shell.theme-teal :deep(.finder-hero),
.site-shell.theme-teal :deep(.detail-hero) {
  background: #d9f1ee;
}
.site-shell.theme-teal :deep(.info-card-accent),
.site-shell.theme-teal :deep(.about-card),
.site-shell.theme-teal :deep(.practitioner-section) {
  background: #c7e8e3;
}
.site-shell.theme-teal :deep(.stats-section) {
  background: #123b3c;
}
.site-shell.theme-teal :deep(.button-primary),
.site-shell.theme-teal :deep(.filter-button) {
  background: #0b7372;
}
.site-shell.theme-teal :deep(.brand-mark),
.site-shell.theme-teal :deep(.eyebrow),
.site-shell.theme-teal :deep(.section-label) {
  color: #0b7372;
}
.site-shell.theme-accessible {
  background: #fffdf3;
  color: #14213d;
}
.site-shell.theme-accessible .site-header,
.site-shell.theme-accessible .site-footer {
  background: #fffdf3;
}
.site-shell.theme-accessible :deep(.hero-section),
.site-shell.theme-accessible :deep(.finder-hero),
.site-shell.theme-accessible :deep(.detail-hero) {
  background: #fff1b8;
}
.site-shell.theme-accessible :deep(.info-card-accent),
.site-shell.theme-accessible :deep(.about-card),
.site-shell.theme-accessible :deep(.practitioner-section) {
  background: #dbe9f7;
}
.site-shell.theme-accessible :deep(.stats-section) {
  background: #14213d;
}
.site-shell.theme-accessible :deep(.button-primary),
.site-shell.theme-accessible :deep(.filter-button) {
  background: #1769aa;
}
.site-shell.theme-accessible :deep(.brand-mark),
.site-shell.theme-accessible :deep(.eyebrow),
.site-shell.theme-accessible :deep(.section-label) {
  color: #1769aa;
}

/* Normal text size */
.site-shell.text-size-normal :deep(.game-play-page) {
  height: calc(100dvh - 78px);
  min-height: 0;
  overflow: hidden;
}

.site-shell.text-size-normal :deep(.game-stage) {
  height: 100%;
  min-height: 0;
}

/* Enlarged text */
.site-shell.text-size-larger :deep(.game-play-page),
.site-shell.text-size-largest :deep(.game-play-page) {
  height: auto;
  min-height: calc(100dvh - 78px);
  overflow: visible;
}

.site-shell.text-size-larger :deep(.game-stage),
.site-shell.text-size-largest :deep(.game-stage) {
  height: auto;
  min-height: calc(100dvh - 78px);
}

/* =========================================
   Mobile game pages
   ========================================= */

@media (max-width: 760px) {
  .site-shell.text-size-normal :deep(.game-play-page),
  .site-shell.text-size-larger :deep(.game-play-page),
  .site-shell.text-size-largest :deep(.game-play-page) {
    height: auto;
    min-height: 0;
    overflow: visible;
  }

  .site-shell.text-size-normal :deep(.game-stage),
  .site-shell.text-size-larger :deep(.game-stage),
  .site-shell.text-size-largest :deep(.game-stage) {
    height: auto;
    min-height: 0;
  }
}

@media (max-width: 700px) {
  .accessibility-trigger {
    right: 16px;
    bottom: 16px;
    width: 48px;
    height: 48px;
  }
  .display-options {
    right: 16px;
    bottom: 76px;
    padding: 24px 20px 22px;
    border-radius: 18px;
  }
  .display-options-title {
    font-size: 24px;
  }
  .display-options-intro {
    font-size: 12px;
    margin-bottom: 22px;
  }
  .option-grid-themes,
  .option-grid-text {
    gap: 6px;
  }
  .option-card {
    min-height: 64px;
    font-size: 11px;
    padding: 8px 4px;
  }
  .option-grid-text .option-card {
    min-height: 48px;
  }
  .display-options legend {
    font-size: 9px;
  }
  .motion-setting {
    padding: 16px 0;
  }
  .motion-setting p {
    font-size: 13px;
  }
  .motion-setting span {
    font-size: 10px;
  }
}
@media (max-width: 420px) {
  .display-options {
    width: calc(100vw - 20px);
    right: 10px;
    padding-left: 14px;
    padding-right: 14px;
  }
  .display-options-title {
    font-size: 23px;
  }
  .option-card {
    font-size: 10px;
  }
  .theme-swatch {
    width: 16px;
    height: 16px;
  }
}
.header-cta,
.site-footer .brand {
  text-decoration: none;
}
.site-footer {
  display: block;
  padding: 48px max(8vw, 28px) 18px;
  border: 0;
  background: #fdf2f7;
  color: #796b6c;
}
.footer-acknowledgement {
  display: flex;
  align-items: stretch;
  gap: 20px;
  max-width: 880px;
  margin: 0 auto 34px;
  padding-bottom: 26px;
  border-bottom: 1px solid #e7d5d4;
}

.footer-acknowledgement p,
.footer-about p {
  margin: 0;
  color: #796b6c;
  font-size: 13px;
  line-height: 1.7;
}

.footer-leaf {
  display: flex;
  align-items: stretch;
  flex-shrink: 0;
}

.footer-leaf img {
  height: 100%;
  max-height: 70px;
  width: auto;
  object-fit: contain;
}
.footer-columns {
  display: grid;
  grid-template-columns: 1.4fr 1fr 1fr;
  gap: 48px;
  max-width: 880px;
  margin: 0 auto;
  padding-bottom: 28px;
  border-bottom: 1px solid #e7d5d4;
}
.footer-columns > div {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 10px;
}
.footer-columns h2 {
  margin: 0 0 3px;
  color: #302a2d;
  font:
    700 16px Georgia,
    serif;
}
.site-footer .brand {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: #302a2d;
  font-size: 18px;
}
.footer-brand-logo {
  width: 30px;
  height: 30px;
  object-fit: contain;
  mix-blend-mode: multiply;
}
.footer-columns a {
  color: #796b6c;
  font-size: 12px;
}
.footer-columns a:hover {
  color: #a75d68;
}
.footer-bottom {
  max-width: 880px;
  margin: 14px auto 0;
  color: #8c7e80;
  font-size: 10px;
}
.header-cta {
  border: 0;
  cursor: pointer;
}
.explore-label-mobile {
  display: none;
}
.overlay-backdrop {
  position: fixed;
  inset: 0;
  z-index: 2000;
  display: grid;
  place-items: center;
  padding: 24px;
  background: #21131d66;
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}
.explore-modal,
.game-start-modal {
  position: relative;
  width: min(100%, 820px);
  max-height: min(92vh, 900px);
  overflow-y: auto;
  padding: clamp(30px, 6vw, 64px);
  border: 1px solid #eadedb;
  border-radius: 34px;
  background: #fff;
  box-shadow: 0 24px 90px #21051f35;
  color: #2b2427;
}
.modal-close {
  position: absolute;
  top: 24px;
  right: 26px;
  width: 40px;
  height: 40px;
  border: 0;
  background: transparent;
  color: #7b6d70;
  font-size: 29px;
}
.modal-eyebrow {
  margin: 0 0 12px;
  color: #a75d68;
  font-size: 14px;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}
.explore-modal h2,
.game-start-modal h2 {
  margin: 0;
  color: #211a1d;
  font-size: clamp(30px, 4vw, 48px);
  font-weight: 800;
  letter-spacing: -0.04em;
  line-height: 1.1;
}
.explore-intro,
.game-start-copy {
  max-width: 650px;
  margin: 15px 0 32px;
  color: #72676a;
  font-size: 17px;
  line-height: 1.65;
}
.explore-options {
  display: grid;
  gap: 12px;
}
.explore-option {
  display: grid;
  grid-template-columns: 44px 1fr;
  align-items: center;
  gap: 16px;
  width: 100%;
  padding: 16px 20px;
  border: 1px solid #e6e1dc;
  border-radius: 20px;
  background: #fff;
  color: #2b2427;
  text-align: left;
  transition:
    background 0.18s ease,
    border-color 0.18s ease,
    transform 0.18s ease;
}
.explore-option:hover,
.explore-option.selected {
  border-color: #b77886;
  background: #fbf0f2;
}
.explore-option:hover {
  transform: translateY(-1px);
}
.option-icon {
  display: grid;
  place-items: center;
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: #edf0e9;
  color: #725454;
  font-size: 20px;
}
.explore-option.selected .option-icon {
  background: #a9476c;
  color: #fff;
}
.explore-option strong {
  display: block;
  font-size: 17px;
  font-weight: 800;
}
.explore-option small {
  display: block;
  margin-top: 4px;
  color: #71686a;
  font-size: 14px;
}
.start-over-link {
  display: block;
  margin: 22px auto 0;
  border: 0;
  background: transparent;
  color: #514448;
  font-size: 15px;
  font-weight: 700;
  text-decoration: underline;
  text-underline-offset: 4px;
}
.game-start-modal {
  width: min(100%, 690px);
  background: #fff5ef;
  border: 0;
}
.game-start-modal h2 {
  font-size: clamp(34px, 5vw, 52px);
}
.game-start-copy {
  margin-bottom: 22px;
}
.game-start-goal {
  display: flex;
  align-items: center;
  gap: 14px;
  margin: 20px 0;
  padding: 16px;
  border-radius: 16px;
  background: #f7e2e6;
  font-weight: 800;
}
.game-start-goal span {
  font-size: 23px;
}
.game-start-controls {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  color: #a75d68;
}
.game-start-controls strong {
  margin-right: 6px;
}
.game-start-controls kbd {
  min-width: 42px;
  padding: 8px 12px;
  border-radius: 9px;
  background: #fff;
  box-shadow: 0 2px 4px #0002;
  color: #2b2427;
  text-align: center;
  font-size: 20px;
}
.game-start-rule {
  margin: 22px 0;
  color: #71686a;
}
.game-guide-steps {
  display: grid;
  gap: 12px;
  margin: 24px 0 26px;
  padding: 0;
  list-style: none;
}

.game-guide-steps li {
  display: grid;
  grid-template-columns: 42px 1fr;
  align-items: center;
  gap: 14px;
  padding: 14px 16px;
  border-radius: 16px;
  background: #fff;
  box-shadow: 0 2px 6px #7c55551a;
}

.guide-step-icon {
  display: grid;
  place-items: center;
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: #f7e2e6;
  font-size: 20px;
}

.game-guide-steps strong {
  display: block;
  color: #211a1d;
  font-size: 16px;
  font-weight: 800;
}

.game-guide-steps small {
  display: block;
  margin-top: 3px;
  color: #71686a;
  font-size: 13.5px;
  line-height: 1.5;
}
.game-start-button {
  width: 100%;
  padding: 16px 24px;
  border: 0;
  border-radius: 99px;
  background: #211719;
  color: white;
  font-size: 18px;
  font-weight: 800;
}
.game-start-button span {
  margin-left: 8px;
  font-size: 22px;
}
@media (max-width: 900px) {
  .main-nav {
    left: 0;
    transform: none;
  }
  .header-cta,
  .language-control {
    position: static;
    transform: none;
  }
  .site-footer {
    padding: 36px 24px 18px;
  }
  .footer-columns {
    gap: 24px;
  }
  .explore-label-desktop {
    display: none;
  }
  .explore-label-mobile {
    display: inline;
  }
}
@media (min-width: 761px) and (max-width: 900px) {
  .main-nav {
    display: flex !important;
    top: 50%;
    left: 50%;
    right: auto;
    width: auto;
    padding: 0;
    background: transparent;
    box-shadow: none;
    flex-direction: row;
    gap: 14px;
    transform: translate(-50%, -50%);
  }
  .main-nav a {
    font-size: 10px;
  }
  .menu-toggle {
    display: none;
  }
}
@media (max-width: 600px) {
  .footer-columns {
    grid-template-columns: 1fr 1fr;
    gap: 28px 18px;
  }
  .footer-about {
    grid-column: 1 / -1;
  }
  .footer-acknowledgement {
    align-items: flex-start;
  }
  .footer-acknowledgement p {
    font-size: 11px;
  }
  .explore-modal,
  .game-start-modal {
    padding: 42px 22px 26px;
    border-radius: 25px;
  }
  .modal-close {
    top: 11px;
    right: 14px;
  }
  .explore-modal h2,
  .game-start-modal h2 {
    font-size: 32px;
  }
  .explore-intro,
  .game-start-copy {
    font-size: 14px;
    margin-bottom: 22px;
  }
  .explore-option {
    grid-template-columns: 38px 1fr;
    gap: 11px;
    padding: 12px;
    border-radius: 15px;
  }
  .game-guide-steps li {
    grid-template-columns: 36px 1fr;
    gap: 11px;
    padding: 12px;
  }

  .guide-step-icon {
    width: 36px;
    height: 36px;
    font-size: 17px;
  }

  .game-guide-steps strong {
    font-size: 14px;
  }

  .game-guide-steps small {
    font-size: 12px;
  }
  .option-icon {
    width: 36px;
    height: 36px;
  }
  .explore-option strong {
    font-size: 14px;
  }
  .explore-option small {
    font-size: 12px;
  }
}
.site-shell :deep(.hero-section .button-primary),
.site-shell :deep(.closing-section .button-primary) {
  background: #b65d6e;
  color: #fff;
}

/* =========================================
HomeView theme support
========================================= */

/* Shared text and card behaviour */
.site-shell :deep(.hero-section),
.site-shell :deep(.screening-info),
.site-shell :deep(.intro-section),
.site-shell :deep(.stats-section),
.site-shell :deep(.faq-preview),
.site-shell :deep(.stats-preview),
.site-shell :deep(.closing-section) {
  transition:
    background-color 0.2s ease,
    color 0.2s ease;
}

.site-shell :deep(.hero-card-face),
.site-shell :deep(.info-card-front),
.site-shell :deep(.info-card-back),
.site-shell :deep(.step-card),
.site-shell :deep(.faq-preview-card),
.site-shell :deep(.chart-card) {
  transition:
    background-color 0.2s ease,
    color 0.2s ease,
    border-color 0.2s ease;
}

/* ---------- Blush theme ---------- */
.site-shell.theme-blush :deep(.hero-section) {
  background: #f8e9e9;
  color: #302a2d;
}

.site-shell.theme-blush :deep(.screening-info) {
  background: #fdf2ef;
  color: #302a2d;
}

.site-shell.theme-blush :deep(.intro-section) {
  background: #fffaf8;
  color: #302a2d;
}

.site-shell.theme-blush :deep(.faq-preview) {
  background: #fcf2eb;
  color: #302a2d;
}

.site-shell.theme-blush :deep(.stats-preview) {
  background: #261417;
  color: #fff4f0;
}

.site-shell.theme-blush :deep(.closing-section) {
  background: #f6e4df;
  color: #302a2d;
}

.site-shell.theme-blush :deep(.hero-card-front),
.site-shell.theme-blush :deep(.info-card-front),
.site-shell.theme-blush :deep(.faq-preview-card) {
  background: #fffaf8;
  color: #302a2d;
}

.site-shell.theme-blush :deep(.hero-card-back),
.site-shell.theme-blush :deep(.info-card-back) {
  background: #f6e1df;
  color: #6e5558;
}

.site-shell.theme-blush :deep(.step-card) {
  background: #fffaf8;
  border-color: #eadedb;
  color: #302a2d;
}

.site-shell.theme-blush :deep(.step-card.featured) {
  background: #f6e1df;
}

.site-shell.theme-blush :deep(.faq-preview-card) {
  border-color: #e7deda;
}

.site-shell.theme-blush :deep(.hero-copy h1),
.site-shell.theme-blush :deep(.screening-info-heading h2),
.site-shell.theme-blush :deep(.intro-grid h2) {
  color: #282326;
}

.site-shell.theme-blush :deep(.hero-text),
.site-shell.theme-blush :deep(.screening-info-heading > p),
.site-shell.theme-blush :deep(.lead),
.site-shell.theme-blush :deep(.step-card p) {
  color: #6e6263;
}

/* ---------- Teal theme ---------- */
.site-shell.theme-teal :deep(.hero-section),
.site-shell.theme-teal :deep(.closing-section) {
  background: #d9f1ee;
  color: #123b3c;
}

.site-shell.theme-teal :deep(.screening-info),
.site-shell.theme-teal :deep(.faq-preview) {
  background: #effcfb;
  color: #123b3c;
}

.site-shell.theme-teal :deep(.intro-section) {
  background: #f3fbfa;
  color: #123b3c;
}

.site-shell.theme-teal :deep(.stats-section),
.site-shell.theme-teal :deep(.stats-preview) {
  background: #123b3c;
  color: #effcfb;
}

.site-shell.theme-teal :deep(.hero-card-front),
.site-shell.theme-teal :deep(.info-card-front),
.site-shell.theme-teal :deep(.faq-preview-card) {
  background: #f5fcfb;
  border-color: #b8ded9;
  color: #123b3c;
}

.site-shell.theme-teal :deep(.hero-card-back),
.site-shell.theme-teal :deep(.info-card-back),
.site-shell.theme-teal :deep(.step-card.featured) {
  background: #c7e8e3;
  color: #123b3c;
}

.site-shell.theme-teal :deep(.step-card),
.site-shell.theme-teal :deep(.chart-card) {
  background: #e0f2ef;
  border-color: #b8ded9;
  color: #123b3c;
}

.site-shell.theme-teal :deep(.hero-copy h1),
.site-shell.theme-teal :deep(.screening-info-heading h2),
.site-shell.theme-teal :deep(.intro-grid h2),
.site-shell.theme-teal :deep(.closing-section h2) {
  color: #123b3c;
}

.site-shell.theme-teal :deep(.hero-text),
.site-shell.theme-teal :deep(.screening-info-heading > p),
.site-shell.theme-teal :deep(.lead),
.site-shell.theme-teal :deep(.step-card p),
.site-shell.theme-teal :deep(.faq-preview-card small) {
  color: #365e5e;
}

.site-shell.theme-teal :deep(.hero-copy h1 em),
.site-shell.theme-teal :deep(.screening-info-heading h2 em),
.site-shell.theme-teal :deep(.intro-grid em),
.site-shell.theme-teal :deep(.closing-section em),
.site-shell.theme-teal :deep(.arrow-link),
.site-shell.theme-teal :deep(.faq-all-link) {
  color: #0b7372;
}

.site-shell.theme-teal :deep(.faq-preview-card > span:first-child) {
  color: #123b3c;
}

.site-shell.theme-teal :deep(.faq-plus) {
  color: #0b7372;
  border-color: #0b7372;
}

/* ---------- Accessible theme ---------- */
.site-shell.theme-accessible :deep(.hero-section),
.site-shell.theme-accessible :deep(.closing-section) {
  background: #fff1b8;
  color: #14213d;
}

.site-shell.theme-accessible :deep(.screening-info),
.site-shell.theme-accessible :deep(.intro-section),
.site-shell.theme-accessible :deep(.faq-preview) {
  background: #fffdf3;
  color: #14213d;
}

.site-shell.theme-accessible :deep(.stats-section),
.site-shell.theme-accessible :deep(.stats-preview) {
  background: #14213d;
  color: #fffdf3;
}

.site-shell.theme-accessible :deep(.hero-card-front),
.site-shell.theme-accessible :deep(.info-card-front),
.site-shell.theme-accessible :deep(.faq-preview-card) {
  background: #fffdf3;
  border-color: #a8c7df;
  color: #14213d;
}

.site-shell.theme-accessible :deep(.hero-card-back),
.site-shell.theme-accessible :deep(.info-card-back),
.site-shell.theme-accessible :deep(.step-card.featured) {
  background: #dbe9f7;
  color: #14213d;
}

.site-shell.theme-accessible :deep(.step-card),
.site-shell.theme-accessible :deep(.chart-card) {
  background: #edf4fb;
  border-color: #a8c7df;
  color: #14213d;
}

.site-shell.theme-accessible :deep(.hero-copy h1),
.site-shell.theme-accessible :deep(.screening-info-heading h2),
.site-shell.theme-accessible :deep(.intro-grid h2),
.site-shell.theme-accessible :deep(.closing-section h2) {
  color: #14213d;
}

.site-shell.theme-accessible :deep(.hero-text),
.site-shell.theme-accessible :deep(.screening-info-heading > p),
.site-shell.theme-accessible :deep(.lead),
.site-shell.theme-accessible :deep(.step-card p),
.site-shell.theme-accessible :deep(.faq-preview-card small) {
  color: #354b68;
}

.site-shell.theme-accessible :deep(.hero-copy h1 em),
.site-shell.theme-accessible :deep(.screening-info-heading h2 em),
.site-shell.theme-accessible :deep(.intro-grid em),
.site-shell.theme-accessible :deep(.closing-section em),
.site-shell.theme-accessible :deep(.arrow-link),
.site-shell.theme-accessible :deep(.faq-all-link) {
  color: #1769aa;
}

.site-shell.theme-accessible :deep(.faq-preview-card > span:first-child) {
  color: #14213d;
}

.site-shell.theme-accessible :deep(.faq-plus) {
  color: #1769aa;
  border-color: #1769aa;
}

/* Keep decorative and statistics text legible on dark sections */
.site-shell.theme-teal :deep(.stats-heading h2),
.site-shell.theme-teal :deep(.stats-preview > h2),
.site-shell.theme-accessible :deep(.stats-heading h2),
.site-shell.theme-accessible :deep(.stats-preview > h2) {
  color: #fffdf3;
}

.site-shell.theme-teal :deep(.stats-preview-note),
.site-shell.theme-accessible :deep(.stats-preview-note) {
  color: #dbe9f7;
}

.site-shell.theme-teal :deep(.stats-data-link),
.site-shell.theme-accessible :deep(.stats-data-link),
.site-shell.theme-teal :deep(.stats-preview .section-next-link),
.site-shell.theme-accessible :deep(.stats-preview .section-next-link) {
  color: #f4c542;
}

/* Respect enlarged text without clipping content */
.site-shell.text-size-larger :deep(.hero-card),
.site-shell.text-size-largest :deep(.hero-card) {
  height: auto;
  min-height: 120px;
}

.site-shell.text-size-largest :deep(.hero-card) {
  min-height: 140px;
}

.site-shell.text-size-larger :deep(.hero-card-face),
.site-shell.text-size-largest :deep(.hero-card-face) {
  overflow-wrap: anywhere;
  padding: 12px;
}

.site-shell.text-size-larger :deep(.hero-card-back p),
.site-shell.text-size-largest :deep(.hero-card-back p) {
  line-height: 1.5;
}

.site-shell.text-size-larger :deep(.info-card-front h3),
.site-shell.text-size-largest :deep(.info-card-front h3),
.site-shell.text-size-larger :deep(.info-card-back p),
.site-shell.text-size-largest :deep(.info-card-back p) {
  overflow-wrap: anywhere;
}

.site-shell.text-size-larger :deep(.faq-preview-card),
.site-shell.text-size-largest :deep(.faq-preview-card) {
  height: auto;
  min-height: 112px;
  overflow-wrap: anywhere;
}

.site-shell.text-size-larger :deep(.chart-top),
.site-shell.text-size-largest :deep(.chart-top) {
  flex-wrap: wrap;
  gap: 10px;
}

.site-shell.text-size-larger :deep(.stats-filters),
.site-shell.text-size-largest :deep(.stats-filters) {
  flex-wrap: wrap;
  max-width: 100%;
}

.site-shell.text-size-larger :deep(.stats-filters label),
.site-shell.text-size-largest :deep(.stats-filters label) {
  min-width: 0;
  flex-wrap: wrap;
}

</style>
