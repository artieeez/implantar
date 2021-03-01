<template>
    <b-button block variant='primary' size='sm' v-b-modal.modal-nova-categoria>
        Adicionar Categoria
        <div>
            <b-modal
            id="modal-nova-categoria"
            ref="modal"
            title="Adicionar Categoria"
            @show="resetModal"
            @hidden="resetModal"
            @ok="handleOk"
            >
                <template #modal-cancel>
                    Cancelar
                </template>
                <template #modal-ok>
                    Adicionar
                </template>
                <form ref="form" @submit.stop.prevent="handleSubmit" novalidate>
                    <b-form-group
                        id="categoria-group-1"
                        label="Nome da Categoria:"
                        label-for="categoria"
                        :state="invalidCategoria"
                        :invalid-feedback="invalidCategoriaFeedback"
                    >
                        <b-form-input
                            id="categoria"
                            name="categoria"
                            v-model="categoria_nome"
                            type="text"
                            placeholder="Escolha o nome da categoria"
                            :state="invalidCategoria"
                            required
                        ></b-form-input>
                    </b-form-group>
                </form>
                <div class='loadingCon' v-show='$store.getters.isLoading'>
                    <b-spinner class="align-middle"></b-spinner>
                </div>
            </b-modal>
        </div>
    </b-button>
</template>

<script>
import { axiosBase, APIEndpoints } from '../../api/axios-base'
export default {
    name: 'NovaCategoria',
    data() {
        return {
            CATEGORIA_LENGTH: 6,
            categoria_nome: "",
            categoria_in_use: false,
        }
    },
    computed: {
        invalidCategoria() {
            if (this.categoria_nome == '') {
            return null
            } else if (this.categoria_nome.length < this.CATEGORIA_LENGTH) {
            return false
            } else {
            this.is_categoria_in_use(); // Altera is_categoria_in_use de forma async
            return !this.categoria_in_use;
            }
        },
        invalidCategoriaFeedback() {
            if (this.categoria_in_use) {
                return `Categoria já existente`;
            }
            return `O nome da categoria deve conter pelo menos ${this.CATEGORIA_LENGTH} 
            caracteres.`;
        },
    },
    methods: {
        checkFormValidity() {
            return this.invalidCategoria
        },
        resetModal() {
            this.categoria_nome = "";
        },
        handleOk(bvModalEvt) {
            // Prevent modal from closing
            bvModalEvt.preventDefault()
            // Trigger submit handler
            this.handleSubmit()
        },
        async handleSubmit() {
            // Exit when the form isn't valid
            this.loading = true;
            if (!this.checkFormValidity()) {
                console.log("not valid");
                return
            }
            // Post data
            await this.postCategoria();
            
            // Hide the modal manually
            this.$nextTick(() => {
                this.$bvModal.hide('modal-nova-categoria')
            })


        },
        is_categoria_in_use() {
        // Altera is_categoria_in_use de forma async
        let categoria = this.categoria_nome;
            axiosBase.get(
                APIEndpoints.is_categoria_in_use + '/' +
                categoria, {
            })
            .then(response => {
                if (response.status == "204") {
                  this.categoria_in_use = false;
                  return true;
                } else {
                  this.categoria_in_use = true;
                  return false;
                }
            })
            .catch(() => {
                this.categoria_in_use = true;
                return false // error generating new access and refresh token because refresh token has expired
            })
        },
        async postCategoria() {
            await this.$store.dispatch('postCategoria', this.categoria_nome)
            this.$store.dispatch('fetchCategorias');
        },
    }
  }
</script>

<style scoped>
</style>