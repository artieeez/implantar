<template>
    <b-button @click='fetchRedes()' block variant='warning' size='sm' v-b-modal.modal-prevent-closing>
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
                <template #modal-cancel>
                    Cancelar
                </template>
                <template #modal-ok>
                    Próximo
                </template>

                <form ref="form" @submit.stop.prevent="handleSubmit" novalidate>
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
                            :options="groups"
                            value-field="id"
                            text-field="name"
                            :select-size="6"
                            :state="invalidGrupo"
                        ></b-form-select>
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
                            value-field="id"
                            text-field="nome"
                            :select-size="6"
                            :state="invalidRedes"
                        ></b-form-select>
                    </b-form-group>
                </form>
                <div class='loadingCon' v-show='$store.getters.isLoading'>
                    <b-spinner class="align-middle"></b-spinner>
                </div>
            </b-modal>
        </div>
        <div>
            <b-modal id="bv-modal-token" hide-footer>
                <template #modal-title>
                    <h4>Aqui está o link de cadastro:</h4>
                </template>
                <div class="d-block text-center">
                    <p class='register-token p-1'>{{ get_register_link }}</p>
                </div>
                <b-button class="" block @click="copy_register_url"><b-icon-clipboard/> Copiar</b-button>
                <input type="hidden" id="register-url">
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
import * as helpers from '../../helpers/index'
export default {
    name: 'RegisterToken',
    data() {
        return {
            // Redes
            filter_options: {
                is_active: {
                    in_use: true,
                    value: true,
                }
            },
            group_selected: null,
            redes_selected: [],
            groups: null,
            redes: [],
            register_token: null,
            register_token_form_to_copy: null,
        }
    },
    mounted() {
        this.fetchGroups();
    },
    computed: {
        ...mapGetters(['getRedes', 'getGroups']),
        itemsRedes() {
            if (this.getRedes != null && this.getRedes.length > 0) {
                return this.getRedes;
            }
            return null;
            /* let _default = {
                text: 'Não associar',
                value: null,
            };
            let items = [_default];
            if (this.getRedes != null) {
                for (let i = 0; i < this.getRedes.length; i++) {
                    let row = {
                        value: this.getRedes[i].id,
                        text: this.getRedes[i].nome,
                    }
                    items.push(row);
                }
            }
            return items; */
        },
        invalidGrupo() {
            if (this.group_selected == null) {
                return false;
            } else {
                return true;
            }
        },
        invalidGrupoFeedback() {
            if (this.group_selected == null) {
                return 'Selecione um grupo.';
            } else {
                return null;
            }
        },
        invalidRedes() {
            if (this.redes_selected == null || this.redes_selected.length == 0) {
                return false;
            } else {
                return true;
            }
        },
        invalidRedesFeedback() {
            if (this.redes_selected == null || this.redes_selected.length == 0) {
                return 'Selecione pelo menos uma rede.';
            } else {
                return null;
            }
        },
        get_register_link() {
            return `${window.location.hostname}/register?register-token=${this.register_token}`
        }
    },
    methods: {
        async fetchGroups() {
            this.$store.commit('setLoading', true);
            let success = false;
            let store = this.$store;
            let count = 1;
            do {
            await store.dispatch('fetchGroups')
                    .then(() => {
                        success = true; // Breaks do while
                        this.groups = this.getGroups;
                        this.$store.commit('setLoading', false);
                        return;
                    })
                    .catch(async err => { // 1* Função anônima async
                        if (err.config && err.response && err.response.status === 401) { 
                            await store.dispatch('refreshToken') // attempt to obtain new access token by running 'refreshToken' action
                        }
                    })
            await helpers.sleep(500);
            count++;
            } while (!success && count < 10);
        },
        async fetchRedes() {
            this.$store.commit('setLoading', true);
            let success = false;
            let store = this.$store;
            let count = 1;
            do {
            await store.dispatch('fetchRedes', this.filter_options)
                    .then(() => {
                        success = true; // Breaks do while
                        this.redes = this.getRedes;
                        this.$store.commit('setLoading', false);
                        return;
                    })
                    .catch(async err => { // 1* Função anônima async
                        if (err.config && err.response && err.response.status === 401) { 
                            await store.dispatch('refreshToken') // attempt to obtain new access token by running 'refreshToken' action
                        }
                    })
            await helpers.sleep(500);
            count++;
            } while (!success && count < 10);
        },
        checkFormValidity() {
            return this.invalidGrupo && this.invalidRedes
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
        async handleSubmit() {
            // Exit when the form isn't valid
            this.loading = true;
            if (!this.checkFormValidity()) {
                console.log("not valid");
                return
            }
            // Post token data
            await this.postRegisterToken();
            // Show register_token
            if (this.register_token != null) {
                this.$bvModal.show('bv-modal-token');
            }

            
            // Hide the modal manually
            this.$nextTick(() => {
                this.$bvModal.hide('modal-prevent-closing')
            })


        },
        async postRegisterToken() {
            // Retorna True em caso de sucesso
            this.$store.commit('setLoading', true);
            let success = false;
            let store = this.$store;
            let count = 1;
            // bugfix - id tem que ser string!
            let _redes = []
            console.log(this.redes_selected);
            for (let i = 0; i < this.redes_selected.length; i++) {
                _redes.push(this.redes_selected[i].toString());
            }
            let data = {
                group: this.group_selected,
                redes: this.redes_selected,
            }
            do {
            await store.dispatch('postRegisterToken', data)
                    .then((response) => {
                        success = true; // Breaks do while
                        this.register_token = response.data.token;
                        this.$store.commit('setLoading', false);
                        return;
                    })
                    .catch(async err => { // 1* Função anônima async
                        if (err.config && err.response && err.response.status === 401) { 
                            await store.dispatch('refreshToken') // attempt to obtain new access token by running 'refreshToken' action
                        }
                    })
            await helpers.sleep(500);
            count++;
            } while (!success && count < 10);
        },
        copy_register_url() {
            let registerTokenUrl = document.querySelector('#register-url');
            registerTokenUrl.value = this.get_register_link;
            registerTokenUrl.setAttribute('type', 'text');
            registerTokenUrl.value = this.get_register_link;
            registerTokenUrl.select();
            try {
                document.execCommand('copy');
            } catch (err) {
                alert('Oops, erro ao copiar.');
            }
            /* unselect the range */
            registerTokenUrl.setAttribute('type', 'hidden')
            window.getSelection().removeAllRanges()

            this.$bvModal.hide('bv-modal-token');
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
.register-token {
    font-size: 14px;
    background-color: lightgray;
}
</style>