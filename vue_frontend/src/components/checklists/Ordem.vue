<template>
    <span class='d-inline-flex'>
        <span v-if='modelName === "itemBase"'>{{ entry.categoria.id_arb }}.</span>{{ entry.id_arb }}
        <div class='ml-2'>
            <b-icon-arrow-up-circle class='mr-1' v-show='entry.id_arb > 1' @click='changeOrder(-1)'/>
            <b-icon-arrow-down-circle v-show='entry.id_arb < entry.id_arb_max' @click='changeOrder(1)'/>
        </div>
    </span>
</template>

<script>
export default {
    name: 'Ordem',
    props: {
        entry: {
            type: Object,
            required: true,
        },
        modelName: {
            type: String,
            required: true,
        },
        changeOrderRoute: {
            type: String,
            require: true,
            default: function () {
                return `${this.modelName}_change_order` 
            },
        },
        fetchRoute: {
            type: String,
            require: true,
            default: function () {
                return `fetch${this.modelName[0].toUpperCase()}` 
                    + `${this.modelName.slice(1)}s`
            },
        },
    },
    methods: {
        changeOrder(quantity) {
            this.$store.commit('setLoading', true);
            this.$store.dispatch(this.changeOrderRoute, {
                id: this.entry.id,
                id_arb: this.entry.id_arb + quantity
            })
            .then(() => {
                this.$store.dispatch(this.fetchRoute)
                .then(() => {
                    this.$store.commit('setLoading', false);
                })
            });
        }
    }
  }
</script>

<style scoped>
</style>