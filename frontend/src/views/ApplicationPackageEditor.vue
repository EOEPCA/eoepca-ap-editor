<template>
  <b-container fluid class="my-2 px-4">
    <b-modal
      @hide="closeCltPaster"
      ref="clt-paste-modal"
      title="Paste Command Line Tool Definition"
      align-h="end"
      hide-footer
      size="lg"
    >
    <command-line-tool-paster
      ref="clt-paste-modal-comp"
      @onClose="closeCltPaster"
    />
    </b-modal>
    <b-modal
      @hide="closeValidationReport"
      ref="validation-report-modal"
      title="Validation Report"
      align-h="end"
      hide-footer
      size="lg"
    >
    <validation-report
      @onClose="closeValidationReport"
    />
    </b-modal>
    <b-modal
      @hide="closeApExplorer"
      ref="ws-manager-modal"
      title="Application Packages Manager"
      align-h="end"
      hide-footer
      size="lg"
    >
      <ap-workspace-manager
        @onClose="closeApExplorer"
        @download="downloadFromWs"
        @openAppPackage="loadWsAppPackage"
        @openAppPackageNewTab="openWsAppPackageNewWindow"
      />
    </b-modal>
    <b-modal
      @hide="closeWorkspaceSaver"
      ref="ws-save-modal"
      title="Save in Workspace"
      align-h="end"
      hide-footer
      size="lg"
    >
      <ap-workspace-saver
        :appNameProp="appPackageName"
        :appVersionProp="appPackageVersion"
        @onClose="closeWorkspaceSaver"
        @onSave="workspaceSave"
      />
    </b-modal>
    <b-modal
      ref="download-modal"
      id="download-modal"
      title="Download Application Package"
      align-h="end"
      hide-footer
      size="md"
    >
      <b-form-group label="Application package name">
        <b-form-input v-model="applicationPackageFilename"> </b-form-input>
      </b-form-group>
      <b-btn
        variant="success"
        @click="
          createDownload(
            $refs.processWrapper.$el.innerText,
            applicationPackageFilename
          )
        "
      >
        <fa-icon class="mr-2" icon="download"></fa-icon>
        <span>Download</span>
      </b-btn>
    </b-modal>
    <v-tour
      name="clt-tour"
      :steps="steps"
      :callbacks="guidedTourCallbacks"
      ref="cltTour"
    />
    <page-title
      title="Application Package Editor"
      subtitle="Interactive Earth Observation Application Package Editor"
    >
      <template v-slot:help>
        <div>
          <b-dropdown
            no-caret
            class="mr-3"
            menu-class="help-menu-dropdown"
            id="help-menu"
          >
            <template v-slot:button-content>
              <b-icon
                icon="three-dots-vertical"
                v-b-tooltip.hover.window="'Help Menu'"
                style="height: 1.8rem; width: 1.8rem; color: white"
              />
            </template>
            <b-dropdown-item @click="showConfirmReset">
              <b-icon icon="arrow-counterclockwise" />
              Reset Editor
            </b-dropdown-item>
            <div class="p-2">
              <span style="font-weight: bold; font-size: 14px"
                >Editor Mode</span
              >
              <b-dropdown-item @click="setMode('simple')">
                <b-icon
                  icon="check-circle"
                  variant="success"
                  v-if="mode === 'simple'"
                />
                Simple
              </b-dropdown-item>
              <b-dropdown-item @click="setMode('advanced')">
                <b-icon
                  icon="check-circle"
                  variant="success"
                  v-if="mode === 'advanced'"
                />
                Advanced
              </b-dropdown-item>
            </div>
            <div class="p-2">
              <span style="font-weight: bold; font-size: 14px"
                >Manuals & References</span
              >
              <b-dropdown-item
                @click="
                  openNewTab(
                    'https://eoepca.readthedocs.io/projects/eo-app-package-editor/en/latest/',
                    $event
                  )
                "
              >
                User Manual
              </b-dropdown-item>
              <b-dropdown-item
                @click="
                  openNewTab('https://docs.ogc.org/bp/20-089r1.html', $event)
                "
              >
                OGC BP Earth Observation Application Package
              </b-dropdown-item>
            </div>
            <div class="p-2">
              <span style="font-weight: bold; font-size: 14px"
                >Application Package Examples</span
              >
              <b-dropdown-item
                v-for="(example, index) in examplesList"
                :key="example._key"
                @click="openNewTab(`${locationHref}?example=${index}`, $event)"
              >
                <b-icon
                  v-if="example['info']"
                  icon="info-circle"
                  variant="info"
                  @click="openNewTab(example['info'], $event)"
                  v-b-tooltip.hover.window="
                    'Click to read more about this example.'
                  "
                />
                {{ example["label"] }}
              </b-dropdown-item>
            </div>
            <div class="p-2">
              <span style="font-weight: bold; font-size: 14px"
                >Guided Tours</span
              >
              <b-dropdown-item
                @click="startGuidedTour('applicationPackageMetadata')"
              >
                1. Application Package Information (Metadata)
              </b-dropdown-item>
              <b-dropdown-item
                @click="startGuidedTour('pasteProcessingTaskTour')"
              >
                2. Paste a Command Line Tool Definition (Processing Task)
              </b-dropdown-item>
              <b-dropdown-item
                @click="startGuidedTour('newProcessingTaskTour')"
              >
                3. Creation of a new Command Line Tool (Processing Task)
              </b-dropdown-item>
              <b-dropdown-item
                @click="startGuidedTour('processingTaskWorkflowIntegration')"
              >
                4. Command Line Tool Workflow Integration (Workflow)
              </b-dropdown-item>
            </div>
          </b-dropdown>
        </div>
      </template>
      <template v-slot:toolbar>
        <b-btn-toolbar class="float-right">
          <div class="m-1 pr-3 pl-3">
            <h6 align="center">Helper</h6>
            <b-dropdown split variant="primary" @click="validateCwl('Errors')">
              <!--<fa-icon class="mr-2" icon="sync-alt"></fa-icon>-->
              <template slot="button-content">
                <fa-icon class="mr-2" icon="sync-alt"></fa-icon>
                <span>Validate</span>
              </template>
              <b-dropdown-item @click="validateCwl('ErrorsAndHints')">Include hints</b-dropdown-item>
              <b-dropdown-item @click="validateCwl('ErrorsHintsAndNotes')">Include hints and notes</b-dropdown-item>
            </b-dropdown>
          </div>
          <div class="m-1 pr-3 pl-3">
            <h6 align="center">Workspace</h6>
            <b-btn variant="primary" @click="showApExplorer" class="mr-2">
              <fa-icon class="mr-2" icon="folder-open" />
              <span>Manage</span>
            </b-btn>
            <b-btn variant="success" @click="showWorkspaceSaver">
              <fa-icon class="mr-2" icon="save" />
              <span>Save</span>
            </b-btn>
          </div>
          <div class="m-1 pr-3 pl-3">
            <h6 align="center">Local Transfer</h6>
            <input
              ref="file"
              type="file"
              accept=".cwl"
              @change="onFileUpload"
              hidden
            />
            <b-btn variant="primary" @click="uploadFile()" class="mr-2">
              <fa-icon class="mr-2" icon="upload"></fa-icon>
              <span>Upload</span>
            </b-btn>
            <b-btn variant="success" @click="showDownloadModal()">
              <fa-icon class="mr-2" icon="download"></fa-icon>
              <span>Download</span>
            </b-btn>
          </div>
        </b-btn-toolbar>
      </template>
    </page-title>
    <b-row>
      <b-col lg="12" xl="7">
        <b-tabs content-class="mt-2" fill v-model="currentTab">
          <b-tab :active="currentTab === 0">
            <template v-slot:title>
              <span id="meta-tab-title">Metadata</span>&nbsp;
              <b-icon
                v-b-tooltip.hover.window="'Metadata Best Practice'"
                icon="info-circle"
                variant="info"
                @click="
                  openNewTab(
                    'https://docs.ogc.org/bp/20-089r1.html#toc31',
                    $event
                  )
                "
              />
            </template>
            <b-card header="Metadata" class="editor-card">
              <metadata-editor />
            </b-card>
          </b-tab>
          <b-tab :active="currentTab === 1">
            <template slot="title">
              <span id="clt-tab-title">Command Line Tool</span>&nbsp;
              <b-icon
                v-b-tooltip.hover.window="'Command Line Tool Best Practice'"
                icon="info-circle"
                variant="info"
                @click="
                  openNewTab(
                    'https://docs.ogc.org/bp/20-089r1.html#toc27',
                    $event
                  )
                "
              />
            </template>
            <b-row class="m-2">
              <b-col align="center">
                <b-btn
                  id="clt-add-btn"
                  class="add-btn"
                  variant="primary"
                  ref="addCltButton"
                  @click="pushNewClt"
                  size="sm"
                >
                  <fa-icon icon="plus"></fa-icon>
                  <span class="ml-2">Add Command Line Tool</span>
                </b-btn>
                <b-btn
                  id="clt-paste-btn"
                  class="ml-2 add-btn"
                  variant="primary"
                  ref="pasteCltButton"
                  @click="showCltPaster"
                  size="sm"
                >
                  <fa-icon icon="plus"></fa-icon>
                  <span class="ml-2">Paste Command Line Tool</span>
                </b-btn>
              </b-col>
            </b-row>
            <div class="clt-list accordion">
              <b-card
                v-for="(clt, index) in commandLineTools"
                :key="clt._key"
                class="mr-1"
              >
                <template v-slot:header>
                  <div
                    v-b-toggle="`clt-accordion-${index}`"
                    style="height: 44px; padding: 10px"
                  >
                    {{
                      clt.id
                        ? `Command Line Tool: ${clt.id}`
                        : "Command Line Tool"
                    }}
                    <b-btn
                      class="float-right"
                      variant="danger"
                      size="sm"
                      @click.stop="removeClt(clt)"
                    >
                      <fa-icon icon="times" />
                    </b-btn>
                  </div>
                </template>
                <b-collapse
                  :id="`clt-accordion-${index}`"
                  accordion="clts-accordion"
                  visible
                >
                  <command-line-tool-editor
                    :command-line-tool-prop="clt"
                    :pos="index"
                  />
                </b-collapse>
              </b-card>
            </div>
          </b-tab>
          <b-tab :active="currentTab === 2">
            <template v-slot:title>
              <span id="wfl-tab-title">Workflow</span>&nbsp;
              <b-icon
                v-b-tooltip.hover.window="'Workflow Best Practice'"
                icon="info-circle"
                variant="info"
                @click="
                  openNewTab(
                    'https://docs.ogc.org/bp/20-089r1.html#toc28',
                    $event
                  )
                "
              />
            </template>
            <b-card
              :header="workflow.id ? `Workflow: ${workflow.id}` : 'Workflow'"
              class="editor-card"
            >
              <workflow-editor />
            </b-card>
          </b-tab>
        </b-tabs>
      </b-col>
      <b-col lg="12" xl="5">
        <b-card class="cwl-template">
          <template v-slot:header>
            <b-row>
              <b-col sm="7" style="display: flex; align-items: center">
                Name:&nbsp;<strong>{{ appPackageName }}</strong>
              </b-col>
              <b-col sm="5" style="display: flex; align-items: center">
                Version:&nbsp;<strong>{{ appPackageVersion }}</strong>
              </b-col>
            </b-row>
          </template>
          <ApplicationPackageCwlTemplate
            :cwlObject="cleanedCwl"
            ref="processWrapper"
          />
        </b-card>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import ApplicationPackageCwlTemplate from "../components/Template/ApplicationPackageCwlTemplate";
