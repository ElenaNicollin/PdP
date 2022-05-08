#Pour créer une image du code
img_name=<nom de limage> #exemple ghcr.io/elenanicollin/expression:0.0.0

sudo docker build -t $img_name .
sudo docker push $img_name
sudo docker run -p 8080:80 $img_name

## Pour créer un container
run_name=<nom du container>

pheno_data=<fichier .csv avec données phénotypiques>
bam_dir=<dossier des fichiers .bam>
genome_dir=<dossier du génome> #un génome en .gff, un en .gtf
#passer de .gtf à .gff : sed 's/;/\";/g;s/gene_id /gene_id \"/g;s/transcript_id /transcript_id \"/g' <genome.gtf> > <genome.gff>

config_path=<fichier .txt avec paramètres>
output_dir=<dossier pour fichiers en sortie>

docker run -dit --name $run_name --rm -v "$bam_dir":/home/BAM/ -v "$genome_dir":/home/Genome/ -v "$pheno_data":/home/Data/pheno_data.csv -v "$output_dir":/home/OutputFiles/ -v "$config_path":/home/Config/config.txt "$img_name"

## Pour executer le container
docker exec $run_name python -u /home/Utils/pipeline.py -f /home/Config/config.txt -c 31 -n $run_name