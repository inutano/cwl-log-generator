# CWL Log Generator

CWL Log Generator is one component of the [CWL-metrics](https://github.com/inutano/cwl-metrics) system for resource usage metrics collection of [Common Workflow Language (CWL)](https://www.commonwl.org) runs. CWL Log Generator generate JSON format log file by analyzing outputs from `[cwltool](https://github.com/common-workflow-language/cwltool/)` including debug output, docker container status, and platform information.

## Usage

A ruby script `generate_cwl_log` is for stand alone execution, but the generator is designed to work as a part of the CWL-metrics system. So we recommend to install CWL-metrics and use `cwl-metrics` to launch the automatic log generation process.

For stand alone use, the script requires following information:

- a path to the file containing debug output via `cwltool --debug`
- a path to the directory containing cid files created by `cwltool --record-container-id`
- a path to the job configuration file in yaml or json (optional)
- output of `docker ps` as output or file (optional)
- output of `docker info` as output or file (optional)
- `docker inspect` command
  - if the provided docker container is used, mount `docker.sock` by `-v /var/run/docker.sock:/var/run/docker.sock` to enable `docker inspect` inside the container

## Concrete example
Here is an example to analyze the execution result of `workflow.cwl` with `inputs.yml`.

```console
$ mkdir result
$ cwltool --debug --leave-container --timestamps --compute-checksum --record-container-id --cidfile-dir $PWD/result --outdir $PWD/result workflow.cwl inputs.yml 2> $PWD/result/cwltool.log
...
$ docker ps -a --no-trunk > ps-file
$ docker info > info-file
$ generate_cwl_log --docker-ps ./ps-file --docker-info ./info-file --job-conf inputs.yml --debug-output result/cwltool.log --output-dir result
$ cat result/cwl_log.json | jq .
{
  "workflow": {
    "docker": {
      "running_containers": "0",
      "server_version": "18.03.1-ce",
      "storage_driver": "overlay2",
      "number_of_cpu": "2",
      "total_memory": "1.952GiB"
    },
    "start_date": "2018-07-18 17:40:33",
    "end_date": "2018-07-18 17:40:40",
    "cwl_file": "workflow.cwl",
    "genome_version": null,
    "input_jobfile": {
    ...
```
