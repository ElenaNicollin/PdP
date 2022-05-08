import xlsxwriter
import pandas as pd
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--infile", help="Filepath")
parser.add_argument("-o", "--outfile", help="Filepath")
parser.add_argument("-p", "--putfile", help="Filepath")
args = parser.parse_args()
path_input = args.infile
path_concor = args.outfile
path_discor = args.putfile

def write_header(sheet,header):
    for i in range (len(header)):
        sheet.write(0,i,header[i])

def add_row(dict_sheets,sheet_name,line):
    sheet = dict_sheets[sheet_name]['ref']
    row = dict_sheets[sheet_name]['row']
    for j in range(len(line)):
        sheet.write(row,j,line[j])
    dict_sheets[sheet_name]['row']+=1



concor = xlsxwriter.Workbook(path_concor) 
discor = xlsxwriter.Workbook(path_discor)
df = pd.read_excel(path_input)
header=list(df.columns)
concor_sheets={}
discor_sheets={}

for i in range(len(df)):
    line=list(df.iloc[i])
    consequences=line[11].split(",")
    if line[9][0] != '.' and line[10][0] != '.':
        for cons in consequences:
            sheet_name=cons[:31]
            if sheet_name not in concor_sheets.keys():
                sheet = concor.add_worksheet(sheet_name)
                concor_sheets[sheet_name]={'ref':sheet,'row':1}
                write_header(sheet,header)
            add_row(concor_sheets,sheet_name,line)
    else:
        for cons in consequences:
            sheet_name=cons[:31]
            if sheet_name not in discor_sheets.keys():
                sheet = discor.add_worksheet(sheet_name)
                discor_sheets[sheet_name]={'ref':sheet,'row':1}
                write_header(sheet,header)
            add_row(discor_sheets,sheet_name,line)

concor.close()
discor.close()