<template>
  <ul>
    <li v-for="item in items" :key="item.id">
      <span>
        <strong>{{ item.title }}</strong>
        <span class="small" v-if="item.url"> — {{ item.url }}</span>
      </span>
      <MenuTree v-if="item.children?.length" :items="item.children" />
    </li>
  </ul>
</template>

<script setup>
import MenuTree from './MenuTree.vue'
defineProps({ items: { type: Array, default: () => [] } })
</script>
