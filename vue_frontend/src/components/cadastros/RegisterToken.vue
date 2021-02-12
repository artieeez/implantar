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
            // Hide the modal manually
            this.$nextTick(() => {
                this.$bvModal.hide('modal-prevent-closing')
            })
        },
        async postRegisterToken() {
            this.$store.commit('setLoading', true);
            let success = false;
            let store = this.$store;
            let count = 1;
            // bugfix - id tem que ser string!
            let _redes = []
            for (let i = 0; i < this.redes_selected; i++) {
                _redes.push(this.redes_selected[i].toString());
            }
            let data = {
                group: this.group_selected,
                redes: this.redes_selected,
            }
            do {
            await store.dispatch('postRegisterToken', data)
                    .then(() => {
                        success = true; // Breaks do while
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
        }
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