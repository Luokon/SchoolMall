<script setup>
import useSystemStore from '@/stores/system'
import {useRouter} from "vue-router";
const $route = useRouter()
const systemStore = useSystemStore()
// 返回首页
const goHome = () => {
  $route.push('/')
}
</script>
<script>
export default {
  name: 'Logo'
}
</script>
<template>
  <div class="logo" :class="{ fold: systemStore.fold ? true : false }" @click="goHome">
    <img src="/public/logo.png" style="width: 20px; height: 20px; margin-left: 23px" />

    <p style="margin-left: 10px; cursor: pointer; color: white">sm-mall</p>
  </div>
</template>

<style scoped lang="scss">
.logo {
  height: 50px;
  width: 200px;
  display: flex;
  align-items: center;

  &.fold {
    p {
      display: none;
    }
  }

}
</style>
