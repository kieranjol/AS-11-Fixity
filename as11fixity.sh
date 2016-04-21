#!/bin/bash 
#http://stackoverflow.com/a/15930450/2188572
#only look for xml files in all directories below your chosen directory
if [ -f  ~/desktop/"$(basename "$1")".csv ]; then
	echo “CSV file already exists. Aborting“ ;
	exit 1
else
echo "Filename,Title,Episode_Number,Md5_From_Xml,Md5_from_Mxf,Checksum_Result" >> ~/desktop/"$(basename "$1")".csv
find "$1" -name "*.xml" | (
while IFS= read -r file; do

    sourcepath="$(dirname "$file")" 
    filename="$(basename "$file")"
    filenoext="${filename%.*}"
    echo "Processing "$file""
	namespace=($(exiftool -ProgrammeXmlns -u -b "$sourcepath/${filenoext}.xml"))
	if [[ "${namespace}" == "http://www.digitalproductionpartnership.co.uk/ns/as11/2015" ]] ; then
		as11_namespace="x=http://www.digitalproductionpartnership.co.uk/ns/as11/2015"
	elif [[ "${namespace}" == "http://www.digitalproductionpartnership.co.uk/ns/as11/2013" ]] ; then
		as11_namespace="x=http://www.digitalproductionpartnership.co.uk/ns/as11/2013"
	fi
	echo bla is $as11_namespace
    md5xml=($(xml sel -N $as11_namespace -t -v "//x:Programme/x:Technical/x:Additional/x:MediaChecksumValue" "$sourcepath/${filenoext}.xml"))
	echo $md5xml
    title=($(xml sel -N $as11_namespace -t -v "//x:Programme/x:Editorial/x:ProgrammeTitle" "$sourcepath/${filenoext}.xml"))
    epnum=($(xml sel -N $as11_namespace -t -v "//x:Programme/x:Editorial/x:EpisodeTitleNumber" "$sourcepath/${filenoext}.xml"))
	
    md5mxf=($(md5deep -e "$sourcepath/${filenoext}.mxf"))
    if [[ "${md5xml}" == "" ]] ; then
        echo "Missing checksum in XML, or not a DPP sidecar, or namespace issue"
    elif [[ "${md5xml}" == "${md5mxf}" ]]  ; then
        echo "all is well!"
	echo ""$file","$title","$epnum","$md5xml","$md5mxf", Correct Checksum" >> ~/desktop/"$(basename "$1")".csv
    else 
	echo "something is wrong!"
	echo ""$file","$title","$epnum","$md5xml","$md5mxf",Bad Checksum" >> ~/desktop/"$(basename "$1")".csv
    fi
	
done
)
fi
