# The Effective-Rank-Deficiency problem when using ICA in EEGLAB

### Description of the problem (07/16/2021 updated)

Sometimes EEGLAB's infomax ICA (called by the *runica()* function) fails in a weird way, refered here as a ghost IC. 

Example of a ghost IC illustrated by power spectral density (top) and scalp topogrpahy (bottom):

<img src="https://github.com/amisepa/Effective-Rank-Deficiency/blob/main/illustrations/ghost_spectra.png" width="300">
<img src="https://github.com/amisepa/Effective-Rank-Deficiency/blob/main/illustrations/ghost_topo.png" width="300">

The ghost IC is caused by running ICA on rank-deficient data. 
However, even if the data is not exactly rank deficient, if the smallest eigenvalue is smaller than a threshold value (near-zero value), the same issue occurs. 
A near-zero eigenvalue means that two lines are quasi parallel, but not exactly. This is a typical ill-conditioned setup. 
While Matlab's *rank()* function can calculate the smallest eigenvalue down to 1E-16, our ICA algorithm starts to fail around 1E-7 (and below).
The exact threshold where the issue starts is unknown, which is the first goal of the current study. 
Hence, using Matlab *rank()* to count the number of eigenvalues does not work. Instead, one must evaluate the smallest eigenvalue of the data. 

In linear algebra, the problem is described as follows: 
The larger the condition number 
The condition number $\frac{ ^\sigma{\max(A)} }{ ^\sigma{\min(A)} }$, where $^\sigma{\max(A)}$ is the maximum singular value of $A$ and $^\sigma{\min(A)}$ is the minimum singular value of $A$. 
The larger the condition number is, the more ill the data is and close to singularity, suggesting ICA is more likely to fail.

Important note: artifact subspace reconstruction (ASR) will also fail if the input data is not full-ranked!



### 3 known scenarios that produce ghost ICs

1) Applying average referencing: the current process either reduces the rank by 1 when the initial reference is not included, or does not cause rank reduction but makes the smallest eigenvalue moderately small (about 1/100 compared with the original data in one case) when the original reference is included.
2) Interpolation of the bad EEG channels that were removed: because the spline interpolation is a non-linear process, rank reduction does not happen but makes the smallest eigenvalue dangerously small (about 10^-9 or 1/1000000000 compared with the original data in one case)
3) 'Bridged' electrodes (i.e. shorted by conductive gel): this is the case that the recorded data is originally rank deficient. The 'bridged' electrodes should show an identical signal in the two (or more) channels.

### The current solution in EEGALB

To avoid instability, the variable “rankTolerance = 1e-7” is set in pop_runica() to hard-code the smallest acceptable value of X. However, this solution remains unvalidated for a long time, and apparently fails from time to time!

### The goal of the project

1. To determine the lower bound of the ICA’s tolerance to the small eigenvalue before it begins to fail. Also, we are interested in confirming signatures when ICA fails.
2. To propose a parameter based on our investigation using simulation and empirical data. 

