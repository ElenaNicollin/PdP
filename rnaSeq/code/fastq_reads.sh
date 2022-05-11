#Permet d'extraire le nombre de reads presents dans les fastq apres trimming. Le rajoute dans le premier fichier issu de FlagStat.

R1_PAIRED=$1
R1_UNPAIRED=$2
R2_PAIRED=$3
R2_UNPAIRED=$4
FLAGSTAT=$5
OUTPUT=$6

count () {

    DIR_EXTRACT=$(echo $1 | grep -o "/.*/")

    unzip -qq $1 -d $DIR_EXTRACT

    DIR=$(echo $1 | cut -d '.' -f 1)

    COUNT=$(grep -oP 'Total\sSequences\s\K([0-9]*)' "$DIR"_fastqc/fastqc_data.txt)

    if [ $4 == "P" ]
    then
        if echo $1 | grep "R1"
        then
            printf "\nFastQ_R1_Paired : "$COUNT"" >> $2
        else
            printf "\nFastQ_R2_Paired : "$COUNT"" >> $2
        fi
    else
        if echo $1 | grep -q "R1"
        then
            printf "\nFastQ_R1_Unpaired : "$COUNT"" >> $2
        else
            printf "\nFastQ_R2_Unpaired : "$COUNT"" >> $2
        fi
    fi

    touch $3

    rm -rf "$DIR"_fastqc/
}


count $R1_PAIRED $FLAGSTAT $OUTPUT P
count $R1_UNPAIRED $FLAGSTAT $OUTPUT U

count $R2_PAIRED $FLAGSTAT $OUTPUT P
count $R2_UNPAIRED $FLAGSTAT $OUTPUT U
