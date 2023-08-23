# Run Atlas CLI Commands with GitHub Actions

This guide provides getting started instructions for the official Atlas CLI GitHub Action.

By default, this Action uses the latest [Atlas CLI](https://github.com/mongodb/mongodb-atlas-cli) version.
The version can be configured with the version input parameter.

## Complete the prerequisites

Before you begin, complete the following prerequisites:
1. Configure Atlas CLI API Keys for the organisation or project that will be used in the Action.
2. Add the API Keys to the [repository secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).
3. For authentication the environment variables MONGODB_ATLAS_PUBLIC_API_KEY and MONGODB_ATLAS_PRIVATE_API_KEY need to be set to the configured API keys in the workflow.
See [Atlas CLI Environment Variables](https://www.mongodb.com/docs/atlas/cli/stable/atlas-cli-env-variables/) for all supported variables.

## Example workflows

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
This workflow sets up a project and a free cluster. It retrieves the connection string to connect to the created cluster.
Afterwards it deletes the project and cluster that was set up.
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
        uses: mongodb/mongodb-atlas-cli@main
        with:
          create-project-name: test-setup-project
      - name: Run setup
        id: setup
        uses: mongodb/mongodb-atlas-cli@main
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
        uses: mongodb/mongodb-atlas-cli@main
        with:
          delete-project-id: ${{ steps.create-project.outputs.create-project-id }}
          delete-cluster-name: test-cluster
```