library(ggplot2)

###==============================================================================
### Función para evaluar un polinomio
###==============================================================================
evalua_polinomio <- function(x, grado, coeficientes){
  matriz <- matriz_poly(x, grado = grado)
  valor <- as.vector(matriz %*% coeficientes)
  return(valor)
}

###==============================================================================
### Función para obtener la matriz con columnas x^i, i=0,...,grado
###==============================================================================
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

###==============================================================================
### Función para evaluar el polinomio de Legendre de orden k
###==============================================================================
evalua_legendre <- function(x, k){
  # ENTRADA
  # x: número
  # k: orden del polinomio
  # SALIDA
  # polinomio de Legendre de grado k evaluado en x
  
  if( k == 0){return(1)}
  else if(k == 1){return(x)}
  else{
    return( ((2*k -1 )/ k)*x*evalua_legendre(x, k - 1) - ((k - 1) / k) * evalua_legendre(x, k - 2) )
  }
  
}

###==============================================================================
### Función para evaluar \sum_{q = 0}^{qf} a[q]*L[q](x)
###==============================================================================
evalua_target <- function(x, qf, a){
  # ENTRADA
  # X: Número
  # qf: Grado del polinomio
  # a: Vector de longitud qf + 1 con variables aleatorias Normal(0,1)
  # SALIDA
  # \sum_{q = 0}^{qf} a[q]*L[q](x)
  # La suma es normalizada (E[f^2] = 1)
  
  suma <- 0
  normalizador <- 0
  for(i in 0:qf){
    normalizador <- normalizador + (evalua_legendre(x, i))^2
    suma <- suma + a[i + 1]*evalua_legendre(x, i)
  }
  
  suma <- suma / sqrt(normalizador)
  
  return(suma)
}

set.seed(12345)

#Información de la función objetivo
grado_target <- 15 #parámetro Qf

#Particiones del eje x y el eje y
n_in <- seq(10, 100, by = 10) #Número de puntos muestrales
sigma <- seq(0.01, 3, le = length(n_in))

#Puntos del conjunto de prueba
n_out <- 10 


#Grados de los polinomios para ajustar
grado_simple <- 2
grado_complejo <- 10

#Para guardar los resultados
datos <- expand.grid(sample_size = n_in, sigma = sigma)

#Número de simulaciones para cada modelo ajustado
n_sim <- 20

#Auxiliar para calcular el overfitt promedio
aux_overfitt <- c()

#Coeficientes
vector_a <- rnorm(grado_target + 1)

for (i in 1:dim(datos)[1]){
  
  aux_overfitt <- c()
  
  for(j in 1:n_sim){
    print(paste("Simulación = ", j, "Sample size = ", datos$sample_size[i], "Sigma = ", datos$sigma[i]))
    #Número de puntos en la muestra
    n <- datos$sample_size[i]
    x_in <- runif(n, min = -1, max = 1)  
    
    #Ruido
    sig <- datos$sigma[i]
    ruido <- rnorm(n, mean = 0, sd = sig)
    
    #Valores para entrenar los modelos (función target + ruido)
    target_determinista_in <- c()
    for(x in x_in){
      f_in <- evalua_target(x, grado_target, vector_a)
      target_determinista_in <- c(target_determinista_in, f_in)
    }
    target_ruido_in <- target_determinista_in + ruido
    
    #Ajuste de modelos
    modelo_complejo <- lm(target_ruido_in ~ x_in + I(x_in^2) + I(x_in^3) + I(x_in^4) + I(x_in^5) + I(x_in^6) + I(x_in^7) + I(x_in^8) + I(x_in^9) + I(x_in^10))
    modelo_simple <- lm(target_ruido_in ~ x_in + I(x_in^2) )
    
    #Conjunto de prueba
    x_out <- runif(n = n_out, min = -1, max = 1)
    ruido_out <- rnorm(length(x_out), mean = 0, sd = sig)
    target_determinista_out <- c()
    for(x in x_out){
      f_out <- evalua_target(x, grado_target, vector_a)
      target_determinista_out <- c(target_determinista_out, f_out)
    }
    target_ruido_out <- target_determinista_out + ruido_out
    
    #Predicciones sobre el conjunto de prueba
    pred_out_complejo <- evalua_polinomio(x_out, grado_complejo, modelo_complejo$coefficients)
    pred_out_simple <- evalua_polinomio(x_out, grado_simple, modelo_simple$coefficients)
    
    #Error fuera de muestra
    eout_complejo <- mean((pred_out_complejo - target_ruido_out)^2)
    eout_simple <- mean((pred_out_simple - target_ruido_out)^2)
    
    aux_overfitt <- c(aux_overfitt, eout_complejo - eout_simple)
    
    
  }
  
  #Overfit
  datos$overfit[i] <- mean(aux_overfitt)
}

#Heatmap
chart <- ggplot(data = datos, aes(x = sample_size, y = sigma, z = overfit)) + geom_tile(aes(fill = overfit))  + scale_fill_gradient(low = "blue", high = "red")
print(chart)