import PageTitle from "../components/Shared/PageTitle";
import "vue-slider-component/theme/antd.css";
import { saveAs } from "file-saver";
import yaml from "js-yaml";
import { cwlValidator } from "../cwlObjectValidator";
import MetadataEditor from "../components/metadata/MetadataEditor";
import WorkflowEditor from "../components/Workflow/WorkflowEditor";
import CommandLineToolEditor from "../components/CommandLinetool/CommandLineToolEditor";
import CommandLineToolPaster from "../components/CommandLinetool/CommandLineToolPasterForm";
import ApWorkspaceManager from "../components/Workspace/ApWorkspaceManager";
import ApWorkspaceSaver from "../components/Workspace/ApWorkspaceSaver";
import ValidationReport from "../components/ValidationReport";
import {
  getURLParam,
  parseCwlObject,
  removeEmpty,
  showApiErrorAsNotification,
  showNotification,
  validateCwlConsistency,
} from "../utils";
import { mapGetters } from "vuex";
import {
  ADD_COMMAND_LINE_TOOL,
  CHANGE_APP_PACKAGE_NAME,
  CHANGE_APP_PACKAGE_VERSION,
  CHANGE_VALIDATION_RESPONSE,
  REMOVE_COMMAND_LINE_TOOL,
  RESET_EDITOR,
  SET_CWL_OBJECT,
  SET_MODE,
} from "../store/action-types";
import { BIcon } from "bootstrap-vue";
import { guidedTours, guidedToursCallbacks } from "../guidedTour";
import examples from "../data/examples.json";
import {
  validateCwlOnBackend,
  createUpdateApplicationPackageVersion,
  getApplicationPackageVersion,
} from "../api";

