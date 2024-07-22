#Область ОписаниеПеременных

Перем Generic_Issue Экспорт;
Перем Generic_Issue_10_3 Экспорт;

#КонецОбласти

#Область ПрограммныйИнтерфейс

Функция Описание(Знач Формат) Экспорт
	
	Если Формат = Generic_Issue Тогда
		Возврат "Формат Generic issue для SonarQube версии 10.2-. Подробнее: https://docs.sonarsource.com/sonarqube/10.2/analyzing-source-code/importing-external-issues/generic-issue-import-format/";
	ИначеЕсли Формат = Generic_Issue_10_3 Тогда
		Возврат "Формат Generic issue для SonarQube версии 10.3+. Подробнее: https://docs.sonarsource.com/sonarqube/10.3/analyzing-source-code/importing-external-issues/generic-issue-import-format/";
	Иначе
		ВызватьИсключение "Неизвестный формат отчета";
	КонецЕсли;

КонецФункции

#КонецОбласти

Generic_Issue = "Generic_Issue";
Generic_Issue_10_3 = "Generic_Issue_10_3";
