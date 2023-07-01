/*
Copyright (c) 2020-2021 Barcelona Supercomputing Center
Copyright (c) 2003-2020 Eelco Dolstra and the Nixpkgs/NixOS contributors

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

{ stdenv
, fetchurl
, ncurses
, lib
, dpkg
, rsync
, libffi
, libelf
, libxml2
, hwloc
, zlib
, autoPatchelfHook
, symlinkJoin
, libfabric
, rdma-core
, ucx
, gcc
, gcc7
, wrapCCWith
, linuxHeaders
, versions
}:

let
  
  v = versions;

  aptPackageIndex = stdenv.mkDerivation {
    name = "intel-oneapi-packages";
    srcs = [
      ./apt-index/2023-06-05-amd64
      ./apt-index/2023-06-05-all
    ];
    phases = [ "installPhase" ];
    installPhase = ''
      awk -F': ' '\
        BEGIN   { print "[ {" } \
        NR>1 && /^Package: / { print "} {"; } \
        /: /    { printf "%s = \"%s\";\n", $1, $2 } \
        END     { print "} ]" }' $srcs > $out
    '';
  };

  aptPackages = import aptPackageIndex;

  apthost = "https://apt.repos.intel.com/oneapi/";

  getSum = pkgList: name:
  let
    matches = lib.filter (x: name == x.Package) pkgList;
    #n = lib.length matches;
    #match = builtins.trace (name + " -- ${builtins.toString n}") (lib.elemAt matches 0);
    match = lib.elemAt matches 0;
  in
    match.SHA256;

  getUrl = pkgList: name:
  let
    matches = lib.filter (x: name == x.Package) pkgList;
    n = lib.length matches;
    match = lib.elemAt matches 0;
  in
    apthost + match.Filename;

  uncompressDebs = debs: name: stdenv.mkDerivation {
    name = name;
    srcs = debs;
    buildInputs = [ dpkg ];
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      for src in $srcs; do
        echo "unpacking $src"
        dpkg -x $src $out
      done
    '';
  };

  joinDebs = name: names:
  let
    urls = builtins.map (x: getUrl aptPackages x) names;
    sums = builtins.map (x: getSum aptPackages x) names;
    getsrc = url: sha256: fetchurl { inherit url sha256; };
    debs = lib.zipListsWith getsrc urls sums;
  in
    uncompressDebs debs "${name}-source";


  intel-mpi = stdenv.mkDerivation rec {
    version = v.mpi;
    pname = "intel-oneapi-mpi";

    src = joinDebs pname [
      "intel-oneapi-mpi-devel-${version}"
      "intel-oneapi-mpi-${version}"
    ];

    buildInputs = [
      rsync
      libfabric
      rdma-core
      ucx
      zlib
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = [ autoPatchelfHook ];
    phases = [ "installPhase" "fixupPhase" ];
    dontStrip = true;
    installPhase = ''
      mkdir -p $out/{bin,etc,lib,include,libfabric,env}
      mkdir -p $out/share/man

      cd $src

      # MPI
      pushd opt/intel/oneapi/mpi/${version}
        rsync -a man/ $out/share/man/
        rsync -a etc/ $out/etc/
        rsync -a include/ $out/include/
        rsync -a lib/ $out/lib/
        rsync -a libfabric/ $out/libfabric/
        cp env/* $out/env
        # Broken due missing libze_loader.so.1
        rsync -a --exclude IMB-MPI1-GPU bin/ $out/bin/
      popd
    '';
  };

  intel-tbb = stdenv.mkDerivation rec {
    version = v.tbb;
    pname = "intel-oneapi-tbb";
    src = joinDebs pname [
      "intel-oneapi-tbb-${version}"
      "intel-oneapi-tbb-common-${version}"
      "intel-oneapi-tbb-common-devel-${version}"
    ];

    buildInputs = [
      intel-mpi
      rsync
      libffi
      libelf
      libxml2
      hwloc
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = [ autoPatchelfHook ];
    phases = [ "installPhase" "fixupPhase" ];
    dontStrip = true;

    autoPatchelfIgnoreMissingDeps = [ "libhwloc.so.5" ];

    installPhase = ''
      mkdir -p $out/{lib,include}

      cd $src

      pushd opt/intel/oneapi/tbb/${version}
        # Libraries
        rsync -a lib/intel64/gcc4.8/ $out/lib/
        rsync -a include/ $out/include
      popd
    '';
  };

  intel-compiler-shared = stdenv.mkDerivation rec {
    version = v.compiler;
    pname = "intel-compiler-shared";
    src = joinDebs pname [
      "intel-oneapi-compiler-shared-${version}"
      "intel-oneapi-compiler-shared-common-${version}"
      "intel-oneapi-compiler-shared-runtime-${version}"
    ];

    buildInputs = [
      intel-mpi
      intel-tbb
      rsync
      libffi
      libelf
      libxml2
      hwloc
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = [ autoPatchelfHook ];
    phases = [ "installPhase" "fixupPhase" ];
    dontStrip = true;

    autoPatchelfIgnoreMissingDeps = [ "libsycl.so.6" ];

    installPhase = ''
      mkdir -p $out/{bin,lib,include}
      mkdir -p $out/share/man

      cd $src

      # Compiler
      pushd opt/intel/oneapi/compiler/${version}
        pushd linux
          # Binaries
          rsync -a bin/ $out/bin/
          rsync -a --exclude libcilkrts.so.5 bin/intel64/ $out/bin/

          # Libraries
          rsync -a lib/ $out/lib/
          rsync -a lib/x64/ $out/lib/
          rsync -a compiler/lib/intel64_lin/ $out/lib/
          chmod +w $out/lib
          cp bin/intel64/libcilkrts.so.5 $out/lib/
          ln -s $out/lib/libcilkrts.so.5 $out/lib/libcilkrts.so

          # Headers
          rsync -a compiler/include/ $out/include/
        popd
      popd
    '';
  };


  intel-compiler-fortran = stdenv.mkDerivation rec {
    version = v.compiler;
    pname = "intel-fortran";
    src = joinDebs pname [
      "intel-oneapi-compiler-fortran-${version}"
      "intel-oneapi-compiler-fortran-common-${version}"
      "intel-oneapi-compiler-fortran-runtime-${version}"

      "intel-oneapi-compiler-dpcpp-cpp-classic-fortran-shared-runtime-${version}"
      #"intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-${version}"
      #"intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-runtime-${version}"
    ];

    langFortran = true;

    buildInputs = [
      intel-mpi
      intel-compiler-shared
      rsync
      libffi
      libelf
      libxml2
      hwloc
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = [ autoPatchelfHook ];

    phases = [ "installPhase" "fixupPhase" ];

    dontStrip = true;

    installPhase = ''
      mkdir -p $out/{bin,lib,include}
      mkdir -p $out/share/man

      cd $src

      # Compiler
      pushd opt/intel/oneapi/compiler/${version}
        pushd linux
          # Binaries
          rsync -a bin/ $out/bin/
          rsync -a bin/intel64/ $out/bin/

          # Libraries
          rsync -a lib/ $out/lib/
          rsync -a compiler/lib/intel64_lin/ $out/lib/

          # Headers
          rsync -a compiler/include/ $out/include/
        popd

        # Manuals
        rsync -a documentation/en/man/common/ $out/share/man/

        # Fix lib_lin
        ln -s $out/lib $out/lib_lin
      popd
    '';
  };

  intel-compiler = stdenv.mkDerivation rec {
    version = v.compiler;
    pname = "intel-compiler";
    src = joinDebs pname [
      # C/C++
      "intel-oneapi-dpcpp-cpp-${version}"
      "intel-oneapi-compiler-dpcpp-cpp-${version}"
      "intel-oneapi-compiler-dpcpp-cpp-common-${version}"
      "intel-oneapi-compiler-dpcpp-cpp-runtime-${version}"
      "intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-${version}"
      "intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-common-${version}"
      "intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-runtime-${version}"
      "intel-oneapi-compiler-dpcpp-cpp-classic-fortran-shared-runtime-${version}"
    ];
    # From https://aur.archlinux.org/packages/intel-oneapi-compiler:
    # - intel-oneapi-compiler-cpp-eclipse-cfg-2023.0.0-25370_all.deb
    # + intel-oneapi-compiler-dpcpp-cpp-2023.0.0-2023.0.0-25370_amd64.deb
    # x intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2023.0.0-2023.0.0-25370_amd64.deb (empty)
    # + intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2023.0.0-25370_amd64.deb
    # + intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-common-2023.0.0-2023.0.0-25370_all.deb
    # + intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-runtime-2023.0.0-2023.0.0-25370_amd64.deb
    # + intel-oneapi-compiler-dpcpp-cpp-classic-fortran-shared-runtime-2023.0.0-2023.0.0-25370_amd64.deb
    # + intel-oneapi-compiler-dpcpp-cpp-common-2023.0.0-2023.0.0-25370_all.deb
    # + intel-oneapi-compiler-dpcpp-cpp-runtime-2023.0.0-2023.0.0-25370_amd64.deb
    # - intel-oneapi-compiler-dpcpp-eclipse-cfg-2023.0.0-25370_all.deb
    # - intel-oneapi-compiler-fortran-2023.0.0-2023.0.0-25370_amd64.deb
    # - intel-oneapi-compiler-fortran-common-2023.0.0-2023.0.0-25370_all.deb
    # - intel-oneapi-compiler-fortran-runtime-2023.0.0-2023.0.0-25370_amd64.deb
    # - intel-oneapi-compiler-fortran-runtime-2023.0.0-25370_amd64.deb
    # - intel-oneapi-compiler-shared-2023.0.0-2023.0.0-25370_amd64.deb
    # - intel-oneapi-compiler-shared-common-2023.0.0-2023.0.0-25370_all.deb
    # - intel-oneapi-compiler-shared-runtime-2023.0.0-2023.0.0-25370_amd64.deb
    # - intel-oneapi-dpcpp-cpp-2023.0.0-2023.0.0-25370_amd64.deb
    # - intel-oneapi-openmp-2023.0.0-2023.0.0-25370_amd64.deb
    # - intel-oneapi-openmp-common-2023.0.0-2023.0.0-25370_all.deb

    buildInputs = [
      intel-compiler-shared
      rsync
      libffi
      libelf
      libxml2
      hwloc
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = [ autoPatchelfHook ];
    autoPatchelfIgnoreMissingDeps = [ "libtbb.so.12" "libtbbmalloc.so.2" "libze_loader.so.1" ];

    phases = [ "installPhase" "fixupPhase" ];

    dontStrip = true;

    installPhase = ''
      mkdir -p $out/{bin,lib}
      mkdir -p $out/share/man

      cd $src

      # Compiler
      pushd opt/intel/oneapi/compiler/${version}
        pushd linux
          # Binaries
          rsync -a bin/ $out/bin/
          rsync -a bin-llvm/ $out/bin/
          rsync -a bin/intel64/ $out/bin/

          # Libraries
          rsync -a --exclude oclfpga lib/ $out/lib/
          rsync -a compiler/lib/intel64_lin/ $out/lib/

          # Headers
          rsync -a compiler/include/ $out/include/ # Intrinsics for icc
          rsync -a include/ $out/include/
          chmod +w $out/include
          ln -s $out/lib/clang/16.0.0/include/ $out/include/icx # For icx
        popd

        # Manuals
        rsync -a documentation/en/man/common/ $out/share/man/
      popd
    '';
  };

  wrapIntel = { cc, mygcc, extraBuild ? "", extraInstall ? "" }:
    let
      targetConfig = stdenv.targetPlatform.config;
    in (wrapCCWith {
      cc = cc;
      extraBuildCommands = ''
        echo "-isystem ${cc}/include" >> $out/nix-support/cc-cflags
        echo "-isystem ${cc}/include/intel64" >> $out/nix-support/cc-cflags

        echo "-L${mygcc.cc}/lib/gcc/${targetConfig}/${mygcc.version}" >> $out/nix-support/cc-ldflags
        echo "-L${mygcc.cc.lib}/lib" >> $out/nix-support/cc-ldflags
        echo "-L${intel-compiler-shared}/lib" >> $out/nix-support/cc-ldflags
        echo "-L${cc}/lib" >> $out/nix-support/cc-ldflags

        # Need the gcc in the path
        echo 'export "PATH=${mygcc}/bin:$PATH"' >> $out/nix-support/cc-wrapper-hook

        # Disable hardening by default
        echo "" > $out/nix-support/add-hardening.sh
      '' + extraBuild;
    }).overrideAttrs (old: {
      installPhase = old.installPhase + extraInstall;
    });

  icx-wrapper = wrapIntel rec {
    cc = intel-compiler;
    mygcc = gcc;
    extraBuild = ''
      wrap icx  $wrapper $ccPath/icx
      wrap icpx $wrapper $ccPath/icpx
      echo "-isystem ${cc}/include/icx" >> $out/nix-support/cc-cflags
      echo "--gcc-toolchain=${mygcc.cc}" >> $out/nix-support/cc-cflags
    '';
    extraInstall = ''
      export named_cc="icx"
      export named_cxx="icpx"
    '';
  };

  # Legacy
  icc-wrapper = wrapIntel rec {
    cc = intel-compiler;
    # Intel icc classic compiler tries to behave like the gcc found in $PATH.
    # EVEN if it doesn't support some of the features. See:
    # https://community.intel.com/t5/Intel-C-Compiler/builtin-shuffle-GCC-compatibility-and-has-builtin/td-p/1143619
    mygcc = gcc;
    extraBuild = ''
      wrap icc  $wrapper $ccPath/icc
      wrap icpc $wrapper $ccPath/icpc
      echo "-isystem ${cc}/include/icc" >> $out/nix-support/cc-cflags
    '';
    extraInstall = ''
      export named_cc="icc"
      export named_cxx="icpc"
    '';
  };

  ifort-wrapper = wrapIntel rec {
    cc = intel-compiler-fortran;
    mygcc = gcc;
    extraBuild = ''
      wrap ifort  $wrapper $ccPath/ifort
    '';
    extraInstall = ''
      export named_fc="ifort"
    '';
  };

  stdenv-icc = stdenv.override {
    cc = icc-wrapper;
    allowedRequisites = null;
  };

  stdenv-icx = stdenv.override {
    cc = icx-wrapper;
    allowedRequisites = null;
  };

  stdenv-ifort = stdenv.override {
    cc = ifort-wrapper;
    allowedRequisites = null;
  };

in
  {
    inherit aptPackages aptPackageIndex;
    icx = icx-wrapper;
    icc = icc-wrapper;
    ifort = ifort-wrapper;

    mpi = intel-mpi;
    tbb = intel-tbb;

    stdenv = stdenv-icx;
    stdenv-icc = stdenv-icc;
    stdenv-ifort = stdenv-ifort;
  }

