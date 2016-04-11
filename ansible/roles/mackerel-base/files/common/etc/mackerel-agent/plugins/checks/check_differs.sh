#!/bin/bash -
# check_diffes.sh
#   ver: 2015/10/27
#

# STAT_DIR is used for mktemp
[ -d /dev/shm ] && declare -r STAT_DIR="/dev/shm" || declare -r STAT_DIR="/tmp"
# Create TMP_FILE
declare -r TMP_FILE="$(mktemp --tmpdir=${STAT_DIR})"
function atexit() {
  [ -f "${TMP_FILE}" ] && rm "${TMP_FILE}"
}
trap atexit EXIT
trap 'trap - EXIT; atexit; exit -1' INT PIPE TERM


function usage_exit() {
  echo "Usage: $(basename ${0}) -[f|o] OK_STATE_FILE CHECK_COMMAND" 1>&2
  echo "       -f : Check state with OK_STATE_FILE" 1>&2
  echo "       -o : Output OK_STATE_FILE for initial configuration" 1>&2
  exit 1
}

# check_exit is used for mackerel
function check_exit() {
  if [ ! -f ${OK_STATE_FILE} ]; then
    echo "'${OK_STATE_FILE}' is not found."
    exit 1
  fi

  eval ${COMMAND} > ${TMP_FILE}
  diff ${OK_STATE_FILE} ${TMP_FILE}
  [ $? -ne 0 ] && exit 2

  echo "OK, no differs."
  exit 0
}

# output_exit is used for initial configuration
function output_exit() {
  if [ -f ${OK_STATE_FILE} ]; then
    BACKUP_FILE="/tmp/tmp.$(basename ${OK_STATE_FILE}).$(date +%s)"
    cp ${OK_STATE_FILE} ${BACKUP_FILE}
    [ $? -eq 0 ] && echo "OK_STATE_FILE is copied to '${BACKUP_FILE}'"
  fi

  eval ${COMMAND} > ${TMP_FILE}
  cp ${TMP_FILE} ${OK_STATE_FILE}
  if [ $? -ne 0 ]; then
    echo "Cannot create OK_STATE_FILE at '${OK_STATE_FILE}'"
    exit 1
  fi

  echo "Create OK_STATE_FILE at '${OK_STATE_FILE}'"
  exit 0
}

#
# MAIN
#
declare FLAG="h"

# parse options
while getopts "f:o:h" opts
do
  case $opts in
    f)
      OK_STATE_FILE=${OPTARG}
      FLAG="f"
      ;;
    o)
      OK_STATE_FILE=${OPTARG}
      FLAG="o"
      ;;
    h)
      usage_exit
      ;;
    *)
      usage_exit
      ;;
  esac
done
shift $(( ${OPTIND} - 1 ))
declare -r COMMAND="$@"
if [[ "${COMMAND}x" == "x" ]]; then
  usage_exit
fi

# main
case ${FLAG} in
  f)
    check_exit
    ;;
  o)
    output_exit
    ;;
esac
# Something obvious...
exit 1
