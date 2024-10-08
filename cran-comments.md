This is a maintenance release to address WARNs in CRAN checks.

## R CMD check results

This package vendors **Rust dependencies** resulting in an 18mb .xz file. 
The final installation size is 2.8mb on MacOS.

>  Size of tarball: 18112805 bytes

0 errors | 0 warnings | 2 notes

* This is a new release.


## Testing environments 

GitHub Actions: 

- {os: windows-latest, r: 'release'}
- {os: ubuntu-latest,   r: 'devel', http-user-agent: 'release'}
- {os: ubuntu-latest,   r: 'release'}
- {os: ubuntu-latest,   r: 'oldrel-1'}

R-hub Runners: 

- MacOS (r-devel): https://github.com/R-ArcGIS/arcgisplaces/actions/runs/9051533790
- Linux (r-devel): https://github.com/R-ArcGIS/arcgisplaces/actions/runs/9051670244

## Software Naming

ArcGIS is a brand name and not the name of a specific software. 
The phrase 'Places service' refers to a spefic API which can be considered
software. This is quoted in the DESCRIPTION file.

