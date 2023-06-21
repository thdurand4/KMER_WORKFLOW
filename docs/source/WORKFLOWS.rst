.. contents:: Table of Contents
   :depth: 2
   :backlinks: entry
   :local:

How to create a workflow
========================

Kmerworkflow allows you to build a workflow using a simple ``config.yaml`` configuration file :

* First, provide the data paths
* Second, manage parameters tools.
* And last, give names to output table and choose optional rules.

To create this file, just run:

.. click:: Kmerworkflow.main:main
    :prog: Kmerworkflow
    :commands: create_config
    :nested: full
    :hide-header:

Then, edit the relevant sections of the file to customize your flavor of a workflow.


1. Providing data
------------------

First, indicate the data path in the ``config.yaml`` configuration file:

.. literalinclude:: ../../Kmerworkflow/install_files/config.yaml
   :language: YAML
   :lines: 3-9

Find here a summary table with description of each data need to launch Kmerworkflow :

.. csv-table::
    :header: "Input", "Description"
    :widths: auto

    "LIST_ACCESSION", "It's a tabulate text file made by the users. It will lot of information about individuals and fastq files. See below"
    "LIST_COULEURS","Give path to a file which permit to get color for the final graph of pipeline. THIS FILE WILL BE CREATED AUTOMATATICALY DON'T CREATE IT"
    "OUTPUT_DIR","output *path* directory"

Example of "LIST_ACCESSION" file : 

.. warning::

    **MAKE SURE TO HAVE ONE LINE PER FASTQ FILE**
    For this file make sur to separate fields with tabulate 
    - **The First field is the name of the individual**
    - **The Second is the path to your FASTQ file**
    - **The Third field is the number of reads you want to subsamplig**. **IF YOU HAVE PAIRED DATA AND YOU WANT TO SUBSAMPLING 20 MILLION OF READ MAKE SURE TO WRITE 10 MILLION FOR EACH PAIRED**
    - **The Fourth field is the seed to random subsampling**. **MAKE SUR TO HAVE THE SAME SEED FOR ALL _R1.fq AND AN OTHER SEED FOR ALL _R2.fq FOR EXAMPLE 100 FOR R1 AND 150 FOR R2**
    - **The Last field is the color to set for the individuals. (the color will be on the graph at the end)

.. literalinclude:: ../../Kmerworkflow/install_files/access_list.txt
   :language: YAML
   :lines: 1-20

.. warning::

    For FASTQ, naming convention is preferable by like *NAME_R1.fastq.gz* or *NAME_R1.fq.gz* or *NAME_R1.fastq* or *NAME_R1.fq*. Preferentially use short names and avoid special characters because report can fail. Avoid to use the long name given directly by sequencer.
    Same for _R2
    All fastq files have to be homogeneous on their extension and can be compressed or not.
    Befor launch the pipeline it's also preferable to check if your data doesn't contains contamination
    

2. Parameters for some specific tools
--------------------

.. literalinclude:: ../../Kmerworkflow/install_files/config.yaml
   :language: YAML
   :lines: 15-22


Find here a summary table with description of each params for Kmerworkflow :

.. csv-table::
    :header: "Params", "Description"
    :widths: auto

    "KAT_HIST", "Manage params of KAT tools"
    "JELLYFISH_DUMP","Manage params of KAT tools"
    "CUT_COVERAGE","Give the cutoff coverage that you want. If you write 10 the pipeline will work on kmer seen at the minimum 10 times."
    "INTERSECT_TABLE","Manage params of script count_intersection.py. See 'Kmerworkflow/snakemake_scripts/count_intersection.py' to check params of the script"
    "FULL_TABLE","Its a params of script count_intersection.py just write Yes or no"


3. Parameters for some specific tools and give name of output 
------------------------

Activate/deactivate tools as you wish.
Name output table of pipeline

Example:

.. literalinclude:: ../../Kmerworkflow/install_files/config.yaml
    :language: YAML
    :lines: 27-



.. warning::
    Please check documentation of each tool (outside of Kmerworkflow, and make sure that the settings are correct!)


------------------------------------------------------------------------

How to run the workflow
=======================

Before attempting to run Kmerworkflow, please verify that you have already modified the ``config.yaml`` file as explained in :ref:`1. Providing data`.

If you installed Kmerworkflow on a HPC cluster with a job scheduler, you can run:

.. click:: Kmerworkflow.main:main
    :prog: Kmerworkflow
    :commands: run_cluster
    :nested: full
    :hide-header:

------------------------------------------------------------------------

.. click:: Kmerworkflow.main:main
    :prog: Kmerworkflow
    :commands: run_local
    :nested: full
    :hide-header:

------------------------------------------------------------------------

Advance run
===========

Providing more resources
--------------------------

If the cluster default resources are not sufficient, you can edit the ``cluster_config.yaml`` file. See :ref:`2. Adapting *cluster_config.yaml*`:

.. click:: Kmerworkflow.main:main
    :prog: Kmerworkflow
    :commands: edit_cluster_config
    :nested: full
    :hide-header:

------------------------------------------------------------------------

Providing your own tools_config.yaml
-------------------------------------

To change the tools used in a Kmerworkflow workflow, you can see :ref:`3. How to configure tools_path.yaml`

.. click:: Kmerworkflow.main:main
    :prog: Kmerworkflow
    :commands: edit_tools
    :nested: full
    :hide-header:

------------------------------------------------------------------------


Output on Kmerworkflow
===================

The architecture of Kmerworkflow output is designed as follow:

.. code-block:: bash

    OUTPUT_Kmerworkflow/
    ├── 1_BIS_SUB_SET_READS
    ├── 1_MERGED_FASTQ
    ├── 2_KMER_COUNT
    ├── 3_MERGE_KMER
    ├── 4_SPLIT_KMER
    ├── 5_MERGE_TABLE
    ├── 6_INTERSECTION_TABLE
    ├── 7_UPSET_PLOT
    └── LOGS

