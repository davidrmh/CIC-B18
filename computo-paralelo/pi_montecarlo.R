
estima_pi_montecarlo_lento <- function(radio = 1, num_puntos = 1000){
  #Genera puntos en el rectángulo
  x <- runif(num_puntos, min = -radio, max = radio)
  y <- runif(num_puntos, min = -radio, max = radio)
  
  #Cuenta cuantos puntos cumplen x^2 + y^2 <= radio^2
  contador_adentro <- 0
  for(i in 1:num_puntos){
    if((x[i]^2 + y[i]^2) <= radio^2){
      contador_adentro <- contador_adentro + 1
    }
  }
  #Estima PI
  pi_estimado <- 4*contador_adentro / num_puntos
  
  return(pi_estimado)  
}

estima_pi_montecarlo_rapido <- function(radio = 1, num_puntos = 1000){
  #Genera puntos en el rectángulo
  x <- runif(num_puntos, min = -radio, max = radio)
  y <- runif(num_puntos, min = -radio, max = radio)
  
  #Cuenta cuantos puntos cumplen x^2 + y^2 <= radio^2
  indices_condicion <- which((x^2 + y^2) <= radio^2)
  contador_adentro <- length(indices_condicion)
  #Estima PI
  pi_estimado <- 4*contador_adentro / num_puntos
  
  return(pi_estimado)  
}
