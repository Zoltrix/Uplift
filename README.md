# Practical investigation of Uplift packages

## Plan

* Investigate the Hillstrom e-mail dataset (similar to Emaar's data)
* Try each uplift model in the `uplift` R package
* Try each quality metric (geni, qini, uplift curve)
* Investigate other packages/softwares (matlab, python, SAS)

## Useful links

* [Hillstrom Dataset](http://blog.minethatdata.com/2008/03/minethatdata-e-mail-analytics-and-data.html)

## Issues with R uplift package

* No support for multilevel trearment/outcome variables (except for Knn, Multi-treatment is supported)


# Checklist (done so far)

* WIP summary table of different models, different metrics and most important variable


# Model Summary

| Model | Split method | Most important var | importance |
|:-----:|:------------:|:------------------:|:----------:|
|   RF  |     Chisq    |       history      |    38.79   |
|   RF  |      ED      |       history      |    47.28   |
|   RF  |      KL      |       history      |    41.26   |
|   RF  |      Int     |        spend       |    60.5    |
