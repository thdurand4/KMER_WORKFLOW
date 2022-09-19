import pandas as pd
import os
import re
import click


#  Ce script permet d'ajouter le nom des colonnes en utilisant le nom de fichier des accessions
#  Pour lancer le script : python name_columns.py -in table_accession -o table_accession_named.

@click.command(context_settings={'help_option_names': ('-h', '--help'), "max_content_width": 800})  # Utilisation de la librairie click pour définir les arguments du script
@click.option('--input', '-in', default=None,
              type=click.Path(exists=True, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to input accession file sorted')
@click.option('--output', '-o', default=None,
              type=click.Path(exists=False, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to output accession with columns name')
def main(input, output):
    """This programme add accession columns name of accession table sorted"""
    acces_file = os.path.basename(input)  # Récupération du nom des fichiers
    acces_name = re.sub("_20M_coverage_sorted.tbl", "", acces_file)  # Remplacer la fin du nom par rien (ne garder que le nom de l'accession) et stocker ce nom dans une variable
    df = pd.read_table(input, header=None)  # Lecture de la table qui ne possède pas encore de nom de colonnes
    df.columns = ["KMER", acces_name]  # Définition du nom des colones
    df.to_csv(output, sep="\t", index=False)  # Écriture de la nouvelle table avec des colonnes nommées dans un fichier


if __name__ == '__main__':  # Fonction permettant de lancer le script
    main()
