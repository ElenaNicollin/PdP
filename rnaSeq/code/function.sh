#!/bin/bash

#Permet de creer le fichier log et qualite final en parcourant et concatenant les differents log pour un individu.

ID=$1
LOG_FOLDER=$2
CASE=$3
RUN_NAME=$4
TOOL_FOLDER=Tools
QUALITY_FOLDER=Quality

version_search () {
    grep -ioe '[a-ZA-Z]* - Picard version.*' -e '[a-ZA-Z]* - HTSJDK version.*' -e 'Picard version.*' -e 'version.*[0-9]*' $1    
}

version_from_web () {
    grep -o \<li\>.*[0-9]\</li\> $1 | cut -d '>' -f 2 | cut -d '<' -f 1
}

is_webpage_existing () {
    if test -f $1
    then
        version_from_web $1 >> $2
    else
        echo "Error, version cannot be set up. The webpage might have been changed." >> $2
    fi
}

qualimap_version () {
    /home/Qualimap/./qualimap --help | grep v\.[0-9]\.[0-9]\.[0-9]
}

get_cmd_line () {
    if echo "$2" | grep "+"
    then
        BQSR=$(echo "$2" | cut -d '+' -f 1)
        APPLY=$(echo "$2" | cut -d '+' -f 2)
    fi
    grep -oe "CMD.*" -e "\-threads.*" -e "\*.*"$2".*" -e "java \-.*"$2".*" -e "java \-.*"$BQSR".*" -e "java \-.*"$APPLY".*" $1
}

link_family_to_sample () {
    FAMILY_ID=$1
    SAMPLE_ID=$2
    for file in $FAMILY_ID
    do
        if grep -q "$SAMPLE_ID" $file
        then
            ID_MAP=$(echo $(basename $file) | cut -d '.' -f 1)
            create_log $ID_MAP $SAMPLE_ID.log "$SAMPLE_ID"_qualite.txt
        fi
    done
}

