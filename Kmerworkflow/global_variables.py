from pathlib import Path

DOCS = "https://kmer-workflow.readthedocs.io/en/latest/"
GIT_URL = "https://github.com/thdurand4/KMER_WORKFLOW"

INSTALL_PATH = Path(__file__).resolve().parent
SINGULARITY_URL_FILES = [('https://github.com/thdurand4/Docker_depot/blob/main/Dockerfile_tools',
                          'INSTALL_PATH/containers/Dockerfile_tools'),
                         ('https://github.com/thdurand4/Docker_depot/blob/main/Dockerfile_perl',
                          'INSTALL_PATH/containers/Dockerfile_perl')
                         ]

DATATEST_URL_FILES = ("https://itrop.ird.fr/culebront_utilities/Data-Xoo-sub.zip", "Data-Xoo-sub.zip")



