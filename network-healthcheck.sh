healthcheck_timeout=${HEALTHCHECK_TIMEOUT:-5};
healthcheck_exec=$(if which nc>/dev/null; then echo 'nc'; elif which bash>/dev/null; then echo 'bash'; else echo 'exit 1'; fi);

for target in $HEALTHCHECK_TARGETS; do
  export address=$(echo $target | cut -d':' -f1);
  export port=$(echo $target | cut -d':' -f2);

  if [ $healthcheck_exec = 'nc' ]; then
    nc -z -w $healthcheck_timeout $address $port || exit 1;
  elif [ $healthcheck_exec = 'bash' ]; then
    (timeout $healthcheck_timeout bash -c '</dev/tcp/$address/$port || exit 1' 2> /dev/null ) || exit 1;
  else
    echo 'healthcheck_exec could not be determined'
    $healthcheck_exec;
  fi
done
