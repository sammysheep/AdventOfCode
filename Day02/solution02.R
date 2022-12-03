#!/usr/bin/env Rscript
# Sam Shepard - 2022

DF=read.table("input.txt",header=FALSE,sep=" ")
DF$TheirPoints <- as.integer(DF$V1)
DF$SelfPoints <- 0

DF$SelfPoints[ DF$V2 == "Y" ] <- DF$TheirPoints[ DF$V2 == "Y" ]
DF$SelfPoints[ DF$V2 == "Z" ] <- DF$TheirPoints[ DF$V2 == "Z" ] %% 3 + 1
DF$SelfPoints[ DF$V2 == "X" ] <- DF$TheirPoints[ DF$V2 == "X" ] - 1
DF$SelfPoints[ DF$SelfPoints == 0 ] <- 3


DF$WonPoints <- (DF$SelfPoints - DF$TheirPoints)
DF$WonPoints[ DF$WonPoints == 0 ] <- 3
DF$WonPoints[ DF$WonPoints ==  1 | DF$WonPoints == -2 ] <- 6
DF$WonPoints[ DF$WonPoints == -1 | DF$WonPoints ==  2 ] <- 0

TotalPoints <- sum(DF$WonPoints + DF$SelfPoints)

print(paste("The points were: ", TotalPoints))