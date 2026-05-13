

rm(list=ls())
setwd('/home/bian_cy/case_unc')

library(smatr)

# Read datasets from csv file
header <- read.csv("0_data/ECO2_SLA_Na_update_4R.csv", header = FALSE, nrows = 1)
da <- read.csv("0_data/ECO2_SLA_Na_update_4R.csv", header = FALSE, skip = 2)
colnames(da) <- header
da$treatment = as.factor(da$treatment)

# Test common slope
sma_result <- sma(da$Na ~ da$SLA*da$treatment, log = "xy")
summary(sma_result)

#sma_result_new <- sma(da$lg_Na ~ da$lg_SLA*da$treatment)

# test elevation
common_slope <- sma(da$Na ~ da$SLA + da$treatment, log = "xy")
summary(common_slope)

coef(sma_result)
summary(sma_result)

# Construct a plot to check assumptions:
plot(sma_result)

# common slope
common_slope <- line.cis(da$lg_SLA, da$lg_Na, group = da$treatment, common.slope = TRUE)