export default {
  name: "ApplicationPackageEditor",
  components: {
    ApWorkspaceSaver,
    ApWorkspaceManager,
    ValidationReport,
    BIcon,
    MetadataEditor,
    WorkflowEditor,
    CommandLineToolEditor,
    ApplicationPackageCwlTemplate,
    PageTitle,
    CommandLineToolPaster,
  },
  data() {
    return {
      guidedTourRunning: false,
      selectedGuidedTour: "newProcessingTaskTour",
      modalIdentifier: "Workflow Input",
      selectedInput: undefined,
      idx: undefined,
      currentTab: 0,
      applicationPackageFilename: undefined,
    };
  },
  mounted() {
    const exampleIndex = getURLParam("example", undefined);
    const apName = getURLParam("apName", undefined);
    const apVersion = getURLParam("apVersion", undefined);
    if (exampleIndex && exampleIndex < this.examplesList.length) {
      this.setCwlExample(
        this.examplesList[exampleIndex]["name"],
        this.examplesList[exampleIndex]["url"]
      );
    } else if (apName && apVersion) {
      this.loadWsAppPackage(apName, apVersion);
    }
  },
  methods: {
    removeClt(clt) {
      this.$store.dispatch(REMOVE_COMMAND_LINE_TOOL, clt);
    },
    pushNewClt() {
      this.$store.dispatch(ADD_COMMAND_LINE_TOOL);
    },
    uploadFile() {
      this.$refs.file.click();
    },
    yamlToObject(yamlContent) {
      let yamlObj = undefined;
      try {
        yamlObj = yaml.load(yamlContent);
      } catch (error) {
        showNotification("YAML Validator", {
          type: "error",
          text: error.message,
          duration: 5000,
          group: "global",
        });
        return undefined;
      }
      return yamlObj;
    },
    onFileUpload(event) {
      if (event.target.files.length) {
        const file = event.target.files[0];
        const reader = new FileReader();
        const appName = file.name.replace(".cwl", "").replace(".CWL", "");
        reader.onload = () => this.loadCwlFile(reader.result, appName);
        reader.onerror = () =>
          showNotification("File Error", {
            type: "error",
            text: reader.error,
            duration: 5000,
            group: "global",
          });
        reader.readAsText(file);
      }
      this.$refs.file.value = ""; // Clear the file to allow change detection when same file is re-uploaded
    },
    downloadWrapper(data, appName, appVersion) {
      this.createDownload(data, `${appName}__${appVersion}.cwl`);
    },
    createDownload(data, filename) {
      let mimetype = "text/yaml";
      let blob = new Blob([data], { type: mimetype + ";charset=utf-8" });
      saveAs(blob, filename);
    },
    handleAppPackageNameChange(value) {
      this.$store.dispatch(CHANGE_APP_PACKAGE_NAME, value);
    },
    validateCwl(validationType) {
      const issues = validateCwlConsistency(this.nsPrefix, this.cwlObject);
      if (issues.length) {
        showNotification("CWL Validation issues", {
          group: "info",
          type: "error",
          text: issues,
          duration: -1,
        });
      } else {
        let payload = { cwl: this.$refs.processWrapper.$el.innerText };
        switch(validationType){
          case 'Errors':
            payload = { cwl: this.$refs.processWrapper.$el.innerText , level: "error" };
            break;
          case 'ErrorsAndHints':
            payload = { cwl: this.$refs.processWrapper.$el.innerText , level: "hint" };
            break;
          case 'ErrorsHintsAndNotes':
            payload = { cwl: this.$refs.processWrapper.$el.innerText , level: "note" };
            break;
        }

        validateCwlOnBackend(payload).then((validationResponse) => {
          validationResponse.issues?.sort((a, b) => a.type.localeCompare(b.type));
          this.$store.dispatch(CHANGE_VALIDATION_RESPONSE, validationResponse);
          if(validationResponse.issues.length == 0){
            if(validationType == 'Errors'){
              showNotification("Your Application Package CWL is valid", {
                group: "info",
                type: "success",
              });
            } else {
              showNotification("Your Application Package CWL is valid and all hints are met", {
                group: "info",
                type: "success",
              });
            }
          } else {
            this.showValidationReport();
          }
        }
        ).catch(showApiErrorAsNotification);
      }
    },
    startGuidedTour(tourName) {
      this.guidedTourRunning = true;
      this.selectedGuidedTour = tourName;
      this.$tours["clt-tour"].start();
    },
    openNewTab(href, event = undefined) {
      if (event) event.stopPropagation();
      window.open(href, "_blank");
    },
    setMode(mode) {
      this.$store.dispatch(SET_MODE, mode);
    },
    resetEditor() {
      this.$store.dispatch(RESET_EDITOR);
    },
    showConfirmReset() {
      this.$bvModal
        .msgBoxConfirm("All entered values will be lost, are you sure?")
        .then((value) => {
          if (value) this.resetEditor();
        });
    },
    setCwlExample(filename, url) {
      fetch(url)
        .then((r) => r.text())
        .then((fileContent) => this.loadCwlFile(fileContent, filename));
    },
    loadWsAppPackage(apName, apVersion) {
      getApplicationPackageVersion(apName, apVersion)
        .then((res) => this.loadCwlFile(res.cwl, apName, apVersion))
        .catch(showApiErrorAsNotification);
    },
    downloadFromWs(appName, appVersion) {
      getApplicationPackageVersion(appName, appVersion)
        .then((res) => this.downloadWrapper(res.cwl, appName, appVersion))
        .catch(showApiErrorAsNotification);
    },
    openWsAppPackageNewWindow(apName, apVersion) {
      this.openNewTab(
        `${this.locationHref}/?apName=${apName}&apVersion=${apVersion}`
      );
    },
    closeCltPaster() {
      this.$refs["clt-paste-modal"].hide();
    },
    closeApExplorer() {
      this.$refs["ws-manager-modal"].hide();
    },
    closeWorkspaceSaver() {
      this.$refs["ws-save-modal"].hide();
    },
    showCltPaster() {
      this.$refs["clt-paste-modal"].show();
    },
    showApExplorer() {
      this.$refs["ws-manager-modal"].show();
    },
    showWorkspaceSaver() {
      this.$refs["ws-save-modal"].show();
    },
    closeValidationReport() {
      this.$refs["validation-report-modal"].hide();
    },
    showValidationReport() {
      this.$refs["validation-report-modal"].show();
    },
    showDownloadModal() {
      this.applicationPackageFilename = this.applicationPackageFilename
        ? this.applicationPackageFilename
        : `${this.appPackageName}__${this.appPackageVersion}.cwl`;
      this.$refs["download-modal"].show();
    },
    loadCwlFile(fileContent, appName, appVersion = "version_1") {
      const yamlObject = this.yamlToObject(fileContent);
      cwlValidator
        .validate(yamlObject, { strict: true })
        .then((validatedCwlObject) => {
          this.$store.dispatch(
            SET_CWL_OBJECT,
            parseCwlObject(validatedCwlObject)
          ).then(() => { this.validateCwl('Errors'); });
          this.$store.dispatch(CHANGE_APP_PACKAGE_NAME, appName);
          this.$store.dispatch(CHANGE_APP_PACKAGE_VERSION, appVersion);
        })
        .catch((error) => {
          showNotification("CWL Validator", {
            type: "error",
            text: error.message,
            duration: 5000,
            group: "global",
          });
          this.$store.dispatch(SET_CWL_OBJECT, parseCwlObject(yamlObject))
            .then(() => { this.validateCwl('Errors'); });
          this.$store.dispatch(CHANGE_APP_PACKAGE_NAME, appName);
          this.$store.dispatch(CHANGE_APP_PACKAGE_VERSION, appVersion);
        });
    },
    workspaceSave(appName, appVersion) {
      const payload = { cwl: this.$refs.processWrapper.$el.innerText };
      createUpdateApplicationPackageVersion(appName, appVersion, payload)
        .then(() => {
          this.$store.dispatch(CHANGE_APP_PACKAGE_NAME, appName);
          this.$store.dispatch(CHANGE_APP_PACKAGE_VERSION, appVersion);
          this.closeWorkspaceSaver();
          showNotification("Saved in Workspace successfully.", {
            group: "info",
            type: "success",
          });
        })
        .catch(showApiErrorAsNotification);
    },
  },
  computed: {
    ...mapGetters({
      cwlObject: "cwlObject",
      commandLineTools: "commandLineTools",
      workflow: "workflow",
      appPackageName: "appPackageName",
      appPackageVersion: "appPackageVersion",
      nsPrefix: "nsPrefix",
      mode: "mode",
    }),
    steps() {
      return guidedTours[this.selectedGuidedTour](this);
    },
    guidedTourCallbacks() {
      return guidedToursCallbacks[this.selectedGuidedTour](this);
    },
    cleanedCwl() {
      return removeEmpty(this.cwlObject);
    },
    idxLastClt() {
      return this.commandLineTools.length - 1;
    },
    examplesList() {
      return examples;
    },
    locationHref() {
      const appPrefix =
        process.env.VUE_APP_ENV === "application_hub"
          ? ""
          : process.env.NODE_ENV === "production" ? "/ap-editor" : "";
      return `${window.location.origin}${appPrefix}`;
    },
  },
};
</script>

