import os
from individual import Individual

class Index(Individual):
    """  Informations exclusive to index case

        Attribute :
        pere : individual object
        mere : individual object
        type_analyse : simplex, trio or others
        apparente (list) : key is sampleID and value is type of relationship
    """

    def __init__(self, sampleID, familyID, sexe, link, illness, path_Ivcf, df, pere=None, mere=None, type_analyse=None, apparente=None):
        super().__init__(sampleID, familyID, sexe, link, illness, path_Ivcf)
        self.pere = pere
        self.mere = mere
        self.type_analyse = type_analyse
        self.apparente=apparente
        self.df = df
    
    def sample_map(self, path_map, all=False):
        if all:
            path = path_map + "cohort.sample_map"
        else:
            path = path_map + str(self.sampleID) + ".sample_map"
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "a") as f:
            line = str(self.sampleID) + "\t" + self.path_Ivcf + "\n"
            if not self.check_sample_map(path, line):
                f.write(line)
                if self.mere:
                    f.write(str(self.mere.sampleID) + "\t" + self.mere.path_Ivcf + "\n")
                if self.pere:
                    f.write(str(self.pere.sampleID) + "\t" + self.pere.path_Ivcf + "\n")
                for related in self.apparente:
                    f.write(str(related.sampleID) + "\t" + related.path_Ivcf + "\n")
                f.close()

    def check_sample_map(self, sample_map, path_vcf):
        f = open(sample_map, "r")
        path_vcfs = f.readlines()
        if path_vcf in path_vcfs:
            return True
        return False
