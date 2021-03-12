<template>
<div>
<b-container class='baseOuterCon1'>
    <h3 class='text-primary'>Itens</h3>
    <b-table
        head-variant='light'
        :busy="$store.getters.isLoading"
        fixed
        striped
        small
        :borderless='false'
        :outlined='true'
        :items="itemBases"
        :fields='fields'
    >
        <template #table-busy>
            <div class="text-center text-primary my-2">
            <b-spinner class="align-middle"></b-spinner>
            <strong> Carregando...</strong>
            </div>
        </template>
    </b-table>
    <b-row>
        <b-col sm='6' md='3' lg='3' class='mt-1'>
            <ModelForm
                :newEntry='true'
                :entry='{text: ""}'
                modelName='item'
            />
        </b-col>
        <b-col sm='6' md='3' lg='3' class='mt-1'>
            <b-form-checkbox
                id="checkbox-1"
                v-model="filter_options.is_active.in_use"
                name="checkbox-1"
                @change='fetchItemBases()'
                >
                Esconder inativos
            </b-form-checkbox>
        </b-col>
    </b-row>
</b-container>
</div>
</template>

<script>
import { mapState } from 'vuex'
import ModelForm from './ModelForm'

export default {
  name: "ItemBase",
  components: {ModelForm},
  data() {
    return {
        filter_options: {
            is_active: {
                in_use: true,
                value: true,
            }
        },
        fields: [
            {
                key: 'index',
                label: '',
            },
            {
                key: 'nome',
                label: 'Nome',
                sortable: true,
            },
            {
                key: 'show_details',
                label: ''
            },
        ],
        selected: [],
    };
  },
  computed: {
      ...mapState(['itemBases']),
  },
};
</script>

<style scoped>
@media (min-width: 768px) {
}
@media (min-width: 992px) {
}
@media (min-width: 1200px) {
}
.actionCell {
    display: flex;
    flex-direction: row-reverse;
}
</style>