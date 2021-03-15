<template>
  <div>
    <b-container class="baseOuterCon1">
      <h3 class="text-primary">{{ modelName + 's' }}</h3>
      <b-table
        head-variant="light"
        :busy="$store.getters.isLoading"
        fixed
        striped
        small
        :borderless="false"
        :outlined="true"
        :items="itemList"
        :fields="model.fields"
        :tbody-tr-class='tr_class'
      >
        <template #table-busy>
          <div class="text-center text-primary my-2">
            <b-spinner class="align-middle"></b-spinner>
            <strong> Carregando...</strong>
          </div>
        </template>

        <!-- Categoria, ItemBase -->
        <template #cell(id_arb)="data">
          <div
            class="ml-2 mt-1"
          >
            <Ordem
              :id="data.item.id"
              :index="data.value"
              :modelName='modelName'
              :listLength="itemList.length"
            />
          </div>
        </template>

        <template #cell(show_details)="row">
          <div class="actionCell">
            <b-button size="sm" @click="row.toggleDetails" class="mr-2">
              <b-icon-info-circle v-show="!row.detailsShowing" />
              <b-icon-x-circle-fill v-show="row.detailsShowing" />
            </b-button>
          </div>
        </template>

        <!-- Detalhes -->
        <template #row-details="row">
          <b-card>
            <b-row class="mb-2">
              <b-col sm="2" class="text-sm-right"><b>Ativo:</b></b-col>
              <b-col>{{ row.item.is_active ? "Ativo" : "Inativo" }}</b-col>
            </b-row>
            <b-row>
              <ModelActiveButton 
                :entry="row.item"
                :modelName='modelName'
              />
              <ModelDeleteButton
                :entry="row.item"
                :modelName='modelName'
              />
              <ModelForm
                :newEntry="false"
                :entry="row.item"
                :modelName='modelName'
              />
            </b-row>
          </b-card>
        </template>
      </b-table>
      <b-row>
        <b-col sm="6" md="3" lg="3" class="mt-1">
          <ModelForm
            :newEntry="true"
            :entry="{}"
            :modelName='modelName'
          />
        </b-col>
        <b-col sm="6" md="3" lg="3" class="mt-1">
          <b-form-checkbox
            :id='`is_active-checkbox-${modelName}`'
            v-model="filter_options.is_active.in_use"
            :name='`is_active-checkbox-${modelName}`'
            @change="fetchList()"
          >
            Esconder inativos
          </b-form-checkbox>
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
import Ordem from "./Ordem";
import ModelForm from "./ModelForm";
import ModelActiveButton from "./ModelActiveButton";
import ModelDeleteButton from "./ModelDeleteButton";

export default {
  name: "ModelList",
  components: { Ordem, ModelForm, ModelActiveButton, ModelDeleteButton },
  props: {
    modelName: {
      type: String,
      required: true,
    },
    fetchRoute: {
      type: String,
      require: true,
      default: function () {
        return (
          `fetch${this.modelName[0].toUpperCase()}` +
          `${this.modelName.slice(1)}s`
        );
      },
    },
  },
  computed: {
    itemList: function () {
      return this.$store.state[this.modelName + 's']
    },
  },
  data() {
    return {
      filter_options: {
        is_active: {
          in_use: true,
          value: true,
        },
      },
      model: null, // Corresponde ao prop modelName
      categoria: {
        fields: [
          {
              key: 'id_arb',
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
      },
      itemBase: {
        fields: [
          {
            key: "categoria.nome",
            label: "Categoria",
          },
          {
            key: "index",
            label: "",
          },
          {
            key: "text",
            label: "Descrição",
          },
          {
            key: "show_details",
            label: "",
          },
        ],
      },
    };
  },
  beforeCreate() {
    this.$store.commit("setLoading", true);
  },
  async created() {
    this.model = this[this.modelName];
    // Observar as DUAS declarações async em 'created()' e na função anônima,
    // de forma que se evite um stack overflow.
    this.fetchList();
  },
  methods: {
    fetchList() {
      this.$store.dispatch(this.fetchRoute, this.filter_options).then(() => {
        this.$store.commit("setLoading", false);
      });
    },
    /* Row Style */
    tr_class(item, type) {
      if (item && type === 'row') {
        if (!item.is_active) {
          return [
            'font-italic',
            'text-muted',
          ]
        } else {
          return null
        }
      } else {
        return null
      }
    }
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