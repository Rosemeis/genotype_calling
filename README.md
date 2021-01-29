# Naive genotype calling
Call genotypes from genotype likelihoods from a gzipped Beagle file.

## Get repository and build
```bash
git clone https://github.com/Rosemeis/genotype_calling.git
cd genotype_calling/
python setup.py build_ext --inplace
```

## Usage
```bash
# Read and convert Beagle file to tped and tfam
python naiveCalling.py -beagle input.beagle.gz -threads 64 -out naive

# With calling threshold
python naiveCalling.py -beagle input.beagle.gz -delta 0.9 -threads 64 -out naive.d90

# Convert to binary PLINK files *.bed, *.bim, *.fam)
plink --tfile naive --make-bed --out naive.plink
```
