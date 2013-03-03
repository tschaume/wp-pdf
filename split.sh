#!/bin/bash

input="userguide.txt"
tmp="tmp.txt"
filelist="filelist.txt"
lvl1="42 64 125 198 402 410 503 882 921"
# check the line numbers below!!
#lvl1="$lvl1 1143 1210 1231 1256 1320 1485 1831 2236 2271"
#lvl1="$lvl1 2300 2419 2981 3054 3540 3615 3695 4123 4149 4282 4345 4555 4679 4960"
#lvl1="$lvl1 5084 5107 5146"
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
  dirname=`echo $title | sed 's: ::g'`
  outdir=out/$dirname
  mkdir $outdir
  if grep -qn '^~~~' $tmp; then
    ln=`grep -n '^~~~' $tmp | awk -F: '{print $1}' | tr '\n' ' '`
    prevv=1
    for l in $ln; do
      if [ $(($prevv-1)) -eq 0 ]; then # level 1 title
        filename=$outdir/$dirname.txt
      else # level 2 title
        subtitle=`sed -n $(($l-1))p $tmp | sed 's: ::g'`
        filename=$outdir/${dirname}_${subtitle}.txt
      fi
      echo $filename
      echo -n "$filename " >> $filelist
      curline=$(($l-2))
      if [[ "`sed -n ${curline}p $tmp`" == *"[["* ]]; then
        curline=$(($curline-1))
      fi
      sed -n $prevv,${curline}p $tmp >> $filename
      prevv=$curline
    done
  else # no level 2 title found
    filename=$outdir/$dirname.txt
    echo $filename
    echo -n "$filename " >> $filelist
    sed $(($line+1))d $tmp | sed "${line}s:^${title}://== ${title}:" >> ${tmp}_2
    echo >> $filename
    echo ":blogpost-title: ${title}" >> $filename
    echo ":blogpost-posttype: page" >> $filename
    cat ${tmp}_2 >> $filename
    rm ${tmp}_2
  fi

  rm $tmp
  prev=$h
done

