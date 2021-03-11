<template>
    <span class='d-inline-flex'>
        {{ index }}
        <div class='ml-2'>
            <b-icon-arrow-up-circle class='mr-1' v-show='index > 1' @click='changeOrder(-1)'/>
            <b-icon-arrow-down-circle v-show='index < length' @click='changeOrder(1)'/>
        </div>
    </span>
</template>

<script>
export default {
    name: 'Ordem',
    props: {
        id: Number,
        index: Number,
        model: String,
        item: Object,
        length: Number,
    },
    computed: {
    },
    methods: {
        changeOrder(quantity) {
            this.$store.commit('setLoading', true);
            if (this.model === 'categoria') {
                this.$store.dispatch('categoria_change_order', {
                    id: this.id,
                    id_arb: this.index + quantity
                })
                .then(() => {
                    this.$store.dispatch('fetchCategorias')
                    .then(() => {
                        this.$store.commit('setLoading', false);
                    })
                });
            }
        }
    }
  }
</script>

<style scoped>
</style>