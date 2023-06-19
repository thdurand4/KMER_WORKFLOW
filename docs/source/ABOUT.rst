.. image:: _images/logo.png
   :target: _images/logo.png
   :align: center
   :alt: KMER Logo

Today, get an assembly of large polyploid genome is very complicated and it's hard to compare lot of individuals of this polyploid species, in particular to compare sequences of many individuals.

Due to the daily deluge of data sequences the number of data increase and need to be analyse ...

So a huge question remains:

*"How can i compare many individuals of a speicies without assembly?"*

To that anguishing idea, we can answer: **KMER_WORFLOW can help you!**

KMER_WORKFLOW is is an open-source, scalable, modulable and traceable snakemake pipeline, able to compare multiple data short read (NGS) obtained from illumina sequencing by counting the number of shared kmers. The workflow KMER_WORKFLOW can help you to find which individuals share sequences informations to other.

KMER_WORKFLOW generates an upset plot (Graph) containing all information about how much kmer are shared by how much indivuduals and the sequences of them.


.. contents:: Table of Contents
   :depth: 1
   :backlinks: entry

Sub_Sampling reads Illumina and count KMERS
-----------------------------

The first step of KMER_WORKFLOW is to sub sampling reads of all of individuals.
The pipeline will take the number of reads to sub sampling for each paired. 

For example if you wante to sub sampling PAIRED data

.. warning::
   * CONTAMINATION: BE CAREFUL MAKE SUR YOURS DATA DOESN'T CONTAINS CONTAMINATION MAYBE BEFORE LAUNCH PIPELINE USE TOOLS LIKE KRAKEN TO CHECK POSSIBLE CONTAMINATION.
   * NUMBER OF READS: MAKE SUR YOURS DATA CONTAINS ENOUGHT READS TO SUBSAMPLING. FOR EXEMPLE IF YOU HAVE _R1.fq.gz AND _R2.fq.gz AND YOU WANT SUB SAMPLING 10 MILLIONS MAKE SURE TO HAVE 5 MILLIONS IN BOTH.
   
.. note::
   * SEQTK: Seqtk is the tool use to subsampling data.

Included tools :

* Seqtk version >= 1.3-r106

Next the pipeline will count KMERS of each individuals

.. note::
   *KAT HIST: K-mer Analysis Toolkit to count Kmer and get binary output
   *JELLYFISH: 



Optional ILLUMINA step
......................

You can activate or deactivate ILLUMINA step; if you have short reads ILLUMINA of your organims then switch to *ILLUMINA=True* in the ``config.yaml``  file.

Directed acyclic graphs (DAGs) show the differences between deactivated (ILLUMINA=False):

.. image:: _images/schema_pipeline_global-QUALITY.png
   :target: _images/schema_pipeline_global-QUALITY.png
   :alt: ILLUMINA_FALSE

and activated ILLUMINA step on configuration file (ILLUMINA=True):

.. image:: _images/PodiumASM_illumina.png
   :target: _images/PodiumASM_illumina.png
   :alt: ILLUMINA_TRUE
   
   
   
.. note::
   * ILLUMINA : this rule will calculates remapping stats using Illumina reads over assemblies
   
   
Included tools :

* SAMTOOLS version >= 1.15.1
* BWA version >= 0.7.17


.. image:: _images/dag.png
   :target: _images/dag.png
   :alt: dag
   :width: 100px
   :height: 800px
