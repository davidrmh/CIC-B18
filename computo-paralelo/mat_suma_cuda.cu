#include <stdio.h>
#include <stdlib.h>

#define N 20
#define BLOCK_DIM 20
double mat_a[N][N]; //matriz A
double mat_b[N][N]; //matrz B
double mat_result[N][N]; //matriz C

//Contadores de los loops for
int i,j,m;

//Flag para imprimir los resultados
int flag;

__global__ void suma(double *A, double *B, double *C){

	//índices de los hilos
	int columna = blockIdx.x * blockDim.x + threadIdx.x;
	int renglon = blockIdx.y * blockDim.y + threadIdx.y;
	int indice = columna + renglon*N;

	//suma
	if(columna < N && renglon < N){
		C[indice] = A[indice] + B[indice];
	}
}

void inicializa_matrices();
void imprime_matrices();

int main(int argc, char *argv[]){

	//Inicializa matrices A y B
	inicializa_matrices();

	//Se imprimen resultados?
	flag = atoi(argv[1]);


//Variables utilizadas por el device
int size = N*N*sizeof(double);
double *pA, *pB, *pC;

//Memory allocation en el device
cudaMalloc((void**)&pA, size);
cudaMalloc((void**)&pB, size);
cudaMalloc((void**)&pC, size);

//Se copian las matrices del host al device
cudaMemcpy(pA, mat_a, size, cudaMemcpyHostToDevice);
cudaMemcpy(pB, mat_b, size, cudaMemcpyHostToDevice);


dim3 dimBlock(BLOCK_DIM,BLOCK_DIM);
dim3 dimGrid((int)ceil(N/dimBlock.x),(int)ceil(N/dimBlock.y));
suma<<<dimGrid,dimBlock>>>(pA,pB,pC);

cudaMemcpy(mat_result, pC, size, cudaMemcpyDeviceToHost);

	if (flag !=0){
		imprime_matrices();	
	}

cudaFree(pA); 
cudaFree(pB); 
cudaFree(pC);

return 0;
}

void inicializa_matrices()
{
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            mat_a[i][j] = i + j;
        }
    }
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            mat_b[i][j] = i*j;
        }
    }
}
void imprime_matrices()
{   printf("Matriz A \n");
    for (i = 0; i < N; i++) {
        printf("\n");
        for (j = 0; j < N; j++)
            printf("%8.2f  ", mat_a[i][j]);
    }
    printf("\n\n\n");
    printf("Matriz B \n");
    for (i = 0; i < N; i++) {
        printf("\n");
        for (j = 0; j < N; j++)
            printf("%8.2f  ", mat_b[i][j]);
    }
    printf("\n\n\n");
    printf("Matriz C = A + B\n");
    for (i = 0; i < N; i++) {
        printf("\n");
        for (j = 0; j < N; j++)
            printf("%8.2f  ", mat_result[i][j]);
    }
    printf("\n\n");
}
