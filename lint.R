#!/usr/bin/env Rscript

lints <- lintr::lint_package()
print(lints)
quit(status = length(lints) > 0)
