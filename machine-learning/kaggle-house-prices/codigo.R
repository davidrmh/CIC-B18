#modelo<-lm(SalePrice ~ YearBuilt + OverallQual + LotArea + GarageCars ,data=entrenamiento)
#predicciones<-predict(modelo,newdata=prueba)


rmse<-function(predicciones,benchmark){
  
  #Se calcula el promedio sin incluir los NA
  indicesNA<-which(is.na(predicciones))
  promedio<-mean(predicciones[-indicesNA])
  
  #Para asegurarnos que se tengan predicciones con valores positivos
  #cambiamos las predicciones negativas por el valor promedio de las predicciones
  indicesNegativos<-which(predicciones<=0)
  predicciones[indicesNegativos]=promedio
  
  #Se sustituyen los NA con el promedio
  predicciones[indicesNA] = promedio
  
  #Se calcula el rmse
  logPredicciones<-log(predicciones)
  logBenchmark<-log(benchmark)
  diferencias<-logPredicciones - logBenchmark
  
  error<-sqrt(mean(diferencias^2))
  
  return (error)
  
  
}