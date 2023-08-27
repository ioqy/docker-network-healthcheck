HEALTHCHECK_TIMEOUT=${HEALTHCHECK_TIMEOUT:-5};
HEALTHCHECK_EXEC=$(if which nc>/dev/null; then echo 'nc'; elif which bash>/dev/null; then echo 'bash'; else echo 'exit 1'; fi);

for TARGET in $HEALTHCHECK_TARGETS; do
  export ADDRESS=$(echo $TARGET | cut -d':' -f1);
  export PORT=$(echo $TARGET | cut -d':' -f2);

  if [ $HEALTHCHECK_EXEC = 'nc' ]; then
    nc -z -w $HEALTHCHECK_TIMEOUT $ADDRESS $PORT || exit 1;
  elif [ $HEALTHCHECK_EXEC = 'bash' ]; then
    (timeout $HEALTHCHECK_TIMEOUT bash -c '</dev/tcp/$ADDRESS/$PORT || exit 1' 2> /dev/null ) || exit 1;
  else
    echo 'HEALTHCHECK_EXEC could not be determined'
    $HEALTHCHECK_EXEC;
  fi
done