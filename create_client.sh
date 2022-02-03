set -e

usage() {
  echo "USAGE: $0 -i IP [-p PORT] [-n CLIENT_NAME] [-o OUTPUT]" >&2
  exit 1
}

OUTPUT=/dev/stdout
ARGS=()
HAS_IP=0
while getopts "i:p:n:o:" option; do
  case $option in
    # Ip address
    i) ARGS[${#ARGS[@]}]="-i"; ARGS[${#ARGS[@]}]="$OPTARG"; HAS_IP=1;;
    p) ARGS[${#ARGS[@]}]="-p"; ARGS[${#ARGS[@]}]="$OPTARG";;
    n) ARGS[${#ARGS[@]}]="-n"; ARGS[${#ARGS[@]}]="$OPTARG";;
    o) OUTPUT="$OPTARG";;
    ?) usage;;
  esac
done

if [ $HAS_IP -eq 0 ]; then
  echo "$0: Requires an IP address"
  usage
fi

sudo docker run -a stderr -a stdout \
  --cap-add=net_admin --rm vpndocker genclient "${ARGS[@]}" > $OUTPUT
