{ stdenv, mpi, fetchurl }:

stdenv.mkDerivation rec {
  pname = "osu-micro-benchmarks";
  version = "5.6.2";

  src = fetchurl {
    url = "mvapich.cse.ohio-state.edu/download/mvapich/${pname}-${version}.tar.gz";
    sha256 = "sha256-LsuQq9hTmHhoI8BxbZJEjXCUZX0/AXxl0nD/45r8e5U=";
  };

  nativeBuildInputs = [ mpi ];

  configureFlags = [
    "CC=${mpi}/bin/mpicc"
    "CXX=${mpi}/bin/mpicxx"
  ];

  enableParallelBuilding = true;
  doCheck = true;

  postInstall = ''
    mkdir $out/bin
    ln -s $out/libexec/${pname}/mpi*/* $out/bin
  '';

}
