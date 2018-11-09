#include <stdio.h>
#include <stdlib.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#ifdef _OPENMP
  #include <omp.h>
#endif
/* Programa para estimar PI utilizando simulación Monte Carlo

Para compilar:
gcc -I /usr/local/include/gsl/ -o pi_montecarlo pi_montecarlo.c -lgsl -lgslcblas -fopenmp

Uso
./pi_montecarlo NUM_SIM
*/

int main(int argc, char *argv[]){

  // argv[1] es el número de simulaciones
  long num_sim = atoi(argv[1]);

  // argv[2] es el número de hilos
  int n_threads = atoi(argv[2]);

  //radio
  float radio = 1.0;
  float radio2 = radio*radio;

  //Para la generación de números aleatorios
  const gsl_rng_type * T;
  gsl_rng * r;
  gsl_rng_env_setup();
  T = gsl_rng_default;
  r = gsl_rng_alloc (T);
  double x, y, u;

  //Para el loop
  int i;

  //Contador de puntos que caen en el círculo
  long contador_adentro = 0;

  #pragma omp parallel for private(u,x,y) num_threads(n_threads)
    for(i = 0; i < num_sim; i++){

      u = gsl_rng_uniform (r);
      x = -radio + (radio + radio)*u;
      u = gsl_rng_uniform (r);
      y = -radio + (radio + radio)*u;

      if((x*x + y*y) <= radio2){
        #pragma omp critical
        contador_adentro = contador_adentro + 1;
      }
    }
    
  //calcula PI
  float pi = (float) 4*contador_adentro / num_sim;

  printf("PI estimado %.5f\n", pi);

  return 0;
}
