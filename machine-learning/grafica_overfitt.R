
evalua_polinomio <- function(x, grado, coeficientes){
  matriz <- poly(x, degree = grado, simple = TRUE, raw = TRUE)
  valor <- as.vector(matriz %*% coeficientes)
  return(valor)
}

set.seed(12345)
grado_target <- 10
n_in <- seq(grado_target + 1, 100, by = 1)
sigma <- seq(0.01, 3, le = length(n_in))
coef_target <- runif(n = grado_target, min = 0.5, max = 10)
n_out <- 20 #número de puntos en out-of-sample
x_out <- runif(n = n_out, min = -5, max = 5)
matriz_resultado <- matrix(0, nrow = length(sigma), ncol = length(sigma))
grado_simple <- 2
grado_complejo <- 10

for(i in 1:length(sigma)){
  sig <- sigma[i]
  
  for(j in 1:length(n_in)){
    
    n <- n_in[j]
    x_in <- runif(n, min = -5, max = 5)
    ruido <- rnorm(n, mean = 0, sd = sig)
    
    matriz_target_in <- poly(x_in, degree = grado_target, simple = TRUE, raw = TRUE)
    target_ruido_in <- as.vector(matriz_target_in %*% coef_target + ruido)
    modelo_complejo <- lm(target_ruido_in ~ poly(x_in, grado_complejo, raw = TRUE) - 1)
    modelo_simple <- lm(target_ruido_in ~ poly(x_in, grado_simple, raw = TRUE) - 1)
    
    matriz_target_out <- poly(x_out, degree = grado_target, simple = TRUE, raw = TRUE)
    ruido_out <- rnorm(length(x_out), mean = 0, sd = sig)
    target_ruido_out <- as.vector(matriz_target_out %*% coef_target + ruido_out)
    pred_out_complejo <- evalua_polinomio(x_out, grado_complejo, modelo_complejo$coefficients)
    pred_out_simple <- evalua_polinomio(x_out, grado_simple, modelo_simple$coefficients)
    
    eout_complejo <- mean((pred_out_complejo - target_ruido_out)^2)
    eout_simple <- mean((pred_out_simple - target_ruido_out)^2)
    
    matriz_resultado[i,j] = eout_complejo - eout_simple
  }
}
