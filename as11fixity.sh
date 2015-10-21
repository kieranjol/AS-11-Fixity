#!/bin/bash 
#http://stackoverflow.com/a/15930450/2188572
#only look for xml files in all directories below your chosen directory
find "$1" -name "*.xml" | (
	while read file; do

	sourcepath="$(dirname "$file")" 
	filename="$(basename "$file")"
	filenoext="${filename%.*}"
    md5xml=($(xml sel -N 'x=http://www.digitalproductionpartnership.co.uk/ns/as11/2013' -t -v "//x:Programme/x:Technical/x:Additional/x:MediaChecksumValue" "$sourcepath/${filenoext}.xml"))
	md5mxf=($(md5deep "$sourcepath/${filenoext}.mxf"))
	if [[ "${md5xml}" == "${md5mxf}" ]] ; then
		echo "all is well!"
	else 
		echo "something is wrong!"
	fi
done
)
