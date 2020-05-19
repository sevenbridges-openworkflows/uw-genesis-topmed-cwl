# Developer notes

Reverse engineered from
https://github.com/UW-GAC/analysis_pipeline/blob/master/assoc.py

## Operations
1. Copy parameter file 



## Subdirectory structure
(From https://github.com/UW-GAC/analysis_pipeline/blob/68de072d1960cb330ced26491ca41ec43464d3bc/TopmedPipeline.py#L164)

```
config
data
log
plots
report
```

In the configuration file these are referred to by keys with suffix `_prefix`
eg `config_prefix`, and the file name prefix they refer to are of the form
`config_prefix/<out_prefix>`


## Copy of parameter file for report

_`config_prefix`, `null_model_params` can not be found in the documentation.

`<config_prefix>_null_model.config.null_model.params`

