APT TestRunner
======================
#Kernel TestSuite 
This is the test framework and the accompanying test suites for Kernel from APT Platform Team.

The testrunner application is the user entry point for the test harness framework.
The following are some usage examples that showcase the functionality of testrunner:

The following execution will permanently store the given path as the path of the suite 'example'. Note that full paths are
required.

`$ testrunner --add /data/local/tmp/examplesuite --suite example`

The following execution will display all the existing suites, known to testrunner.

`$ testrunner --list`

The following execution will list all usecases inside the suite 'example'. Note that the suite has to have been added first in order to be visible to testrunner.

`$ testrunner --list --suite example`

the following execution will run 'testcase0' that belongs to suite 'example' once. NOTICE that '--run' must be followed by a TAG. In this example, the tag used is the date:

`$ testrunner --run ``date +%Y.%m.%d-%H.%M.%S`` --suite example --testcase testcase0`

The following exection will run entire suite

`$ testrunner --run ``date +%Y.%m.%d-%H.%M.%S`` --suite example --all --verbose`

The following execution will run 10 times every testcase in suite 'example'.

`$ for i in testrunner --list --suite example; do
  testrunner --run ``date +%Y.%m.%d-%H.%M.%S`` --n 10 --suite example --testcase $i
  done`

The following execution prints the description of the testcase tc1 which belongs to suite 'example':

`$ testrunner --desc --suite example --testcase tc1`

These are all the options available for the Testrunner framework:

testrunner [--[OPTION] [ARGUMENT]]...

OPTION LIST :
--run TAG       indicates that the testcase specified must be executed using TAG to mark output files
                        see --suite and --testcase
--list  if a suite is specified it will list all its testcases
                        otherwise it will print all known suites
--add PATH       requires that the --suite option is given
                         it will permanently asociate the given PATH with the specified suite
--suite SUITENAME        indicates on which suite testrunner should operate
--testcase TESTCASE      indicates the testcase on which testrunner should operate
                         whenever the --testcase option is enabled the --suite should also be enabled
--description    will print the description of the specified testcase
--verbose        indicates that all messages warnings and results should be printed
--allsuites      indicates run the all testcases in all suites
--random         indicates run random testcases from diff suites
--specific       indicates run specific testcases from specified test suite
--synchronous    indicates run random testcases from random suites and launch no.of instances in parallel as per sync_level input
--n N    specifies the number of repetitions of the given testcase
--t      specifies the time period in h - hours or m - min or s - sec
--cl     specifies cpu load and no of cps
--iol    specifies process  ioload and need to provide no of cpus ....
--iol-f          specifies the no of files for process io load......
--iol-b          specifies the no of bytes  (ex: 10k 0r 10m or 10g).....
--iol-nc         specifies noclean for process io load...
--iobl   specifies process iobusload and need to provide no of cpus....
--ml     specifies process memload and need to provide no of cpus.......
--ml-c   specifies  no of chunks for process mem load....
--ml-b   specifies no of bytes for process mem load (ex: 10k or 10m or 10g )  ....
--ml-h           specifies the hang for process mem load .....
