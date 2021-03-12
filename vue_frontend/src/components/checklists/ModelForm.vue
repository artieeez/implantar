<template>
    <b-button
        :variant='newEntry 
            ? "primary"
            : "warning"'
        :block='newEntry'
        size='sm'
        v-b-modal='modalName'
        :class='!newEntry 
            ? "ml-2" 
            : ""'
        @click="showModal= !showModal">
        <span v-if='newEntry'>Adicionar {{ modelName }}</span>
        <span v-else><b-icon-pen-fill/></span>
        <div>
            <b-modal
                :id='modalName'
                ref="modal"
                :title="newEntry 
                    ? `Novo ${modelName}`
                    : `${entry.nome}`"
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
                        v-for='(field, index) in model.fields'
                        :key='index'
                        :id='`${modelName}-group-${index}`'
                        :label='field.label'
                        :label-for='field.name'
                        :state='field.stateFunction'
                        :invalid-feedback='field.invalidStateFeedback'
                    >   
                        <!-- if select -->
                        <b-form-select
                            v-if='field.type === "select"'
                            :id='field.name'
                            :name='field.name'
                            v-model='model.data[field.name]'
                            :options="field.options"
                            :value-field='field.select_value_field'
                            :text-field='field.select_text_field'
                            :select-size='6'
                            :state='field.stateFunction'
                        ></b-form-select>
                        <!-- else -->
                        <b-form-input
                            v-else
                            :id='field.name'
                            :name='field.name'
                            v-model='model.data[field.name]'
                            :type='field.type || "text"'
                            :placeholder='field.placeholder || ""'
                            :state='field.stateFunction'
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
import { mapGetters } from 'vuex'
export default {
    name: 'ModelForm',
    props: {
        newEntry: {
            type: Boolean,
            require: true,
        },
        modelName: { // Define o model
            type: String,
            require: true,
        },
        postRoute: {
            type: String,
            require: true,
            default: function () {
                return `post${this.modelName[0].toUpperCase()}` 
                    + `${this.modelName.slice(1)}`
            },
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
        entry: Object,
    },
    data() {
        return {
            model: null, // Corresponde ao prop modelName
            categoria: {
                data: {
                    nome: this.entry.nome,
                },
                fields: [
                    {
                        name: 'nome',
                        label: 'Escolha o nome da categoria',
                        stateFunction: null,
                    },
                ]
            },
            item: {
                data: {
                    categoria: this.entry.categoria,
                    text: this.entry.text,
                },
                fields: [
                    { // Não trocar ordem deste field!!
                        name: 'categoria',
                        label: 'Escolha a categoria',
                        type: 'select',
                        select_value_field: 'id',
                        select_text_field: 'nome',
                        stateFunction: null,
                        options: [],
                    },
                    {
                        name: 'text',
                        label: 'Escolha o nome do texto',
                        stateFunction: null,
                    },
                ]
            }
        }
    },
    created() {
        this.model = this[this.modelName];
        this.model.data.id = this.entry.id || null; // Utilizado no patch
        this.fetchOptions();
    },
    computed: {
        ...mapGetters(['getCategorias']),
        modalName() {
            return this.newEntry
                    ? `new${this.modelName}` 
                    : `edit${this.modelName}-${this.entry.id}`
        },
        invalidForm() {
            return true
        },
        invalidFormFeedback() {
            return ''
        },
    },
    methods: {
        async fetchOptions() { // Get options for select
            if (this.modelName === 'item') {
                this.$store.dispatch('fetchCategorias')
                .then(() => {
                        this[this.modelName].fields[0].options = this.getCategorias;
                        this.$store.commit('setLoading', false);
                    })
            }
        },
        checkFormValidity() {
            return this.invalidForm
        },
        resetModal() {
            if (this.newEntry) {
                this.model.fields.forEach((field) => {
                    this.model.data[field.name] = field.default || null
                });
            } else {
                this.model.fields.forEach((field) => {
                    this.model.data[field.name] = this.entry[field.name];
                });
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
                await this.postForm();
            } else {
                await this.patchForm();
            }
            
            // Hide the modal manually
            this.$nextTick(() => {
                this.$bvModal.hide(this.modalName);
            })
        },
        async postForm() {
            await this.$store.dispatch(this.postRoute, this.model.data);
            this.$store.dispatch(this.fetchRoute);
        },
        async patchForm() {
            await this.$store.dispatch(this.patchRoute, this.model.data);
            this.$store.dispatch(this.fetchRoute);
        }
    }
  }
</script>

<style scoped>
</style>