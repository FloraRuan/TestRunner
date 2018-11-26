#!/system/bin/sh
#

# source ../../utils/root-check.sh
source ../../../../init_env
source $TOOLS/functestlib.sh

check_root
is_root=$?
if [ "$is_root" -ne "0" ]; then
	exit 3
fi

# Run
./drop_caches.sh
if [ "$?" -ne "0" ]; then
	echo "Could not run tests"
	exit -1
fi
