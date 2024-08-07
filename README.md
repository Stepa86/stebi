# Sonar Transform External Bsl Issues

[![OpenYellow](https://img.shields.io/endpoint?url=https://openyellow.neocities.org/badges/2/230765834.json)](https://openyellow.notion.site/openyellow/24727888daa641af95514b46bee4d6f2?p=1faefbc7324e4d9abfe5cf63902878a4&amp;pm=s)

Экспорт диагностик 1С: EDT для SonarQube 1C (BSL) Community Plugin.
Трансформация диагностик: изменение параметров, удаление файлов на поддержке, удаление неактуальных диагностик.
Получение версии конфигурации.

## Получение джсон файла для сонара по отчету о проверке EDT

`stebi c ./edt-result.out ./edt-json.json ./src`

```bat
Команда: c, convert
 Конвертировать результат проверки проекта 1С:EDT из .tsv-файл в выбранный формат

Строка запуска: stebi c [ОПЦИИ] EDT_VALIDATION_RESULT EDT_VALIDATION_JSON SRC

Аргументы:
  EDT_VALIDATION_RESULT         Путь к файлу с результатом проверки edt. Например ./edt-result.out (env $EDT_VALIDATION_RESULT)
  EDT_VALIDATION_JSON           Путь к файлу результату. Например ./edt-json.json (env $EDT_VALIDATION_JSON)
  SRC                           Путь к каталогам с исходниками. Можно указать несколько, если результат проверки содержит несколько проектов.
                Пример для одного проекта: `project/src`.
                Пример для несколькоих проектов `project1/src, project2/src` (env $SRC)

Опции:
  -e, --ObjectErrors            Ошибки объектов назначать на первую строку модуля формы/объекта
  -r, --UseRelativePaths        В файл результата записывать относительные пути
  -f, --Format                  Формат отчета (env $STEBI_REPORT_FORMAT) (по умолчанию Generic_Issue)
                             Generic_Issue: Формат Generic issue для SonarQube версии 10.2-. Подробнее: https://docs.sonarsource.com/sonarqube/10.2/analyzing-source-code/importing-external-issues/generic-issue-import-format/
                             Generic_Issue_10_3: Формат Generic issue для SonarQube версии 10.3+. Подробнее: https://docs.sonarsource.com/sonarqube/10.3/analyzing-source-code/importing-external-issues/generic-issue-import-format/
  -d, --debug                   Режим отладки
```

## Пример настроек проекта Сонара

```
sonar.host.url=http://localhost:9000
sonar.projectKey=UNF
sonar.projectVersion=1.6.17
sonar.sources=src
sonar.sourceEncoding=UTF-8
sonar.inclusions=**/*.bsl
sonar.externalIssuesReportPaths=edt-json.json,acc-generic-issue.json,bsl-generic-json.json
```

## Переопределение файла с ошибками

Приложение позволяет создать файл настроек по существующим выгрузкам формата [generic-issue](https://docs.sonarqube.org/latest/analysis/generic-issue/) и применить эти настройки к указанным файлам generic-issue.

Таким образом возможно указать effortMinutes, переопределить type и severity.

### Файл настроек

Для создания файла используется команда `p` или `prepare`.  

```bat
Команда: p, prepare
 Подготовить файл настроек

Строка запуска: stebi p [ОПЦИИ] GENERIC_ISSUE_SETTINGS_JSON GENERIC_ISSUE_JSON

Аргументы:
  GENERIC_ISSUE_SETTINGS_JSON   Путь к файлу настроек. Если файл существует, то он будет обновлен. Например ./generic-issue-settings.json (env $GENERIC_ISSUE_SETTINGS_JSON)
  GENERIC_ISSUE_JSON            Путь к файлам generic-issue.json, на основе которых будет создан файл настроек. Например ./edt-json.json,./acc-generic-issue.json (env $GENERIC_ISSUE_JSON)

Опции:
  -f, --Format  Формат отчета (env $STEBI_REPORT_FORMAT) (по умолчанию Generic_Issue)
                   Generic_Issue: Формат Generic issue для SonarQube версии 10.2-. Подробнее: https://docs.sonarsource.com/sonarqube/10.2/analyzing-source-code/importing-external-issues/generic-issue-import-format/
                   Generic_Issue_10_3: Формат Generic issue для SonarQube версии 10.3+. Подробнее: https://docs.sonarsource.com/sonarqube/10.3/analyzing-source-code/importing-external-issues/generic-issue-import-format/
  -d, --debug   Режим отладки
```

Пример команды `stebi prepare ./test/settigs.json ./test/acc-generic-issue.json,./test/edt-json.json`

Будет создан файл json с массивом настроек. В каждой настройке есть ключевые поля: `ruleId`, `message`, `filePath` и значения для переопределения `severity`, `type` и `effortMinutes`.

Ошибка соответствует ключевому полю, если значения совпадают, ключевое поле пустое или поле ошибки соответствует ключевому полю с учетом регулярного выражения.

Если все ключевые поля соответствуют ошибке, то в ошибке подменяются заполненные значения для переопределения.

Например, файл настроек с таким содержимым:

```json
[
{
"ruleId": "",
"message": "",
"filePath": ".*Documents.*",
"severity": null,
"type": null,
"effortMinutes": 500
}
]
```
Установит всем документам effortMinutes = 500.

Настройки проверяются и применяются по очереди, поэтому могут друг друга переопределять.

## Применение настроек и удаление файлов на поддержке

Для применения файла настроек к файлам используется команда `t` или `transform`.

```bat
Команда: t, transform
 Применить файл настроек к generic-issue.json

Строка запуска: stebi t [ОПЦИИ] GENERIC_ISSUE_JSON

Аргументы:
  GENERIC_ISSUE_JSON    Путь к файлам generic-issue.json, на основе которых будет создан файл настроек. Например ./edt-json.json,./acc-generic-issue.json (env $GENERIC_ISSUE_JSON)

Опции:
  -s, --settings                Путь к файлу настроек. Например -s=./generic-issue-settings.json (env $GENERIC_ISSUE_SETTINGS_JSON)
      --src                     Путь к каталогу с исходниками. Например -src=./src (env $SRC)
  -r, --remove_support          Удаляет из отчетов файлы на поддержке. Например -r=0
                0 - удалить файлы на замке,
                1 - удалить файлы на замке и на поддержке
                2 - удалить файлы на замке, на поддержке и снятые с поддержки (env $GENERIC_ISSUE_REMOVE_SUPPORT)
      --filter_by_subsystem     Фильтр по подсистеме в формате [+/-]Подсистема1.Подсистема2[*][^].
                Например, исключение подсистем СтандартныеПодсистемы и ПодключаемоеОборудование и всех дочерних объектов
                        '-СтандартныеПодсистемы*, -ПодключаемоеОборудование*' (env $GENERIC_ISSUE_FILTER_BY_SUBSYSTEM)
  -f, --Format                  Формат отчета (env $STEBI_REPORT_FORMAT) (по умолчанию Generic_Issue)
                                Generic_Issue: Формат Generic issue для SonarQube версии 10.2-. Подробнее: https://docs.sonarsource.com/sonarqube/10.2/analyzing-source-code/importing-external-issues/generic-issue-import-format/
                                Generic_Issue_10_3: Формат Generic issue для SonarQube версии 10.3+. Подробнее: https://docs.sonarsource.com/sonarqube/10.3/analyzing-source-code/importing-external-issues/generic-issue-import-format/
  -d, --debug                   Режим отладки
```

Пример команды:

```bat
@set GENERIC_ISSUE_SETTINGS_JSON=%1conf\settigs.json
@set GENERIC_ISSUE_JSON=%1acc-generic-issue.json,%1bsl-generic-json.json,%1edt-json.json
@set SRC=%1src

@call stebi convert "%1temp\edt-result.out" "%1edt-json.json" 

@call stebi transform -r=1
```

## Вывод версии конфигурации

```bat
Команда: g, get_version
 Выводит версию конфигурации

Строка запуска: stebi g [ОПЦИИ]

Опции:
      --src     Путь к каталогу с исходниками. Например --src=./src (env $SRC)
```