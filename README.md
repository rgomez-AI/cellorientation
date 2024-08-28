
# Snakemake workflow: `CellOrientation`

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/<owner>/<repo>/workflows/Tests/badge.svg?branch=main)](https://github.com/<owner>/<repo>/actions?query=branch%3Amain+workflow%3ATests)


## For testing uniformity orientation of centrosome respect to the nucleus of cells (in angles) comming fron [Scratch Assay](https://cytosmart.com/resources/resources/wound-healing-assay-what-why-and-how)

The usage of this workflow is described also in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/?usage=<owner>%2F<repo>).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) `<repo>`sitory and its DOI (see above).


## Image acquisition settings for data generation

The scratch assay was carried out
with the following fluorophores:
* Channel 0 : Centrosome marker CEp170, Alexa647
* Channel 1 : Golgi marker GM130, Alexa488

For nuclei detection, cells were stained with 
* Channel 2 : DAPI 

3D multiplex images (stack) of cells were acquired with Stellaris Falcon from Leica.
* Objective Immersion="Oil" LensNA="1.3"
* Model="HC PL APO CS2 40x/1.30 OIL"
* NominalMagnification="40"
* Voxel Size: 0.2841x0.2841x0.3462


## Installation

You will need a current version of `snakemake` to run this workflow. To get `snakemake` please follow the install [instructions](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) on their website, but in brief once `conda` and `mamba` are installed you can install `snakemake` with:

```
mamba create -n snakemake -c conda-forge -c bioconda snakemake
```

Afterwards you can activate the `conda` environment and download the repository. And all additional dependencies will be handled by `snakemake`.

```
conda activate snakemake
git clone https://github.com/rgomez-AI/CellOrientation.git
```

### - Enviroment creation

Create required environments by going to the directory `CellOrientation/workflow` 

where `Snakefile` is located and execute the following command:
```
snakemake --cores all --use-conda --conda-create-envs-only Data_Analysis
```

## Workflow Diagram

<p align="center">
  <img width=150 src="img/dag.svg" alt="Workflow execution order">
</p>


## Input

Acquired images (multichannel, Z stack and series) storaged in .lif format


## Running

To execute change current directory to the directory `workflow` where `Snakefile` is located.

```
snakemake --cores all --use-conda Data_Analysis
```

## Output

As an output there are two files:
* `results/INNERCells.pdf` which contain the analysis for cells
located at the inner region.

* `results/OUTTERCells.pdf` which contain the analysis for cells
located at the edge region.


## Report generation

For report generation snakemake required `pygments` module and it can be installed with:
```
pip install pygments
```
 
Afterward you can create a report file with the name *report.html* as the example bellow:
```
snakemake Data_Analysis --report report.html
```

## TODO

* Replace `<owner>` and `<repo>` everywhere in the template (also under .github/workflows) with the correct `<repo>` name and owning user or organization.
* Replace `<name>` with the workflow name (can be the same as `<repo>`).
* Replace `<description>` with a description of what the workflow does.
* The workflow will occur in the snakemake-workflow-catalog once it has been made public. Then the link under "Usage" will point to the usage instructions if `<owner>` and `<repo>` were correctly set.