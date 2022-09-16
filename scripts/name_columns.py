import pandas as pd
import os
import re
import click

@click.command(context_settings={'help_option_names': ('-h', '--help'), "max_content_width": 800})
@click.option('--input', '-in', default=None,
              type=click.Path(exists=True, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to input accession file sorted')
@click.option('--output', '-o', default=None,
              type=click.Path(exists=False, file_okay=True, dir_okay=False, readable=True, resolve_path=True),
              required=True, show_default=True, help='Path to output accession with columns name')


def main (input, output):
    """This programme add accession columns name of accession table sorted"""
    acces_file = os.path.basename(input)
    acces_name = re.sub("_20M_coverage_sorted.tbl","",acces_file)
    df = pd.read_table(input, header=None)
    df.columns = ["KMER",acces_name]
    df.to_csv(output,sep="\t",index=False)

if __name__ == '__main__':
    main()

