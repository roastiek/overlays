{ pythonPackages }:
pythonPackages.buildPythonApplication rec {
  pname = "snapperS";
  version = "1.1.8";

  src = pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-AxuHiseNGvxUzITxU6z9T3t89YPlRRkA+21EO7Pyfi0=";
  };

  prePatch = ''
    pwd
    ls
    2to3 -wn snapperS/snapperS
    substituteInPlace setup.py --replace '"argparse",' ""
    substituteInPlace snapperS/snapperS --replace 'set -ts' 'set -ts -f'
  '';

  propagatedBuildInputs = [ pythonPackages.tabulate ];


}