create_log () {
    SAMPLE=$1
    LOG=$2
    QUALITY=$3
    RUN=$4
    printf "Nom du run : %s\nNumero patient : %s\nDate : %s" "$RUN" "$SAMPLE" "$(date)" | tee -a "$LOG_FOLDER"/"$TOOL_FOLDER"/$LOG "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY > /dev/null
    
    for FILENAME in /home/Log/*"$SAMPLE"*.log
    do
        BENCHMARK=$(echo /home/Benchmark/$(echo $(basename $FILENAME) | cut -d '.' -f 1).txt)
        TOOL=$(echo $(basename $FILENAME) | cut -d '_' -f 2)
        if echo $(basename $FILENAME) | grep -qe 01.*"$SAMPLE".*R1.* -e 04.*"$SAMPLE".*R1.*
        then
            printf "\n\n\n############################################################$TOOL############################################################\n" >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
            printf "\n\n\n############################################################$TOOL############################################################\n" >> "$LOG_FOLDER"/"$TOOL_FOLDER"/$LOG
            if echo $(basename $FILENAME) | grep -q 01.*"$SAMPLE".*R1.*
            then
                grep -o 'version.*[0-9]' /home/OutputFiles/QC/1-BeforeTrimming/*"$SAMPLE"*R1*.html >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
            else
                grep -o 'version.*[0-9]' /home/OutputFiles/QC/2-AfterTrimming/*"$SAMPLE"*R1*.html >> "$LOG_FOLDER"/"$TOOL_FOLDER"/$LOG
            fi
            PARAMS=$(grep ""$TOOL"_.*parameters : .*" /home/Utils/config.yaml | cut -d ':' -f 2)
            printf "\nCMD : $TOOL $PARAMS" >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
        elif echo $(basename $FILENAME) | grep -qv '^0[58]'
        then
            printf "\n\n\n############################################################$TOOL############################################################\n" >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
            printf "\n\n\n############################################################$TOOL############################################################\n" >> "$LOG_FOLDER"/"$TOOL_FOLDER"/$LOG
            if echo $(basename $FILENAME) | grep -q 03.*"$SAMPLE".*
            then
                is_webpage_existing /home/Utils/pe.html "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
                get_cmd_line $FILENAME $TOOL >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
            elif echo $(basename $FILENAME) | grep -qe 07.*"$SAMPLE".* -e 071.*"$SAMPLE".* -e 8.*"$SAMPLE".* -e 10.*"$SAMPLE".* -e 16.*"$SAMPLE".* -e 17.*"$SAMPLE".*
            then
                is_webpage_existing /home/Utils/view.html "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
                if echo $(basename $FILENAME) | grep -q 8.*"$SAMPLE".*
                then
                    FLAGSTAT=$(echo $(basename $FILENAME) | cut -d '.' -f 1)
                    cat /home/OutputFiles/QC/3-FlagstatReadsMapped/"$FLAGSTAT".txt >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
                elif echo $(basename $FILENAME) | grep -q 10.*"$SAMPLE".*
                then
                    FLAGSTAT=$(echo $(basename $FILENAME) | cut -d '.' -f 1)
                    cat /home/OutputFiles/QC/5-FlagstatMarkDuplicates/"$FLAGSTAT".txt >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
                elif echo $(basename $FILENAME) | grep -q 16.*"$SAMPLE".*
                then
                    FLAGSTAT=$(echo $(basename $FILENAME) | cut -d '.' -f 1)
                    cat /home/OutputFiles/QC/6-FlagstatBQSR/"$FLAGSTAT".txt >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
                fi
                printf "\nCMD : "$TOOL" $(grep -i ""$TOOL"_parameters : .*" /home/Utils/config.yaml | cut -d ':' -f 2)" >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
            elif echo $(basename $FILENAME) | grep -qe 12.*"$SAMPLE".* -qe 15.*"$SAMPLE".*
            then
                qualimap_version >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
            else
                version_search $FILENAME >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
                printf "\n\nCMD :\n" >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
                get_cmd_line $FILENAME $TOOL >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
            fi
        fi
        printf "\n\nBenchmarking :\n" >> "$LOG_FOLDER"/"$TOOL_FOLDER"/$LOG
        cat $BENCHMARK >> "$LOG_FOLDER"/"$TOOL_FOLDER"/$LOG
        printf "\n\nBenchmarking :\n" >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
        cut $BENCHMARK -f 2 >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
        printf "\n\n" >> "$LOG_FOLDER"/"$TOOL_FOLDER"/$LOG 
        cat $FILENAME >> "$LOG_FOLDER"/"$TOOL_FOLDER"/$LOG 
    done
}

add_config_file () {
    QUALITY=$1
    printf "\n\n\n############################################################Pipeline configuration file############################################################\n"  >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
    cat /home/Utils/config.yaml >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
    printf "\n\n\n############################################################Aligner configuration file############################################################\n"  >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
    MAPPING=$(grep -o "/.*/Rules/Mapping/.*/" /home/Utils/config.yaml)
    cat "$MAPPING"config.yaml >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
    printf "\n\n\n############################################################Variant calling configuration file############################################################\n"  >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
    VARIANTCALLING=$(grep -o "/.*/Rules/VariantCalling/.*/" /home/Utils/config.yaml)
    VC_NB=$(echo $VARIANTCALLING | grep -o "," | wc -l)
    if [ $VC_NB -eq 0 ]
    then
        cat "$VARIANTCALLING"config.yaml >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
    else
        VC_NB=$((VC_NB + 2))
        for ((i=1; i<=$VC_NB; i+=2))
        do
            VC=$(echo $VARIANTCALLING | cut -d '"' -f $i | grep -o /.*/Rules/VariantCalling/.*/)
            cat "$VC"config.yaml >> "$LOG_FOLDER"/"$QUALITY_FOLDER"/$QUALITY
        done
    fi
}

mkdir -p "$LOG_FOLDER"/"$QUALITY_FOLDER" 2> /dev/null
mkdir -p "$LOG_FOLDER"/"$TOOL_FOLDER" 2> /dev/null

if [ "$CASE" == "SAMPLE" ]
then
    create_log $ID $ID.log "$ID"_qualite.txt $RUN_NAME
    FAMILY=$(find /home/OutputFiles/SampleMap/ -type f -name "*.sample_map")
    link_family_to_sample $FAMILY $ID
else
    FAMILY=$(find /home/OutputFiles/SampleMap/ -type f -name "*.sample_map")
    link_family_to_sample $FAMILY $ID
fi
add_config_file "$ID"_qualite.txt
