# Purpose
This project implements "memory-mapped" matrices in R, so that matrices used in statistical calculations do not have to be stored in memory (RAM). Operations performed on matrices stored this way are almost as fast as if the matrix were stored in RAM.

## Application to spatial statistics
When trying to perform spatial prediction using Reproducing Kernel Hilbert Spaces (RKHS) with large datasets, calculation of the distance matrix can be difficult (i.e., break the R session). Memory mapped matrices might be able to facilitate computation of the distance matrix.