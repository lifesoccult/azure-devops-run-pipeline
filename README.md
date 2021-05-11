# Azure DevOps Run Pipeline Template
This is a generic template that can be used to invoke the execution of a pipeline from another pipeline. 
You will need to provide your own [Personal Access Token](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
in order to authenticate to the API.

## Usage
This template is designed to operate at the root level of an Azure Pipeline. It has its own `stages` declaration.
To use this template, add the following two segments to your `azure-pipelines.yml`:

First add a resource definition for the repository
```
resources:
  repositories:
  - repository: run-pipeline
    type: github
    name: lifesoccult/azure-devops-run-pipeline
```
Next add the template reference at the point you want to call another pipeline:
```
- template: run-pipeline.yml@run-pipeline
  parameters:
    organization: <str> # Name of your ADO Organization
    project: <str> # Name of your ADO Project
    pipeline_id: <int> # Get ID from the web URI
    pipeline_branch <str> # Optional, defaults to 'main'
    pipeline_variables: <JSON blob> # Optional, defaults to '{}'. See working examples below for good structure
    stages_to_skip: <str[]> # Optional, defaults to '[]' 
    ado_token: <PAT> # It is recommended to use a secret variable for safe keeping
```

## Pipeline Variables Examples
There is a specific format for this argument based on the [API documentation](https://docs.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/run%20pipeline?view=azure-devops-rest-6.0). 
The `isSecret` key/value pair is optional. **It is recommended to condense the JSON blob to a single line.**

NOTE: These examples are completely dependent on the pipeline you intend to invoke. 
The below examples are for a specific pipeline and will be different from what you need to supply. 
If you do not need to pass in variables, you can ignore this parameter altogether.

Condensed, sans `isSecret` key example:
```
pipeline_variables: "{'environment': {'value': 'dev'}, 'var1': {'value': 'foo'}, 'var2': {'value': 'bar'}}"
```

Non-condensed example:
```
pipeline_variables: "{
    'environment': {
        'isSecret': false,
        'value': 'dev'
        },
    'var1': {
        'isSecret': false,
        'value': 'foo'
        },
    'var2': {
        'isSecret': false,
        'value': 'bar'
        }
    }
}"
```
### A Note on Variables
In my testing, it seems that you cannot override variables that are defined in your pipeline YAML.
For best results, I opted to leave out all variable declarations in the target pipeline I wish to trigger,
realizing this is not the most optional solution as those variable names are now obfuscated from anyone reading that
pipeline code.