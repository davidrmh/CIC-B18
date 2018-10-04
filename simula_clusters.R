library(clusterlab)
library(ggplot2)

##=============================================================##
## Función para simular N clusters gaussianos
##=============================================================##
crea_clusters<-function(num_clust = 5, sdesv = c(1.5,2,0.5,0.2,1), dimension = 2, muestras_cluster = c(10,10,10,10,10), separacion = c(0,1,2,3,4)){
  
  clusters <- clusterlab(centers = num_clust, sdvec = sdesv, features = dimension, numbervec = muestras_cluster, alphas = separacion)
  datos <- t(clusters$synthetic_data)
  datos <- cbind(datos, clusters$identity_matrix[,2])
  datos <- as.data.frame(datos)
  names(datos) <- c("x", "y", "clase")
  datos$clase <- as.factor(datos$clase)
  grafica_clusters(datos)
  return(datos)
}

##=============================================================##
## Función para graficar clusters
##=============================================================##
grafica_clusters <- function(datos){
  g <- ggplot(data = datos, mapping = aes(x = x, y = y))
  g + geom_point(mapping = aes(col = clase), size = 3)
  
}
