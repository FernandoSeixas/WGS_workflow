## Explanation of necessary support files


## readgroups.txt ******************************************************************************************************
#/ tab delimited file, contains 5 columns with the following information:
#/ the important columns are columns 1,2 and 4. The other can take dummy names.
cl1 - Specimen name (e.g. individual1)
cl2 - Specimen library name (e.g. individual1.lib1)
cl3 - Library and lane (e.g. individual1.lb1.lane1)
cl4 - platform name (e.g. ILLUMINA)
cl5 - repeat Specimen library name (e.g. individual1.lib1)

Example:
individual1 individual1.lib1    individual1.lb1.lane1   ILLUMINA    individual1.lib1
individual2 individual2.lib1    individual2.lb1.lane1   ILLUMINA    individual2.lib1
individual2 individual2.lib2    individual2.lb2.lane4   ILLUMINA    individual2.lib2
individual3 individual3.lib1    individual3.lb1.lane1   ILLUMINA    individual3.lib1



## samples.sex *********************************************************************************************************
#/ tab delimited file, contains two columns
cl1 - Specimen name
cl2 - Sex

Examples:
individual1 F
individual2 F
individual3 M


## ploidy.txt *********************************************************************************************************
Use the example file I provide


