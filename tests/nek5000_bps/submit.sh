#!/bin/bash
#SBATCH -o out.file
#SBATCH -e error.file

echo $1        >  SESSION.NAME
echo `pwd`'/' >>  SESSION.NAME
touch $1.rea
rm -f logfile
rm -f ioinfo
mv $1.log.$2 $1.log1.$2 2>/dev/null
mv $1.sch $1.sch1       2>/dev/null
# echo "Executing: $mpi_run ./nek5000 > $1.log.$2"
echo "Executing: $mpi_run ./nek5000"
echo "In directory: $PWD"
# $mpi_run ./nek5000 > $1.log.$2
$mpi_run ./nek5000
sleep 2
# ln $1.log.$2 logfile
