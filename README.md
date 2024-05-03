# A healthcheck script for docker containers connected to gluetun

The container has to have either of the following sets of programs:

* `cut`, `echo`, `nc`, `sh`, `which`
* `bash`, `cut`, `echo`, `timeout`, `which`

## How to use:

1. Add the environment variable `HEALTHCHECK_TARGETS` with the targets in the format `<address>:<port>` delimited by a space:

```YAML
environment:
  - HEALTHCHECK_TARGETS=127.0.0.1:443 cloudflare.com:443
```

2. Add the script to the docker container:

Either take the contents of `docker-compose.sh` and put them as the `test` script in the healthcheck configuration:

```YAML
healthcheck:
  test: sh -c "healthcheck_timeout=\$${HEALTHCHECK_TIMEOUT:-5}; healthcheck_exec=\$$(if which nc>/dev/null; then echo 'nc'; elif which bash>/dev/null; then echo 'bash'; else echo 'exit 1'; fi); for target in \$$HEALTHCHECK_TARGETS; do export address=\$$(echo \$$target | cut -d':' -f1); export port=\$$(echo \$$target | cut -d':' -f2); if [ \$$healthcheck_exec = 'nc' ]; then nc -z -w \$$healthcheck_timeout \$$address \$$port || exit 1; elif [ \$$healthcheck_exec = 'bash' ]; then (timeout \$$healthcheck_timeout bash -c '</dev/tcp/\$$address/\$$port || exit 1' 2> /dev/null ) || exit 1; else echo 'healthcheck_exec could not be determined' \$$healthcheck_exec; fi done"
  interval: 60s
```

Or save `network-healthcheck.sh` at `/usr/local/bin/network-healthcheck.sh` on the docker host and mount the script into the docker container:

```YAML
volumes:
  - /usr/local/bin/network-healthcheck.sh:/network-healthcheck.sh:ro
healthcheck:
  test: /network-healthcheck.sh
  interval: 60s
```

## Options

### Timeout

The default timeout of 5 seconds, used for checking each target in `HEALTHCHECK_TARGETS`, can be changed with the environment variable `HEALTHCHECK_TIMEOUT` like this:

```YAML
environment:
  - HEALTHCHECK_TIMEOUT=10
```
