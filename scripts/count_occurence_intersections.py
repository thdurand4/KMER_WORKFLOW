# module load python/3.8.2
# Liste pour chaque intersection son nombre de k-mers
#
# Pour donner :
# 123 Acc1 Acc2 Acc3
# 100 Acc1 Acc3
# etc


import re
import argparse
import os


################################
##    PARAMETERS
################################

parser = argparse.ArgumentParser(description='Count nomber of k-mers for each intersection.')

parser.add_argument('--database', help='File wich contains the kmers and their presence in accs  (ex: AAAAAAAAAAAAA	0	1)', required=True)
parser.add_argument('--output', help='Prefix for the output file', required=True)

args = parser.parse_args()
database = args.database
output = args.output

occurence = {} # Contient la liste des ensembles et leur occurence
list_names = []

# Lecture du fichier d'entrée 'database' et mis à jour dans le dic de l'occurence de cet ensemble pour chaque kmer
for line in open(database,'r') :
	line_split = re.split(r'\t+', line.rstrip())

	if line_split[0] == 'KMER' :
		for el in line_split[1:] :
			list_names.append(el)
	else :
		group = ""
		id = 0
		for el in line_split[1:] :
			if float(el) != 0 :
				group +=  "\t" +list_names[id]
			id += 1

		if group in occurence :
			occurence[group] += 1
		else :
			occurence[group] = 1

print('Writing in ', output)

# Ecriture des résultats dans le fichier d'output : KMER	NAME-ACC	NAME-ACC ; par exemple
output_file = open(str(output),'w')


for key in sorted(occurence, key=occurence.get, reverse=True) :
	text = str(occurence[key]) + key + '\n'
	output_file.write(text)

