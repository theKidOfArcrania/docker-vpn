set -e

usage() {
  echo "USAGE: $0 -i IP [-p PORT] [-n CLIENT_NAME] [-o OUTPUT]" >&2
  exit 1
}

SCRIPTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"

CLIENT_NAME=client$RANDOM
OUTPUT=
ARGS=()
HAS_IP=0
while getopts "i:p:n:o:" option; do
  case $option in
    # Ip address
    i) ARGS[${#ARGS[@]}]="-i"; ARGS[${#ARGS[@]}]="$OPTARG"; HAS_IP=1;;
    p) ARGS[${#ARGS[@]}]="-p"; ARGS[${#ARGS[@]}]="$OPTARG";;
    n) CLIENT_NAME="$OPTARG";;
    o) OUTPUT="$OPTARG";;
    ?) usage;;
  esac
done

pushd "$SCRIPTPATH/.certs" > /dev/null 2> /dev/null
TEMP="$(mktemp -p .)"
test -f "$TEMP"
TEMP_OUTPUT="/mnt/certs/$TEMP"
TEMP="$SCRIPTPATH/.certs/$TEMP"
popd > /dev/null 2> /dev/null

if [ -z "$OUTPUT" ]; then
  OUTPUT="$CLIENT_NAME.ovpn"
fi

if [ $HAS_IP -eq 0 ]; then
  echo "$0: Requires an IP address"
  usage
fi

ARGS[${#ARGS[@]}]="-o"
ARGS[${#ARGS[@]}]="$TEMP_OUTPUT"
ARGS[${#ARGS[@]}]="-n"
ARGS[${#ARGS[@]}]="$CLIENT_NAME"
sudo docker-compose run manage_cert ovpn genclient "${ARGS[@]}"

mv "$TEMP" "$OUTPUT"
echo "Client configuration is at: $(realpath "$OUTPUT")"
