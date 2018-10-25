library(ggplot2)
library(parallel)
set.seed(12345)

###==============================================================================
### Función para evaluar el polinomio de Legendre de orden k
###==============================================================================
evalua_legendre <- function(x, k){
  # ENTRADA
  # x: número
  # k: orden del polinomio
  # SALIDA
  # polinomio de Legendre de grado k evaluado en x
  
  if(k %% 2 == 0){
    M<-k /2
  }
  else if ((k - 1) %% 2 == 0 ){
    M <- (k - 1) / 2
  }
  
  suma <-0
  for(m in 0:M){
    suma <- suma + ((-1)^m) * (factorial(2*k - 2*m)) * x^(k - 2*m) / ((2^k) * factorial(m) * factorial(k - m) * factorial(k - 2*m))
  }
  
  return(suma)
  
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
    normalizador <- normalizador + 1 / (2*i + 1)
    suma <- suma + a[i + 1]*evalua_legendre(x, i)
  }
  
  suma <- suma / sqrt(normalizador)
  
  return(suma)
}

polinomio <- function(x,a, grado = 10){
  suma <- 0
  suma_norm <- 0
  for(i in 0:grado){
    suma_norm <- suma_norm + 1 / (2*i + 1)
    suma <- suma + a[i + 1]*(x^i)
  }
  return(suma / sqrt(suma_norm))
}

n_sim <- 15

grado_simple <- 2
grado_complejo <- 10
grado_target <- 15

ptos_muestra <- seq(60, 120, by = 10)
sigma <- seq(0.5, 4, le = length(ptos_muestra))
datos <- expand.grid(sigma = sigma, ptos_muestra = ptos_muestra)
n_rows <- dim(datos)[1]

for(j in 1:n_rows){
  vector_overfitt <- c() 
  
  for(i in 1:n_sim){
    
    sig <- datos$sigma[j]
    n <- datos$ptos_muestra[j]
    print(paste("Simulación = ", i," sigma = ", sig, " N = ", n, sep=""))
    
    x_in <- runif(n, -1, 1)
    ruido <- rnorm(n, 0, sig)
    a <- rnorm(grado_target + 1)
    
    target_determinista_in <- mclapply(x_in, evalua_target, qf = grado_target, a = a)
    target_determinista_in <- simplify2array(target_determinista_in)
    y_in_true <- target_determinista_in + ruido
    modelo_simple <- lm(y_in_true ~ x_in + I(x_in^2))
    modelo_complejo <- lm(y_in_true ~ x_in + I(x_in^2) + I(x_in^3) + I(x_in^4) + I(x_in^5) + I(x_in^6) +I(x_in^7) + I(x_in^8) + I(x_in^9) + I(x_in^10))
    
    x_out <- runif(n, -1, 1)
    target_determinista_out <- mclapply(x_out, evalua_target, qf = grado_target, a = a)
    target_determinista_out <- simplify2array(target_determinista_out)
    y_out_true <- target_determinista_out
    y_pred_simple <- predict(modelo_simple, newdata = as.data.frame(x_out))
    y_pred_complejo <- predict(modelo_complejo, newdata = as.data.frame(x_out))
    
    error_simple <- mean((y_out_true - y_pred_simple)^2)
    error_complejo <- mean((y_out_true - y_pred_complejo)^2)
    
    vector_overfitt <- c(vector_overfitt, error_complejo - error_simple)
    
  }
  
  datos$overfitt[j] <- mean(vector_overfitt)
  
}

chart <- ggplot(data = datos, aes(x = ptos_muestra, y = sigma, z = overfitt)) + geom_tile(aes(fill = overfitt))  + scale_fill_gradient2(low = "blue",mid = "green", high = "red")
print(chart)
