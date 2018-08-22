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
## colName: String con el nombre de la columna de interés
##========================================##
quitaExtremos <- function(datos,colName="SalePrice"){
  nOrig <- dim(datos)[1] # Num Observaciones originales
  media <- mean(datos[,colName])
  desv <- sd(datos[,colName])
  limiteSup <- media + 2*desv
  limiteInf <- media - 2*desv
  indicesRemover <- which(datos[,colName] > limiteSup | datos[,colName] < limiteInf )
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
## Función para crear un conjunto de 
## prueba ficticio
##
## Argumentos:
## datos: Dataframe con los datos del archivo "train.csv"
## prop: Proporción del conjunto de entrenamiento (número en (0,1))
##
## Salida:
## Una lista con [["entrenamiento"]] el conjunto de entrenamiento
## [["prueba"]] el conjunto de prueba
##========================================##
creaConjuntoPrueba <-function(datos,prop=0.8){
  #Obtiene el número de renglones
  renglonesTotal <- dim(datos)[1]
  
  #Obtiene los renglones del conjunto de entrenamiento
  numRenEntrena <- round(renglonesTotal*prop)
  renglonesEntrena <- sample(seq(1,renglonesTotal,by=1),
                             size = numRenEntrena, replace = FALSE)
  
  #Crea el conjunto de entrenamiento
  entrena <- datos[renglonesEntrena,]
  
  #crea el conjunto de prueba
  prueba <- datos[-renglonesEntrena,]
  
  lista <- list(entrenamiento = entrena,prueba = prueba)
  return(lista)
}

##========================================##
## Función para cambiar los NA
##
## Argumentos
## datos: Dataframe con los datos de interés
## columna: String con el nombre de la columna de interés
## valor: Valor por el cual se cambiarán los NA
##
## Salida
## Dataframe datos con los NA de la columna modificados
##========================================##
cambiaNA <-function(datos,columna,valor){
  #Busca las observaciones a modificar
  indices <-which(is.na(datos[columna]))
  
  #El tipo de dato original
  tipoOriginal <- class(datos[,columna])
  
  #convierte a character toda la columna
  datos[,columna] = as.character(datos[,columna])
  
  #Cambia los renglones con NA
  datos[indices,columna] = as.character(valor)
  
  #Regresa al tipo de dato original (TRUCO)
  datos[,columna] = as.factor(datos[,columna])
  datos[,columna] = as(datos[,columna],tipoOriginal)
  
  return(datos)
}

##========================================##
## Función main
##
## Argumentos
## prop: Proporción del conjunto de entrenamiento (número en (0,1))
##========================================##
main <- function(prop=0.8){
  #No olvidar fijar una semilla
  set.seed(12345)
  
  #Carga conjunto de entrenamiento
  datos <- cargaDatos("train.csv")
  
  #Carga conjunto de prueba (el real)
  pruebaReal <- cargaDatos("test.csv")
  
  #Cambia los NA necesarios
  datos <- cambiaNA(datos,"GarageFinish","N")
  pruebaReal <- cambiaNA(pruebaReal,"GarageFinish","N")
  
  #Obtiene conjuntos de entrenamiento y prueba ficticios
  lista <- creaConjuntoPrueba(datos,prop)
  entrenaFicticio <-lista[["entrenamiento"]]
  pruebaFicticio <-lista[["prueba"]]
  
  #Quita valores extremos del conjunto de entrenamiento
  entrenaReal <- quitaExtremos(datos,"GrLivArea")
  entrenaFicticio <- quitaExtremos(entrenaFicticio,"GrLivArea") 
  
  #Carga el archivo ejemplo
  ejemplo <- cargaDatos("sample_submission.csv")
  
  #Ajusta el modelo
  modeloFicticio <- lm(SalePrice ~  GrLivArea * YearBuilt * YearRemodAdd*GarageFinish,
                       data=entrenaFicticio)
  modeloReal <- lm(SalePrice ~  GrLivArea * YearBuilt * YearRemodAdd*GarageFinish,
                   data=entrenaReal)
  
  #Obtiene las predicciones sobre el conjunto de prueba y de entrenamiento
  prediccionesEntrenaReal<-predict(modeloReal,newdata=entrenaReal)
  prediccionesPruebaReal<-predict(modeloReal,newdata=pruebaReal)
  prediccionesEntrenaFicticio <- predict(modeloFicticio, newdata = entrenaFicticio)
  prediccionesPruebaFicticio <- predict(modeloFicticio, newdata = pruebaFicticio)
  
  #Calcula el RMSE sobre el conjunto de entrenamiento
  errorEntrenaReal <- rmse(prediccionesEntrenaReal, entrenaReal$SalePrice)
  errorEntrenaFicticio <- rmse(prediccionesEntrenaFicticio,entrenaFicticio$SalePrice)
  errorPruebaFicticio <- rmse(prediccionesPruebaFicticio,pruebaFicticio$SalePrice)
  
  
  #Crea el CSV con los resultados
  creaCSVKaggle(prediccionesPruebaReal,ejemplo)
  
  print(paste("El RMSE de EntrenaReal es ", round(errorEntrenaReal,4),sep=""))
  print(paste("El RMSE de EntrenaFicticio es ", round(errorEntrenaFicticio,4),sep=""))
  print(paste("El RMSE de PruebaFicticio es ", round(errorPruebaFicticio,4),sep=""))
  
}
