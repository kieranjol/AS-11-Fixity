#!/bin/bash -x
find "$1" -name "*.xml" | (
	while read file; do

	sourcepath="$(dirname "$file")" 
	filename="$(basename "$file")"
	filenoext="${filename%.*}"
	xml sel -N 'x=http://www.digitalproductionpartnership.co.uk/ns/as11/2013' -t -v "//x:Programme/x:Technical/x:Additional/x:MediaChecksumValue" "$sourcepath/${filenoext}.xml"
	md5 "$sourcepath/${filenoext}.mxf"

done
)
