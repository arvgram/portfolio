## My procedure to find the underlying patter in the dataset:
1. Visually probe a subset of the images, identify four main categories of images
2. Use a pre-trained CNN classifier to label the images according to the 1000 ImageNet-1k categories
3. Map these predictions to the four identified main supercategories car, fish, dog, bike
4. Present the distribution of these four categories, and infer some kind of pattern.

## How to run

```bash
mv <path/to/image/dir/> Dataset
conda env create venv -f requirements.text
conda activate venv
jupyter lab
```