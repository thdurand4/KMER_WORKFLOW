import os.path
import functools as ft
import pandas as pd
import glob
from tqdm import tqdm
import click


# Ce script permet de former une seule grosse table d'accessions en regroupant toutes les tables de chaque accession
# Lancer le script : python merge_table.py -in All_accessions/ -o table_of_all_accession.tbl.

@click.command(context_settings={'help_option_names': ('-h', '--help'), "max_content_width": 800})  # Utilisation de la librairie Click pour définir les arguments du script
@click.option('--input', '-in', default=None,
              type=click.Path(exists=True, file_okay=True, dir_okay=True, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to input of directory of all table')
@click.option('--output', '-o', default=None,
              type=click.Path(exists=False, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to output of the merged table')
def main(input, output):
    """This programme merge all table """

    dir_file = input  # Définition de répertoire d'entrée ou se trouve toutes les tables de chaque accession
    all_files = glob.glob(os.path.join(dir_file, "*.tbl"))  # Récupération que des fichiers se terminant par .tbl dans ce répertoire

    dfs = [pd.read_table(f, low_memory=False) for f in tqdm(all_files, desc="Read all table")]  # On lit toutes les tables présentes dans le répertoire que l'on stocke dans une variable

    for i in tqdm(dfs, desc="Merging all table"):  # Utilisation de tqdm pour effectuer des bars de progression lors de l'exécution du script
        merge_table = ft.reduce(lambda left, right: pd.merge(left, right, on="KMER", how="outer"), dfs)  # Utilisation de la fonction merge de pandas pour regrouper toutes les tables qui sont rassemblées en fonction de la colonne KMER en gardant toutes les colonnes ("outer")

    merge_table = merge_table.fillna(0)  # Remplacement des valeurs NaN par 0.

    print("Writing Table")
    merge_table.to_csv(output, sep="\t", index=False)  # Écriture de la table merged dans un fichier de sortie

    print("Done")


if __name__ == '__main__':  # Fonction pour lancer le script
    main()
