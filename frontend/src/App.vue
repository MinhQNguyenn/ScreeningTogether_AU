<template>
  <div class="site-shell">
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

const { t, changeLanguage, currentLanguage } = useTranslation()

const toggleMenu = () => {
  menuOpen.value = !menuOpen.value
}
const closeMenu = () => {
  menuOpen.value = false
}

const handleResize = () => {
  isMobile.value = window.innerWidth <= 900

  // Keep desktop menu open
  if (window.innerWidth > 900) {
    menuOpen.value = true
  }
}

onMounted(() => {
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
</style>
