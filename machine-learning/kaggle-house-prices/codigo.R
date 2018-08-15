#modelo<-lm(SalePrice ~ YearBuilt + OverallQual + LotArea + GarageCars ,data=entrenamiento)
#modelo <- lm(SalePrice ~ I(YearBuilt^3) + OverallQual:LotArea + LotArea + GarageCars:LotArea,data=entrena2)
#predicciones<-predict(modelo,newdata=prueba)


rmse<-function(predicciones,benchmark){

  #Se calcula el promedio sin incluir los NA
  indicesNA<-which(is.na(predicciones))

  if(length(indicesNA)){
   promedio <- mean(predicciones[-indicesNA])
  }

  else{promedio <- mean(predicciones)}


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
