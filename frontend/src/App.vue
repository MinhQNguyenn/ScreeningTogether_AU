<template>
  <div class="site-shell">
    <header :class="['site-header', { 'header-hidden': !headerVisible }]">
      <RouterLink to="/" class="brand"
        ><span class="brand-mark">✳</span> ScreeningTogether AU</RouterLink
      >
      <nav :class="['main-nav', { open: menuOpen }]" aria-label="Main navigation">
        <RouterLink to="/" @click="closeMenu">Home</RouterLink>
        <template v-if="isHomePage">
          <a href="/#learn" @click="closeMenu">Learn</a>
          <a href="/#screening-info" @click="closeMenu">FAQ</a>
          <a href="/#stats" @click="closeMenu">The numbers</a>
        </template>
        <RouterLink to="/gpfinder" @click="closeMenu">GP Finder</RouterLink>
      </nav>
      <RouterLink to="/game" class="header-cta">Learn through the game<span>↗</span></RouterLink>
      <button class="menu-toggle" aria-label="Toggle menu" @click="toggleMenu">
        <span></span><span></span>
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

const menuOpen = ref(true)
const headerVisible = ref(true)
let previousScrollY = 0

const route = useRoute()
const isHomePage = computed(() => route.path === '/')

const toggleMenu = () => {
  menuOpen.value = !menuOpen.value
}

const closeMenu = () => {
  menuOpen.value = false
}

const updateHeaderVisibility = () => {
  const currentScrollY = window.scrollY
  headerVisible.value = currentScrollY < 12 || currentScrollY < previousScrollY
  previousScrollY = currentScrollY
}

onMounted(() => window.addEventListener('scroll', updateHeaderVisibility, { passive: true }))

onUnmounted(() => window.removeEventListener('scroll', updateHeaderVisibility))
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
  background: none;
  border: 0;
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
</style>
