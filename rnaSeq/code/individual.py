class Individual:
    """ Common informations between index and related

        Attributes :
            sex (str)
            sampleID (str)
            familyID (str)
            sex (str)
            illness (bool)
            link (str)
            path_Ivcf (str) : path of the final vcf
    """

    def __init__(self, sampleID, familyID, sexe, link, illness, path_Ivcf):
        self.sampleID = sampleID
        self.familyID = familyID
        self.sexe = sexe
        self.link = link
        self.illness = illness
        self.path_Ivcf = path_Ivcf