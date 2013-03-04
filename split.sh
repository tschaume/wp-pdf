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

writeHeader() { # line, title, filename, tmp, levelstring
  sed $(($1+1))d $4 | sed "$1s:^$2://$5 $2:" >> xxx
  echo >> $3
  echo ":blogpost-title: $2" >> $3
  echo ":blogpost-posttype: page" >> $3
  cat xxx >> $3
  rm xxx 
}

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
    echo $ln
    for l in $ln; do
      if [ $prevv -eq 1 ]; then # level 1 title
        filename=$outdir/$dirname.txt
      else # level 2 title
        echo $prevv
        subtitle=`sed -n ${prevv}p $tmp` # subtitle doesn't fit file content
        # need previous line
        filename=$outdir/${dirname}_`echo ${subtitle} | sed 's: ::g'`.txt
      fi
      echo $filename
      echo -n "$filename " >> $filelist
      curline=$(($l-2))
      if [[ "`sed -n ${curline}p $tmp`" == *"[["* ]]; then
        curline=$(($curline-1))
      fi
      sed -n $prevv,${curline}p $tmp >> ${tmp}_2
      if [ $(($prevv-1)) -eq 0 ]; then # level 1 title
        writeHeader $line "$title" $filename ${tmp}_2 '=='
      else # level 2 title
        #writeHeader $line "$subtitle" $filename ${tmp}_2 '==='
        cp ${tmp}_2 $filename
      fi
      rm ${tmp}_2
      prevv=$curline
    done
  else # no level 2 title found
    filename=$outdir/$dirname.txt
    echo $filename
    echo -n "$filename " >> $filelist
    writeHeader $line "$title" $filename $tmp '=='
  fi

  rm $tmp
  prev=$h
done

