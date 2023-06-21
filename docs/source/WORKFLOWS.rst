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

.. warning::

    For FASTQ, naming convention is preferable by like *NAME_R1.fastq.gz* or *NAME_R1.fq.gz* or *NAME_R1.fastq* or *NAME_R1.fq*. Preferentially use short names and avoid special characters because report can fail. Avoid to use the long name given directly by sequencer.
    Same for _R2
    All fastq files have to be homogeneous on their extension and can be compressed or not.


2. Providing params
--------------------

.. code-block:: YAML

    PARAMS:
        MITOCHONDRIAL_NAME : ""
        # The filter suffix to add on vcf filter in order to allow multiple filter
        FILTER_SUFFIX: ["-Q30-DP5-MAF005-MISS07",
                        "-Q30-DP20-MAF001-MISS05"]


Find here a summary table with description of each params for Kmerworkflow :

.. csv-table::
    :header: "Params", "Description"
    :widths: auto

    "MITOCHONDRIAL_NAME", "The name of mitochondrial sequence on fasta, used to remove on VCF file. If not keep empty"
    "FILTER_SUFFIX","The suffix name add to vcf filters file"


3. Provide workflow step
------------------------

Activate/deactivate tools as you wish.
Feel free to activate only assembly, assembly+polishing or assembly+polishing+correction.

Example:

.. literalinclude:: ../../Kmerworkflow/install_files/config.yaml
    :language: YAML
    :lines: 19-30


4. Parameters for some specific tools
--------------------------------------

You can manage tools parameters on the params section in the ``config.yaml`` file.

Here you find standard parameters used on Kmerworkflow. Feel free to adapt it to your requires.


.. literalinclude:: ../../Kmerworkflow/install_files/config.yaml
    :language: YAML
    :lines: 34-

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
    ├── 1_mapping
    ├── 2_snp_calling
    ├── 3_full_snp_calling_stats
    ├── 4_raxml
    ├── LOGS



Report
======

Kmerworkflow generates a useful report containing, foreach fastq, a summary of interesting statistics !!
