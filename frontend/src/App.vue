<template>
  <div class="site-shell">
    <header class="site-header">
      <RouterLink to="/" class="brand"
        ><span class="brand-mark">✳</span> ScreeningTogether AU</RouterLink
      >
      <nav :class="['main-nav', { open: menuOpen }]" aria-label="Main navigation">
        <RouterLink to="/">Home</RouterLink>

        <template v-if="isHomePage">
          <a href="/#learn">Learn</a>
          <a href="/#screening-info">FAQ</a>
          <a href="/#stats">The numbers</a>
        </template>
        <!-- This section will be implemented when GP finder feature is ready (Iteration 2)
                <RouterLink to="/gpfinder" @click="closeMenu">GP Finder</RouterLink>
                -->
      </nav>
      <RouterLink to="/gprunner" class="header-cta">
        <span v-if="isMobile">Game</span>
        <span v-else>Learn through the game</span>
        <span>↗</span>
      </RouterLink>
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
      ><span>Prevention starts with a conversation.</span><span>© 2026 ScreeningTogether AU</span>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref, computed } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'

const menuOpen = ref(window.innerWidth > 900)
const isMobile = ref(window.innerWidth <= 900)

const route = useRoute()
const isHomePage = computed(() => route.path === '/')

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
  transition: transform 0.25s ease;
  justify-content: space-between;
  padding: 0 max(6vw, 24px);
  background: #fffaf8;
  position: sticky;
  top: 0;
  z-index: 1050;
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
.menu-toggle {
  display: none;
}
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
@media (max-width: 700px) {
  .main-nav {
    display: none !important;
    position: absolute;
    top: 78px;
    left: 0;
    right: 0;
    width: 100%;
    height: auto;
    background: #fffaf8;
    padding: 20px 24px;
    flex-direction: column;
    gap: 18px;
    box-shadow: 0 10px 20px #0000000c;
  }
  .main-nav.open {
    display: flex !important;
    visibility: visible;
    opacity: 1;
  }
  .main-nav:not(.open) {
    visibility: hidden;
    pointer-events: none;
  }
  .header-cta {
    display: none;
  }
  .menu-toggle {
    display: flex;
    flex-direction: column;
    gap: 5px;
  }
  .menu-toggle span {
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
@media (max-width: 900px) {
  .site-header {
    padding: 0 20px;
  }

  .main-nav {
    display: none;
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
    display: flex;
  }

  /* Keep the game button visible */
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

  /* Hamburger / close button */
  .menu-toggle {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 5px;
    width: 40px;
    height: 40px;
    margin-left: 8px;
    padding: 0;
    border: 0;
    background: transparent;
    cursor: pointer;
  }

  .menu-toggle > span:not(.close-icon) {
    display: block;
    width: 23px;
    height: 2px;
    background: #302a2d;
  }

  .menu-toggle .close-icon {
    font-size: 32px;
    font-weight: 300;
    line-height: 1;
    color: #302a2d;
  }
}

@media (max-width: 420px) {
  .site-header {
    padding: 0 14px;
  }

  .brand {
    font-size: 15px;
  }

  .brand-mark {
    font-size: 18px;
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

  .menu-toggle {
    margin-left: 3px;
  }

  .main-nav {
    padding: 18px 16px;
  }
}

@media (max-width: 420px) {
  .site-header {
    padding: 0 14px;
  }

  .brand {
    font-size: 15px;
  }

  .brand-mark {
    font-size: 18px;
    margin-right: 3px;
  }

  .main-nav {
    padding: 18px 16px;
  }
}
@media (max-width: 520px) {
  .brand {
    font-size: 14px;
  }
  .brand-mark {
    font-size: 17px;
  }
  .header-cta {
    padding: 8px 9px;
    font-size: 9px;
  }
  .header-cta span {
    font-size: 12px;
    margin-left: 4px;
  }
  .menu-toggle {
    margin-left: 3px;
  }
}
</style>
