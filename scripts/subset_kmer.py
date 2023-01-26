import os.path
import functools as ft
import pandas as pd
import glob
from tqdm import tqdm
import click


# Ce script permet de garder une table de subset d'accessions.
# Commande pour le lancer : python subset_kmer.py -in table_all_access -o subset_table -a list_file_of_accession --argument yes


@click.command(context_settings={'help_option_names': ('-h', '--help'), "max_content_width": 800})  # Utilisation de la librairie Click pour définir les arg du script
@click.option('--input', '-in', default=None,
              type=click.Path(exists=True, file_okay=True, dir_okay=True, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to input of merge table')
@click.option('--output', '-o', default=None,
              type=click.Path(exists=False, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to output of subset table')
@click.option('--accessions', '-a', default=None,
              type=click.Path(exists=False, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to the file of list of accession')
@click.option('--argument', '-arg', default=None,
              type=click.STRING,
              required=True, show_default=True, help='Yes or No for subset accessions')
def main(input, output, accessions, argument):
    """This programme give a subset table sort on the accessions """

    arg = argument  # Stockage de l'option --argument dans une variable
    cmd = "sed -i '/^$/d' " + accessions  # Utilisation d'une commande sed pour supprimer toutes les lignes vides du fichier liste contenant les accessions

    liste_accession = []  # Création d'une liste vide qui contiendra les accessions présentes dans le fichier liste_accessions

    if arg == str("yes"):  # Si l'argument == yes
        if os.path.exists(accessions):  # Si le fichier existe
            os.system(cmd)  # On supprime les lignes vides
            if os.path.getsize(accessions) > 0:  # Si le fichier n'est pas vide
                with open(accessions, "r+") as f1:  # On l'ouvre
                    for lignes in f1:
                        lignes = lignes.rstrip()  # On supprime le \n à la fin des lignes
                        liste_accession.append(lignes)  # On ajoute les accessions dans la liste

                merged_table = pd.read_table(input, low_memory=False)  # Lecture de la table contenant toutes les accessions
                all_columns = merged_table.columns  # Stockage du nom des colonnes (accessions) de la table dans une liste

                for elem in liste_accession:  # Pour tous les éléments présents dans la liste donnée par l'utilisateur
                    if elem not in all_columns:  # Si cet élément n'est pas présent dans la table
                        print("L'accession " + elem + " n'existe pas dans la table")
                        exit()  # Arrêt du script

                merged_table[liste_accession].to_csv(output, sep="\t", index=False)  # Si cet élément est présent on écrit la table avec ces éléments.

            else:
                print("Le fichier est vide")
        else:
            print("Le fichier n'existe pas")


if __name__ == '__main__':  # Fonction pour lancer le script
    main()
