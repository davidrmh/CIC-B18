#include <stdio.h>
#ifdef _OPENMP
  #include <omp.h>
#endif
/* Programa para realizar la suma de dos vectores*/

int main(int argc, char *argv[]){
  int N;
  printf("Dame el tamaño de los vectores \n");
  scanf("%d", &N);
  int a[N], b[N], c[N];
  int num_hilos, i;

  //obtiene el número de hilos
  printf("Dame el número de hilos\n");
  scanf("%d",&num_hilos);

  //Llena los arreglos a y b
  printf("Inicilizando los arreglos\n");
  for(i = 0; i < N; i++){
    a[i] = i;
    b[i] = 2*i;
  }

  //suma
  #pragma omp parallel num_threads(num_hilos) private(i) shared(a,b,c,N)
  {
    #pragma omp for
      for(i = 0; i < N; i++){
        c[i] = a[i] + b[i];
        printf("El hilo %d calculó el índice %d\n",omp_get_thread_num(), i);
      }
  }

  return 0;

}
