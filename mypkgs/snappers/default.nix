{ pythonPackages }:
pythonPackages.buildPythonApplication rec {
  pname = "snapperS";
  version = "1.1.8";

  src = ./src;

  propagatedBuildInputs = [ pythonPackages.tabulate ];

  pyproject = true;
  build-system = with pythonPackages; [ setuptools ];

}
