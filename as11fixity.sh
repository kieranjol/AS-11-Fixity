#!/bin/bash 
#http://stackoverflow.com/a/15930450/2188572
#only look for xml files in all directories below your chosen directory
if [ -f ~/desktop/"$1.csv" ]; then
	echo “CSV file already exists. Aborting“ ;
	exit 1
else
echo "Filename,Title,Episode_Number,Md5_From_Xml,Md5_from_Mxf,Checksum_Result" >> ~/desktop/"$1.csv" 
find "$1" -name "*.xml" | (
while IFS= read -r file; do

    sourcepath="$(dirname "$file")" 
    filename="$(basename "$file")"
    filenoext="${filename%.*}"
    echo "Processing "$file""
    md5xml=($(xml sel -N 'x=http://www.digitalproductionpartnership.co.uk/ns/as11/2013' -t -v "//x:Programme/x:Technical/x:Additional/x:MediaChecksumValue" "$sourcepath/${filenoext}.xml"))
    title=($(xml sel -N 'x=http://www.digitalproductionpartnership.co.uk/ns/as11/2013' -t -v "//x:Programme/x:Editorial/x:ProgrammeTitle" "$sourcepath/${filenoext}.xml"))
    epnum=($(xml sel -N 'x=http://www.digitalproductionpartnership.co.uk/ns/as11/2013' -t -v "//x:Programme/x:Editorial/x:EpisodeTitleNumber" "$sourcepath/${filenoext}.xml"))
	
    md5mxf=($(md5deep -e "$sourcepath/${filenoext}.mxf"))
    if [[ "${md5xml}" == "" ]] ; then
        echo "not a sidecar"
    elif [[ "${md5xml}" == "${md5mxf}" ]]  ; then
        echo "all is well!"
	echo ""$file","$title","$epnum","$md5xml","$md5mxf", Correct Checksum" >> ~/desktop/"$1.csv"
    else 
	echo "something is wrong!"
	echo ""$file","$title","$epnum","$md5xml","$md5mxf",Bad Checksum" >> ~/desktop/"$1.csv"
    fi
	
done
)
fi
