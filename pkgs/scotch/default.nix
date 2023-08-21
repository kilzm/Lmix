{ stdenv
, lib
, fetchFromGitLab
, cmake
, fortran
, mpi
, bzip2
, zlib
, xz
, bison
, flex
}:

stdenv.mkDerivation rec {
  pname = "scotch";
  version = "7.0.3";

  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "scotch";
    repo = "scotch";
    rev = "v${version}";
    sha256 = "sha256-wrOH0+DDzJ6utJYRSZWu2td1dTWJCzgfpNs4/QoiOk8=";
  };

  preConfigure = "echo $I_MPI_ROOT";

  nativeBuildInputs = [ cmake fortran ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  buildInputs = [
    mpi
    bzip2
    zlib
    xz
    bison
    flex
  ];

  passthru = {
    inherit mpi;
  };

  meta = with lib; {
    description = "Package for graph and mesh/hypergraph partitioning, graph clustering, and sparse matrix ordering";
    homepage = "https://www.labri.fr/perso/pelegrin/scotch/";
    license = licenses.cecill-c;
    platform = platforms.unix;
  };
}