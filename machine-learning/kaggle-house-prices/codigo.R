#modelo <- lm(SalePrice ~ I(YearBuilt^3) + OverallQual:LotArea + LotArea + GarageCars:LotArea,data=entrena)
#modelo <- lm(SalePrice ~ LotArea, data = entrena)
#predicciones<-predict(modelo,newdata=prueba)


library(ggplot2)

##========================================##
## Función para calcular el RMSE del
## logaritmo de las predicciones
##========================================##
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

##========================================##
## Función para cargar los datos del csv
##========================================##
cargaDatos <- function(path = "train.csv"){
  data <- read.csv(path)
  return(data)
}

##========================================##
## Función para obtener gráficos de
## dispersión
##
## Argumentos:
## x: string con el nombre de la variable x
##
## y: string con el nombre de la variable y
##
## z: string con el nombre de la variable z
## la variable z es para obtener el color
## de los puntos
## 
## datos: data.frame de donde se obtienen
## los datos
##========================================##
graficoDispersion <- function(x,y,z,datos){
  g <- ggplot(data=datos, mapping = aes_string(x = x, y = y, colour = z)) + geom_point()
  g
}

##========================================##
## Función para remover las observaciones
## con SalePrice mayores / menores a 
## dos desviaciones estándar
##
## Atributos:
## datos: data.frame con los datos
##========================================##
quitaExtremos <- function(datos){
  nOrig <- dim(datos)[1] # Num Observaciones originales
  media <- mean(datos$SalePrice)
  desv <- sd(datos$SalePrice)
  limiteSup <- media + 2*desv
  limiteInf <- media - 2*desv
  indicesRemover <- which(datos$SalePrice > limiteSup | datos$SalePrice < limiteInf )
  datos = datos[-indicesRemover,]
  nNew <- dim(datos)[1] #Num de observaciones entre los límites
  print(paste("Se quitaron ",round(100*(nOrig - nNew)/nOrig,2), "% de observaciones",sep=""))
  return(datos)
}

##========================================##
## Función para crear el archivo csv
## que se envía a Kaggle
##
## Atributos:
## predicciones: Vector con las predicciones del modelo
## objetivo: Data.frame con el contenido del archivo "sample_submission.csv"
##========================================##
creaCSVKaggle <- function(predicciones,objetivo){
  #Número de predicciones
  numPred <- length(predicciones)
  datos <- data.frame(Id = objetivo$Id, SalePrice = predicciones)
  write.csv(datos, file = "David-Montalvan-House-Prices-Kaggle.csv", row.names = FALSE)
}

##========================================##
## Función main
##========================================##
main <- function(){
  #Carga conjunto de entrenamiento
  datos <- cargaDatos("train.csv")
  
  #Quita valores extremos del conjunto de entrenamiento
  #Este conjunto será el utilizado para entrenar
  entrena <- quitaExtremos(datos)
  
  #Carga conjunto de prueba
  prueba <- cargaDatos("test.csv")
  
  #Carga valores objetivos
  objetivo <- cargaDatos("sample_submission.csv")
  
  #Ajusta el modelo
  modelo <- lm(SalePrice ~ LotArea, data = entrena)
  
  #Obtiene las predicciones sobre el conjunto de prueba
  predicciones<-predict(modelo,newdata=prueba)
  
  #Calcula el RMSE
  error <- rmse(predicciones, objetivo$SalePrice)
  
  #Crea el CSV con los resultados
  creaCSVKaggle(predicciones,objetivo)
  
  print(paste("El RMSE es ",round(error,6),sep=""))
  
}
