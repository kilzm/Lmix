# Example 3: "fftw-mpi"

An MPI C program that performs a 2d fast fourier transform from the FFTW3 library. The build process is handled by GNU autotools.

## Building with modules

Load the following modules:
* pkgconfig
* autoconf
* autoconf-archive
* automake
* intel-mpi/2019.10.317-intel21
* fftw/3.3.10-intel21-impi

Then use the autotools process:

```bash
autoreconf -i -f -v
export I_MPI_CC=icc  # needed for intels mpicc wrapper
./configure
make
# run it
mpirun -np 4 ./fftw_mpi
```

## Flake

With the aforementioned modules loaded run:

```
nix run . -- ./examples/fftw-mpi
```

The flake has been modified. The environment variable I_MPI_ROOT is set in the devshell which is needed by mpirun. Additionally there is a packages output which calls the derivation specified in default.nix. There is an intel version and a gcc/openmpi version.

## Building from the flake

The autotools process still works as before. Since nix develop initializes a full nix environment the default phases from the generic builder will be available to us:

```bash
autoreconfPhase # essentially runs autoreconf -i -f -v
export I_MPI_CC=icc
configurePhase # runs the configure script
buildPhase # runs make
# run it
mpirun -np 4 ./fftw_mpi
```

## Building as a derivation

The next step is to write the derivation in default.nix which performs these steps for us. We carry over the buildInputs and nativeBuildInputs from the devShell. To make the build process work we need to define I_MPI_CC which we accomplish by modifying the preConfigure hook.

Building our package becomes trivial:

```bash
nix build .#fftw_mpi_intel21_impi # for intel version
nix build .#fftw_mpi_gcc11_ompi # for gcc/openmpi version
```
