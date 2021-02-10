<template>
    <b-button block variant='warning' size='sm' v-b-modal.modal-prevent-closing>
        Gerar link de cadastro
        <div>
            <b-modal
            id="modal-prevent-closing"
            ref="modal"
            title="Gerar link de cadastro"
            @show="resetModal"
            @hidden="resetModal"
            @ok="handleOk"
            >
                <form ref="form" @submit.stop.prevent="handleSubmit">
                    <b-form-group
                        id="input-group-1"
                        label="Grupo do usuário:"
                        label-for="grupoSelect"
                        :state="invalidGrupo"
                        :invalid-feedback="invalidGrupoFeedback"
                    >
                        <b-form-select
                            id='grupoSelect'
                            v-model="group_selected"
                            class="mb-3"
                            :state="invalidGrupo"
                        >
                            <b-form-select-option :value="null">Selecione uma opção</b-form-select-option>
                            <b-form-select-option-group label="Operador">
                                <b-form-select-option :value="'operador'">Operador (Acesso irrestrito)</b-form-select-option>
                                <b-form-select-option :value="'operador_limitado'">Operador Limitado</b-form-select-option>
                            </b-form-select-option-group>
                            <b-form-select-option-group label="Representante">
                                <b-form-select-option :value="'representante'">Representante</b-form-select-option>
                                <b-form-select-option :value="'representante_limitado'">Representante Limitado</b-form-select-option>
                            </b-form-select-option-group>
                        </b-form-select>
                    </b-form-group>
                    <b-form-group
                        id="input-group-2"
                        label="Redes associadas:"
                        label-for="redesSelect"
                        :state="invalidRedes"
                        :invalid-feedback="invalidRedesFeedback"
                    >
                        <b-form-select 
                            id='redesSelect'
                            v-model="redes_selected"
                            :options="redes"
                            multiple
                            :select-size="6"
                            :state="invalidRedes"
                        ></b-form-select>
                    </b-form-group>
                </form>
                <div class='loadingCon' v-show='loading'>
                    <b-spinner class="align-middle"></b-spinner>
                </div>
            </b-modal>

        </div>
    </b-button>
</template>

<script>
    /* Precisa 
        - lista de nomoes dos grupos 
        - lista de redes
    */
import { mapGetters } from 'vuex'
export default {
    name: 'RegisterToken',
    data() {
        return {
            loading: false,
            redes: [],
            group_selected: [],
            redes_selected: [],
        }
    },
    computed: {
      ...mapGetters(['accessToken', 'getUserProfile']),
        invalidGrupo() {
            if (this.group_selected == null) {
                return false;
            }
            return true;
        },
        invalidGrupoFeedback() {
            if (this.group_selected == null) {
                return 'Selecione um grupo.';
            }
            return null;
        },
        invalidRedes() {
            if (this.redes_selected == null || this.redes_selected.length == 0) {
                return false;
            }
            return true;
        },
        invalidRedesFeedback() {
            if (this.redes_selected == null || this.redes_selected.length == 0) {
                return 'Selecione pelo menos uma rede.';
            }
            return null;
        }
    },
    methods: {
        fetchRedes() {
        },
        checkFormValidity() {
            const valid = this.$refs.form.checkValidity()
            this.nameState = valid
            return valid
        },
        resetModal() {
            this.group_selected = null;
            this.redes_selected = null;
            this.loading = false;
        },
        handleOk(bvModalEvt) {
            // Prevent modal from closing
            bvModalEvt.preventDefault()
            // Trigger submit handler
            this.handleSubmit()
        },
        handleSubmit() {
            // Exit when the form isn't valid
            this.loading = true;
            if (!this.checkFormValidity()) {
                console.log("not valid");
                return
            }
            // Push the name to submitted names
            this.submittedNames.push(this.name)
            // Hide the modal manually
            this.$nextTick(() => {
            this.$bvModal.hide('modal-prevent-closing')
            })
        },
    }
  }
</script>

<style scoped>
.loadingCon {
    display: flex;
    width: 100%;
    justify-content: center;
}
</style>