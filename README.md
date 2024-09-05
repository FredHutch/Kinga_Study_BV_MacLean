# Kinga_Study_BV_MacLean
Kinga Study on bacterial vaginosis (MacLean et al.)

## Overview
This repository contains the MATLAB scripts used to run the image analysis of the Kinga Study on bacterial vaginosis performed by MacLean *et al.*.
The ultimate goal of the analysis pipeline is to count the number of positive cells for different markers in the lamina propria and epithelium region of fluorescently labeled tissue sections of vaginal biopsies. This analysis is done interactively through a succession of steps requiring user input:

1. thresholding of the different fluorescent markers
2. removal of unwanted regions
3. defining boundary between epithelium and lamina propria
4. adjusting tissue compartmentalization
5. computing counts and densities for the 2 regions

 ## Requirements
   - MATLAB R2022a or higher with Image Processing ToolBox
   - Bio-formats package for MATLAB [bfmatlab](https://www.openmicroscopy.org/bio-formats/downloads/)
  
 ## Input data
  Images of the tissue sections were acquired with a 20x/0.8 objective on a Zeiss AxioImager Z2 operated by the TissueFAXS software and contained up to 4 different channels, including DAPI. Stitched regions were exported as single tifs OME tiled TIFF files. Final image size did not exceed 4000 by 4000 pixels.
  **Disclaimer**: This pipeline has not been tested on different input datasets and its behavior is unknown.

  ## Pipeline
  The main pipeline is started by calling `[dataPL, dataEP, outdata] = KingaBVTissueQuest();`
