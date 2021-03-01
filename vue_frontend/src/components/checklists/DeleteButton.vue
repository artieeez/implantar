<template>
    <b-button variant='danger' class='ml-2' size='sm' v-b-modal.modal-delete-item>
        <b-icon-trash/>
        <div>
            <b-modal
            id="modal-delete-item"
            ref="modal"
            :title="`Excluir ${model}?`"
            @ok="handleOk"
            >
                <template #modal-cancel>
                    Cancelar
                </template>
                <template #modal-ok>
                    Excluir
                </template>
                <div class='loadingCon' v-show='$store.getters.isLoading'>
                    <b-spinner class="align-middle"></b-spinner>
                </div>
            </b-modal>
        </div>
    </b-button>
</template>

<script>
export default {
    name: 'DeleteButton',
    props: {
        id: Number,
        model: String,
        item: Object,  
    },
    computed: {
    },
    methods: {
        resetModal() {
        },
        handleOk() {
            // Trigger submit handler
            if (this.model === 'categoria') {
                this.deleteCategoria()
            }
        },
        async deleteCategoria() {
            await this.$store.dispatch('deleteCategoria', this.id);
            this.$store.dispatch('fetchCategorias');
        }
    }
  }
</script>

<style scoped>
</style>