{ stdenv
, cmake
, fetchurl
, python
, blas
, lapack
, gfortran
, suitesparse
, lapackSupport ? true
, kluSupport ? true }:

assert (!blas.isILP64) && (!lapack.isILP64);

stdenv.mkDerivation rec {
  pname = "sundials";
  version = "5.3.0";

  buildInputs = [
    python
  ] ++ stdenv.lib.optionals (lapackSupport) [
    gfortran
    blas
    lapack
  ] 
  # KLU support is based on Suitesparse.
  # It is tested upstream according to the section 1.1.4 of
  # [INSTALL_GUIDE.pdf](https://raw.githubusercontent.com/LLNL/sundials/master/INSTALL_GUIDE.pdf)
  ++ stdenv.lib.optionals (kluSupport) [
    suitesparse
  ];

  nativeBuildInputs = [ cmake ];

  src = fetchurl {
    url = "https://computation.llnl.gov/projects/${pname}/download/${pname}-${version}.tar.gz";
    sha256 = "19xwi7pz35s2nqgldm6r0jl2k0bs36zhbpnmmzc56s1n3bhzgpw8";
  };

  patches = [
    (fetchurl {
      # https://github.com/LLNL/sundials/pull/19
      url = "https://github.com/LLNL/sundials/commit/1350421eab6c5ab479de5eccf6af2dcad1eddf30.patch";
      sha256 = "0g67lixp9m85fqpb9rzz1hl1z8ibdg0ldwq5z6flj5zl8a7cw52l";
    })
  ];

  cmakeFlags = [
    "-DEXAMPLES_INSTALL_PATH=${placeholder "out"}/share/examples"
  ] ++ stdenv.lib.optionals (lapackSupport) [
    "-DSUNDIALS_INDEX_TYPE=int32_t"
    "-DLAPACK_ENABLE=ON"
    "-DLAPACK_LIBRARIES=${lapack}/lib/liblapack${stdenv.hostPlatform.extensions.sharedLibrary}"
  ] ++ stdenv.lib.optionals (kluSupport) [
    "-DKLU_ENABLE=ON"
    "-DKLU_INCLUDE_DIR=${suitesparse.dev}/include"
    "-DKLU_LIBRARY_DIR=${suitesparse}/lib"
  ];

  doCheck = true;
  checkPhase = "make test";

  meta = with stdenv.lib; {
    description = "Suite of nonlinear differential/algebraic equation solvers";
    homepage    = "https://computation.llnl.gov/projects/sundials";
    platforms   = platforms.all;
    maintainers = with maintainers; [ flokli idontgetoutmuch ];
    license     = licenses.bsd3;
  };
}
