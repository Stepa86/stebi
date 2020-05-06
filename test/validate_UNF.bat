@chcp 65001

@rem Начало замера времени
@set OSCRIPT_TIMER_START=%DATE:~0,2%.%DATE:~3,2%.%DATE:~6,4%_%TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%
@set OSCRIPT_TIMER_START=%OSCRIPT_TIMER_START: =0%

rem EDT или ring не умеет в относительные пути
set PROJECT_DIR=%~dp0/edt/

set PRJ=%PROJECT_DIR%/UNF
set WP=%PROJECT_DIR%/w

set EDT_VALIDATION_RESULT=%~dp0/edt_validate_result_UNF_RU.csv

if exist "%WP%" RD /S /Q "%WP%"
if exist "%EDT_VALIDATION_RESULT%" DEL "%EDT_VALIDATION_RESULT%"

set RING_OPTS=-Dfile.encoding=UTF-8 -Dosgi.nl=ru

call ring edt workspace validate --workspace-location "%WP%" --file "%EDT_VALIDATION_RESULT%" --project-list "%PRJ%"

@call oscript timer.os