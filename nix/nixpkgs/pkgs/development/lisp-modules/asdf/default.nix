{stdenv, fetchurl, texinfo, texLive, perl}:
let
  s = # Generated upstream information
  rec {
    baseName="asdf";
    version="3.3.2";
    name="${baseName}-${version}";
    hash="1bdrybn97qhny5192ifis8fp8m79djql2k4h9r9q2wnwxf9q2d4x";
    url="http://common-lisp.net/project/asdf/archives/asdf-3.3.2.tar.gz";
    sha256="1bdrybn97qhny5192ifis8fp8m79djql2k4h9r9q2wnwxf9q2d4x";
  };
  buildInputs = [
    texinfo texLive perl
  ];
in
stdenv.mkDerivation {
  inherit (s) name version;
  inherit buildInputs;
  src = fetchurl {
    inherit (s) url sha256;
  };

  buildPhase = ''
    make build/asdf.lisp
    make -C doc asdf.info asdf.html
  '';
  installPhase = ''
    mkdir -p "$out"/lib/common-lisp/asdf/
    mkdir -p "$out"/share/doc/asdf/
    cp -r ./* "$out"/lib/common-lisp/asdf/
    cp -r doc/* "$out"/share/doc/asdf/
    ln -s  "$out"/lib/common-lisp/{asdf/uiop,uiop}
  '';
  meta = {
    inherit (s) version;
    description = ''Standard software-system definition library for Common Lisp'';
    license = stdenv.lib.licenses.mit ;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
  };
}
