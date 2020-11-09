# CI Integrations GitHub Actions integration.

> Summary of the proposed change

Describe the mechanism of integration of the CI Integrations component to the GitHub Actions to automatically push the build data.

# References

> Link to supporting documentation, GitHub tickets, etc.

- [CI integrations](metrics/ci_integrations/docs/01_ci_integration_module_architecture.md)

# Motivation

> What problem is this project solving?

This document describe the organization and structure of the GitHub Actions used in this repository to automatically integrate the data into the Metrics Web application.

# Goals

> Identify success metrics and measurable goals.

This document aims the following goals: 

- Explain the structure of the GitHub Actions used to push the data to the Metrics Web app.
- Explain the mechanism of adding actions for a new project in this repository.

# Non-Goals

> Identify what's not in scope.

This document does not describes the configuration of building or publishing jobs.

# Design

> Explain and diagram the technical design
>
> Identify risks and edge cases

To be able to track the state of the applications under development, we should configure the GitHub actions that will export the build data to the Metrics Web application. 

To export the data, we should configure the following actions: 

- [`Metrics Integration Actions`](#Metrics-Integration-Actions) - the workflow needed to export the data to the Metrics Web application using the CI Integrations component.
- [`Notify about the building project`](#Notify-about-the-building-project) - the job needed to notify the `Metrics Integration Actions` that some project build was started.

Let's consider each action in more detail.

## Metrics Integration Actions

A `Metrics Integration Actions` is a workflow containing integration jobs for all projects we want to export to the Metrics Web application. This workflow triggers on repository dispatch event with `building_project` type. The `building_project` repository dispatch event, in its turn, should contain the information about which project build started as a `client_payload` JSON. Currently, the `building_project` repository dispatch event can contain the following data: 

- `building_ci_integrations` - a `bool` field of the `client_payload` that indicates whether the `CI Integrations` project is building. 
- `building_coverage_converter` - a `bool` that indicates whether the `Coverage Converter` project is building. 
- `building_metrics_web` - indicates whether the `CI Integrations` project is building. 

The `Metrics Integration Actions` currently has the following jobs: 

- `Sync CI integrations` job that waits until the `CI Integration Actions` workflow finishes and exports the CI Integrations data to the Metrics Web application.
- `Sync Coverage Converter` job that waits for `Coverage Converter Actions` workflow finished and exports the Coverage Converter building data to the Metrics Web app.
- `Sync Metrics Web` job that waits for `Metrics Web Actions` workflow finished and exports the Metrics Web building data to the Metrics Web app.

So, once the `Metrics Integration Actions` workflow receives the `building_project` repository dispatch event, it gets the project that is currently building from the `client_payload` and starts the job that corresponds to the building project to export the building data.  The export job, in its turn, checkouts the repository, waits until the project's building job gets finished, downloads the `CI Integrations` tool, and runs the synchronization process.

__*Please, NOTE*__  that since we are using the [Wait For Check](https://github.com/marketplace/actions/wait-for-check) action that allows us to wait until the job gets finished, we should wait unlit the last workflow job gets finished. Usually, this job is a ` Notify about the building project`. It is needed to be sure that the project's building workflow is finished and we can get the building artifacts from this workflow if there any.

So, let's consider an example of the `Metrics Integrations Actions` job for some `Awesome project`: 

```yml
  awesome_project_sync:
    name: Awesome Project build data sync
    runs-on: macos-latest
    if: github.event.client_payload.building_awesome_project == 'true'
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 1
          ref: ${{ github.ref }}
      - name: Download Ci integrations
        run: |
          curl -L -o ci_integrations "https://docs.google.com/uc?export=download&id=1Uex_lKxXybX0WFU7nSo49jgM0smbbjc3"
          chmod a+x ci_integrations
      - name: Wait For Metrics Web check finished
        uses: fountainhead/action-wait-for-check@v1.0.0
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          checkName: Notify about building the Awesome Project
          ref: ${{ github.sha }}
          timeoutSeconds: 3600
      - name: Apply environment variables
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          WEB_APP_USER_EMAIL: ${{ secrets.WEB_APP_USER_EMAIL }}
          WEB_APP_USER_PASSWORD: ${{ secrets.WEB_APP_USER_PASSWORD }}
        run: eval "echo \"$(sed 's/"/\\"/g' metrics_web_config.yml)\"" >> integration.yml
        working-directory: .metrics/
      - name: Metrics Web build data sync
        run: ./ci_integrations sync --config-file .metrics/integration.yml
```

## Notify about the building project

The `Notify about the building project` step notifies the `Metrics Integration Actions` about some project's build started. As I've mentioned above, this job should emit a repository dispatch event containing `client_payload` with the data about the current building project. To send the repository dispatch event, we are using the [Repository Dispatch](https://github.com/marketplace/actions/repository-dispatch) action.

Also, to reduce the about of time taken for the `Metrics Integration Actions` workflow, we should run the `Notify about the building project` job after all jobs in the project building workflow. To do so, this job should depend on all jobs from the current workflow, defining the [needs](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#jobsjob_idneeds) key in the configuration file. Moreover, the `Notify about the building project` job should run even if any of the other jobs canceled/failed, so it should include `if: "always()"` option in the configuration file.

 So, let's consider the example of the `Notify about the building project` job for `Awesome project` in our repository: 

 Let's assume we have a workflow containing the following jobs: 

 - `Run tests` with `run_awesome_tests` identifier.
 - `Build and publish` with `build_and_publish_app` identifier.


 So, the `Notify about the building project` for this project will look like this: 

```yml
  notify-actions:
    name: Notify about building the Awesome project
    runs-on: macos-latest
    needs: [ run_awesome_tests, build_and_publish_app ]
    if: "always()"
    steps:
      - name: Notify about building the Awesome project
        uses: peter-evans/repository-dispatch@v1
        with:
          token: ${{ secrets.ACTIONS_TOKEN }}
          repository: platform-platform/monorepo
          event-type: building_project
          client-payload: '{"building_awesome_project": "true"}'
```

As you can see above, the `Notify about building the Awesome project` uses some `ACTIONS_TOKEN` secret. This secret is a [GitHub personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) that is configured to have access to all public and private repositories of the user.


# API

> What will the proposed API look like?

Once we've figured out the workflows and jobs we need to sync the project's builds with the Metrics Web application, let's consider the sequence diagram that will explain the mail relationships between the different workflows on the example with the `AwesomeProject`: 

![GitHub Actions Sequence Diagram](http://www.plantuml.com/plantuml/proxy?cache=no&fmt=svg&src=https://raw.githubusercontent.com/platform-platform/monorepo/github_actions_integration_documentation/docs/diagrams/github_actions_seequence_diagram.puml)

# Dependencies

> What is the project blocked on?

This project has no dependencies.

> What will be impacted by the project?

The GitHub Actions structure will be impacted by this project.

# Testing

> How will the project be tested?

This project will be tested manually. 

# Alternatives Considered

> Summarize alternative designs (pros & cons)

No alternatives considered.

# Timeline

> Document milestones and deadlines.

DONE:

  - 

NEXT:

  -
  
# Results

> What was the outcome of the project?

The export GitHub actions was configured for Metrics Web, Ci Integrations, and Coverage Converter projects.
