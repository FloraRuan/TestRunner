#!/system/bin/bash

# Import test suite definitions
source ../../../../init_env

BIN=$TOOLS/pointer_tagging_tests

if [ ! -x $BIN ]; then
  echo "Couldn't find $BIN. Please cross check first."
  exit
fi

if [ -t 1 ]; then
  CLR_PASS="\033[1;32m"
  CLR_FAIL="\033[1;31m"
  CLR_RESET="\033[m"
else
  CLR_PASS=""
  CLR_FAIL=""
  CLR_RESET=""
fi

# Filter the test list.
if [ $# == 0 ]; then
  TEST_LIST=`$BIN --list`
else
  TEST_LIST=`$BIN --list | grep "$1"`
fi
TEST_COUNT=`echo "$TEST_LIST" | wc -l`

if [ -z "$TEST_LIST" ]; then
  echo "No matching tests."
  exit
fi

echo "==== Running $TEST_COUNT tests. ===="
for TEST in $TEST_LIST
do
  OUT=`$BIN --test $TEST 2>&1`
  if [ $? == 0 ]; then
    echo -e "Test '$TEST' ${CLR_PASS}PASSED${CLR_RESET}."
  else
    echo -e "Test '$TEST' ${CLR_FAIL}FAILED${CLR_RESET}."
    if [ -n "$OUT" ]; then
      echo -e "Output:\n$OUT\n"
    fi
  fi
done
