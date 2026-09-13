<template>
  <div class="site-shell" :class="[`theme-${selectedTheme}`, `text-size-${textSize}`]">
    <header class="site-header">
      <RouterLink to="/" class="brand"
        ><span class="brand-mark">✳</span> ScreeningTogether AU</RouterLink
      >
      <nav :class="['main-nav', { open: menuOpen }]" aria-label="Main navigation">
        <RouterLink to="/">{{ t('header.home') }}</RouterLink>

        <template v-if="isHomePage">
          <a href="/#learn">{{ t('header.learn') }}</a>
          <a href="/#screening-info">{{ t('header.faq') }}</a>
          <a href="/#stats">{{ t('header.numbers') }}</a>
        </template>
        <RouterLink to="/gpfinder" @click="closeMenu">{{ t('header.gpFinder') }}</RouterLink>
      </nav>
      <RouterLink to="/gprunner" class="header-cta">
        <span v-if="isMobile">{{ t('header.game') }}</span>
        <span v-else>{{ t('header.learnThroughGame') }}</span>
      </RouterLink>

      <div class="dropdown language-control">
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
    <RouterView />
    <footer class="site-footer">
      <RouterLink to="/" class="brand">ScreeningTogether AU</RouterLink
      ><span>{{ t('footer.tagline') }}</span
      ><span>{{ t('footer.copyright') }}</span>
    </footer>

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

    <aside v-if="displayOptionsOpen" class="display-options" aria-label="Display options">
      <button
        class="display-options-close"
        type="button"
        aria-label="Close display options"
        @click="displayOptionsOpen = false"
      >
        ×
      </button>
      <p class="display-options-title">Display options</p>
      <p class="display-options-intro">
        Choose how the app looks for you. Saved only in this browser
      </p>

      <fieldset>
        <legend>Appearance</legend>
        <div class="option-grid option-grid-themes">
          <button
            type="button"
            :class="['option-card', { selected: selectedTheme === 'blush' }]"
            @click="setTheme('blush')"
          >
            <span class="theme-swatch swatch-blush"></span>Blush &amp; sage
          </button>
          <button
            type="button"
            :class="['option-card', { selected: selectedTheme === 'teal' }]"
            @click="setTheme('teal')"
          >
            <span class="theme-swatch swatch-teal"></span>Cervical teal
          </button>
          <button
            type="button"
            :class="['option-card', { selected: selectedTheme === 'accessible' }]"
            @click="setTheme('accessible')"
          >
            <span class="theme-swatch swatch-accessible"></span>Colour friendly
          </button>
        </div>
      </fieldset>

      <fieldset>
        <legend>Text size</legend>
        <div class="option-grid option-grid-text">
          <button
            type="button"
            :class="['option-card', { selected: textSize === 'normal' }]"
            @click="setTextSize('normal')"
          >
            Normal
          </button>
          <button
            type="button"
            :class="['option-card', { selected: textSize === 'larger' }]"
            @click="setTextSize('larger')"
          >
            Larger
          </button>
          <button
            type="button"
            :class="['option-card', { selected: textSize === 'largest' }]"
            @click="setTextSize('largest')"
          >
            Largest
          </button>
        </div>
      </fieldset>

      <button class="reset-display-options" type="button" @click="resetDisplayOptions">
        Reset to default
      </button>
    </aside>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref, computed } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'
import { useTranslation } from './i18n/useTranslation'

const menuOpen = ref(window.innerWidth > 900)
const isMobile = ref(window.innerWidth <= 900)

const route = useRoute()
const isHomePage = computed(() => route.path === '/')

const { t, changeLanguage } = useTranslation()

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
  font-size: 20px;
  color: #bd6f76;
  margin-right: 5px;
}

.brand-dot {
  color: #be6870;
}

.main-nav {
  display: flex;
  gap: 34px;
  margin-left: auto;
  margin-right: 46px;
}

.main-nav a {
  color: #796b6c;
  font-size: 12px;
  font-weight: 700;
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
  background: #302a2d;
  color: #fffaf8;
  border-radius: 100px;
  padding: 12px 17px;
  font-size: 11px;
  font-weight: 700;
}

.header-cta span {
  font-size: 15px;
  margin-left: 8px;
}

/* Language selector */
.language-control {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin: 0 4px;
}

.language-button {
  width: 52px;
  height: 38px;
  padding: 0 10px;
  border: 1px solid #6b595c;
  border-radius: 14px;
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
.site-shell.text-size-larger :deep(h1),
.site-shell.text-size-larger :deep(h2),
.site-shell.text-size-larger :deep(h3) {
  transform: scale(1.1);
  transform-origin: left center;
}
.site-shell.text-size-larger :deep(p),
.site-shell.text-size-larger :deep(a),
.site-shell.text-size-larger :deep(button),
.site-shell.text-size-larger :deep(label) {
  font-size: 1.08em;
}
.site-shell.text-size-largest :deep(h1),
.site-shell.text-size-largest :deep(h2),
.site-shell.text-size-largest :deep(h3) {
  transform: scale(1.2);
  transform-origin: left center;
}
.site-shell.text-size-largest :deep(p),
.site-shell.text-size-largest :deep(a),
.site-shell.text-size-largest :deep(button),
.site-shell.text-size-largest :deep(label) {
  font-size: 1.16em;
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
</style>
