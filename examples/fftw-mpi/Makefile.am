bin_PROGRAMS = fftw_mpi
fftw_mpi_SOURCES = main.c

fftw_mpi_CFLAGS = $(IMPI_CCFLAG) $(FFTW_CFLAGS)
fftw_mpi_LDADD = $(FFTW_LIBS) -lfftw3_mpi

AUTOMAKE_OPTIONS = foreign
