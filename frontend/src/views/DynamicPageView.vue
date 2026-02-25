<template>
  <div class="row justify-content-center">
    <div class="col-12 col-lg-8">
      <!-- Loading -->
      <div v-if="loading" class="card shadow-sm">
        <div class="card-body">
          <div class="placeholder-glow">
            <span class="placeholder col-6"></span>
            <span class="placeholder col-8"></span>
            <span class="placeholder col-4"></span>
          </div>
          <div class="text-muted small mt-2">Betöltés...</div>
        </div>
      </div>

      <!-- Matched page -->
      <div v-else-if="matched" class="card shadow-sm">
        <div class="card-body">
          <div class="d-flex align-items-start justify-content-between gap-3">
            <div>
              <h2 class="h4 mb-1">{{ matched.title }}</h2>
              <div class="text-muted small">
                URL: <code>{{ matched.url }}</code>
              </div>
            </div>

            <span class="badge text-bg-secondary">Dinamikus oldal</span>
          </div>

          <hr />

          <p class="mb-0">
            Ez az oldal a menüből jön (dinamikus route). Ide később tehetsz tényleges tartalmat, jogosultságot,
            vagy akár backendről betöltött “page content”-et.
          </p>
        </div>
      </div>
      <!-- No access -->
      <div v-else-if="accessDenied" class="card shadow-sm border-warning">
        <div class="card-body">
            <h2 class="h4 mb-2">Nincs hozzáférés</h2>
            <p class="mb-3">A tartalom megtekintéséhez jelentkezz be.</p>
            <router-link class="btn btn-primary" to="/">Belépés</router-link>
        </div>
      </div>

      <!-- 404 -->
      <div v-else class="card shadow-sm border-danger">
        <div class="card-body">
            <h2 class="h4 mb-2">404</h2>
            <p class="mb-3">Ez az oldal nem létezik a menüben.</p>
            <router-link class="btn btn-outline-primary" to="/">Vissza a loginhoz</router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { api } from '../api'

const route = useRoute()

const loading = ref(true)
const menu = ref([])
const matched = ref(null)

const accessDenied = ref(false)

function findByUrl(items, url) {
  for (const it of items || []) {
    if (it?.url === url) return it
    const found = findByUrl(it?.children, url)
    if (found) return found
  }
  return null
}

async function load() {
  loading.value = true
  matched.value = null
  accessDenied.value = false

  try {
    const res = await api.get('/api/menu')
    menu.value = res.data?.menu || []
  } catch (e) {
    const status = e?.response?.status
    if (status === 401) {
        accessDenied.value = true
    }
    menu.value = []
  }

  const path = route.path
  matched.value = findByUrl(menu.value, path)

  loading.value = false
}

onMounted(load)
</script>