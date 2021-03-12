<template>
    <b-button
        variant='danger'
        class='ml-2'
        size='sm'
        v-b-modal='modalName'>
        <b-icon-trash/>
        <div>
            <b-modal
            :id='modalName'
            ref="modal"
            :title="`Excluir ${modelName}?`"
            @ok="handleOk"
            >
                <p v-html='model.aviso'/> 

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
    name: 'ModelDeleteButton',
    props: {
        modelName: { // Define o model
            type: String,
            require: true,
        },
        entry: {
            type: Object,
            require: true,
        },
        fetchRoute: {
            type: String,
            require: true,
            default: function () {
                return `fetch${this.modelName[0].toUpperCase()}` 
                    + `${this.modelName.slice(1)}s`
            },
        },
        deleteRoute: {
            type: String,
            require: true,
            default: function () {
                return `delete${this.modelName[0].toUpperCase()}` 
                    + `${this.modelName.slice(1)}`
            }
        }
    },
    data() {
        return {
            model: null, // Corresponde ao prop modelName
            categoria: {
                aviso: `
                    Atenção! Ao excluir esta categoria você pode estar deixando alguns itens sem categoria. <br>
                    Considere <b>desativar</b> a categoria.
                `,
            },
            item: {
                aviso: `
                    Atenção! Ao excluir este item você pode quebrar relátorios que o utilizem. <br>
                    Considere <b>desativar</b> o item.
                `,
            }
        }
    },
    created() {
        this.model = this[this.modelName];
    },
    computed: {
        modalName() {
            return `del${this.modelName}-${this.entry.id}`
        },
    },
    methods: {
        handleOk() {
            // Trigger submit handler
            this.deleteModel();
        },
        async deleteModel() {
            await this.$store.dispatch(this.deleteRoute, this.entry.id);
            this.$store.dispatch(this.fetchRoute);
        },
    }
  }
</script>

<style scoped>
</style>