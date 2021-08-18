{ pkgs ? import <nixpkgs> {}
, defineInstallRpath ? true
, skipBuildRpath ? false
, skipInstallRpath ? false
, multipleOutputs ? true
}:

let
  filterIgnored = with pkgs.nix-gitignore; patterns: root:
    gitignoreFilterPure (_: _: true) (withGitignoreFile patterns root) root;

  localSrc = { path, name, patterns ? [] }: builtins.path {
    inherit path name;
    filter = filterIgnored patterns path;
  };

  libExt = with pkgs; if (!stdenv.isDarwin) then ".so" else ".dylib";

  enableFlag = n: b: "-D${n}:BOOL=${if b then "ON" else "OFF"}";
in

with pkgs; stdenv.mkDerivation rec {

  pname = "cmake-rpath-test";
  version = "1";

  src = localSrc {
    path = ./.;
    name = pname;
    patterns = [ "/check" ];
  };

  outputs = [ "out" ] ++ lib.optionals multipleOutputs [ "lib" "dev" ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ jsoncpp ];

  cmakeFlags = [
    (enableFlag "DEFINE_INSTALL_RPATH" defineInstallRpath)
    (enableFlag "CMAKE_SKIP_BUILD_RPATH" skipBuildRpath)
    (enableFlag "CMAKE_SKIP_INSTALL_RPATH" skipInstallRpath)
  ];

  buildFlags = [ "VERBOSE=1" ];

  doCheck = !skipBuildRpath;
  doInstallCheck = true;

  postBuild = let
    binPath = "bin/hello";
    libPath = "lib/libhello${libExt}";
  in ''
    echo "##### BEGIN BUILD TREE INSPECT"
    bash ../scripts/inspect ${binPath} ${libPath}
    echo "##### END BUILD TREE INSPECT"
   '';

  installCheckPhase = let
    binPath = "$out/bin/hello";
    libDir = if multipleOutputs then "$lib" else "$out";
    libPath = "${libDir}/lib/libhello${libExt}";
  in ''
    runHook preInstallCheck
    echo "##### BEGIN INSTALL TREE INSPECT"
    echo "$ $out/bin/hello"
    $out/bin/hello
    echo
    bash ../scripts/inspect ${binPath} ${libPath}
    echo "##### END INSTALL TREE INSPECT"
    runHook postInstallCheck
   '';
}
