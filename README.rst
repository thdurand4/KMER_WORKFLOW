.. raw:: html

   <img src="https://raw.githubusercontent.com/thdurand4/PodiumASM/main/docs/source/_images/PodiumASM_logo.png" align="right" alt="podiumASM Logo">

|PythonVersions| |SnakemakeVersions|

.. contents:: Table of Contents
    :depth: 2
    
About KMER_Workflow
===============

|readthedocs|

**Homepage:** `https://workflow_kmer.readthedocs.io/en/latest/ <https://workflow-kmer.readthedocs.io/en/latest/>`_

Using reads fastq of lot of accessions obtained by illumina
sequencing can help to know origin of polyploid organisms like
sugarcane. Indeed few tools exist and can work with very polyploidic 
genomes and its very complex to analyse this kind of genomes.  

**KMER_Workflow is able to do that!** KMER_Workflow is an open-source, scalable,
modulable and traceable snakemake pipeline, able to launch multiple
tools in parallel and providing help for obtaining the true origin of your accessions.
It uses methods based on KMER sharing by all accessions.

Citation
________


Authors
_______

* Théo Durand (CIRAD)
* Olivier Garsmeur (CIRAD)

License
=======

Licencied under `CeCill-C <http://www.cecill.info/licences/Licence_CeCILL-C_V1-en.html>`_ and GPLv3.

Intellectual property belongs to `CIRAD <https://www.cirad.fr/>`_ and authors.

.. |PythonVersions| image:: https://img.shields.io/badge/python-≥3.8%2B-blue
   :target: https://www.python.org/downloads

.. |SnakemakeVersions| image:: https://img.shields.io/badge/snakemake-≥5.13.0-brightgreen.svg
   :target: https://snakemake.readthedocs.io
   
.. |readthedocs| image:: https://pbs.twimg.com/media/E5oBxcRXoAEBSp1.png
   :target: https://workflow_kmer.readthedocs.io/en/latest/
   :width: 400px
