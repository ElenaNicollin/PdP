rule all:
    input:
        "/home/OutputFiles/DNA_RNA_merged.xlsx",
        "/home/OutputFiles/Concordant.xlsx",
        "/home/OutputFiles/Discordant.xlsx"

rule to_vcf:
    input:
        "/home/OutputFiles/DNA_RNA_merged.vcf"
    output:
        "/home/OutputFiles/DNA_RNA_merged.xlsx"
    shell:
        "python /home/Utils/vcf_to_excel.py -i {input} -o {output}"

rule split_excel:
    input:
        "/home/OutputFiles/raw_data.xlsx"
    output:
        concor="/home/OutputFiles/Concordant.xlsx",
        discor="/home/OutputFiles/Discordant.xlsx"
    shell:
        "python /home/Utils/excel_split.py -i {input} -o {output.concor} -p {output.discor}"
