set -o pipefail
make -n -B -C $1 | awk makefile_parse.awk
