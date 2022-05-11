url() {
    curl $1 -s -L -I -o /dev/null -w '%{url_effective}' > gatk.txt
    sed -i -e 's/tag/download/g' gatk.txt
    version=$(cat gatk.txt | rev | cut -d "/" -f 1 | rev)
    if [ $(echo "$version") != "4.1.8.0" ]
    then
        mkdir /home/version/
        printf "New version available for GATK\n" >> /home/version/new_version.txt
        printf "Current version : 4.1.8.0\n" >> /home/version/new_version.txt
        printf "Latest version : $version\n\n" >> /home/version/new_version.txt
    fi
    rm gatk.txt
}

url $1