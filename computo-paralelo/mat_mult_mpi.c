#include<stdio.h>
#include<mpi.h>
#ifdef _OPENMP
  #include <omp.h>
#endif

#define MASTER_TO_SLAVE_TAG 1
#define SLAVE_TO_MASTER_TAG 4
#define NUM_ROWS_A 1200
#define NUM_ROWS_B 1200
#define NUM_COLUMNS_A 1200
#define NUM_COLUMNS_B 1200
#define n_hilos 8

void inicializa_matrices();
void imprime_matrices();
int rank;
int size;
int i, j, k; //Para loops
double start_time; //Tiempo inicial
double end_time; //Tiempo final
int low_bound; //Cota inferior de los renglones de A que se asignan a un proceso
int upper_bound; //Cota inferior de los renglones de A que se asignan a un proceso
int portion; //Número de renglones asignados a un proceso
double mat_a[NUM_ROWS_A][NUM_COLUMNS_A]; //matriz A
double mat_b[NUM_ROWS_B][NUM_COLUMNS_B]; //matrz B
double mat_result[NUM_ROWS_A][NUM_COLUMNS_B]; //matriz C


MPI_Status status;
MPI_Request request;

int main(int argc, char *argv[])
{
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size); // Número de procesos

    // Proceso maestro
    if (rank == 0) {

        //Inicializa matrices A y B
        inicializa_matrices();

        // Número de renglones asignados a los procesos esclavos
        portion = (NUM_ROWS_A / (size - 1));
        start_time = MPI_Wtime();

        for (i = 1; i < size; i++) {//Procesos esclavos
            low_bound = (i - 1) * portion;
            if (((i + 1) == size) && ((NUM_ROWS_A % (size - 1)) != 0)) {
                upper_bound = NUM_ROWS_A; // Si no se puede dividir el trabajo de manera equitativa
            }
            else {
                upper_bound = low_bound + portion; //Los renglones de A se pueden dividir de manera equitativa
            }
            //Non-blocking (ojo con los tags)
            MPI_Isend(&low_bound, 1, MPI_INT, i, MASTER_TO_SLAVE_TAG, MPI_COMM_WORLD, &request);
            MPI_Isend(&upper_bound, 1, MPI_INT, i, MASTER_TO_SLAVE_TAG + 1, MPI_COMM_WORLD, &request);
            MPI_Isend(&mat_a[low_bound][0], (upper_bound - low_bound) * NUM_COLUMNS_A, MPI_DOUBLE, i, MASTER_TO_SLAVE_TAG + 2, MPI_COMM_WORLD, &request);
        }
    }
    //broadcast [B] hacia todos los procesos esclavos
    MPI_Bcast(&mat_b, NUM_ROWS_B*NUM_COLUMNS_B, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    //Procesos esclavos
    if (rank > 0) {
        MPI_Recv(&low_bound, 1, MPI_INT, 0, MASTER_TO_SLAVE_TAG, MPI_COMM_WORLD, &status);
        MPI_Recv(&upper_bound, 1, MPI_INT, 0, MASTER_TO_SLAVE_TAG + 1, MPI_COMM_WORLD, &status);
        MPI_Recv(&mat_a[low_bound][0], (upper_bound - low_bound) * NUM_COLUMNS_A, MPI_DOUBLE, 0, MASTER_TO_SLAVE_TAG + 2, MPI_COMM_WORLD, &status);

        #pragma omp parallel for private(i,j,k) num_threads(n_hilos)
        for (i = low_bound; i < upper_bound; i++) {//Itera sobre los renglones de A que fueron asignados
            for (j = 0; j < NUM_COLUMNS_B; j++) {
                for (k = 0; k < NUM_ROWS_B; k++) {
                    mat_result[i][j] += (mat_a[i][k] * mat_b[k][j]);
                }
            }
        }
        MPI_Isend(&low_bound, 1, MPI_INT, 0, SLAVE_TO_MASTER_TAG, MPI_COMM_WORLD, &request);
        MPI_Isend(&upper_bound, 1, MPI_INT, 0, SLAVE_TO_MASTER_TAG + 1, MPI_COMM_WORLD, &request);
        MPI_Isend(&mat_result[low_bound][0], (upper_bound - low_bound) * NUM_COLUMNS_B, MPI_DOUBLE, 0, SLAVE_TO_MASTER_TAG + 2, MPI_COMM_WORLD, &request);
    }

    // Proceso maestro junta toda la información
    if (rank == 0) {
        for (i = 1; i < size; i++) {
          // Recibe la información de cada esclavo
            MPI_Recv(&low_bound, 1, MPI_INT, i, SLAVE_TO_MASTER_TAG, MPI_COMM_WORLD, &status);
            MPI_Recv(&upper_bound, 1, MPI_INT, i, SLAVE_TO_MASTER_TAG + 1, MPI_COMM_WORLD, &status);
            MPI_Recv(&mat_result[low_bound][0], (upper_bound - low_bound) * NUM_COLUMNS_B, MPI_DOUBLE, i, SLAVE_TO_MASTER_TAG + 2, MPI_COMM_WORLD, &status);
        }
        end_time = MPI_Wtime();
        //imprime_matrices();
        printf("\nTiempo de ejecución = %f\n\n", end_time - start_time);
    }
    MPI_Finalize();
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
{
    for (i = 0; i < NUM_ROWS_A; i++) {
        printf("\n");
        for (j = 0; j < NUM_COLUMNS_A; j++)
            printf("%8.2f  ", mat_a[i][j]);
    }
    printf("\n\n\n");
    for (i = 0; i < NUM_ROWS_B; i++) {
        printf("\n");
        for (j = 0; j < NUM_COLUMNS_B; j++)
            printf("%8.2f  ", mat_b[i][j]);
    }
    printf("\n\n\n");
    for (i = 0; i < NUM_ROWS_A; i++) {
        printf("\n");
        for (j = 0; j < NUM_COLUMNS_B; j++)
            printf("%8.2f  ", mat_result[i][j]);
    }
    printf("\n\n");
}
