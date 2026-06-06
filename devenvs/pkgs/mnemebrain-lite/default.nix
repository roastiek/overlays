{
  lib,
  python3Packages,
  fetchFromGitHub,
  withApi ? true,
  withEmbeddings ? true,
  withOpenai ? false,
}:

python3Packages.buildPythonPackage rec {
  pname = "mnemebrain-lite";
  version = "0.1.0a6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mnemebrain";
    repo = "mnemebrain-lite";
    rev = "v${version}";
    hash = "sha256-3/EzbNKE9i/IslcWfUB9iA6LkGXxhJRE1SEzfFYnkhs=";
  };

  patches = [ ./socket-activation.patch ];

  build-system = [ python3Packages.hatchling ];

  # Upstream pins numpy<2.0 but the code works fine with numpy 2.x
  pythonRelaxDeps = [ "numpy" ];

  dependencies = with python3Packages;
    [
      pydantic
      kuzu
      numpy
      httpx
    ]
    ++ lib.optionals withApi [
      fastapi
      uvicorn
    ]
    ++ lib.optionals withEmbeddings [
      sentence-transformers
    ]
    ++ lib.optionals withOpenai [
      openai
    ];

  pythonImportsCheck = [ "mnemebrain_core" ];

  # Tests require running database
  doCheck = false;

  meta = {
    description = "Give your AI a real brain - belief memory with evidence, confidence, and revision logic";
    homepage = "https://github.com/mnemebrain/mnemebrain-lite";
    license = lib.licenses.mit;
    mainProgram = "mnemebrain";
  };
}
