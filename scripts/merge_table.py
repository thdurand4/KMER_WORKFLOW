from pathlib import Path
import functools as ft
import re
import numpy as np
import pandas as pd
import glob
from tqdm import tqdm
import click
import os
import psutil

# Ce script permet de former une seule grosse table d'accessions en regroupant toutes les tables de chaque accession
# Lancer le script : python merge_table.py -in All_accessions/ -o table_of_all_accession.tbl -log info_file.txt

@click.command(context_settings={'help_option_names': ('-h', '--help'), "max_content_width": 800})  # Utilisation de la librairie Click pour définir les arguments du script
@click.option('--input_path', '-in', default=None,
              type=click.Path(exists=True, file_okay=False, dir_okay=True, readable=True, resolve_path=True, path_type=Path),
              required=True, show_default=False, help='Path to input of directory of all table')
@click.option('--output', '-o', default=None,
              type=click.Path(exists=False, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to output of the merged table')

def main(input_path, output):
    """Ce script permet de former une seule grosse table d'accessions en regroupant toutes les tables de chaque accession
# Lancer le script : python merge_table.py -in All_accessions/ -o table_of_all_accession.tbl."""
    nb_acces = []
    process = psutil.Process(os.getpid())
    i = 1
    df_merge = None
    first = True
    all_files = input_path.glob("*.tbl")  # Récupération que des fichiers se terminant par .tbl dans ce répertoire
    test = input_path.glob("*.tbl")

    for elem in test:
        nb_acces.append(elem)

    for elem in all_files:
        test = elem.stem
        colonnes = re.sub("_named","",test)
        #print(colonnes)
        if first:
            df_merge = pd.read_table(elem, engine='pyarrow', dtype={colonnes:int,'KMER':str})
            print(str(i)+"/"+str(len(nb_acces))+" "+colonnes+"\n")
            i = i+1
            first = False
        else:
            df_temps = pd.read_table(elem, engine='pyarrow', dtype={colonnes:int,'KMER':str})
            df_merge = pd.merge(df_merge, df_temps, on="KMER", how="outer")
            print(str(i)+"/"+str(len(nb_acces))+" "+colonnes+"\n")
            print(df_merge.shape)
            print(process.memory_info().rss)
            i = i+1

    df_merge = df_merge.fillna(0)  # Remplacement des valeurs NaN par 0.

    print("Writing Table")
    df_merge.to_csv(output, sep="\t", index=False)  # Écriture de la table merged dans un fichier de sortie

    print("Done")

if __name__ == '__main__':  # Fonction pour lancer le script
    main()