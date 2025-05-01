#!/bin/bash
set -ex

for FILE in *.mov; do 
  echo $FILE; 
  docker run --rm -it -v $(pwd):/config linuxserver/ffmpeg -i /config/${FILE} -vcodec h264 -c:a copy /config/output/${FILE%%.*}.mp4;
  echo "remove file ${FILE}";
  rm -rf ${FILE};
  echo "done"; 
done