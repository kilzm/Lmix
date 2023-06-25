AC_PREREQ([0.29])
AC_INIT([fftw-mpi], [1.0])

AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AX_MPI([], [AC_MSG_ERROR([MPI compiler not found])])
CC=${MPICC}
AC_PROG_CC([$CC])

PKG_PROG_PKG_CONFIG([0.20.0])
PKG_CHECK_MODULES([FFTW], [fftw3 >= 3.1.0])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
