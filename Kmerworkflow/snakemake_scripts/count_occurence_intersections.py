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
from collections import defaultdict
import gzip

################################
##    PARAMETERS
################################

parser = argparse.ArgumentParser(description='Count nomber of k-mers for each intersection.')

parser.add_argument('--database',
                    help='File wich contains the kmers and their presence in accs  (ex: AAAAAAAAAAAAA	0	1)',
                    required=True)
parser.add_argument('--output', help='Prefix for the output file')
parser.add_argument('--exclude', help='File wich contains accs to exclude')
parser.add_argument('--start', help='First column to keep')
parser.add_argument('--end', help='Last column to keep')
parser.add_argument('--graph', help='Last column to keep')
parser.add_argument('--full_table', help='Say yes or no')
parser.add_argument('--path', help='PATH to fasta sequences', required=True)

args = parser.parse_args()
database = args.database
f_exclude = args.exclude
# output = args.output
start = args.start
end = args.end
graph = args.graph
full_table = args.full_table
path = args.path

output = args.output

occurence = {}  # Contient la liste des ensembles et leur occurence
list_names = []
seq_acc = defaultdict(list)
accs = []
accession_exclude = []
index_keep = []
name_file = []
all_file = []
intersect = []

singleton = set()

os.system("mkdir -p " + path)
os.system("mkdir -p " + path + "/SINGLETON")
os.system("mkdir -p " + path + "/INTERSECTION")

# Lecture du fichier d'entrée 'database' et mis à jour dans le dic de l'occurence de cet ensemble pour chaque kmer

if f_exclude:
    for line in open(f_exclude, 'r'):
        accession_exclude.append(line.rstrip())
    for line in gzip.open(database, 'rt'):
        line_split = re.split(r'\t+', line.rstrip())
        if line_split[0] == 'KMER':
            for index, el in enumerate(line_split[1:]):
                if el not in accession_exclude:
                    list_names.append(el)
                    index_keep.append(index)
            # print(list_names)
        else:
            group = ""
            i = 0
            for index, el in enumerate(line_split[1:]):
                if index in index_keep:
                    if float(el) != 0:
                        group += "\t" + list_names[i]
                        #print(group)
                    i = i + 1
            if group != "":
                seq_acc[group].append(line_split[0])
                if group in occurence and group != "":
                    occurence[group] += 1
                else:
                    occurence[group] = 1



else:
    for line in gzip.open(database, 'rt'):
        line_split = re.split(r'\t+', line.rstrip())
        if line_split[0] == 'KMER':
            for el in line_split[1:]:
                list_names.append(el)
        else:
            group = ""
            id = 0
            for el in line_split[1:]:
                if float(el) != 0:
                    group += "\t" + list_names[id]
                id += 1
            seq_acc[group].append(line_split[0])
            if group in occurence:
                occurence[group] += 1
            else:
                occurence[group] = 1
if full_table == "yes":
    print('Writing in ', output)
# print(seq_acc)
# Ecriture des résultats dans le fichier d'output : KMER	NAME-ACC	NAME-ACC ; par exemple

if full_table == "yes":
    output_file = open(str(output), 'w')

i = 0
for key in sorted(occurence, key=occurence.get, reverse=True):
    text = str(occurence[key]) + "\t" + str(i + 1) + "_" + str(occurence[key]) + ".fasta" + key + '\n'
    all_file.append(text)
    if full_table == "yes":
        output_file.write(text)
    i += 1

if full_table == "yes":
    output_file.close()

test2 = open(str(graph), 'w')
j = 0
g = 0
for elem in all_file:
    if (elem.count("\t")) > 2:
        j = j + 1
        if int(start) <= j <= int(end):
            intersect.append(elem)
            test2.write(elem)
        elif j > int(end):
            break

fasta = []
for lignes in intersect:
    lignes = lignes.rstrip("\n")
    # print(lignes)
    yop = re.sub("\d+\t\d+_\d+.fasta\t", "\t", lignes)
    nb_kmer = lignes.split("\t")
    name_file.append(nb_kmer[0])
    # print(yop)
    accs.append(yop)
    fasta.append(nb_kmer[1])
    print(nb_kmer[1])
    for elem in nb_kmer[2:]:
        reform = re.sub("^", "\t", elem)
        # print(reform)
        singleton.add(reform)

# singleton.add(yop2.rstrip())

for index, elem in enumerate(accs):
    for single in singleton:
        if elem == single:
            accs.remove(elem)
            name_file.remove(name_file[index])

i = 0
for k in sorted(seq_acc, key=occurence.get, reverse=True):
    if k in accs:
        open(path + "/INTERSECTION/" + fasta[i], 'w').write('{}\n'.format(str(seq_acc[k])))
        i += 1
    if k in singleton:
        name_singleton = re.sub("\t", "", k)
        open(path + "/SINGLETON/" + str(name_singleton) + ".txt", 'w').write('{}\n'.format(str(seq_acc[k])))
        test2.write(str(len(seq_acc[k])) + "\t" + str(name_singleton) + ".fasta" + k + "\n")
        fasta_sequence = open(path + "/SINGLETON/" + str(name_singleton) + ".fasta", 'w')
        with open(path + "/SINGLETON/" + str(name_singleton) + ".txt", 'r') as f1:
            for lignes in f1:
                no_quote = re.sub("'", "", lignes) # Formate the file , remove "'"
                no_left_crochet = re.sub("\[", "", no_quote)  # Formate the file , remove "["
                no_right_crochet = re.sub("\]", "", no_left_crochet)  # Formate the file , remove "]"
                no_space = re.sub("\s", "", no_right_crochet)  # Formate the file , remove space
                ligne = no_space.split(",")  # Split by ,
                for elem in ligne:
                    print(">" + elem + "\n" + elem, file=fasta_sequence)

    # print(name_singleton[j], seq_acc[k])
    # print(k)
    # print(seq_acc[k])

# print(accs)seq_inter = open('yolo', 'r')
test2.close()

os.system('''for file in ''' + path +'''/INTERSECTION/*.fasta; do sed 's/\,/\\n/g' $file|sed 's/\]//'|sed 's/\[//'|sed "s/'//g"|sed 's/\s//g'|awk '{print ">"$o}1'> $file.fasta; done''')
os.system('''rename .fasta.fasta .fasta ''' + path + '''/INTERSECTION/*.fasta.fasta''')



os.system("rm " + path + "/SINGLETON/" +"*.txt")
