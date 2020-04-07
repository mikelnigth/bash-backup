#!/bin/bash
#
#
#
#   --------------------------------------------------
#
#   Autor: Miquel Servera
#   Descripción:	Backup setting the variables SOURCE, DESTINATION, EXCEPTION and as paramether the function (inc or full).
#               	Destination folder exist -> the destination folder will have and suffix _(numer of copies)
#               	Incremental backup without new files to copy -> the destination folder will have the suffix: "no_files"
#
#   --------------------------------------------------
#
#
#
#   ----- Variables to set up -----
#
SOURCE=/home/user/
DESTINATION=/media/user/HDD_EXTERNAL
EXCEPTIONS=/home/user/exceptions.txt
#
#   --------------------------------------------------
#
#
#
#   ----- Variables for the script -----
#
HOST=`hostname`
DATE=`date +%F`                                     # format: yyyy-mm-dd -> 2017-09-05
#
FUNCTION=$1                                         # function introduced as paramether (full / inc)
#
#   --------------------------------------------------
#
#
#
#   ----- Paramether error -----
if [ "$FUNCTION" != 'full' ] && [ "$FUNCTION" != 'inc' ]; then
	echo "Function error"
	exit
fi
#
#
#
#   ----- Define destination folder name with functions as suffix -----
if [ "$FUNCTION" == 'full' ]; then
	echo "Function FULL"
    F_DESTINATION=$DESTINATION'/'$DATE---FULL
	DUPLICATE=2
	while [ -e $F_DESTINATION ]
	do
		echo "The folder "$F_DESTINATION" already exists"
        while [ -e $F_DESTINATION"_"$DUPLICATE ]
        do
            echo "The folder "$F_DESTINATION"_"$DUPLICATE" already exists"
            DUPLICATE=`expr $DUPLICATE + 1`
            echo $DUPLICATE
		done
		F_DESTINATION=$F_DESTINATION'_'$DUPLICATE
	done
fi
#
if [ "$FUNCTION" == 'inc' ]; then
	echo "Function INC"
    F_DESTINATION=$DESTINATION'/'$DATE---inc
	DUPLICATE=2
	while [ -e $F_DESTINATION ]
	do
		echo "The folder "$F_DESTINATION" already exists"
        while [ -e $F_DESTINATION"_"$DUPLICATE ]
        do
            echo "The folder "$F_DESTINATION"_"$DUPLICATE" already exists"
            DUPLICATE=`expr $DUPLICATE + 1`
		done
		F_DESTINATION=$F_DESTINATION'_'$DUPLICATE
	done
    LIST=$F_DESTINATION/list.txt                    #List for incremental backup (files edited last 48h)
fi
#
#
#
# Setting variables
LOG_P=$F_DESTINATION/log_provisional.txt
LOG=$F_DESTINATION/log_copia.txt
# Capture the initial time
D_INICIO=`date +%d-%m-%y"     "%H:%M:%S`
#
#
#
# Create destination folder
mkdir $F_DESTINATION
#
#
#
#   ----- Backups -----
if [ "$FUNCTION" == 'full' ]; then
    echo "Starting backup"                           > /dev/pts/0
	cp -Rv $SOURCE $F_DESTINATION                   >> $LOG_P
	echo "Backup finished"                           > /dev/pts/0
fi
#
if [ "$FUNCTION" == 'inc' ]; then
#
# Listamos los archivos editados desde hace un día
    echo "Listing files to copy"                     > /dev/pts/0
    find $SOURCE -type f -mtime -2                  >> $LIST
	if [[ -s $LIST ]] ; then
		# If the file is not empty
		cp $EXCEPTIONS $F_DESTINATION
		# We do the backup
		echo "Starting backup"                                                    > /dev/pts/0
		tar -X $EXCEPTIONS -h -czvf $F_DESTINATION/backup.tgz --files-from $LIST >> $LOG_P
		echo "Backup finished"                                                    > /dev/pts/0	

	else
		# If the files is empty
		rm -r $F_DESTINATION
		mkdir $F_DESTINATION---sin_archivos_copiados
		exit
	fi
