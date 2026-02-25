<template>
  <div class="row g-3">
    <!-- Header card -->
    <div class="col-12">
      <div class="card shadow-sm">
        <div class="card-body d-flex align-items-center justify-content-between">
          <div>
            <h2 class="h4 mb-0">Admin</h2>
            <div class="text-muted small">Menürendszer kezelése</div>
          </div>
          <button class="btn btn-outline-secondary" @click="logout">Kijelentkezés</button>
        </div>
      </div>
    </div>

    <!-- Menu tree -->
    <div class="col-12 col-lg-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <h3 class="h5 mb-0">Menü fa</h3>
            <button class="btn btn-sm btn-outline-primary" @click="loadMenu">Frissítés</button>
          </div>

          <div v-if="menu.length" class="mt-3">
            <MenuTree :items="menu" />
          </div>
          <div v-else class="text-muted small mt-3">
            Nincs adat (vagy nem vagy bejelentkezve).
          </div>
        </div>
      </div>
    </div>

    <!-- Create menu item -->
    <div class="col-12 col-lg-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h3 class="h5 mb-3">Új menüpont</h3>

          <form @submit.prevent="createItem">
            <div class="mb-3">
              <label class="form-label">Title*</label>
              <input class="form-control" v-model="form.title" />
              <div class="text-danger small mt-1" v-if="errors.title">{{ errors.title }}</div>
            </div>

            <div class="mb-3">
              <label class="form-label">URL</label>
              <input class="form-control" v-model="form.url" placeholder="/valami" @blur="normalizeUrl" />
              <div class="text-danger small mt-1" v-if="errors.url">{{ errors.url }}</div>
            </div>

            <div class="row g-2">
              <div class="col-12 col-md-4">
                <label class="form-label">Szülő menüpont</label>
                <select class="form-select" v-model="form.parent_id">
                  <option value="">(nincs – gyökérszint)</option>
                  <option v-for="opt in parentOptions" :key="opt.id" :value="String(opt.id)">
                    {{ opt.label }}
                  </option>
                </select>
                <div class="text-danger small mt-1" v-if="errors.parent_id">{{ errors.parent_id }}</div>
              </div>

              <div class="col-12 col-md-4">
                <label class="form-label">Sort</label>
                <input class="form-control" v-model="form.sort_order" placeholder="0" />
                <div class="text-danger small mt-1" v-if="errors.sort_order">{{ errors.sort_order }}</div>
              </div>

              <div class="col-12 col-md-4">
                <label class="form-label">Állapot</label>
                <select class="form-select" v-model="form.is_active">
                  <option value="1">Aktív</option>
                  <option value="0">Inaktív</option>
                </select>
                <div class="text-danger small mt-1" v-if="errors.is_active">{{ errors.is_active }}</div>
              </div>
            </div>

            <div class="d-grid mt-3">
              <button class="btn btn-primary" type="submit">Létrehozás</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, inject, reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '../api'
import MenuTree from '../components/MenuTree.vue'

const { showToast } = inject('toast')
const router = useRouter()

const parentOptions = computed(() => flattenMenu(menu.value))

const menu = ref([])
const form = reactive({ title:'', url:'', parent_id:'', sort_order:'0', is_active:'1' })
const errors = reactive({})

async function loadMenu() {
  try {
    const res = await api.get('/api/menu')
    menu.value = res.data?.menu || []
  } catch (e) {
    showToast('error', e?.response?.data?.message || 'Nem sikerült betölteni a menüt.')
    menu.value = []
  }
}

async function createItem() {
  for (const k of Object.keys(errors)) errors[k] = ''

  try {
    ensureUrlFromTitle()
    normalizeUrl()

    const fd = new FormData()
    fd.append('title', form.title)
    fd.append('url', form.url)
    if (form.parent_id) fd.append('parent_id', form.parent_id)
    fd.append('sort_order', form.sort_order)
    fd.append('is_active', form.is_active)

    const res = await api.post('/api/menu', fd)
    showToast('success', res.data?.message || 'Létrehozva.')
    form.title = ''; form.url = ''; form.parent_id=''; form.sort_order='0'; form.is_active='1'
    await loadMenu()
  } catch (e) {
    const data = e?.response?.data
    if (data?.errors) Object.assign(errors, data.errors)
    showToast('error', data?.message || 'Hiba történt.')
  }
}

function slugify(str) {
  return (str || '')
    .toString()
    .trim()
    .toLowerCase()
    .normalize('NFD')                 // ékezetek szétbontása
    .replace(/[\u0300-\u036f]/g, '')  // ékezetek eltávolítása
    .replace(/[^a-z0-9]+/g, '-')      // nem alfanumerikus -> kötőjel
    .replace(/^-+|-+$/g, '')          // szélső kötőjelek le
}

function ensureUrlFromTitle() {
  const url = (form.url || '').trim()
  if (url) return
  const s = slugify(form.title)
  form.url = s ? `/${s}` : ''
}

function flattenMenu(items, depth = 0, out = []) {
  for (const it of items || []) {
    out.push({
      id: it.id,
      label: `${'—'.repeat(depth)} ${it.title}`.trim(),
    })
    if (it.children?.length) flattenMenu(it.children, depth + 1, out)
  }
  return out
}

function normalizeUrl() {
  const v = (form.url || '').trim()
  if (!v) return

  // ha "test-1" -> "/test-1"
  if (!v.startsWith('/')) {
    form.url = '/' + v
  } else {
    form.url = v
  }
}

async function logout() {
  try { await api.post('/api/logout') } catch {}
  showToast('success', 'Kijelentkezve.')
  router.push('/')
}

onMounted(loadMenu)
</script>
