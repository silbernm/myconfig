{ stdenv, fetchurl, fetchpatch, zlib, openssl, libedit, pkgconfig, pam, autoreconfHook, patchutils
, etcDir ? null
, hpnSupport ? false
, withKerberos ? true
, withGssapiPatches ? false
, kerberos
, linkOpenssl? true
}:

let

  # **please** update this patch when you update to a new openssh release.
  gssapiPatch = fetchpatch {
    name = "openssh-gssapi.patch";
    url = "https://salsa.debian.org/ssh-team/openssh/raw/"
      + "e395eed38096fcda74398424ea94de3ec44effd5"
      + "/debian/patches/gssapi.patch";
    sha256 = "0x7xysgdahb4jaq0f28g2d7yzp0d3mh59i4xnffszvjndhvbk27x";
  };

in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "openssh-${version}";
  version = if hpnSupport then "7.7p1" else "7.7p1";

  src = if hpnSupport then
      fetchurl {
        url = "https://github.com/rapier1/openssh-portable/archive/hpn-KitchenSink-7_7_P1.tar.gz";
        sha256 = "1l4k8mg3gnzxbz53cma8s6ak56waz03ijsr08p8vgpi0c2rc5ri5";
      }
    else
      fetchurl {
        url = "mirror://openbsd/OpenSSH/portable/${name}.tar.gz";
        sha256 = "13vbbrvj3mmfhj83qyrg5c0ipr6bzw5s65dy4k8gr7p9hkkfffyp";
      };

  patches =
    [
      # Remove on update!
      (fetchpatch {
        name = "fix-tunnel-forwarding.diff";
        url = "https://github.com/openssh/openssh-portable/commit/cfb1d9bc767.diff";
        sha256 = "1mszj7f1kj6bazr7asbi1bi4238lfpilpp98f6c1dn3py4fbsdg8";
      })

      ./locale_archive.patch
      ./fix-host-key-algorithms-plus.patch

      # See discussion in https://github.com/NixOS/nixpkgs/pull/16966
      ./dont_create_privsep_path.patch

      # CVE-2018-20685, can probably be dropped with next version bump
      # See https://sintonen.fi/advisories/scp-client-multiple-vulnerabilities.txt
      # for details
      (fetchpatch {
        name = "CVE-2018-20685.patch";
        url = https://github.com/openssh/openssh-portable/commit/6010c0303a422a9c5fa8860c061bf7105eb7f8b2.patch;
        sha256 = "1bzbdfww5rbr3kwlvr1hg9glxkz5xr1qg2pc3zmd5z3z5k4sx5fs";
        # remove the CVS headers since they do not apply to this OpenSSH version
        postFetch = ''
          ${patchutils}/bin/filterdiff --lines=1100-1200 --clean "$out" > "$TMPDIR/postFetch"
          mv "$TMPDIR/postFetch" "$out"
        '';
      })
    ]
    ++ optional withGssapiPatches (assert withKerberos; gssapiPatch);

  postPatch =
    # On Hydra this makes installation fail (sometimes?),
    # and nix store doesn't allow such fancy permission bits anyway.
    ''
      substituteInPlace Makefile.in --replace '$(INSTALL) -m 4711' '$(INSTALL) -m 0711'
    '';

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ zlib openssl libedit pam ]
    ++ optional withKerberos kerberos
    ++ optional hpnSupport autoreconfHook
    ;

  preConfigure = ''
    # Setting LD causes `configure' and `make' to disagree about which linker
    # to use: `configure' wants `gcc', but `make' wants `ld'.
    unset LD
  '';

  # I set --disable-strip because later we strip anyway. And it fails to strip
  # properly when cross building.
  configureFlags = [
    "--sbindir=\${out}/bin"
    "--localstatedir=/var"
    "--with-pid-dir=/run"
    "--with-mantype=man"
    "--with-libedit=yes"
    "--disable-strip"
    (if pam != null then "--with-pam" else "--without-pam")
  ] ++ optional (etcDir != null) "--sysconfdir=${etcDir}"
    ++ optional withKerberos (assert kerberos != null; "--with-kerberos5=${kerberos}")
    ++ optional stdenv.isDarwin "--disable-libutil"
    ++ optional (!linkOpenssl) "--without-openssl";

  enableParallelBuilding = true;

  hardeningEnable = [ "pie" ];

  postInstall = ''
    # Install ssh-copy-id, it's very useful.
    cp contrib/ssh-copy-id $out/bin/
    chmod +x $out/bin/ssh-copy-id
    cp contrib/ssh-copy-id.1 $out/share/man/man1/
  '';

  installTargets = [ "install-nokeys" ];
  installFlags = [
    "sysconfdir=\${out}/etc/ssh"
  ];

  meta = {
    homepage = http://www.openssh.com/;
    description = "An implementation of the SSH protocol";
    license = stdenv.lib.licenses.bsd2;
    platforms = platforms.unix;
    maintainers = with maintainers; [ eelco aneeshusa ];
  };
}
