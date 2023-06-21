#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from module import Kmerworkflow
from Kmerworkflow.global_variables import *
from pathlib import Path
from .global_variables import GIT_URL, DOCS, DATATEST_URL_FILES, SINGULARITY_URL_FILES

logo = Path(__file__).parent.resolve().joinpath('logo.png').as_posix()

__version__ = Path(__file__).parent.resolve().joinpath("VERSION").open("r").readline().strip()


__doc__ = """KMER_WORKFLOW is is an open-source, scalable, modulable and traceable snakemake pipeline, able to compare multiple data short read (NGS) obtained from illumina sequencing by counting the number of shared kmers. The workflow KMER_WORKFLOW can help you to find which individuals share sequences informations to other."""

description_tools = f"""
    Welcome to Kmerworkflow version: {__version__} ! Created on June 2023
    @author: Théo Durand (CIRAD)
    @email: theo.durand@cirad.fr

    Please cite our github: GIT_URL
    and GPLv3 Intellectual property belongs to CIRAD and authors.
    Documentation avail at: DOCS"""

dico_tool = {
    "soft_path": Path(__file__).resolve().parent.as_posix(),
    "url": GIT_URL,
    "docs": DOCS,
    "description_tool": description_tools,
    "singularity_url_files": SINGULARITY_URL_FILES,
    "datatest_url_files": DATATEST_URL_FILES,
    "snakefile": Path(__file__).resolve().parent.joinpath("snakefiles", "Snakefile"),
    "snakemake_scripts": Path(__file__).resolve().parent.joinpath("snakemake_scripts")
}
