<template>
  <div class="position-fixed top-0 end-0 p-3" style="z-index: 1080;">
    <div
      class="toast show align-items-center border-0"
      :class="type === 'success' ? 'text-bg-success' : 'text-bg-danger'"
      role="alert"
      aria-live="assertive"
      aria-atomic="true"
    >
      <div class="d-flex">
        <div class="toast-body">
          {{ message }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  type: { type: String, default: 'success' },
  message: { type: String, required: true }
})
</script>