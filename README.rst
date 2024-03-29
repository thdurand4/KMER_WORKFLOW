.. raw:: html

   <img src="https://raw.githubusercontent.com/thdurand4/KMER_WORKFLOW/main/docs/source/_images/logo.png" align="right" alt="KMER Logo">

|PythonVersions| |SnakemakeVersions|

.. contents:: Table of Contents
    :depth: 2
    
About KMER_Workflow
===============

|readthedocs|

Check the doc's homepage to see how to install and use our workflow !

**Homepage:** `https://kmer-workflow.readthedocs.io/en/latest/ <https://kmer-workflow.readthedocs.io/en/latest/>`_

Using reads fastq (NGS) of lot of accessions obtained by illumina
sequencing can help to know origin of polyploid organisms like
sugarcane. Indeed few tools exist and can work with very polyploidic 
genomes and its very complex to analyse this kind of genomes.  

**KMER_Workflow is able to do that!** KMER_Workflow is an open-source, scalable,
modulable and traceable snakemake pipeline, able to launch multiple
tools in parallel and providing help for obtaining the shared information between differents individuals.
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

.. |PythonVersions| image:: https://img.shields.io/badge/python-≥3.8.2%2B-blue
   :target: https://www.python.org/downloads

.. |SnakemakeVersions| image:: https://img.shields.io/badge/snakemake-≥7.15.1-brightgreen.svg
   :target: https://snakemake.readthedocs.io
   
.. |readthedocs| image:: https://pbs.twimg.com/media/E5oBxcRXoAEBSp1.png
   :target: https://kmer-workflow.readthedocs.io/en/latest/
   :width: 400px
