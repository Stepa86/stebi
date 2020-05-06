@chcp 65001

@rem Начало замера времени
@set OSCRIPT_TIMER_START=%DATE:~0,2%.%DATE:~3,2%.%DATE:~6,4%_%TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%
@set OSCRIPT_TIMER_START=%OSCRIPT_TIMER_START: =0%

rem EDT или ring не умеет в относительные пути
set XML=%~dp0/src/erp
set PROJECT_DIR=%~dp0/edt/

set PRJ=%PROJECT_DIR%/ERP
set WP=%PROJECT_DIR%/w

if exist "%WP%" RD /S /Q "%WP%"

set RING_OPTS=-Dfile.encoding=UTF-8 -Dosgi.nl=ru

call ring edt workspace import --workspace-location "%WP%" --configuration-files "%XML%" --project "%PRJ%"

@call oscript timer.os