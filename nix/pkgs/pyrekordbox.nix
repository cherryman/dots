{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  bidict,
  construct,
  numpy,
  packaging,
  psutil,
  python-dateutil,
  sqlalchemy,
  sqlcipher3,
}:
buildPythonPackage rec {
  pname = "pyrekordbox";
  version = "0.4.4";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-i9tZ98RcdDvSAhYTpyYEt2BwktOG4l8gzOeK3+ML+aQ=";
  };

  # obsolete plugin, merged into setuptools-scm 7.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools_scm_git_archive",' ""
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    bidict
    construct
    numpy
    packaging
    psutil
    python-dateutil
    sqlalchemy
    sqlcipher3
  ];

  # `sqlcipher3-wheels` is a prebuilt wheel of `sqlcipher3`.
  pythonRemoveDeps = [ "sqlcipher3-wheels" ];

  pythonImportsCheck = [ "pyrekordbox" ];

  meta = {
    description = "Python package for interacting with the library of Pioneer's Rekordbox DJ software";
    homepage = "https://github.com/dylanljones/pyrekordbox";
    license = lib.licenses.mit;
  };
}
