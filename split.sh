#!/bin/bash

input="userguide.txt"
tmp="tmp.txt"
filelist="filelist.txt"
lvl1="42 63 124 197 401 409 502"
#lvl1="$lvl1 521 900 939 1162 1229 1250 1275 1338 1503 2254"

if [ -d out ]; then rm -rf out; fi
mkdir out
if [ -e $filelist ]; then rm $filelist; fi

prev=1
for h in $lvl1; do
  echo "-------------------------------------------"
  sed -n $prev,${h}p $input >> $tmp
  line=3 # default header line
  title=`sed -n ${line}p $tmp`
  if [[ "$title" == *"[["* ]]; then line=4; title=`sed -n ${line}p $tmp`; fi
  filename=`echo $title | sed 's: ::g'`
  out="out/$filename.txt"
  echo -n "$out " >> $filelist
  sed $(($line+1))d $tmp | sed "${line}s:^${title}://== ${title}:" | sed 1,2d >> ${tmp}_2
  echo >> $out
  echo ":blogpost-title: ${title}" >> $out
  echo ":blogpost-posttype: page" >> $out
  cat ${tmp}_2 >> $out
  cat $out | head -5
  rm $tmp*
  prev=$h
done

