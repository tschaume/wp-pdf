#!/bin/bash

input="userguide.txt"
tmp="tmp.txt"
filelist="filelist.txt"
lvl1="42 63 124 197 401 409 502 881 920 1143 1210 1231 1256 1320 1485 1831 2236 2271"
lvl1="$lvl1 2300 2419 2981 3054 3540 3615 3695 4123 4149 4282 4345 4555 4679 4960"
lvl1="$lvl1 5084 5107 5146"
#"5501 5525 5551"

if [ -d out ]; then rm -rf out; fi
mkdir out
if [ -e $filelist ]; then rm $filelist; fi

prev=1
for h in $lvl1; do
  sed -n $prev,${h}p $input >> $tmp
  line=3 # default header line
  title=`sed -n ${line}p $tmp`
  if [[ "$title" == *"[["* ]]; then line=4; title=`sed -n ${line}p $tmp`; fi
  filename=`echo $title | sed 's: ::g'`
  out="out/$filename.txt"
  echo $out
  echo -n "$out " >> $filelist
  sed $(($line+1))d $tmp | sed "${line}s:^${title}://== ${title}:" | sed 1,2d >> ${tmp}_2
  echo >> $out
  echo ":blogpost-title: ${title}" >> $out
  echo ":blogpost-posttype: page" >> $out
  cat ${tmp}_2 >> $out
  #cat $out | head -5
  rm $tmp*
  prev=$h
done

