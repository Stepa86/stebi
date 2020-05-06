@chcp 65001

@rem Начало замера времени
@set OSCRIPT_TIMER_START=%DATE:~0,2%.%DATE:~3,2%.%DATE:~6,4%_%TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%
@set OSCRIPT_TIMER_START=%OSCRIPT_TIMER_START: =0%

set RUNNER_IBCONNECTION=/FD:\Work\Bases\УНФ
set RUNNER_DBUSER=Андрей Кудрявцев
set RUNNER_V8VERSION=8.3.15

@rem Раннер строит пути от корня репо. Если написать "./src/erp", то выгружено будет в корень/src/erp, а не в корень/test/src/erp
set SRC=%~dp0/src/unf

@call runner decompile --out="%SRC%" --current

@call oscript timer.os