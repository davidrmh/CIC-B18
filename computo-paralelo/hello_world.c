#include <stdio.h>
#ifdef _OPENMP
  #include <omp.h>
#endif

/* Programa para ejecutar en paralelo de acuerdo a un número de
hilos determinados*/

int main(int argc, char *argv[]){
  //Obtiene el número de hilos determinados por el usuario
  int num_hilos;
  int contador = 0;

  printf("Dame el número de hilos\n");
  scanf("%d",&num_hilos);
  //Fija el número de hilos
  #pragma omp parallel num_threads(num_hilos)
  {
    printf("Hello world! desde el hilo %d \n", omp_get_thread_num());
    contador = contador + 1;
    printf("Se han desplegado %d mensajes\n",contador);
  }

  return 0;
}
