import os.path
import functools as ft
import pandas as pd
import glob
from tqdm import tqdm
import click


@click.command(context_settings={'help_option_names': ('-h', '--help'), "max_content_width": 800})
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

    arg = argument
    cmd = "sed -i '/^$/d' " + accessions

    liste_accession = []

    if arg == str("yes"):
        if os.path.exists(accessions):
            os.system(cmd)
            if os.path.getsize(accessions) > 0:
                with open(accessions, "r+") as f1:
                    for lignes in f1:
                        lignes = lignes.rstrip()
                        liste_accession.append(lignes)

                merged_table = pd.read_table(input, low_memory=False)
                all_columns = merged_table.columns

                for elem in liste_accession:
                    if elem not in all_columns:
                        print("L'accession " + elem + " n'existe pas dans la table")
                        exit()

                merged_table[liste_accession].to_csv(output, sep="\t", index=False)

            else:
                print("Le fichier est vide")
        else:
            print("Le fichier n'existe pas")

if __name__ == '__main__':
    main()