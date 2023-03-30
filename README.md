# Build "cover" databases from sourmash GenBank databases

[Sourmash](https://sourmash.readthedocs.io/en/latest/) is a tool for estimating sequencing similarity between (potentially) very large data sets quickly and accurately.
Some sourmash commands use [databases](https://sourmash.readthedocs.io/en/latest/databases.html) to estimate the containment between a query sample and samples (genomes, metagenomes) in a database.
Sourmash provides a bunch of [prepared databases](https://sourmash.readthedocs.io/en/latest/databases.html) from subsets of GenBank or GTDB. 
These databases are great for lots of things! but they're also very big (e.g. GenBank bacteria contains 1.1 million genomes, >50GB, and takes ~4 hours to search).
Part the large size of the database comes from redundancy -- there are a lot of e.g. *Escherichia coli* genomes in the database.
While some part of each of these genomes may be unique, lots of portions are shared because many *E. coli*.
One way to reduce database size it to build a database where each hash (k-mer) in the database only occurs once.
That's what this repository does.
It builds a "cover" database where each hash is only represented once.
It does this by looking at each sketch sequentially and retaining only the hashes that have not been previously observed.
This strategy makes the database much, much smaller, but it might have some caveats for intepretation of the results.
The strain-level information may no longer be accurate, so summarizing up a level of taxonomy, e.g. to species, might be necessary.
There might be other shortcomings to this approach as well that we haven't thought of yet.

For the original issue outlining this approach, see [here](https://github.com/sourmash-bio/sourmash/issues/1852). 
For ideas of how to use these databases, see [here](https://github.com/dib-lab/2022-sra-gather/issues/11) and [here](https://github.com/dib-lab/2022-sra-gather/issues/12).
To download the databases, see [here](https://osf.io/6zk3d/).

## Getting started


This repository uses snakemake to run the pipeline and conda to manage software environments and installations.
You can find operating system-specific instructions for installing miniconda [here](https://docs.conda.io/en/latest/miniconda.html).

```
curl -JLO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh # download the miniconda installation script
bash Miniconda3-latest-Linux-x86_64.sh
source ~/.bashrc # source the .bashrc for miniconda to be available in the environment

# configure miniconda channel order
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict # make channel priority strict so snakemake doesn't yell at you
conda install mamba # install mamba for faster software installation.
```

After installing conda and [mamba](https://mamba.readthedocs.io/en/latest/) and cloning the repo, run the following command to create the pipeline run environment.
```
mamba env create -n covers --file environment.yml
conda activate covers
```

To start the pipeline, run:

```
snakemake --use-conda -j 1
```

## Next steps

This repository builds a cover for the pre-built sourmash GenBank databases.
This includes the bacterial, archaeal, viral, fungal, and protist fractions of GenBank.
In the long run, it could be nice to have other lineages like plant, invertebrate, vertebrate_mammalian, and vertebrate_other.
Because there are not pre-built databases for these GenBank fractions, this would require the genomes to be downloaded and sketched and built into a database before the cover could be calculated.
See [this issue](https://github.com/sourmash-bio/sourmash/issues/2395) for a discussion of strategies for doing this.
