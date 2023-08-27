# A healthcheck script for docker containers connected to gluetun

The container has to have either of the following sets of programs installed:

* `cut`, `echo`, `nc`, `sh`, `which`
* `bash`, `cut`, `echo`, `nc`, `which`

## How to use:

1. Add the environment variable `HEALTHCHECK_TARGETS` with the targets in the format `<address>:<port>` delimited by a space:

```YAML
environment:
  - HEALTHCHECK_TARGETS=cloudflare.com:443 google.com:443
```

2. Add the script to the docker container:

Either take the contents of `docker-compose.sh` and put them as the `test` script in the healthcheck configuration:

```YAML
healthcheck:
  test: sh -c "HEALTHCHECK_TIMEOUT=\$${HEALTHCHECK_TIMEOUT:-5}; HEALTHCHECK_EXEC=\$$(if which nc>/dev/null; then echo 'nc'; elif which bash>/dev/null; then echo 'bash'; else echo 'exit 1'; fi); for TARGET in \$$HEALTHCHECK_TARGETS; do export ADDRESS=\$$(echo \$$TARGET | cut -d':' -f1); export PORT=\$$(echo \$$TARGET | cut -d':' -f2); if [ \$$HEALTHCHECK_EXEC = 'nc' ]; then nc -z -w \$$HEALTHCHECK_TIMEOUT \$$ADDRESS \$$PORT || exit 1; elif [ \$$HEALTHCHECK_EXEC = 'bash' ]; then (timeout \$$HEALTHCHECK_TIMEOUT bash -c '</dev/tcp/\$$ADDRESS/\$$PORT || exit 1' 2> /dev/null ) || exit 1; else echo 'HEALTHCHECK_EXEC could not be determined' \$$HEALTHCHECK_EXEC; fi done"
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

