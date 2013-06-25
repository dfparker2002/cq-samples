Support Scripts (Collected)

NOTE PLEASE TEST IN A NON PRODUCTION ENVIRONMENT FIRST

getcqdata.sh
Usage: ./getcqdata.sh
Description: collects all relevant log and configuration file data from the instance.
Run this script after you have collected all the data you need.
ORIGINAL SOURCE: http://helpx.adobe.com/crx/kb/AnalyzePersistenceProblems.html

Profile.java
Usage: java Profile <pid> > myProileCapture.log # where pid is your running instance PID
Description: Out of CQ process to capture profiling data for the CQ instance
Run this script just before the problem occurs, until after the problem occurs
ORIGINAL SOURCE:  ?  (See Javadoc)

threaddumps.sh
Usage: Usage: jstackSeries <pid>[ <count> [ ,<delay> [, <logpath> ] ] ]  # Defaults: count = 10 (0 means infinite), delay = 0 (seconds), logpath = ./logs
Description: Modifiation of standard thread dump script to take a defined amount, or inifinite number of thread dumps
Run this script just before problem occurs, until after problem occurs.
Delay is dependant on the length of the performance issue (if 2hrs+ use 60s, less use 15s)
ORIGINAL SOURCE: http://helpx.adobe.com/cq/kb/TakeThreadDump.html