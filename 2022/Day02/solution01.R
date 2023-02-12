#!/usr/bin/env Rscript
# Sam Shepard - 2022

DF=read.table("input.txt",header=FALSE,sep=" ")
DF$TheirPoints <- as.integer(DF$V1)
DF$SelfPoints <- as.integer(DF$V2)

DF$WonPoints <- (DF$SelfPoints - DF$TheirPoints)
DF$WonPoints[ DF$WonPoints == 0 ] <- 3
DF$WonPoints[ DF$WonPoints ==  1 | DF$WonPoints == -2 ] <- 6
DF$WonPoints[ DF$WonPoints == -1 | DF$WonPoints ==  2 ] <- 0

TotalPoints <- sum(DF$WonPoints + DF$SelfPoints)

print(paste("The points were: ", TotalPoints))