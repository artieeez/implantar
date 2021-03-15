<template>
    <b-button
        variant="warning"
        class='ml-2'
        size='sm'
        @click="active_change(entry.id, !entry.is_active)"
        v-b-tooltip.hover title="Ao desativar uma categoria, novos checklists serão gerados sem ela."
    >
        <span v-if='entry.is_active'><b-icon-lock-fill/> Desativar {{ modelName }}</span>
        <span v-if='!entry.is_active'><b-icon-unlock-fill/> Ativar {{ modelName }}</span>
    </b-button>
</template>

<script>
export default {
    name: 'ModelActiveButton',
    props: {
        modelName: { // Define o model
            type: String,
            require: true,
        },
        entry: {
            type: Object,
            require: true,
        },
        patchRoute: {
            type: String,
            require: true,
            default: function () {
                return `patch${this.modelName[0].toUpperCase()}` 
                    + `${this.modelName.slice(1)}`
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
        active_change(id, boolean) {
        let modelObject = {
            id: id,
            is_active: boolean,
        };
        this.$store.dispatch(this.patchRoute, modelObject).then(() => {
            this.$store.dispatch(this.fetchRoute, modelObject).then(() => {
            });
        });
        },
    }
  }
</script>

<style scoped>
</style>