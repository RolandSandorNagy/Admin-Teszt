<template>
  <div class="container py-4">
    <div class="mb-3">
      <div class="h4 mb-0">Admin Teszt</div>
      <div class="text-muted small">Vue 3 + CI4 API</div>
    </div>

    <router-view />

    <Toast v-if="toast.show" :type="toast.type" :message="toast.message" />
  </div>
</template>

<script setup>
import { reactive, provide } from 'vue'
import Toast from './components/Toast.vue'

const toast = reactive({ show: false, type: 'success', message: '' })

function showToast(type, message) {
  toast.type = type
  toast.message = message
  toast.show = true
  setTimeout(() => (toast.show = false), 2500)
}

provide('toast', { showToast })
</script>