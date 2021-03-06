{ lib, stdenv, fetchFromGitHub, rustPlatform, darwin, cmake
, useMimalloc ? false
, doCheck ? true

# Version specific args
, rev, version, sha256, cargoSha256
}:

rustPlatform.buildRustPackage {
  pname = "rust-analyzer-unwrapped";
  inherit version cargoSha256;

  src = fetchFromGitHub {
    owner = "rust-analyzer";
    repo = "rust-analyzer";
    inherit rev sha256;
  };

  patches = [
    # FIXME: Temporary fix for our rust 1.45.0 since rust-analyzer requires 1.46.0
    ./no-loop-in-const-fn.patch
    ./no-option-zip.patch
  ];

  buildAndTestSubdir = "crates/rust-analyzer";

  cargoBuildFlags = lib.optional useMimalloc "--features=mimalloc";

  nativeBuildInputs = lib.optional useMimalloc cmake;

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin
    [ darwin.apple_sdk.frameworks.CoreServices ];

  RUST_ANALYZER_REV = rev;

  inherit doCheck;
  preCheck = lib.optionalString doCheck ''
    export RUST_SRC_PATH=${rustPlatform.rustcSrc}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    versionOutput="$($out/bin/rust-analyzer --version)"
    echo "'rust-analyzer --version' returns: $versionOutput"
    [[ "$versionOutput" == "rust-analyzer ${rev}" ]]
    runHook postInstallCheck
  '';

  meta = with stdenv.lib; {
    description = "An experimental modular compiler frontend for the Rust language";
    homepage = "https://github.com/rust-analyzer/rust-analyzer";
    license = with licenses; [ mit asl20 ];
    maintainers = with maintainers; [ oxalica ];
  };
}
