# DIC_FFT_Geomorphology_Tools

MATLAB tools for Digital Image Correlation (DIC) applied to geomorphological displacement analysis from multitemporal orthophotographs.

## Description

This repository contains a customized implementation of the DIC_FFT workflow originally developed by Bickel et al. (2018, 2020) for geomorphological applications. The code allows the computation of horizontal displacement fields from multitemoral orthophotographs using subpixel image correlation techniques.

The workflow has been adapted to:

- process georeferenced raster datasets,
- automatically convert pixel offsets into metric displacements,
- export GIS-ready outputs,
- generate displacement maps and vector layers,
- calculate displacement statistics and quality-control indicators.

## Main scripts

### run_pixel_offset_PARTVII_newB2n.m

Core Digital Image Correlation workflow.

Outputs:

- Ux
- Uy
- displacement magnitude (MAG)
- displacement direction (DIR)
- RMSE

### run_pixel_offset_PARTVII_newB3.m

Post-processing and visualization tools.

Generates:

- displacement magnitude maps
- vector maps
- percentile-based visualizations
- descriptive statistics

### run_pixel_offset_PARTVII_newB3nn.m

Generation of GIS-compatible outputs.

Exports:

- ESRI shapefiles
- summary statistics
- GIS-ready products

## Requirements

- MATLAB
- Image Processing Toolbox

## Coordinate systems

The workflow preserves the spatial reference system of the input rasters and exports georeferenced products suitable for integration within GIS environments.

## Citation

If you use this software, please cite:

González-Díez, A. (2026).

DIC_FFT_Geomorphology_Tools:
MATLAB scripts for Digital Image Correlation analysis of geomorphological displacements.

GitHub repository:

https://github.com/alberto1gonzalez/DIC_FFT_Geomorphology_Tools
