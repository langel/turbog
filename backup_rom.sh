#!/bin/bash

count=$(ls -1q exports/ | wc -l)
padding_length=4
padded_count=$(printf "%0${padding_length}d" "$count")
new_name="turbog_$padded_count.pce"	
	
echo $new_name 
cp turbog.pce exports/$new_name
