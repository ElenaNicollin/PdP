# Projet de Programmation

Ce code est la propriété de BERNACHOT Léa, GERBER Zoé, HENNI Mélissa, et NICOLLIN Elena.

Il a été produit pour le Projet de Programmation 2022, dans le cadre du Master 1 de Bio-Informatique de Bordeaux. Nous avons travaillé sous la direction de nos clients GASTON Laetitia et MICHAUD Vincent, membres du Laboratoire de Génétique Biologique du CHU de Bordeaux. Nous étions également encadrées par notre enseignant KARKAR Slim.

## Préambule
Ces pipelines nécessitent l'installation de Docker.

Certaines données nécessaires à l'exécution sont confidentielles et ne peuvent donc pas être fournies. Des données libres d'accès sont néanmoins accessibles en ligne, et devraient 

## Utilisation du pipeline expression
Les commandes à exécuter dans le terminal sont dans le fichier *cmd_expression.sh*.

L'exécution du script R à l'intérieur du pipeline n'est pas fonctionnelle. Un fichier alternatif, *plots_brut.R*, est mis à disposition pour fonctionner en dehors du pipeline. Il nécessite des fichiers GTF, des fichiers BAM, un génome au format GTF, et le fichier *sample_info.csv*.


## Utilisation du pipeline vcfMerge
Les commandes à exécuter dans le terminal sont dans le fichier *cmd_merge.sh*.

Deux fichiers VCF sont fournis dans le dossier data.

Un fichier *raw_data.csv* est fourni pour pouvoir exécuter *split_excel.py*. Il est à placer dans le dossier de fichiers en sortie.
