# EOEPCA Application Package Editor

EOEPCA Application Package Editor is an interactive editor for the Common Workflow Language that allow users to easily 
build an Application Package following the 
[OGC Best Practice for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html).

The editor uses FastAPI for the Backend to manage user workspace and application package version and VueJS for the Frontend.

The documentation can be found [here](https://eoepca.github.io/eoepca-ap-editor/current/).

## Development Environment

### Frontend

From the `frontend` folder, run:
1. Project setup: `yarn install`
2. Compiles and hot-reloads for development: `yarn serve`

### Backend

From the `backend` folder:

#### Prerequisites

1. Create a virtual environment: `python3 -m venv venv`
2. Install FastAPI and dependencies`pip install -r requirements.txt`

#### Running the dev server

```shell
uvicorn main:app --reload
```

## Docker & Kubernetes Environments

From the root folder of this project:

### Docker Environment

Build a docker image of the Application Package Editor and run it as a container:

```shell
docker build -t eo-application-package-editor .
docker run -it -p 8080:80 -p 8000:8000 --rm --name ap-editor eo-application-package-editor
```

### Kubernetes Environment

1. Build, Tag and Push the docker image version to Space Application Nexus Repository where `<version>` 
   should follow this format `[Build Date][a-z]`. The `[a-z]` is a one alphabetical character that allow to differentiate 
   between version build the same day. Example: `2023-05-22a`.

    ```shell
    docker build -t eo-application-package-editor .
    docker tag eo-application-package-editor nexus.spaceapplications.com/repository/docker-eoepca/ap-editor:<version>
    docker login nexus.spaceapplications.com
    docker push nexus.spaceapplications.com/repository/docker-eoepca/ap-editor:<version>
    ```

2. Deploy in a kubernetes cluster (from `helm` folder).
    ```shell
    helm upgrade --kubeconfig kubeconfig --install ap-editor eo-application-package-editor/ --values values/<environment>/values.yaml
    ```

## EOEPCA Application Hub Environment

Follow these instructions to create a version of the Application Package Editor
that may be started on-demand using the EOEPCA
[Application Hub](https://deployment-guide.docs.eoepca.org/v1.4/eoepca/application-hub/).

1. Build, Tag and Push a docker image suitable for deployment in the EOEPCA
   Application Hub.
   A specific Dockerfile is available for that purpose: `Dockerfile_apphub`.

   Substitute these values in the following commands:

   - `DOCKER_REPO` = name and path of the Docker repository where the image must be pushed
   - `IMAGE_NAME` = Docker image name
   - `IMAGE_TAG` = Docker image tag

    From the root folder of this project:

    ```shell
    docker build -f Dockerfile_apphub -t <DOCKER_REPO>/<IMAGE_NAME>:<IMAGE_TAG> .
    docker push <DOCKER_REPO>/<IMAGE_NAME>:<IMAGE_TAG>
    ```

2. Add the Application Package Editor profile in the Application Hub configuration.
   See other examples in [`config.yaml`](https://github.com/EOEPCA/helm-charts/blob/main/charts/application-hub/files/hub/config.yml).

    ```yaml
      - id: profile_ap_editor
        groups:
        - group-1
        definition:
          display_name: Application Package Editor
          slug: eoepca_ap_editor
          default: False
          kubespawner_override:
            cpu_limit: 1
            mem_limit: 4G
            image: <DOCKER_REPO>/<IMAGE_NAME>:<IMAGE_TAG>
        node_selector:
          {{ .Values.nodeSelector.key }}: {{ .Values.nodeSelector.value }}
        volumes:
          - name: volume-workspace
            claim_name: claim-workspace
            size: 1Gi
            storage_class: "{{ .Values.jupyterhub.hub.extraEnv.STORAGE_CLASS }}"
            access_modes:
              - "ReadWriteOnce"
            volume_mount:
              name: volume-workspace
              mount_path: "/workspace"
            persist: true
    ```

    Indicate in the application profile the list of user groups who may see and run
    the application (members of `group-1`, in this example).

    The `STORAGE_CLASS` and node selector (`key` and `value`) are substituted when deployed
    using Helm but may be directly specified in the application profile if necessary.

    The volume created for the user is mounted in the application container and never
    deleted. The Application Packages stored in it are thus persisted across executions.

    If the docker repository is not public, add the encrypted secret in the
    application profile (see [doc](https://eoepca.github.io/application-hub-context/configuration/#image-pull-secrets)):

    ```yaml
        image_pull_secrets:
          - data: "eyJhdXRocyI6eyJ[.....]lObWxOYTNWaFpWbDRNdz09In19fQ=="
            name: "ap-editor-pull-secret"
            persist: false
    ```

    The `data` property must be given the encrypted version of the secret.

The Application Package Editor is listed in the available applications (Server Options)
when authenticated in the Application Hub as a member of one of the authorised user groups.

Spawning the application for the first time takes more time as the Docker image must be
pulled from the repository. Subsequent executions take less time.

## Documentation

See the [documentation page](https://eoepca.github.io/eoepca-ap-editor/current/) for the latest docs.

## Useful links

1. [OGC Best Practice for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html)
2. [CWL Workflow](https://www.commonwl.org/v1.0/Workflow.html)
3. [CWL CommandLineTool](https://www.commonwl.org/v1.0/CommandLineTool.html)
4. [Application Hub Deployment](https://deployment-guide.docs.eoepca.org/v1.4/eoepca/application-hub)
5. [Application Hub Configuration](https://eoepca.github.io/application-hub-context/configuration/)