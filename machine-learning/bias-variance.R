#semilla
set.seed(12345)
#Crea grid para graficar la función objetivo
xgrid <- seq(-1,1,le = 500)
ytrue <- sin(pi * xgrid)

#Número de puntos simulados
N<-100

#n_muestra <- Número de puntos en la muestra
bias_variance<-function(n_muestra = 2){
  
  ##### MODELO CONSTANTE #####
  
  horizontales <- rep(0,N)
  
  for(i in 1:N){
    x <- runif(n = n_muestra, min = -1, max = 1)
    y <- sin(pi*x)
    horizontales[i] <- mean(y)
    
  }
  
  #Calcula g barra para el modelo constante
  horizontales_promedio <- mean(horizontales)
  
  #Calcula el bias para el modelo constante
  bias_const <- mean((horizontales_promedio - ytrue)^2)
  
  #Calcula la varianza para el modelo constate
  var_const <- mean((horizontales - horizontales_promedio)^2)
  
  #Grafica el modelo consante
  mai <- paste ("Bias = ", round(bias_const,2), " Variance = ", round(var_const,2), "\n Bias + Variance = ", round(bias_const + var_const, 2), sep= "")
  sub <- paste("Número de puntos en la muestra = ", n_muestra, sep ="")
  plot(xgrid, ytrue, type = "l", lwd = 5, main = mai, sub = sub, xlab = "x", ylab = "y")
  for(i in 1:N){
    abline(h = horizontales[i], col = "lightblue4")
  }
  abline(h = horizontales_promedio, col ="red", lwd = 5)
  abline(h = horizontales_promedio + sqrt(var_const), col ="green4", lwd = 5, lty = 2)
  abline(h = horizontales_promedio - sqrt(var_const), col ="green4", lwd = 5, lty = 2)
  
  ##### MODELO LÍNEA RECTA #####
  evalua_recta <- function(x, ordenada, pendiente){
    return (ordenada + pendiente*x)
  }
  
  ordenadas <- rep(0, N)
  pendientes <- rep(0, N)
  
  #Genera las rectas 
  for(i in 1:N){
    x <- runif(n = n_muestra, min = -1, max = 1)
    y <- sin(pi*x)
    modelo <- lm(y ~ x)
    ordenadas[i] <- modelo$coefficients[1]
    pendientes[i] <- modelo$coefficients[2]
  }
  
  #calcula g barra para el modelo lineal
  ord_prom <- mean(ordenadas)
  pend_prom <- mean(pendientes)
  
  #calcula el bias para la linea recta
  bias_recta <- mean((evalua_recta(xgrid, ord_prom, pend_prom) - ytrue)^2)
  
  #calcula la varianza para cada punto en xgrid
  var_recta <- rep(0, length(xgrid))
  for(i in 1:length(xgrid)){
    var_recta[i] = mean((evalua_recta(x = rep(xgrid[i], N), ordenadas, pendientes) - evalua_recta(xgrid[i], ord_prom, pend_prom))^2)  
  }
  
  var_recta_total <- mean(var_recta)
  
  #Grafica el modelo lineal
  mai <- paste ("Bias = ", round(bias_recta,2), " Variance = ", round(var_recta_total,2), "\n Bias + Variance = ", round(bias_recta + var_recta_total, 2), sep= "")
  sub <- paste("Número de puntos en la muestra = ", n_muestra, sep ="")
  plot(xgrid, ytrue, type = "l", lwd = 5, main = mai, sub = sub, xlab = "x", ylab = "y", ylim = c(-2,2))
  for(i in 1:N){
    abline(a = ordenadas[i] , b = pendientes[i], col = "lightblue4")
  }
  abline(a = ord_prom, b = pend_prom, col ="red", lwd = 5)
  lines(xgrid, evalua_recta(xgrid, ord_prom, pend_prom) + sqrt (var_recta), lwd = 5, lty = 2, col = "green4")
  lines(xgrid, evalua_recta(xgrid, ord_prom, pend_prom) - sqrt (var_recta), lwd = 5, lty = 2, col = "green4")
  
  
}

