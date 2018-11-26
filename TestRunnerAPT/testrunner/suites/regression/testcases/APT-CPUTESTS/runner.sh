#!/system/bin/sh

scripts_dir="/data/local/tmp/testrunner/suites/regression/testcases/APT-CPUTESTS"
tests_dirs="$@"
test_func(){
   if [ ! -d "${scripts_dir}" ]; then
       echo "ATP-TESTS=fail"
       exit
   fi

   bin_dir="/data/bin"

   if [ ! -d $bin_dir ]; then
        mkdir $bin_dir
   fi

   cd ${bin_dir}

   export PATH=${bin_dir}:$PATH

   cd "${scripts_dir}"

   pwd_dir=$PWD
   echo $pwd
   RESULT="0"
   for dir in $tests_dirs; do
       var=$dir'_sanity.sh'
       subDir=${pwd_dir}/$dir
       if [ -d $subDir ]; then
           cd $subDir
       else
           continue
       fi

       echo `pwd`

       /system/bin/sh $var
       if [ $? -ne 1 ]; then
           continue
       fi

       for file in `busybox find . -name "*.sh" | busybox sort`; do
           path=$file
           echo $path
           chk=`echo $file| grep -c "sanity"`
           /system/bin/sh $path
            status=$?
            if [ "$chk" -eq "0" ] ; then 
                if [ $status -ne 0 ] ; then
                    RESULT="1"
                fi
            fi
       done
       cd ..
   done
    if [ "$RESULT" != "0" ] ; then
        echo "APT-TESTS:Fail"
        exit 1
    else
        echo "APT-TESTS:Pass"
        exit 0
    fi
}

test_func
