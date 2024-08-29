
# Snakemake workflow: `CellOrientation`

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.3.0-brightgreen.svg)](https://snakemake.github.io)


## For testing uniformity orientation of centrosome respect to the nucleus of cells (in angles) comming fron [Scratch Assay](https://cytosmart.com/resources/resources/wound-healing-assay-what-why-and-how)

## Authors

* Raul Gomez Riera [ORCI](https://orcid.org/0000-0003-4197-180X)

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repo.


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

### Enviroment creation

Create required environments by going to the directory `CellOrientation/workflow` 

where `Snakefile` is located and execute the following command:
```
snakemake --cores all --use-conda --conda-create-envs-only Data_Analysis
```

## Workflow Diagram

<p align="center">
  <img width=150 src="img/dag.svg" alt="Workflow execution order">
</p>

A list of the tools used in this pipeline:

| Tool         | Link                                              |
|--------------|---------------------------------------------------|
| Fiji         | https://doi.org/10.1038/nmeth.2019                |
| CellProfiler | https://doi.org/10.1186/s12859-021-04344-9        |
| Snakemake    | https://doi.org/10.12688/f1000research.29032.1    |
| R            | https://wwwr-projectorg/                          |
| Mamba        | https://github.com/mamba-org/mamba                |
| Python       | https://www.python.org/                           |


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
