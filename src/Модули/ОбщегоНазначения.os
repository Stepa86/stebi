Функция ФайлСуществует(Знач пИмяФайла) Экспорт
	
	файл = Новый Файл(УбратьКавычки(пИмяФайла));
	
	Возврат файл.Существует()
	И Не файл.ЭтоКаталог();
	
КонецФункции

Функция КаталогСуществует(Знач пИмяФайла) Экспорт
	
	файл = Новый Файл(УбратьКавычки(пИмяФайла));
	
	Возврат файл.Существует()
	И файл.ЭтоКаталог();
	
КонецФункции

Функция АбсолютныйПуть(Знач пИмяФайла) Экспорт
	
	Попытка
		
		файл = Новый Файл(УбратьКавычки(пИмяФайла));
		
		путь = файл.ПолноеИмя;
		путь = СтрЗаменить(путь, "\", "/");

		Возврат путь;
		
	Исключение
		
		Сообщить("Ошибка получения абсолютного пути для " + пИмяФайла);
		Сообщить("	" + ОписаниеОшибки());
		Возврат пИмяФайла;
		
	КонецПопытки;
	
КонецФункции

Функция КаталогиСИсходниками(Знач ПутьККаталогуИсходников, Знач Лог) Экспорт

	Лог.Отладка("Получение каталогов с исходниками по %1", ПутьККаталогуИсходников);

	путьККаталогуБезКавычек = УбратьКавычки(ПутьККаталогуИсходников);

	стрКаталоги = СтрЗаменить(путьККаталогуБезКавычек, ";", ",");
	каталоги = СтрРазделить(стрКаталоги, ",");
	
	каталогиСИсходниками = Новый Массив;

	Если каталоги.Количество() = 0 Тогда

		Возврат каталогиСИсходниками;

	КонецЕсли;
	
	Если каталоги.Количество() = 1 Тогда

		// Если передали ровно один каталог, то доверяем вызывающему коду и не делаем доп. проверок
		
		каталогИсходников = Новый Файл(СокрЛП(УбратьКавычки(каталоги[0])));
		каталогиСИсходниками.Добавить(каталогИсходников);
		Лог.Информация("Каталог исходников = " + каталогИсходников.ПолноеИмя);

		Возврат каталогиСИсходниками;

	КонецЕсли;

	Для Каждого цКаталог Из каталоги Цикл
		
		каталогИсходников = Новый Файл(СокрЛП(УбратьКавычки(цКаталог)));
		каталогПроекта = Новый Файл(каталогИсходников.Путь);
		
		Лог.Отладка("Проверка каталога %1 на существование файла .project", каталогПроекта.ПолноеИмя);

		файлПроекта = Новый Файл(ОбъединитьПути(каталогПроекта.ПолноеИмя, ".project"));
		
		Если файлПроекта.Существует()
			И каталогИсходников.Существует()
			И каталогИсходников.ЭтоКаталог() Тогда
			
			каталогиСИсходниками.Добавить(каталогИсходников);
			Лог.Информация("Каталог исходников = " + каталогИсходников.ПолноеИмя);
			
		КонецЕсли;
		
	КонецЦикла;

	Возврат каталогиСИсходниками;
	
КонецФункции

Функция УбратьКавычки(Знач пСтрока) Экспорт
	
	строкаБезКавычек = пСтрока;
	
	Если СтрНачинаетсяС(строкаБезКавычек, """") Тогда
		СтрокаБезКавычек = Сред(СтрокаБезКавычек, 2);
	КонецЕсли;
	
	Если СтрЗаканчиваетсяНа(строкаБезКавычек, """") Тогда
		СтрокаБезКавычек = Лев(СтрокаБезКавычек, СтрДлина(СтрокаБезКавычек) - 1);
	КонецЕсли;
	
	СтрокаБезКавычек = СтрЗаменить(СтрокаБезКавычек, """""", """");
	
	Возврат строкаБезКавычек;
	
КонецФункции

Функция ПолучитьТаблицуНастроек(Знач пФайлНастроек, Знач Лог) Экспорт
	
	таблицаНастроек = Новый ТаблицаЗначений;
	таблицаНастроек.Колонки.Добавить("ruleId", Новый ОписаниеТипов("Строка"));
	таблицаНастроек.Колонки.Добавить("message", Новый ОписаниеТипов("Строка"));
	таблицаНастроек.Колонки.Добавить("filePath", Новый ОписаниеТипов("Строка"));
	таблицаНастроек.Колонки.Добавить("severity", Новый ОписаниеТипов("Строка"));
	таблицаНастроек.Колонки.Добавить("type", Новый ОписаниеТипов("Строка")); // sonarqube 10.2-
	таблицаНастроек.Колонки.Добавить("effortMinutes", Новый ОписаниеТипов("Число"));
	таблицаНастроек.Колонки.Добавить("cleanCodeAttribute", Новый ОписаниеТипов("Строка")); // sonarqube 10.3+
	таблицаНастроек.Колонки.Добавить("softwareQuality", Новый ОписаниеТипов("Строка")); // sonarqube 10.3+
	
	Если ФайлСуществует(пФайлНастроек) Тогда
		
		настройки = ПрочитатьJSONФайл(пФайлНастроек, Лог);
		
		Для каждого цСтрокаНастройки Из настройки Цикл
			
			ЗаполнитьЗначенияСвойств(таблицаНастроек.Добавить(), цСтрокаНастройки);
			
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат таблицаНастроек;
	
КонецФункции

Функция ПрочитатьJSONФайл(Знач пИмяФайла, Знач Лог) Экспорт
	
	текДата = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьФайл(пИмяФайла, "UTF-8");
	
	прочитанныйТекст = ПрочитатьJSON(ЧтениеJSON);
	
	Лог.Информация("JSON прочитан из <%1> за %2мс", пИмяФайла, ТекущаяУниверсальнаяДатаВМиллисекундах() - текДата);
	
	Возврат прочитанныйТекст;
	
КонецФункции

Процедура ЗаписатьJSONВФайл(Знач пЗначение, Знач пИмяФайла, Знач Лог) Экспорт
	
	текДата = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.ОткрытьФайл(пИмяФайла, "UTF-8");
	ЗаписатьJSON(ЗаписьJSON, пЗначение);
	ЗаписьJSON.Закрыть();
	
	Лог.Информация("JSON записан в <%1> за %2мс", пИмяФайла, ТекущаяУниверсальнаяДатаВМиллисекундах() - текДата);
	
КонецПроцедуры