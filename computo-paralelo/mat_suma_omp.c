/* Suma de matrices utilizando OMP
/* Uso: ./mat_mult_omp 0 (para no desplegar resultados)
/* ./mat_mult_omp 1 (para desplegar resultados)
*/

#include<stdio.h>
#include<stdlib.h>
#ifdef _OPENMP
  #include <omp.h>
#endif

#define NUM_ROWS_A 10
#define NUM_ROWS_B 10
#define NUM_COLUMNS_A 10
#define NUM_COLUMNS_B 10

double mat_a[NUM_ROWS_A][NUM_COLUMNS_A]; //matriz A
double mat_b[NUM_ROWS_B][NUM_COLUMNS_B]; //matrz B
double mat_result[NUM_ROWS_A][NUM_COLUMNS_B]; //matriz C

//Contadores de los loops for
int i,j,m;

//Flag para imprimir los resultados
int flag;



void inicializa_matrices();
void imprime_matrices();

int main(int argc, char *argv[]){
	//Inicializa matrices A y B
	inicializa_matrices();

	//Se imprimen resultados?
	flag = atoi(argv[1]);

	//Suma
	#pragma omp parallel for private(i,j)
	for(i = 0; i< NUM_ROWS_A; i++){

		for(j = 0; j < NUM_COLUMNS_B; j++){

            mat_result[i][j] = mat_a[i][j] + mat_b[i][j];

		}
	}

	if (flag !=0){
		imprime_matrices();	
	}
	
	return 0;
}

void inicializa_matrices()
{
    for (i = 0; i < NUM_ROWS_A; i++) {
        for (j = 0; j < NUM_COLUMNS_A; j++) {
            mat_a[i][j] = i + j;
        }
    }
    for (i = 0; i < NUM_ROWS_B; i++) {
        for (j = 0; j < NUM_COLUMNS_B; j++) {
            mat_b[i][j] = i*j;
        }
    }
}
void imprime_matrices()
{   printf("Matriz A \n");
    for (i = 0; i < NUM_ROWS_A; i++) {
        printf("\n");
        for (j = 0; j < NUM_COLUMNS_A; j++)
            printf("%8.2f  ", mat_a[i][j]);
    }
    printf("\n\n\n");
    printf("Matriz B \n");
    for (i = 0; i < NUM_ROWS_B; i++) {
        printf("\n");
        for (j = 0; j < NUM_COLUMNS_B; j++)
            printf("%8.2f  ", mat_b[i][j]);
    }
    printf("\n\n\n");
    printf("Matriz C = A + B\n");
    for (i = 0; i < NUM_ROWS_A; i++) {
        printf("\n");
        for (j = 0; j < NUM_COLUMNS_B; j++)
            printf("%8.2f  ", mat_result[i][j]);
    }
    printf("\n\n");
}
