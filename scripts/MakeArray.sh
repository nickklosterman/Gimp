#!/bin/bash
x=0
while [ $x -lt 256 ]
do
echo "(aset points $x 0)"
let "x+=1"
done;