<template>
  <div>
    <div v-if="noErrorsInIssuesList()">Your Application Package CWL is valid</div>
    <br/>
    <b-table :fields="issuesTableFields" :items="validationResponseIssues()" small show-empty>
      <template #cell(message)="data">
        <span v-html="toHtml(data.value)"></span>
      </template>
    </b-table>
    <br/>
    <b-list-group>
      <b-list-group-item v-for="(reqText, reqId) in validationResponse.requirements" :key="reqId"> 
        <b-row>
          <b-col sm="1"><b-badge>{{ reqId }}</b-badge></b-col>
          <b-col sm="11" class="text-break">{{ reqText }}</b-col>
        </b-row>
      </b-list-group-item>
    </b-list-group>
    <br/>
<!--    <div class="form-control-btn">
      <b-btn size="sm" id="clt-input-modal-cancel-btn" @click="handleClose">
        <span>Close</span>
      </b-btn>
    </div>
    <br/>-->
  </div>
</template>

<script>

import {mapGetters} from "vuex";

export default {
  name: "ValidationReport",
  mounted() {
  },
  data() {
    return {
      issuesTableFields: [
        {key: 'type', label: 'Type', thStyle: {width: "10%"}},
        {key: 'message', label: 'Message', thStyle: {width: "80%"}},
        {key: 'req', label: 'Req', thStyle: {width: "10%"}},
      ],
    };
  },
  methods: {
    handleClose() {
      this.$emit('onClose');
    },
    toHtml(msg) {
      return msg.replaceAll('<', '&lt;').replaceAll('\n', '<br>').replaceAll('  ', '&nbsp;&nbsp;&nbsp;&nbsp;');
    },
    validationResponseIssues(){
      return this.validationResponse.issues;
    },
    noErrorsInIssuesList(){
      const foundError = this.validationResponse.issues.some((e) => e.type == 'error');
      const foundSyntax = this.validationResponse.issues.some((e) => e.type == 'syntax');
      return !(foundError||foundSyntax);
    },

  },
  computed: {
    ...mapGetters({
      validationResponse: 'validationResponse'
    }),
  }
};
</script>

<style scoped>
.form-control-btn {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.form-control-btn .btn {
  margin-left: 6px;
  margin-right: 6px;
}

.list-group {
  overflow-y: auto;
  max-height: 600px;
}

.list-group-item {
  padding-top: 0.3rem;
  padding-bottom: 0.3rem;
}

.app-package-items:hover {
  background-color: #ececec;
}

.app-package-items .item {
  display: flex;
  align-items: center;
}

.sorter:hover {
  cursor: pointer;
}
</style>
