@echo off

REM Install packages if needed
if not exist "Packages" (
    echo Installing packages...
    pushd "%~dp0.."
    wally install
    popd
)

REM Set development environment
set ROBLOX_DEV=true

REM Generate initial sourcemap
echo Generating sourcemap...
rojo sourcemap default.project.json -o sourcemap.json

REM Process source files initially
echo Processing source files...
darklua process --config .darklua.json src\ dist\

REM Start Rojo server (this will block and run in current terminal)
echo Starting Rojo server...
echo Press Ctrl+C to stop the development server.
rojo serve build.project.json