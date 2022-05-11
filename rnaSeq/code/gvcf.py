import pandas as pd
from individual import *
from index import *
import pickle

#Creation des objets a partir du fichier formulaire.

def read(path):
    return pd.read_csv(path, delimiter = "\t")

#Cree les objets CI et leur associe une liste d'individu apparente.
def createObjects(df):
    casindex = []
    for row in df.iterrows():
        if row[1]["Lien de parente"] in ["Fils", "Fille"] and isIllness(row[1]["atteint"]):
            i = Index(row[1]["ID"], row[1]["ID famille"], isMale(row[1]["sexe"]), "enfant", isIllness(row[1]["atteint"]), "/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/" + str(row[1]["ID"]) + ".g.vcf.gz", {})
            ci = findRelated(i, df)
            casindex.append(ci)
    return casindex

#Trouve les apparentes et cree un objet individu et le stocke soit en attribut pere ou mere soit dans apparente (liste d'individus).
def findRelated(ci, df):
    related = df.loc[(df["ID famille"] == ci.familyID) & (df["ID"] != ci.sampleID)]
    ci.apparente = []
    for row in related.iterrows():
        if row[1]["Lien de parente"] == "Mere":
            ci.mere = Individual(row[1]["ID"], row[1]["ID famille"], isMale(row[1]["sexe"]), "mere", isIllness(row[1]["atteint"]), "/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/" + str(row[1]["ID"]) + ".g.vcf.gz")
        elif row[1]["Lien de parente"] == "Pere":
            ci.pere = Individual(row[1]["ID"], row[1]["ID famille"], isMale(row[1]["sexe"]), "pere", isIllness(row[1]["atteint"]), "/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/" + str(row[1]["ID"]) + ".g.vcf.gz")
        else:
            if row[1]["Lien de parente"] not in ["Fils", "Fille"]:
                ci.apparente.append(Individual(row[1]["ID"], row[1]["ID famille"], isMale(row[1]["sexe"]), row[1]["Lien de parente"], isIllness(row[1]["atteint"]), "/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/" + str(row[1]["ID"]) + ".g.vcf.gz"))
            elif row[1]["Lien de parente"] == "Fils" and isIllness(row[1]["atteint"]):
                ci.apparente.append(Index(row[1]["ID"], row[1]["ID famille"], isMale(row[1]["sexe"]), "frere", isIllness(row[1]["atteint"]), "/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/" + str(row[1]["ID"]) + ".g.vcf.gz", {}))
            elif row[1]["Lien de parente"] == "Fille" and isIllness(row[1]["atteint"]):
                ci.apparente.append(Index(row[1]["ID"], row[1]["ID famille"], isMale(row[1]["sexe"]), "soeur", isIllness(row[1]["atteint"]), "/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/" + str(row[1]["ID"]) + ".g.vcf.gz", {}))
            elif isMale(row[1]["sexe"]):
                ci.apparente.append(Individual(row[1]["ID"], row[1]["ID famille"], isMale(row[1]["sexe"]), "frere", isIllness(row[1]["atteint"]), "/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/" + str(row[1]["ID"]) + ".g.vcf.gz"))
            else:
                ci.apparente.append(Individual(row[1]["ID"], row[1]["ID famille"], isMale(row[1]["sexe"]), "soeur", isIllness(row[1]["atteint"]), "/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/" + str(row[1]["ID"]) + ".g.vcf.gz"))
    setAnalysisType(ci)
    pickle.dump(ci, open("/home/OutputFiles/" + str(ci.sampleID) + ".pickle", "wb"))
    return ci

#definit le type d'analyse pour le CI.
def setAnalysisType(ci):
    if ci.pere and ci.mere:
        ci.type_analyse = "trio"
    elif ci.pere or ci.mere:
        ci.type_analyse = "duo"
    elif len(ci.apparente) == 0:
        ci.type_analyse = "simplex"
    else:
        ci.type_analyse = "autre"
    
def isMale(value):
    if value == "M":
        return True
    return False

def isIllness(value):
    if value == "Oui":
        return True
    return False

#Creer un fichier sample par trio ou simplex. Permet de realiser le joint calling avec GenomicsDBImport
def create_sample_map(path_file, path_map, all=False):
    obj_list = createObjects(read(path_file))
    for index in obj_list:
        index.sample_map(path_map, all)
    return obj_list
    

def sampleList(familyID, listIndex):
    trio = []
    for index in listIndex:
        if index.familyID == familyID:
            related = index.getRelated()
            for relationship in related:
                trio.append(relationship.path_Ivcf)
            trio.append(index.path_Ivcf)
            return trio

#Identifie les CI
def wildcard(df):
    sampleID = []
    for row in df.iterrows():
        if row[1]["Lien de parente"] in ["Fils", "Fille"] and isIllness(row[1]["atteint"]):
            sampleID.append(row[1]["ID"])
    return sampleID
