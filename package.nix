{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glew,
  glfw,
  eigen,
  libpng,
  enablePython ? false,
}:

stdenv.mkDerivation rec {
  pname = "offscreen-renderer";
  version = "unstable-2023-10-12";

  src = fetchFromGitHub {
    owner = "MeshFEM";
    repo = "OffscreenRenderer";
    rev = "3f4bb7dc63e618ba74b8ddc551aa1792fcbf5a38";
    hash = "sha256-AQrUjUlW8r2Ny2PDL2v4IKh39Nfz2MZMR8NhZ1Qs5rY=";
  };

  postPatch = lib.optionalString (!enablePython) ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "add_subdirectory(src/python_bindings)" ""
    echo "$cmakeInstallRules" >> src/OffscreenRenderer/CMakeLists.txt
  '';

  cmakeInstallRules = ''
    include(GNUInstallDirs)
    if (TARGET demo)
      install(TARGETS demo DESTINATION ''${CMAKE_INSTALL_BINDIR})
    endif()
    if (TARGET demo_multicontext)
      install(TARGETS demo_multicontext DESTINATION ''${CMAKE_INSTALL_BINDIR})
    endif()
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    glew
    glfw
    eigen
    libpng
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_OSMESA" false)
    (lib.cmakeFeature "SHADER_PATH" "${placeholder "out"}/share/offscreen-renderer")
  ];

  postInstall = ''
    for s in ../shaders/* ; do
      mkdir -p $out/share/offscreen-renderer
      cp "$s" $out/share/offscreen-renderer/
    done
  '';

  meta = with lib; {
    description = "Basic cross-platform offscreen rendering with both software and GPU support";
    homepage = "https://github.com/MeshFEM/OffscreenRenderer/";
    # license = licenses.unfree; # FIXME: nix-init did not found a license
    # maintainers = with maintainers; [ ];
    mainProgram = "demo";
    platforms = platforms.all;
  };
}
