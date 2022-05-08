import xlsxwriter
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--infile", help="Filepath")
parser.add_argument("-o", "--outfile", help="Filepath")
args = parser.parse_args()
path_vcf = args.infile
path_excel = args.outfile
    

def write_line(list,row,worksheet):
    for i in range(0,len(list)):
        worksheet.write(row, i, list[i])


workbook = xlsxwriter.Workbook(path_excel)
worksheet = workbook.add_worksheet('Sheet')
filename = path_vcf
file = open(filename, "r")  
line = file.readline()
row=0
for line in file:
    if line[1] == '#':
        continue                #skip header
    line=line.split('\t')
    if row == 0:
        line[0] = line[0][1:]   #remove the '#' from the line of column names
    write_line(line,row,worksheet)
    row += 1
file.close()
workbook.close()