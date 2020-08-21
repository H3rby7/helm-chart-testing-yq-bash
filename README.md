# Helm Chart Testing

Enhances https://github.com/helm/chart-testing with jq, yq and bash

# Found on

* [Github](https://github.com/H3rby7/helm-chart-testing-yq-bash)
* [Docker - lujoka/helm-chart-testing-yq-bash](https://hub.docker.com/repository/docker/lujoka/helm-chart-testing-yq-bash)

# Stage Check

Small CLI tool to prevent copy-paste errors from one stage to another.

## Usage

`stage-check.sh <stage> <file>`

* Exit code 0 if everything is ok
* Exit code 1 if a file contains strings it should not.

### Config

Config is done via yaml. The command will take chose the first matched config file:
 
1. `.stage-check.yaml` in your working dir
1. `.stage-check.yaml` in the scripts directory (see [this file](./cli/.stage-check.yaml))

Add any stage you like as key. As long as you do not call it `global` which is reserved to define global ignores. 

```yaml
# SAMPLE
global:
  allow:
  - intranet
dev:
  deny:
  - int
  - prod
  allow:
  - integration
# ... more stages ...
```

### Internals

1. Copy input file to ".tmp-stage"
1. replace occurrences defined by a stage using `sed`
1. replace occurrences defined by `global` using `sed`
1. run `grep` for strings defined in `stage-name.deny` using `grep -n denied-word`
