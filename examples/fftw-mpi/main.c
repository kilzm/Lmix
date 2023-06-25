#include <stdio.h>
#include <stddef.h>
#include <complex.h>
#include <mpi.h>
#include <fftw3-mpi.h>

int main(int argc, char **argv) {
  int rank, size;
  const ptrdiff_t N0 = 100, N1 = 100;
  fftw_complex *data;
  fftw_plan plan;
  ptrdiff_t alloc_local, local_n0, local_0_start, i, j;
  double t1, t2;
  
  MPI_Init(&argc, &argv);
  fftw_mpi_init();

  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  alloc_local = fftw_mpi_local_size_2d(N0, N1, MPI_COMM_WORLD, &local_n0, &local_0_start);

  data = fftw_alloc_complex(alloc_local);

  plan = fftw_mpi_plan_dft_2d(N0, N1, data, data, MPI_COMM_WORLD, FFTW_FORWARD, FFTW_ESTIMATE);

  for (i = 0; i < local_n0; ++i) {
    for (j = 0; j < N1; ++j) {
      data[i*N1 + j] = i * j;
    }
  }

  MPI_Barrier(MPI_COMM_WORLD);
  t1 = MPI_Wtime();

  fftw_execute(plan);

  MPI_Barrier(MPI_COMM_WORLD);
  t2 = MPI_Wtime();

  if (rank == 0) printf("Time: %gs, Procs: %d\n", t2 - t1, size);

  fftw_destroy_plan(plan);
  fftw_free(data);
  MPI_Finalize();
}
