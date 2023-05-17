##################################################################################################################################
# Cleaning up OpenFace 2.0 output CSVs
# Mark Szenteczki
#
# Description: This small script cuts down the CSV files output by OpenFace to include key metadata and AU data only 
# Input: This script should be run from a folder containing two sub-folders, named /raw/ and /clean/
#
# Requirements:
# 1) Copy all of your output CSVs from the /processed/ folder (generated by OpenFace) to the new /raw/ folder you made
# 2) Copy and then run this script (i.e. run ./cut.sh) from the folder containing the /raw/ and /clean/ folders
# 3) The trimmed down CSV files should now be available in the /clean/ folder you made
#
# Note: if you run ./cut.sh a second time, it will overwrite any files from the previous time the script was run
#
# Typical Usage (in terminal): ./cut.sh
#

#!/usr/bin/env bash

for i in $(ls *.csv)

do

echo "processing ${i}..." 

cut -d "," -f1-13,680-714 ./raw/${i} > ./clean/${i}

echo "done ${i}..." 

done
