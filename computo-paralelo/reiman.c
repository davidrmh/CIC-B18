#include <stdio.h>
#include <math.h>
#ifdef _OPENMP
#include <omp.h>
#endif

int main(int argc, char *argv[]){

  double sum = 0.0;
  int n = 2;
  long limit = 10000000000;
  #pragma omp parallel for reduction(+: sum)
  for(int k=limit ; k>0; k--){
    sum = sum + 1.0 / pow(k, (double) n);
  }

  printf("La suma es: %5f\n", sum);

  return(0);
}
