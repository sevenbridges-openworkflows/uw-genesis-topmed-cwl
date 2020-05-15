# Developer notes

The report tool (null_model_report.R) needs the params file produced by the 
`null_model.R` script. But this dependency is hidden. The params file is given 
a fixed name `null_model.config.null_model.params`. This params file has the 
absolute path to the input files originally passed to `null_model.R`. For this
reason, it is best if the two scripts are run in the same docker container, one
after the other. Otherwise we will have to recreate the
`null_model.config.null_model.params` file and replace the old absolute paths
with the new paths to the data files.
