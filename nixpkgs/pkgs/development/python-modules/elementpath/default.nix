{ lib, buildPythonPackage, fetchFromGitHub, isPy27 }:

buildPythonPackage rec {
  version = "1.4.3";
  pname = "elementpath";
  disabled = isPy27; # uses incompatible class syntax

  src = fetchFromGitHub {
    owner = "sissaschool";
    repo = "elementpath";
    rev = "v${version}";
    sha256 = "18gqqdsrdlgwn93xnxy6ifxrk7ppaimijinflphxia2qcm8czkgf";
  };

  # avoid circular dependency with xmlschema which directly depends on this
  doCheck = false;

  pythonImportsCheck = [
    "elementpath.xpath1_parser"
    "elementpath.xpath2_parser"
    "elementpath.xpath2_functions"
    "elementpath.xpath_context"
    "elementpath.xpath_selectors"
  ];

  meta = with lib; {
    description = "XPath 1.0/2.0 parsers and selectors for ElementTree and lxml";
    homepage = "https://github.com/sissaschool/elementpath";
    license = licenses.mit;
    maintainers = with maintainers; [ jonringer ];
  };
}
