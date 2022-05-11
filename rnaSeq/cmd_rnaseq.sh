#Pour créer une image du code
img_name=<nom de limage> #exemple ghcr.io/elenanicollin/rnaseq:0.0.0

sudo docker build -t $img_name .
sudo docker push $img_name
sudo docker run -p 8080:80 $img_name

## Pour créer un container
run_name=<nom du container>

snp_dir=<dossier contenant les snp>
fastq_dir=<dossier avec les fastq>
bed_dir=<dossier avec les bed>
genome_dir=<dossier avec le genome indexé>
panel_dir=<dossier avec les panel>

formulaire_path=<fichier formulaire>
config_path=<fichier .txt avec paramètres>

output_dir=<dossier pour fichiers en sortie>

docker run -dit --name $run_name --rm -v "$snp_dir":/home/SNP/ -v "$genome_dir":/home/Genome/ -v "$fastq_dir"/Fastq_reads:/home/Data/FastQ/ -v "$formulaire_path":/home/SampleSheet/formulaire.txt -v "$output_dir":/home/OutputFiles/ -v "$config_path":/home/Config/config.txt -v "$bed_dir":/home/Bed/ -v "$panel_dir":/home/Panels/ "$img_name"

## Pour executer le container
docker exec $run_name python -u /home/Utils/pipeline.py -f /home/Config/config.txt -c 31 -n $run_name
