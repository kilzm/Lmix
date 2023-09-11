setImpiCompilers() {
    export I_MPI_CC=$CC
    export I_MPI_CXX=$CXX
    export I_MPI_FC=${FC:-}
    export I_MPI_ROOT=@out@
}

addEnvHooks "${hostOffset}" setImpiCompilers