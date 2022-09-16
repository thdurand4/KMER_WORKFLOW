import os.path
import functools as ft
import pandas as pd
import glob
from tqdm import tqdm
import click

@click.command(context_settings={'help_option_names': ('-h', '--help'), "max_content_width": 800})
@click.option('--input', '-in', default=None,
              type=click.Path(exists=True, file_okay=True, dir_okay=True, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to input of directory of all table')
@click.option('--output', '-o', default=None,
              type=click.Path(exists=False, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to output of the merged table')
def main(input, output):
    """This programme merge all table """

    dir_file = input
    all_files = glob.glob(os.path.join(dir_file, "*.tbl"))

    dfs = [pd.read_table(f, low_memory=False) for f in tqdm(all_files, desc="Read all table")]

    for i in tqdm(dfs, desc="Merging all table"):
        merge_table = ft.reduce(lambda left, right: pd.merge(left, right, on="KMER", how="outer"), dfs)

    merge_table = merge_table.fillna(0)

    print("Writing Table")
    merge_table.to_csv(output, sep="\t", index=False)

    print("Done")


if __name__ == '__main__':
    main()
