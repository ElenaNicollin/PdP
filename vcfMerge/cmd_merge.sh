#Pour créer une image du code
img_name=<nom de limage> #exemple ghcr.io/elenanicollin/vcfmerge:0.0.0

sudo docker build -t $img_name .
sudo docker push $img_name
sudo docker run -p 8080:80 $img_name

## Pour créer un container
run_name=<nom du container>

vcf_dir=<dossier des fichiers .vcf>
output_dir=<dossier pour fichiers en sortie>

docker run -dit --name $run_name --rm -v "$vcf_dir":/home/VCF/ -v "$output_dir":/home/OutputFiles/ "$img_name"

## Pour executer le container
docker exec $run_name python -u /home/Utils/pipeline.py -f /home/Config/config.txt -c 31 -n $run_name