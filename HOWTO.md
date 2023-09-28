# Run Atlas CLI Commands with GitHub Actions

This guide provides getting started instructions for the official [Atlas CLI](https://github.com/mongodb/mongodb-atlas-cli) GitHub Action.

This Action allows you to run any Atlas CLI command in your own GitHub workflows.
By default, this Action uses the latest version of the Atlas CLI. The version can be configured with the 'version' input parameter, but only the
latest version is officially supported.

## Complete the prerequisites

Before you begin, complete the following prerequisites:

1. [Configure Atlas CLI API Keys](https://www.mongodb.com/docs/atlas/configure-api-access/) for your organization or project.
2. Add the API Keys to the [repository secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).
3. Set the environment variables `MONGODB_ATLAS_PUBLIC_API_KEY` and `MONGODB_ATLAS_PRIVATE_API_KEY` to the Atlas CLI API Keys you configured.
See [Atlas CLI Environment Variables](https://www.mongodb.com/docs/atlas/cli/stable/atlas-cli-env-variables/) for all supported environment variables.

## Configuration

To run CLI commands with this Action you can either use custom commands (see Basic workflow below) or use the configuration parameters
to run predefined workflows. See [action.yml](action.yml) for available inputs/outputs.

## Example workflows

See [test.yml](https://github.com/mongodb/atlas-github-action/blob/main/.github/workflows/test.yml) for more examples.

### Basic
This workflow installs the CLI and prints the CLI version.
```yaml
on: [push]

name: Atlas CLI Action Sample

jobs:
  use-atlas-cli:
    runs-on: ubuntu-latest
    
    steps:
      - name: Setup AtlasCLI
        uses: mongodb/mongodb-atlas-cli@main
      - name: Use AtlasCLI
        shell: bash
        run: atlas --version # Print Atlas CLI Version
```

### Setup and Teardown
This workflow sets up a project and creates a free cluster. It retrieves the connection string which can be used to connect to the new cluster.
Afterwards, it deletes the project and cluster.
```yaml
on: [push]

name: Atlas CLI Action Sample

env:
  MONGODB_ATLAS_PUBLIC_API_KEY: ${{ secrets.PUBLIC_API_KEY }}
  MONGODB_ATLAS_PRIVATE_API_KEY: ${{ secrets.PRIVATE_API_KEY }}
  MONGODB_ATLAS_ORG_ID: ${{ secrets.ORG_ID }} # default organisation ID
  MONGODB_ATLAS_PROJECT_ID: ${{ secrets.PROJECT_ID }} # default project ID

jobs:
  setup:
    runs-on: ubuntu-latest

    steps:
      - name: Setup AtlasCLI and create a project
        id: create-project
        uses: mongodb/atlas-github-action@main
        with:
          create-project-name: test-setup-project
      - name: Run setup
        id: setup
        uses: mongodb/atlas-github-action@main
        with:
          run-setup: true
          project-id: ${{ steps.create-project.outputs.create-project-id }}
          cluster-name: test-cluster
          username: test-user
          password: test-password
      - name: Retrieve Connection String
        shell: bash
        run: |
          echo "${{ steps.setup.outputs.connection-string }}"
      - name: Teardown
        uses: mongodb/atlas-github-action@main
        with:
          delete-project-id: ${{ steps.create-project.outputs.create-project-id }}
          delete-cluster-name: test-cluster
```
