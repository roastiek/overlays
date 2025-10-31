{ stdenv, clangStdenv, buildBazelPackage, fetchFromGitHub, git, autoconf, automake, libtool, cmake, go, python3, ninja }:
buildBazelPackage rec {
  name = "envoy-${version}";
  version = "1.14.3";
  rev = "8fed4856a7cfe79cf60aa3682eff3ae55b231e49";

  src = fetchFromGitHub {
    owner = "envoyproxy";
    repo  = "envoy";
    rev   = "v${version}";
    sha256 = "1rihp25f0ilsn8h6algvv5011sc0w9ygz48pjiyphg3fv6mdc77l";
  };

  patches = [ ./sys_cmake.patch ];

  preBuild = ''
    patchShebangs .
    patchShebangs $bazelOut/external
    rm .bazelversion

    sed -E -i \
      -e 's|GO_VERSION\s*=\s*"[^"]+"|GO_VERSION = "host"|g' \
      bazel/dependency_imports.bzl
    cat > SOURCE_VERSION <<EOF
    ${rev}
    EOF

    substituteInPlace BUILD --replace /usr/bin/cmake3 "${cmake}/bin/cmake" --replace /usr/bin/ninja-build "${ninja}/bin/ninja"

    #echo "*************"
    #grep cmake -C 3 bazel/dependency_imports.bzl
    #echo "*************"
    #grep ninja -C 3 BUILD
    #echo "*************"
  '';

  bazelTarget = "//source/exe:envoy-static";
  #bazelTarget = "//source/common/http:header_map_lib";

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  nativeBuildInputs = [ git autoconf automake libtool go python3 cmake ninja ];

  fetchAttrs = {
    inherit preBuild;
    sha256 = "1q51g58gnghfvxdzv6s2hdi4id2rahb6xlx628mvqf1zm9b8gf7q";
    postInstall = "
      #find $out -executable
      rm -rf $out/com_github_gperftools_gperftools/autom4te.cache
      #grep -F  /nix/store -r $out
    ";
  };

  buildAttrs = {
    inherit preBuild;
    bazelFlags = [ "--verbose_failures" "--sandbox_debug" ];

    installPhase = ''
      mkdir -p $out/bin
      mv bazel-bin/source/exe/envoy-static $out/bin/envoy
    '';
  };
}
