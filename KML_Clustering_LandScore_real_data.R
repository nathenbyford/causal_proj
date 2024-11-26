## Longitudinal data clustering (real data)
## Author: Haliduola 

setwd("datapath") 
getwd()

install.packages('kml', lib = 'package_path')
library(clv,lib.loc = 'package_path')
library(longitudinalData, lib.loc = 'package_path')
library(kml, lib.loc = 'package_path')

rm(list = ls())


############################################################################
## Read in the real data 
land_score = read.csv("data\land_score_real_data.csv")

# clustering is done within each treatment group

################### Treatment group=0 ######################################
trt0 <- subset(land_score,treat==0,select=c(-treat))

# run the algorithm 
cld.trt0 <- cld(traj=trt0,time=c(0,1,2,4,6),varNames="week")
kml(cld.trt0,toPlot="both")

# user define to have 3 clusters, to see the best partition with 3 clusters
plotTraj(cld.trt0,3)

# get the clustering results
trt0$cluster <- getClusters(cld.trt0,3,1)

# Re-code cluster results
trt0$clustn <- ifelse(trt0$cluster=="B", 1,
               ifelse(trt0$cluster=="A", 2,
               ifelse(trt0$cluster=="C", 3, 999)))

cluster_trt0 <- subset(trt0, select=c(id,clustn))
#table(cluster_trt0$clustn)



################### Treatment group=1 ######################################
trt1 <- subset(land_score,treat==1,select=c(-treat))

# run the algorithm 
cld.trt1 <- cld(traj=trt1,time=c(0,1,2,4,6),varNames="week")
kml(cld.trt1,toPlot="both")

# user define to have 3 clusters, to see the best partition with 3 clusters
plotTraj(cld.trt1,3)


# get the clustering results
trt1$cluster <- getClusters(cld.trt1,3,1)

# Re-code cluster results
trt1$clustn <- ifelse(trt1$cluster=="C", 4,
               ifelse(trt1$cluster=="A", 5,
               ifelse(trt1$cluster=="B", 6, 999)))

cluster_trt1 <- subset(trt1, select=c(id,clustn))
#table(cluster_trt1$clustn)



############################################################################
## Combine cluster from two treatment group 
cluster <- rbind(cluster_trt1,cluster_trt0)
cluster <- cluster[order(cluster$id),]


############################################################################
## Save cluster results into CSV files  
write.csv(cluster, file.path("\supporting_information\2_real_data\2.2_clustering\cluster_real_data.csv"))
  
