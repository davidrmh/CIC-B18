##================= EJERCICIO 1.10================##
## David R. Montalván Hernández
## Página 23
##================================================##

####################################################
## Función para inicializar las 1000 monedas
####################################################
inicializa_monedas <-function(num_monedas = 1000, num_tiros = 10){
  
  #lista con las 1000 monedas
  lista_monedas <- list()
  
  #tira 10 veces cada moneda
  for(i in 1:num_monedas){
    lista_monedas[[i]] = rbinom(num_tiros,1,0.5) # 1 = Head, 0 = Tail
  }
  
  return(lista_monedas)
}

####################################################
## Función para encontrar c_min
####################################################
encuentra_min <- function(lista_monedas){
  # ENTRADA
  # lista_monedas: lista creada con la función inicializa monedas
  #
  # SALIDA
  # c_min: vector que representa la moneda con el menor número de 1's
  
  minimo <- 100000
  index_min <- 0
  
  for(i in 1:length(lista_monedas)){
    suma <- sum(lista_monedas[[i]])
    
    if(suma < minimo){
      minimo <- suma
      index_min <- i
    }
    
  }
  
  c_min <- lista_monedas[[index_min]]
  
  return(c_min)
  
}

####################################################
## Inciso B
####################################################
inciso_b <- function(num_sim = 100000, num_monedas = 1000, num_tiros = 10){
  
  v1 <- c()
  v_rand <- c()
  v_min <- c()
  
  for(i in 1:num_sim){
    
    lista_monedas <- inicializa_monedas(num_monedas, num_tiros)
    
    #moneda c1
    c1 <- lista_monedas[[1]]
    
    #moneda c_rand
    c_rand <- lista_monedas[[sample(1:num_monedas, 1)]]
    
    #moneda c_min
    c_min <- encuentra_min(lista_monedas)
    
    #proporciones
    v1 <- c(v1, sum(c1) / num_tiros)
    v_rand <- c(v_rand, sum(c_rand) / num_tiros)
    v_min <- c(v_min, sum(c_min) / num_tiros)
  }
  
  #Histogramas
  hist(v1)
  hist(v_rand)
  hist(v_min)
  
  lista_prop <- list(v1, v_rand, v_min)
  names(lista_prop) <- c("v1", "v_rand", "v_min")
  return(lista_prop)
}
