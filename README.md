# nixpkgs example CMake project (library + executable)

Test `RPATH` settings when building nixpkgs packages with CMake.

Build a library and executable with CMake:

- The library depends on a third-party library available in nixpkgs.
- The executable depends on the library.
- The test executable depends on the build-tree library
  (it won't run when `CMAKE_SKIP_BUILD_RPATH` is enabled).

The derivation accepts the following arguments to configure CMake:

- `defineInstallRpath`: set [`CMAKE_INSTALL_RPATH`][] to `$ORIGIN $ORIGIN/..lib`
  (`@loader_path @loader_path/../lib`) inside `CMakeLists.txt`
  as many projects may do (default `true`).
- `skipBuildRpath`: set [`CMAKE_SKIP_BUILD_RPATH`][] (default `false`)
- `skipInstallRpath`: set [`CMAKE_SKIP_INSTALL_RPATH`][] (default `false`)

[`CMAKE_INSTALL_RPATH`]: <https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_RPATH.html>
[`CMAKE_SKIP_BUILD_RPATH`]: <https://cmake.org/cmake/help/latest/variable/CMAKE_SKIP_BUILD_RPATH.html>
[`CMAKE_SKIP_INSTALL_RPATH`]: <https://cmake.org/cmake/help/latest/variable/CMAKE_SKIP_INSTALL_RPATH.html>

Build with:

    $ nix-build [ --arg <argument> (true|false) ]

The `buildPhase` and `installCheckPhase` will inspect the build-tree and the
install-tree objects to show dependencies and the RPATH:

- In Linux:

  - `readelf -d <obj> | grep -E '(NEEDED|RPATH|RUNPATH)'`

- On Darwin:

  - `otool -D <lib>` (show `install_name`)
  - `otool -L <obj>` (show dependencies)
  - `otool -l <obj> | grep -A2 LC_RPATH` (show `RPATH` values)

-----

The following script:

    $ ./check

can be used to build and inspect the following combinations:

| `defineInstallRpath` | `skipBuildRpath` | `skipInstallRpath` | |
|:--------------------:|:----------------:|:------------------:|-|
| `true`  | `true`  | `false` | The current CMake hook configuration |
| `true`  | `false` | `false` | The proposed configuration by NixOS/nixpkgs#108496 |
| `true`  | `false` | `true`  | |
| `false` | `false` | `false` | |
| `false` | `false` | `true`  | |

The log files and the link to the nix store path for each configuration will
be saved as subdirectories in the `out` directory.
