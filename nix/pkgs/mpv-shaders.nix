{
  stdenvNoCC,
  fetchurl,
  fetchFromGitHub,
}:
let
  fsrcnnx8 = fetchurl {
    url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/FSRCNNX_x2_8-0-4-1.glsl";
    sha256 = "sha256-6ADbxcHJUYXMgiFsWXckUz/18ogBefJW7vYA8D6Nwq4=";
  };
  fsrcnnx16 = fetchurl {
    url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/FSRCNNX_x2_16-0-4-1.glsl";
    sha256 = "sha256-1aJKJx5dmj9/egU7FQxGCkTCWzz393CFfVfMOi4cmWU=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "mpv-shaders";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "bjin";
    repo = "mpv-prescalers";
    rev = "b3f0a59d68f33b7162051ea5970a5169558f0ea2";
    hash = "sha256-KfCFU3fa8Fr5G5zVqKS35CJBzTYMY72kep8+Kd0YIu4=";
    name = "bjin-mpv-prescalers";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -v ${fsrcnnx8} "$out/FSRCNNX_x2_8-0-4-1.glsl"
    cp -v ${fsrcnnx16} "$out/FSRCNNX_x2_16-0-4-1.glsl"
    cp -v "gather/ravu-lite-ar-r2.hook" "$out"
    cp -v "gather/ravu-lite-ar-r4.hook" "$out"
    cp -v "compute/ravu-r4-yuv.hook" "$out"
    runHook postInstall
  '';
}
