<template>
    <span class='d-inline-flex'>
        {{ index }}
        <div class='ml-2'>
            <b-icon-arrow-up-circle class='mr-1' v-show='index > 1' @click='changeOrder(-1)'/>
            <b-icon-arrow-down-circle v-show='index < listLength' @click='changeOrder(1)'/>
        </div>
    </span>
</template>

<script>
export default {
    name: 'Ordem',
    props: {
        id: {
            type: Number,
            required: true,
        },
        index: {
            type: Number,
            required: true,
        },
        modelName: {
            type: String,
            required: true,
        },
        listLength: {
            type: Number,
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
                id: this.id,
                id_arb: this.index + quantity
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