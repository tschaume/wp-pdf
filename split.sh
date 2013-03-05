#!/bin/bash
# Copyright (c) 2013 Patrick Huck

input="userguide.txt"
tmp="tmp.txt"
filelist="filelist.txt"
lvl1="42 64 125 198 402 410 503 882 921"
# check the line numbers below!!
#lvl1="$lvl1 1143 1210 1231 1256 1320 1485 1831 2236 2271"
#lvl1="$lvl1 2300 2419 2981 3054 3540 3615 3695 4123 4149 4282 4345 4555 4679 4960"
#lvl1="$lvl1 5084 5107 5146"
#"5501 5525 5551"

appendFile() { # filename
  echo $1
  echo -n "$1 " >> $filelist
}

getSplitLine() { # ~~~line tmp
  local splitline=$(($1-2))
  if [[ "`sed -n ${splitline}p $2`" == *"[["* ]]; then
    splitline=$(($splitline-1))
  fi
  echo $splitline
}

writeHeader() { # line, title, filename, tmp, levelstring
  sed $(($1+1))d $4 | sed "$1s:^$2://$5 $2:" >> xxx
  echo >> $3
  echo ":blogpost-title: $2" >> $3
  echo ":blogpost-posttype: page" >> $3
  cat xxx >> $3
  rm xxx 
}

if [ ! -d out ]; then mkdir out; fi
find out -type f -name "*.txt" | xargs rm
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

  if grep -qn '^~~~' $tmp; then # sub-titles
    ln=`grep -n '^~~~' $tmp | awk -F: '{print $1}' | tr '\n' ' '`

    # level 1 title
    filename=$outdir/$dirname.txt
    appendFile $filename
    sl=$(getSplitLine `echo $ln | awk '{print $1}'` $tmp)
    sed -n 1,${sl}p $tmp >> ${tmp}_2
    writeHeader $line "$title" $filename ${tmp}_2 '=='
    rm ${tmp}_2

    # level 2 titles
    fld=2
    for l in $ln; do
      subtitle=`sed -n $(($l-1))p $tmp`
      filename=$outdir/${dirname}_`echo ${subtitle} | sed 's: ::g'`.txt
      appendFile $filename

      sl1=$(getSplitLine $l $tmp)
      nl=$(echo $ln | awk "{print \$$fld}") # next ~~~~line
      if [ -z "$nl" ]; then
        nl=$(cat $tmp | wc -l | sed 's: ::g')
        let nl=$nl+2
      fi
      sl2=$(getSplitLine $nl $tmp)
      sed -n $sl1,${sl2}p $tmp >> ${tmp}_2
      let fld=$fld+1 # next field for awk

      subline=2 # default sub-header line
      if [[ "$(sed -n ${subline}p ${tmp}_2)" == *"[["* ]]; then subline=3; fi
      writeHeader $subline "$subtitle" $filename ${tmp}_2 '==='
      #cp ${tmp}_2 $filename
      rm ${tmp}_2
    done

  else # no level 2 title found
    filename=$outdir/$dirname.txt
    appendFile $filename
    writeHeader $line "$title" $filename $tmp '=='
  fi

  rm $tmp
  prev=$h
done
