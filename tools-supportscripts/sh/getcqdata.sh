#!/bin/bash
if [ $# -eq 0 ]; then
    echo >&2 "Usage: getcqdata <cqpath>"
    echo >&2 "    cqpath is the folder that contains the crx-quickstart folder"
    exit 1
fi

cqpath=$1          # required

cd $cqpath
java -version 2> infoJavaVersion.log
find . -name "crx*.jar" > infoCrxVersion.log
ls -alR > infoFileList.log
zip -r clusterNode1.zip . -i */repository.xml */workspace.xml */*.log *.log */*.log.*
rm info*

echo "data gathered at $cqpath/clusterNode1.zip"