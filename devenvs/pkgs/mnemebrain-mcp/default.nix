{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "mnemebrain-mcp";
  version = "1.0.0a1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mnemebrain";
    repo = "mnemebrain-mcp";
    rev = "v${version}";
    hash = "sha256-QDSbcBxmzTENH8Dzb6Y94kUPu+LPo0VqDGt2F3JhJ/w=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = with python3Packages; [
    mcp
    httpx
    pydantic
  ];

  pythonImportsCheck = [ "mnemebrain_mcp" ];

  doCheck = false;

  meta = {
    description = "MCP server for MnemeBrain belief memory system";
    homepage = "https://github.com/mnemebrain/mnemebrain-mcp";
    license = lib.licenses.mit;
    mainProgram = "mnemebrain-mcp";
  };
}
