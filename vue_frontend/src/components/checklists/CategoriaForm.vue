<template>
    <b-button 
        :variant='newEntry 
            ? "primary"
            : "warning"'
        :block='newEntry'
        size='sm'
        v-b-modal='newEntry
            ? "novaCategoria"
            : `editCategoria-${entry.id}`'
        :class='!newEntry 
            ? "ml-2" 
            : ""'
        @click="showModal= !showModal">
        <span v-if='newEntry'>Nova Categoria</span>
        <span v-else><b-icon-pen-fill/></span>
        <div>
            <b-modal
            :id='newEntry
                ? "novaCategoria" 
                : `editCategoria-${entry.id}`'
            ref="modal"
            :title="newEntry 
                ? 'Nova categoria' 
                : `${entry.nome}`"
            @show="resetModal"
            @hidden="resetModal"
            @ok="handleOk"
            >
                <template #modal-cancel>
                    Cancelar
                </template>
                <template #modal-ok>
                    Salvar
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
                            v-model="nome"
                            type="text"
                            placeholder="Escolha o nome da categoria"
                            :state="invalidCategoria"
                            required
                            autofocus
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
    name: 'CategoriaForm',
    props: {
        newEntry: {
            type: Boolean,
            require: true,
        },
        entry: Object,
    },
    data() {
        return {
            nome: this.entry.nome,
            CATEGORIA_LENGTH: 6,
            categoria_in_use: false,
        }
    },
    computed: {
        invalidCategoria() {
            if (this.nome == '') {
            return null
            } else if (this.nome.length < this.CATEGORIA_LENGTH) {
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
            if (this.newEntry) {
                this.nome = "";
            } else {
                this.nome = this.entry.nome;
            }
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
            if (this.newEntry) {
                await this.postCategoria();
            } else {
                await this.patchCategoria();
            }
            
            // Hide the modal manually
            this.$nextTick(() => {
                this.newEntry
                ? this.$bvModal.hide("novaCategoria")
                : this.$bvModal.hide(`editCategoria-${this.entry.id}`)
            })


        },
        is_categoria_in_use() {
        // Altera is_categoria_in_use de forma async
        let categoria = this.nome;
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
            await this.$store.dispatch('postCategoria', this.nome)
            this.$store.dispatch('fetchCategorias');
        },
        async patchCategoria() {
            await this.$store.dispatch('categoria_partial_update', {
                id: this.entry.id,
                nome: this.nome
                })
            this.$store.dispatch('fetchCategorias');
        }
    }
  }
</script>

<style scoped>
</style>