<template>
  <div>
    <b-container class="baseOuterCon1">
      <h3 class="text-primary">{{ model.title }}</h3>
      <b-table
        head-variant="light"
        :busy="$store.getters.isLoading"
        small
        :borderless="false"
        :outlined="true"
        :items="itemList"
        :fields="model.fields"
        :tbody-tr-class='tr_class'
        thead-class="hidden_header"
      >
        <template #table-busy>
          <div class="text-center text-primary my-2">
            <b-spinner class="align-middle"></b-spinner>
            <strong> Carregando...</strong>
          </div>
        </template>

        <!-- Group by -->
        <template #cell(group_by)="data">
          <div
            v-if='data.item.group_by !== undefined'
          >
            {{ data.item.group_by.text }}
          </div>
        </template>

        <!-- Categoria, ItemBase -->
        <template #cell(id_arb)="data">
          <div
            class="ml-2 mt-1"
            v-if='data.item.group_by === undefined'
          >
            <Ordem
              :entry='data.item'
              :modelName='modelName'
            />
          </div>
        </template>

        <!-- Detalhes -->
        <template #cell(show_details)="row">
          <div class="actionCell" v-if='row.item.group_by === undefined'>
            <b-button size="sm" @click="row.toggleDetails" class="mr-2">
              <b-icon-info-circle v-show="!row.detailsShowing" />
              <b-icon-x-circle-fill v-show="row.detailsShowing" />
            </b-button>
          </div>
        </template>

        <template #row-details="row">
          <b-card v-if='row.item.group_by === undefined'>
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

      <!-- Action bar -->
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
        title: 'Categorias',
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
        title: 'Itens',
        group_by: {
          field: 'categoria.id',
          display_field: 'categoria.nome',
        },
        fields: [
          {
              key: 'id_arb',
              label: '',
          },
          {
              key: 'group_by',
              label: '',
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
  computed: {
    itemList: function () {
      let _itemList = this.$store.state[this.modelName + 's'].slice()

      if (this.model.group_by !== undefined) { // Group_by
        let _itemListFinal = [];
        let group_by_buffer; /* Valor a ser comparado entre as iterações para
        não repetir o header do agrupamento  */
        for (let i = 0; i < _itemList.length; i++) {
          let iteration_field_value = this.object_lookup_byString( 
            _itemList[i], 
            this.model.group_by.field);
          if (iteration_field_value !== group_by_buffer) { // Caso seja um novo grupo
            /* Preparar o obj do grupo */
            let group_by = Object.assign({}, this.model.group_by);
            /* Texto para vizualização */
            group_by.text = this.model.group_by.display_field !== undefined
            ? this.object_lookup_byString(_itemList[i], this.model.group_by.display_field)
            : iteration_field_value;
            _itemListFinal.push(
              {
                group_by: group_by,
                categoria: {},
              }
            );           
            group_by_buffer = iteration_field_value;
          }
          _itemListFinal.push(_itemList[i]);
        }
        return _itemListFinal
      }
      return _itemList
    },
  },
  methods: {
    object_lookup_byString: function (o, s) {
      /* Retorna o valor de uma propiedade através de uma string com as pro-
      piedades separadas por ponto("."). 
        Ex.: 'propriedade1.propriedade1_2[.[...]]'
      */
      s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
      s = s.replace(/^\./, '');           // strip a leading dot
      var a = s.split('.');
      for (var i = 0, n = a.length; i < n; ++i) {
          var k = a[i];
          if (k in o) {
              o = o[k];
          } else {
              return;
          }
      }
      return o;
    },
    fetchList() {
      this.$store.dispatch(this.fetchRoute, this.filter_options).then(() => {
        this.$store.commit("setLoading", false);
      });
    },
    /* Row Style */
    tr_class(item, type) {
      if (item && type === 'row') {
        let classList = [];
        if (item.group_by !== undefined) {
          return [
            'table-success',
            'text-muted'
          ]
        }
        if (!item.is_active) {
          classList = classList.concat([
            'font-italic',
            'text-muted',
          ]);
        }
        return classList;
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
<style>
.hidden_header {
  display: none;
}
</style>