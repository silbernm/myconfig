{ stdenv, buildPythonPackage, fetchFromGitHub, pytest }:

buildPythonPackage rec {
  pname = "boltons";
  version = "19.1.0";

  # No tests in PyPi Tarball
  src = fetchFromGitHub {
    owner = "mahmoud";
    repo = "boltons";
    rev = version;
    sha256 = "0b55wly0ksviyl3a4dmih9vzd7bj3p10gr6la4722cs9cx4128q5";
  };

  checkInputs = [ pytest ];
  checkPhase = "pytest tests";

  meta = with stdenv.lib; {
    homepage = https://github.com/mahmoud/boltons;
    description = "220+ constructs, recipes, and snippets extending (and relying on nothing but) the Python standard library";
    longDescription = ''
      Boltons is a set of over 220 BSD-licensed, pure-Python utilities
      in the same spirit as — and yet conspicuously missing from — the
      standard library, including:

      - Atomic file saving, bolted on with fileutils
      - A highly-optimized OrderedMultiDict, in dictutils
      - Two types of PriorityQueue, in queueutils
      - Chunked and windowed iteration, in iterutils
      - Recursive data structure iteration and merging, with iterutils.remap
      - Exponential backoff functionality, including jitter, through
      iterutils.backoff
      - A full-featured TracebackInfo type, for representing stack
      traces, in tbutils
    '';
    license = licenses.bsd3;
    maintainers = with maintainers; [ twey ];
  };
}
