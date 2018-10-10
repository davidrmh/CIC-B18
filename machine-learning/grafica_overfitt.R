library(ggplot2)
library(orthopolynom)

evalua_polinomio <- function(x, grado, coeficientes){
  matriz <- matriz_poly(x, grado = grado)
  valor <- as.vector(matriz %*% coeficientes)
  return(valor)
}

matriz_poly <- function(x, grado){
  # ENTRADA
  # x <- vector con los valores a evaluar
  # grado <- entero que especifíca del grado del polinomio
  
  #SALIDA
  # matriz con length(x) renglones y grado + 1 columnas (se incluye el grado 0)
  
  n_reng <- length(x)
  n_col <- grado + 1
  
  #inicializa la matriz
  matriz <- matrix(data = 0, nrow = n_reng, ncol = n_col)
  for(i in 1:n_reng){
    
    for(j in 1:n_col){
      matriz[i, j] <- x[i]^(j-1)
    }
    
  }

  return(matriz)  
}

set.seed(12345)

#Información de la función objetivo
grado_target <- 20

#Obtiene los coeficientes del polinomio de Legendre (Normalizados)
legendre <- legendre.polynomials(grado_target, TRUE)
polinomio <- 0
for(k in 1:length(legendre)){
  polinomio <- legendre[[k]]
}
coef_target <- coefficients(polinomio)

#Particiones del eje x y el eje y
n_in <- seq(grado_target, 50, by = 1)
sigma <- seq(0.01, 5, le = length(n_in))

#Puntos del conjunto de prueba
n_out <- 20 
x_out <- runif(n = n_out, min = -5, max = 5)

#Grados de los polinomios para ajustar
grado_simple <- 2
grado_complejo <- 10

#Para guardar los resultados
datos <- expand.grid(sample_size = n_in, sigma = sigma)

for (i in 1:dim(datos)[1]){
  
  #Número de puntos en la muestra
  n <- datos$sample_size[i]
  x_in <- runif(n, min = -5, max = 5)  
  
  #Ruido
  sig <- datos$sigma[i]
  ruido <- rnorm(n, mean = 0, sd = sig)
  
  #Valores para entrenar los modelos
  matriz_target_in <- matriz_poly(x_in, grado = grado_target)
  target_ruido_in <- as.vector(matriz_target_in %*% coef_target + ruido)
  
  #Ajuste de modelos
  modelo_complejo <- lm(target_ruido_in ~ x_in + I(x_in^2) + I(x_in^3) + I(x_in^4) + I(x_in^5) + I(x_in^6) + I(x_in^7) + I(x_in^8) + I(x_in^9) + I(x_in^10))
  modelo_simple <- lm(target_ruido_in ~ x_in + I(x_in^2) )
  
  #Conjunto de prueba
  matriz_target_out <- matriz_poly(x_out, grado = grado_target)
  ruido_out <- rnorm(length(x_out), mean = 0, sd = sig)
  target_ruido_out <- as.vector(matriz_target_out %*% coef_target + ruido_out)
  
  #Predicciones sobre el conjunto de prueba
  pred_out_complejo <- evalua_polinomio(x_out, grado_complejo, modelo_complejo$coefficients)
  pred_out_simple <- evalua_polinomio(x_out, grado_simple, modelo_simple$coefficients)
  
  #Error fuera de muestra
  eout_complejo <- mean((pred_out_complejo - target_ruido_out)^2)
  eout_simple <- mean((pred_out_simple - target_ruido_out)^2)
  
  #Overfit
  datos$overfit[i] <- eout_complejo - eout_simple
}

#Heatmap
ggplot(data = datos, aes(x = sample_size, y = sigma, z = overfit)) + geom_tile(aes(fill = overfit))  + scale_fill_gradient(low = "blue", high = "red")
