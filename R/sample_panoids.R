require('maptools')
require('rgeos')
require('rgdal')
require('spatialEco')
require('parallel')
require('data.table')
require('reticulate')

#' Draw random sample of GoogleStreetview Panoids
#'
#' This function draws a random sample of GoogleStreetviewPanoids from a provided
#' SpatialLinesDataFrame object, usually constructed from the shapefile of a road
#' network. Spatial sampling is done via the spatialEco package, while interactions
#' with the Streetview API are handled by the robolyst/streetview github module.
#' No API keys are necessary for this function, as it only queries the Streetview
#' Metadata API.
#' @param sldf a SpatialLinesDataFrame object from which points are to be sampled.
#' @param mc.cores number of cores to use when drawing the sample. Defaults to 1.
#' @param ... additional params to be passed to the spatialEco::sample.line.
#' @return a SpatialPointsDataFrame object containing the following columns:
#' \itemize{
#'   \item{"panoid"}{Google Streetview PanoID obtained from Streetview metadata API.}
#'   \item{"lat"}{Latitude associated with the PanoID (returned by Streetview metadata API).}
#'   \item{"lon"}{Longitude associated with the PanoID (returned by Streetview metadata API).}
#'   \item{"month"}{Month during which the image associated with the PanoID was taken. Can be NA.}
#'   \item{"year"}{Year during which the image associated with the PanoID was taken. Can be NA.}
#'   \item{"sampled_lat"}{Latitude of sampled point (against which Streetview API was queried).}
#'   \item{"sampled_lon"}{Longitude of sampled point (against which Streetview API was queried).}
#' }
#' @export

sample_panoids <- function(sldf, mc.cores=1, ...) {
  # wrapper to the sample.line call for the i-th line in the provided
  # SpatialLinesDataFrame.
  sample_points <- function(i, sldf, ...) {
    tryCatch({
      # call sample.line for the i-th line in the provided
      # SpatialLinesDataFrame.
      smp <- sample.line(x=sldf[i,], ...)
    }, error=function(x) {return(NULL)})
  }
  # for every point in the SLDF, get a list of sample points
  res <- mclapply(1:nrow(sldf), function(i) {
    spdf <- sample_points(i, sldf, ...)
    if (is.null(spdf)) {
      return(list())
    }
    spdf@data <- cbind(spdf@data, sldf@data[i,])
    panoids <- apply(
      spdf@coords,
      c(1),
      function(x) streetview$panoids(x[2], x[1])
    )
    panoids <- lapply(panoids, function(x) {
      rbindlist(lapply(x, function(d) {
        if (! 'month' %in% names(d)) {d$month <- NA}
        if (! 'year' %in% names(d)) {d$year <- NA}
        return(d[c('panoid', 'lat', 'lon', 'month', 'year')])
    }))})
    panoids <- mapply(
      function(panoid.data, j) {
        tryCatch({
          if (!is.null(panoid.data) && ncol(panoid.data) > 0) {
            panoid.data[,sampled_lat:=spdf@coords[j,1]]
            panoid.data[,sampled_lon:=spdf@coords[j,2]]
            panoid.data[,names(spdf@data):=spdf@data]
          }
        }, error=function(e) {
          print('Problem encountered with panoid data:')
          print(e)
          print(is.null(panoid.data))
          print(ncol(panoid.data))
          print(panoid.data)
        })
      },
      panoids,
      1:nrow(spdf),
      SIMPLIFY=F
    )
    return(rbindlist(panoids))
  }, mc.cores=mc.cores)
  res <- res[which(sapply(res, function(x) "data.table" %in% class(x)))]
  return(rbindlist(res))
}
