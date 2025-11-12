@echo off
REM Build script for AffinityBootstrap native DLL on Windows
REM Requires: Visual Studio or MinGW-w64

setlocal enabledelayedexpansion

echo ================================================
echo   AffinityBootstrap Native DLL Builder
echo ================================================
echo.

REM Check if we're in a VS Developer Command Prompt
if defined VSCMD_VER (
    echo Detected Visual Studio Developer Command Prompt
    goto :build_msvc
)

REM Try to find and run vcvarsall.bat
echo Searching for Visual Studio...

REM Try Visual Studio 2022
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2022 Community
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
    goto :build_msvc
)

if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2022 Professional
    call "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
    goto :build_msvc
)

if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2022 Enterprise
    call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
    goto :build_msvc
)

REM Try Visual Studio 2019
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2019 Community
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
    goto :build_msvc
)

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    echo Found Visual Studio 2019 Professional
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
    goto :build_msvc
)

REM Try MinGW-w64
echo Visual Studio not found, trying MinGW-w64...
where x86_64-w64-mingw32-gcc >nul 2>&1
if %errorlevel% == 0 (
    goto :build_mingw
)

REM Try MSYS2 MinGW
if exist "C:\msys64\mingw64\bin\gcc.exe" (
    echo Found MSYS2 MinGW
    set "PATH=C:\msys64\mingw64\bin;%PATH%"
    goto :build_mingw
)

REM Nothing found
echo.
echo ================================================
echo   ERROR: No suitable compiler found!
echo ================================================
echo.
echo Please install one of the following:
echo.
echo Option 1: Visual Studio (recommended for Windows)
echo   Download: https://visualstudio.microsoft.com/
echo   - Select "Desktop development with C++"
echo   - No need to run from Developer Command Prompt
echo     (this script finds it automatically)
echo.
echo Option 2: MinGW-w64 via MSYS2
echo   Download: https://www.msys2.org/
echo   After install:
echo     1. Open MSYS2 terminal
echo     2. Run: pacman -S mingw-w64-x86_64-gcc
echo     3. Add to PATH or run this script from MSYS2
echo.
echo Option 3: Standalone MinGW-w64
echo   Download: https://winlibs.com/
echo   Extract and add bin\ folder to PATH
echo.
pause
exit /b 1

:build_msvc
echo.
echo Building with Microsoft Visual C++...
echo.

REM Clean old files
if exist AffinityBootstrap.dll del AffinityBootstrap.dll
if exist AffinityBootstrap.obj del AffinityBootstrap.obj
if exist AffinityBootstrap.exp del AffinityBootstrap.exp
if exist AffinityBootstrap.lib del AffinityBootstrap.lib

REM Compile
cl.exe /nologo /O2 /LD bootstrap.c ^
    /link /NOLOGO ^
    ole32.lib oleaut32.lib uuid.lib ^
    /OUT:AffinityBootstrap.dll

if %errorlevel% == 0 (
    echo.
    echo ================================================
    echo   Build Successful!
    echo ================================================
    goto :success
) else (
    echo.
    echo ================================================
    echo   Build Failed!
    echo ================================================
    pause
    exit /b 1
)

:build_mingw
echo.
echo Building with MinGW-w64...
echo.

REM Clean old files
if exist AffinityBootstrap.dll del AffinityBootstrap.dll

REM Compile
x86_64-w64-mingw32-gcc -shared -O2 -o AffinityBootstrap.dll bootstrap.c ^
    -lole32 -loleaut32 -luuid ^
    -static-libgcc ^
    -Wl,--subsystem,windows

if %errorlevel% == 0 (
    echo.
    echo ================================================
    echo   Build Successful!
    echo ================================================
    goto :success
) else (
    echo.
    echo ================================================
    echo   Build Failed!
    echo ================================================
    pause
    exit /b 1
)

:success
echo.
echo Created: AffinityBootstrap.dll
echo Size: 
for %%A in (AffinityBootstrap.dll) do echo   %%~zA bytes
echo.
echo Next steps:
echo   1. Copy to Affinity directory:
echo      copy AffinityBootstrap.dll "C:\Program Files\Affinity\Affinity\"
echo.
echo   2. Make sure these are also in Affinity directory:
echo      - AffinityPluginLoader.dll
echo      - 0Harmony.dll
echo.
echo   3. Run AffinityHook.exe
echo.

REM Clean up intermediate files
if exist AffinityBootstrap.obj del AffinityBootstrap.obj
if exist AffinityBootstrap.exp del AffinityBootstrap.exp
if exist AffinityBootstrap.lib del AffinityBootstrap.lib

pause
