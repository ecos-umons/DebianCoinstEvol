#!/bin/bash
#
# get all Packages.bz2 files
#
for year in `seq 2006 2013`; do
  for month in `seq -w 01 12`; do
      last=31
      if [ $month -eq 2 ]; then 
	  last=28
	  if [ $year -eq 2008 -o $year -eq 2012 ]; then
	      last=29
	  fi
      elif [ $month -eq 04 -o $month -eq 06 -o $month -eq 09 -o $month -eq 11 ]; then
	  last=30
      fi
      for day in `seq -w 01 $last`; do
	  dn="$year$month${day}T060000Z"
          mkdir -p $dn
	  echo $dn
          echo "curl -s -S http://snapshot.debian.org/archive/debian/$year$month${day}T060000Z/dists/testing/main/binary-i386/Packages.bz2 -o $dn/Packages.bz2" > $dn/cmd
          curl -s -S http://snapshot.debian.org/archive/debian/$year$month${day}T060000Z/dists/testing/main/binary-i386/Packages.bz2 -o $dn/Packages.bz2
          (cd $dn; timeout 90s ../coinst -conflicts conflicts -stats -o graph.dot Packages.bz2 >& log)
      done
  done
done
