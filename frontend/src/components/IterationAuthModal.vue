```vue
<template>
  <div v-if="authState.visible" class="auth-overlay">
    <div class="auth-modal" role="dialog" aria-modal="true" aria-labelledby="auth-title">
      <h2 id="auth-title">Restricted Access</h2>
      <p>Please enter your credentials to access this iteration.</p>

      <form @submit.prevent="handleLogin">
        <label for="iteration-username">Username</label>
        <input
          id="iteration-username"
          v-model="username"
          type="text"
          autocomplete="username"
          required
        />

        <label for="iteration-password">Password</label>
        <input
          id="iteration-password"
          v-model="password"
          type="password"
          autocomplete="current-password"
          required
        />

        <p v-if="errorMessage" class="auth-error" role="alert">
          {{ errorMessage }}
        </p>

        <button type="submit">Log in</button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { authState, resolveAuth } from '../router/iterationAuth'

const username = ref('')
const password = ref('')
const errorMessage = ref('')

const CORRECT_USERNAME = 'deepluna'
const CORRECT_PASSWORD = 'fit5120'

function handleLogin() {
  if (username.value === CORRECT_USERNAME && password.value === CORRECT_PASSWORD) {
    sessionStorage.setItem('iteration-authenticated', 'true')

    username.value = ''
    password.value = ''
    errorMessage.value = ''

    resolveAuth(true)
  } else {
    errorMessage.value = 'Incorrect username or password. Please try again.'
    password.value = ''
  }
}
</script>

<style scoped>
.auth-overlay {
  position: fixed;
  inset: 0;
  z-index: 10000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: rgba(30, 20, 25, 0.65);
  backdrop-filter: blur(4px);
}

.auth-modal {
  width: 100%;
  max-width: 420px;
  padding: 32px;
  border-radius: 16px;
  background: #fffaf8;
  color: #3e3033;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
}

.auth-modal h2 {
  margin: 0 0 10px;
}

.auth-modal p {
  line-height: 1.5;
}

.auth-modal form {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.auth-modal label {
  font-weight: 600;
  margin-top: 8px;
}

.auth-modal input {
  width: 100%;
  box-sizing: border-box;
  padding: 12px;
  border: 1px solid #d9c4c8;
  border-radius: 8px;
  font: inherit;
}

.auth-modal button {
  margin-top: 12px;
  padding: 12px;
  border: none;
  border-radius: 8px;
  background: #a95f70;
  color: white;
  font: inherit;
  font-weight: 600;
  cursor: pointer;
}

.auth-modal button:hover {
  background: #874657;
}

.auth-error {
  color: #b42318;
  font-size: 0.9rem;
}
</style>
```
