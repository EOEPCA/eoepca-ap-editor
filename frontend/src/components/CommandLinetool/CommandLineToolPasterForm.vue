<template>
  <b-form @submit.stop.prevent>
    <div class="form-content" id="clt-paster-form">
      <b-form-group label="Paste here the definition of a CWL Command Line Tool in YAML format:">
        <b-form-textarea v-model="cltCwl" id="clt-paste-textarea" rows="10" max-rows="20"/>
      </b-form-group>
      <b-form-invalid-feedback :state="cltCwlValidator">
        {{ this.cltCwlValidatorFeedback }}
      </b-form-invalid-feedback>
    </div>
    <div class="form-control-btn">
      <b-btn variant="primary" id="clt-paste-add-btn" :disabled="!cltCwlValidator" @click="handleSubmit" size="sm">
        <fa-icon class="mr-2" icon="plus"/>
        <span>Add</span>
      </b-btn>
      <b-btn @click="handleCancel" size="sm" id="clt-paste-cancel-btn">
        <fa-icon class="mr-2" icon="times"/>
        <span>Cancel</span>
      </b-btn>
    </div>
  </b-form>
</template>

<script>
import yaml from "js-yaml";
import {
  showNotification,
} from "../../utils";
import {
  PASTE_COMMAND_LINE_TOOL,
} from "../../store/action-types";

export default {
  name: "CommandLineToolPasterForm",
  data() {
    return {
      cltCwl: "",
    };
  },
  methods: {
    handleSubmit() {
      let cltObject = yaml.load(this.cltCwl);
      let cltDefaults = {
        // id: undefined,
        // class: "CommandLineTool",
        baseCommand: [],
        arguments: [],
        label: undefined,
        doc: undefined,
        inputs: [],
        outputs: [],
        requirements: {},
      };
      let data = { ...cltDefaults, ...cltObject };
      this.$store.dispatch(PASTE_COMMAND_LINE_TOOL, data);
      this.cltCwl = "";
      this.$emit("onClose");
    },
    handleCancel() {
      this.cltCwl = "";
      this.$emit("onClose");
    },
  },
  computed: {
    cltCwlValidator() {
      if (this.cltCwl?.length == 0) {
        return false;
      }
      return this.cltCwlValidatorFeedback == "OK";
    },
    cltCwlValidatorFeedback() {
      if (this.cltCwl?.length == 0) {
        return "Please enter a Command Line Tool definition";
      }
      try {
        let data = yaml.load(this.cltCwl);
        if (data === undefined || data == null) {
          return "Please enter a Command Line Tool definition";
        }
        if (data["class"] === undefined || data["class"] != "CommandLineTool") {
          return "The object class must be \"CommandLineTool\"";
        }
        if (data["id"] === undefined || data["id"] == null || data["id"].length == 0) {
          return "The identifier may not be empty";
        }
      } catch (error) {
        return "The CWL is not valid: " + error.message;
      }
      return "OK";
    },
  }
};
</script>

<style scoped>
.composite-input {
  margin-left: 20px;
}

.form-content {
  padding-left: 16px;
  padding-right: 16px;
  max-height: 75vh;
  overflow: auto;
}

.form-control-btn {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.form-control-btn .btn {
  margin-left: 6px;
  margin-right: 6px;
}
</style>