<style>
.add-btn {
  text-transform: uppercase;
  font-size: 0.8rem;
  width: fit-content;
}

.editor-card .card-body {
  max-height: 79vh;
  overflow-y: auto;
}

.card-section .title {
  display: flex;
  justify-content: center;
  padding: 4px;
  margin: 20px 0px 0px 0px;
  background-color: #f7f7f7;
  border-bottom: 1px solid rgba(0, 0, 0, 0.125);
}

.center-text {
  display: flex;
  align-items: center;
}

.nav-tabs .nav-link {
  padding: 12px !important;
}

.clt-list {
  height: 80vh;
  overflow-y: auto;
}

.clt-list .card-body {
  padding: 0px;
}

.clt-list .card-header {
  padding: 0px;
}

.cwl-template .card-header {
}

.card-header {
  background-color: #ebebeb !important;
}

.cwl-template .card-body {
  max-height: 85vh;
  overflow-y: auto;
  padding: 12px 12px 0px 12px;
}

.empty-text .alert {
  padding: 0.7rem 0.25rem 0rem 0.25rem;
  margin: 0rem;
}

.v-step__content {
  word-break: break-word;
}

.help-menu-dropdown {
  border-radius: 6px !important;
  box-shadow: 2px 7px 17px 1px rgba(0, 0, 0, 0.6) !important;
}

#help-menu .btn {
  background-color: #333333;
  padding: 0.3rem;
  border-radius: 0.2rem !important;
}

.read-only {
  pointer-events: none;
}
</style>
