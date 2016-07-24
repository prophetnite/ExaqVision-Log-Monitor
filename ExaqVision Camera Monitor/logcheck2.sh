SHELL=/bin/bash

echo "Start!"
cat log.txt | grep -i '160000'| while read line
do
   echo $line
done
