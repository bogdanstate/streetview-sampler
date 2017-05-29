# streetview-sampler
Helper functions for sampling points on a road network and downloading associated Google Streetview images.

I am providing code in this repository to you under an open source license. Because this is my personal repository, the license you receive to my code is from me and not from my employer (Facebook).

## Installation

1. Create a directory in which to install required packages:
```
mkdir streetviewSampler
cd streetviewSampler
```

2. In the new directory, create and activate a virtualenv to ensure we're using Python 2.7:
```
virtualenv -p python2.7 env
source env/bin/activate
```

3. Clone the robolyst/streetview package for interacting with the Streetview API:
```
git clone https://github.com/robolyst/streetview.git env/lib/python2.7/site-packages/streetview
```

4. Install other required pip modules:
```
pip install requests pillow
```

5. Update `PYTHONPATH` environment variable to pick up virtualenv packages:
```
export PYTHONPATH=env/lib/python2.7/site-packages
```

6. Create R site library and point R to it:
```
mkdir -p env/lib/R/site-library
export R_LIBS=env/lib/R/site-library
```

7. Start R from your installation directory and install required packages:
```
devtools::install_github("rstudio/reticulate")
install.packages('maptools')
install.packages('rgeos')
install.packages('rgdal')
install.packages('spatialEco')
install.packages('data.table')
```

8. Make sure virtualenv site packages are the first ones to be considered by Python by running this command from your R environment.
```
reticulate::py_eval('sys.path.insert(0, "env/lib/python2.7/site-packages")')
```

9. Load the streetview module into R:
```
streetview <- reticulate::import("streetview")
```

10. You should now be able to install the streetview-sampler package from github:
```
devtools::install_github('bogdanstate/streetview-sampler')
```

## Testing

1. Download, unzip, and read a shapefile containing roads:
```
library('rgdal')
system("wget http://www.dot.ca.gov/hq/tsip/gis/datalibrary/zip/highway/ScenicHwys2014.zip")
system("unzip ScenicHwys2014.zip -d ScenicHwys2014")
sldf <- readOGR('ScenicHwys2014', 'ScenicHwys2014')

library('parallel')
library('data.table')
library('spatialEco')
panoids <- sample_panoids(sldf, mc.cores=4, type='random', n=1)
head(panoids)
```

The result is a table containing information about:
- the sampled lat/lons from the street network.
- the resolved lat/lons from the Google Streetview metadata API endpoint.
- the panoids (which you can use to download Streetview images with an R package like [googleway](https://cran.r-project.org/web/packages/googleway/index.html), or using [robolyst/streetview](https://github.com/robolyst/streetview).
- whatever other data was contained in the SpatialLinesDataFrame object you provided.

## Visualization

To see where the sampled points are located, type the following into your R console (after having executed the previous commands):

```
system("wget http://www.dot.ca.gov/hq/tsip/gis/datalibrary/zip/highway/shn2016v2_Segments.zip")
system("unzip shn2016v2_Segments.zip -d shn2016v2_Segments")
roads <- readOGR('shn2016v2_Segments', 'shn2016v2_Segments')
plot(roads, col='gray')
plot(sldf, add=T, col='black')
sp <- SpatialPointsDataFrame(panoids[,.(lon, lat)], panoids)
plot(sp, add=T, col='red')
```

The visualization should look something like this:

![Sampled Points from California Scenic Roads](https://github.com/bogdanstate/streetview-sampler/blob/master/cal_scenic.png)
