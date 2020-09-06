# Aurora Bootstrap Parallelization

Script that generates and applies kubernetes job manifests to run [aurora-parallelizer](https://github.com/gaorlov/aurora-bootstrap). Takes a config file and runs `kubectl apply` for every job manifest.

## Local Checklist
* Do I have `kubectl` installed?
* Am I in the right kuberenetes context?
* Do I have job resource write permissions?


## Running

To run the job, generate your [config file](#config-file), install the gems and then
```bash
./bin/strap -c CONFIG_FILE
```

### Kubernetes Prerequisites
The manifests will expect 2 kubernetes contructs:

* `aurora-bootstrap` namespace to which the generated manifests will be applied.
  ```yaml
  apiVersion: v1
  kind: Namespace
  metadata:
    name: aurora-bootstrap
  ```
* `configMap` named `configs` in the `aurora-bootstrap` namespace. It can contain as many or as few of the env vars. It is recommended to keep all the common values in here to keep the config small:
  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: configs
    namespace: aurora-bootstrap
  data:
    PREFIX:
    ROLLBAR_TOKEN:
    BLACKLISTED_FIELDS:
    BLACKLISTED_TABLES:
    DB_USER:
    DB_PASS:
  ```

### Env Vars
This is the full list of env vars the job will expect. It is up to you how many of those go into the configMap and how many are in the config file.
* `PREFIX`: Database prefix. Will only export databases that start with the prefix. Useful for omitting internal MySQL schemas.
* `ROLLBAR_TOKEN`: Rollbar token for error reporting.
* `BLACKLISTED_FIELDS`: comma separated list of fields across all tables to exclude from export. Supports regexp for entries formatted as `/exp`/. 
* `BLACKLISTED_TABLES`: comma separated list of tables across all databases to exclude from export. Supports regexp for entries formatted as `/exp/`
* `DB_HOST`: connection string to Aurora MySQL host
* `DB_USER`: DB user with `SELECT INTO S3` grant
* `DB_PASS`: password of user
* `EXPORT_BUCKET`: bucket into which data will be exported

### Config File
```yaml
default: &default
  version: 0.1.0.9

exporters:
  - <<: *default
    # name of first kuberenetes job
    name: 
    env:
    - name: EXPORT_BUCKET
      value: 
    - name: DB_HOST
      value:

  - <<: *default
    # name of second kuberenetes job
    name: 
    env:
    - name: EXPORT_BUCKET
      value: 
    - name: DB_HOST
      value: 

  # etc. 
```

## Running tests

```bash
bundle install
bundle exec rake test`
```