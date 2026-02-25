<template>
  <div class="row justify-content-center">
    <div class="col-12 col-md-6 col-lg-5">
      <div class="card shadow-sm">
        <div class="card-body">
          <h2 class="h4 mb-3">Belépés</h2>

          <form @submit.prevent="onSubmit">
            <div class="mb-3">
              <label class="form-label">Nickname</label>
              <input class="form-control" v-model="form.nickname" placeholder="admin" />
              <div class="text-danger small mt-1" v-if="errors.nickname">{{ errors.nickname }}</div>
            </div>

            <div class="mb-3">
              <label class="form-label">Jelszó</label>
              <input class="form-control" v-model="form.password" type="password" placeholder="Admin123!" />
              <div class="text-danger small mt-1" v-if="errors.password">{{ errors.password }}</div>
            </div>

            <button class="btn btn-primary w-100" type="submit">Belépés</button>

            <div class="text-muted small mt-3">
              Backend: <code>/api/login</code> (Vite proxy: 5173 → 8080)
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { inject, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { api, refreshCsrf } from '../api'

const router = useRouter()
const { showToast } = inject('toast')

const form = reactive({ nickname: '', password: '' })
const errors = reactive({})

async function onSubmit() {
  errors.nickname = ''
  errors.password = ''

  try {
    await refreshCsrf()

    const fd = new FormData()
    fd.append('nickname', form.nickname)
    fd.append('password', form.password)

    const res = await api.post('/api/login', fd)
    if (res.data?.ok) {
      showToast('success', res.data.message || 'Sikeres bejelentkezés!')
      router.push('/admin')
    } else {
      showToast('error', res.data?.message || 'Sikertelen belépés.')
    }
  } catch (e) {
    const data = e?.response?.data
    if (data?.errors) {
      Object.assign(errors, data.errors)
    }
    showToast('error', data?.message || 'Hiba történt.')
  }
}
</script>