#
fi
#
#
#
# Capture the finish time
D_FIN=`date +%d-%m-%y"     "%H:%M:%S`
# Count copied files
FILES=`more $LOG_P | grep '/' | wc -l`
#
#
#
# Count types of files per extension
# ----- Systems -----
L_SCRIPT_LINUX=`more $LOG_P | grep '/' | grep '.sh$' | wc -l`
L_SCRIPT_WINDOWS=`more $LOG_P | grep '/' | grep '.bat$' | wc -l`
# ----- Office -----
L_TEXT_M=`more $LOG_P | grep '/' | grep '.docx$' | wc -l`
L_CALC_M=`more $LOG_P | grep '/' | grep '.xlsx$' | wc -l`
L_PRES_M=`more $LOG_P | grep '/' | grep '.pptx$' | wc -l`
L_TEXT_L=`more $LOG_P | grep '/' | grep '.odt$' | wc -l`
L_CALC_L=`more $LOG_P | grep '/' | grep '.ods$' | wc -l`
L_PRES_L=`more $LOG_P | grep '/' | grep '.odg$' | wc -l`
L_TEXT_S=`more $LOG_P | grep '/' | grep '.txt$' | wc -l`
L_PDF=`more $LOG_P | grep '/' | grep '.pdf$' | wc -l`
# ----- Software -----
L_OS=`more $LOG_P | grep '/' | grep '.iso$' | wc -l`
L_HTML=`more $LOG_P | grep '/' | grep '.html$' | wc -l`
L_XML=`more $LOG_P | grep '/' | grep '.xml$' | wc -l`
L_PHP=`more $LOG_P | grep '/' | grep '.php$' | wc -l`
L_JAVA=`more $LOG_P | grep '/' | grep '.java$' | wc -l`
L_JAVA_S=`more $LOG_P | grep '/' | grep '.js$' | wc -l`
#
#
#
# Genere the final report
#
echo "Generating report"                                     > /dev/pts/0
echo														>> $LOG
echo Host:"       	"$HOST                                  >> $LOG
echo														>> $LOG
echo Started:"      "$D_INICIO                              >> $LOG
echo Finished:"   	"$D_FIN                                 >> $LOG
echo														>> $LOG
echo Source:"       "$SOURCE                                >> $LOG
echo Destination:"  "$DESTINATION                           >> $LOG
echo														>> $LOG
echo Archivos:"     "$FILES									>> $LOG
echo														>> $LOG
echo ------------------------------                         >> $LOG
echo														>> $LOG
more $LOG_P													>> $LOG
echo														>> $LOG
echo ------------------------------							>> $LOG
echo														>> $LOG
echo ----- Systems -----									>> $LOG
echo Script Linux :"         "$L_SCRIPT_LINUX				>> $LOG
echo Script Winddows :"      "$L_SCRIPT_WINDOWS				>> $LOG
echo														>> $LOG
echo ----- Office -----										>> $LOG
echo Microsoft Word :"       "$L_TEXT_M						>> $LOG
echo Microsoft Excel :"      "$L_CALC_M						>> $LOG
echo Microsoft Powerpoint :" "$L_PRES_M						>> $LOG
echo LibreOffice Write :"    "$L_TEXT_L						>> $LOG
echo LibreOffice Calc :"     "$L_CALC_L						>> $LOG
echo LibreOffice Impress :"  "$L_PRES_L						>> $LOG
echo Texto simple :"         "$L_TEXT_S						>> $LOG
echo PDF :"                  "$L_PDF						>> $LOG
echo														>> $LOG
echo ----- Software -----									>> $LOG
echo Operative System :"     "$L_OS							>> $LOG
echo HTML :"                 "$L_HTML						>> $LOG
echo XML :"                  "$L_XML						>> $LOG
echo PHP :"                  "$L_PHP						>> $LOG
echo Java :"                 "$L_JAVA						>> $LOG
echo Java Script :"          "$L_JAVA_S						>> $LOG
echo														>> $LOG
echo														>> $LOG
echo ------------------------------							>> $LOG
echo														>> $LOG
echo END													>> $LOG
echo														>> $LOG
echo "Report finished"			        	 				 > /dev/pts/0
#
#
# Removing temporally files
rm $LOG_P
#
#
exit
#
#
#	
#   --------------------------------------------------
