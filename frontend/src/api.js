import axios from 'axios'

export const api = axios.create({
  baseURL: '',
  withCredentials: true,
  headers: { 'X-Requested-With': 'XMLHttpRequest' }
})

let csrfToken = null
let csrfRefreshing = null

export async function refreshCsrf() {
  // egyszerre csak 1 refresh fusson
  if (!csrfRefreshing) {
    csrfRefreshing = api.get('/api/csrf')
      .then((res) => {
        csrfToken = res.data?.token || null
      })
      .finally(() => {
        csrfRefreshing = null
      })
  }
  await csrfRefreshing
}

api.interceptors.request.use(async (config) => {
  const method = (config.method || 'get').toLowerCase()

  // GET/HEAD/OPTIONS általában nem igényel CSRF-et
  const needsCsrf = !['get', 'head', 'options'].includes(method)

  if (needsCsrf) {
    await refreshCsrf()
    if (csrfToken) {
      config.headers['X-CSRF-TOKEN'] = csrfToken
    }
  }

  return config
})