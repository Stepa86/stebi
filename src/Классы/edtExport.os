#Использовать logos
#Использовать csv
#Использовать v8metadata-reader

#Область ОписаниеПеременных

Перем _Лог;
Перем _РезультатПроверки;
Перем _ФайлДжсон;
Перем _ВыгружатьОшибкиОбъектов;
Перем _ИспользоватьОтносительныеПути;
Перем _ФорматОтчета; // Используемый формат отчета

Перем ГенераторПутейПоПроекту;

Перем ВыведенныеСообщения; // Кэш уже выведенных сообщений, чтобы не повторяться

#КонецОбласти

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("EDT_VALIDATION_RESULT", "", "Путь к файлу с результатом проверки edt. Например ./edt-result.out")
		.ТСтрока()
		.ВОкружении("EDT_VALIDATION_RESULT");
	
	Команда.Аргумент("EDT_VALIDATION_JSON", "", "Путь к файлу результату. Например ./edt-json.json")
		.ТСтрока()
		.ВОкружении("EDT_VALIDATION_JSON");
	
	Команда.Аргумент(
		"SRC",
		"",
		"Путь к каталогам с исходниками. Можно указать несколько, если результат проверки содержит несколько проектов.
		|		Пример для одного проекта: `project/src`.
		|		Пример для несколькоих проектов `project1/src, project2/src`")
		.ТСтрока()
		.ВОкружении("SRC");
	
	Команда.Опция("e ObjectErrors", Ложь, "Ошибки объектов назначать на первую строку модуля формы/объекта");
	Команда.Опция("r UseRelativePaths", Ложь, "В файл результата записывать относительные пути");
	
	Команда.Опция("f Format", ТипыФорматаОтчетаСонар.Generic_Issue, "Формат отчета")
		.ТПеречисление()
		.Перечисление(
			ТипыФорматаОтчетаСонар.Generic_Issue,
			ТипыФорматаОтчетаСонар.Generic_Issue,
			ТипыФорматаОтчетаСонар.Описание(ТипыФорматаОтчетаСонар.Generic_Issue))
		.Перечисление(
			ТипыФорматаОтчетаСонар.Generic_Issue_10_3,
			ТипыФорматаОтчетаСонар.Generic_Issue_10_3,
			ТипыФорматаОтчетаСонар.Описание(ТипыФорматаОтчетаСонар.Generic_Issue_10_3));
	
	Команда.Опция("d debug", Ложь, "Режим отладки")
		.ТБулево();
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	ИнициализацияПараметров(Команда);
	
	таблицаРезультатов = ТаблицаПоФайлуРезультата();
	
	ЗаполнитьВТаблицеРезультатовИсходныеПути(таблицаРезультатов);
	ЗаполнитьВТаблицеРезультатовНомераСтрок(таблицаРезультатов);
	
	ПереопределитьИдентификаторыПравил(таблицаРезультатов);
	
	записьВДжсон = Новый ЗаписьReportJSON(_ФорматОтчета, _ФайлДжсон, _Лог, _ИспользоватьОтносительныеПути);
	записьВДжсон.Записать(таблицаРезультатов);
	
КонецПроцедуры

Процедура ИнициализацияПараметров(Знач Команда)
	
	Если Команда.ЗначениеОпции("debug") Тогда
		_лог.УстановитьУровень(УровниЛога.Отладка);
	КонецЕсли;
	
	результатПроверки = Команда.ЗначениеАргумента("EDT_VALIDATION_RESULT");
	_лог.Отладка("EDT_VALIDATION_RESULT = " + результатПроверки);
	
	путьКРезультату = Команда.ЗначениеАргумента("EDT_VALIDATION_JSON");
	_лог.Отладка("EDT_VALIDATION_JSON = " + путьКРезультату);
	
	путьККаталогуИсходников = Команда.ЗначениеАргумента("SRC");
	_лог.Отладка("SRC = " + путьККаталогуИсходников);
	
	_РезультатПроверки = ОбщегоНазначения.АбсолютныйПуть(результатПроверки);
	_лог.Отладка("Файл с результатом проверки EDT = " + _РезультатПроверки);
	
	Если НЕ ОбщегоНазначения.ФайлСуществует(_РезультатПроверки) Тогда
		
		_лог.Ошибка(СтрШаблон("Файл с результатом проверки <%1> не существует.", результатПроверки));
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	_ФайлДжсон = ОбщегоНазначения.АбсолютныйПуть(путьКРезультату);
	_лог.Отладка("Файл результат = " + _ФайлДжсон);
	
	_ВыгружатьОшибкиОбъектов = Команда.ЗначениеОпции("ObjectErrors");
	_ИспользоватьОтносительныеПути = Команда.ЗначениеОпции("UseRelativePaths");
	_ФорматОтчета = Команда.ЗначениеОпции("Format");
	_лог.Отладка("Формат отчета = " + _ФорматОтчета);
	
	ИнициализироватьКаталогиПоПроектам(путьККаталогуИсходников);
	
	ВыведенныеСообщения = Новый Структура;
	ВыведенныеСообщения.Вставить("ПутьНеПолучен", Новый Соответствие);
	ВыведенныеСообщения.Вставить("ПутьНеСуществует", Новый Соответствие);
	ВыведенныеСообщения.Вставить("ПутьНеПереопределен", Новый Соответствие);
	
КонецПроцедуры

Процедура ИнициализироватьКаталогиПоПроектам(Знач ПутьККаталогуИсходников)
	
	каталоги = ОбщегоНазначения.КаталогиСИсходниками(ПутьККаталогуИсходников, _лог);
	
	Если каталоги.Количество() = 0 Тогда
		
		_лог.Ошибка("Каталог исходников SRC не указан. Продолжение невозможно.");
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	каталогПоУмолчанию = каталоги[0];
	
	КаталогИсходниковПоПроекту = Новый Соответствие;
	
	Для Каждого цКаталог Из каталоги Цикл
		
		каталогПроекта = Новый Файл(цКаталог.Путь);
		имяПроекта = каталогПроекта.Имя;
		
		КаталогИсходниковПоПроекту.Вставить(имяПроекта, цКаталог.ПолноеИмя);
		
		_лог.Отладка("Каталог исходников для проекта %1 = %2", имяПроекта, цКаталог.ПолноеИмя);
		
	КонецЦикла;
	
	Если КаталогИсходниковПоПроекту.Количество() = 0 Тогда
		
		_лог.Ошибка("Не удалось заполнить соответствие проектов исходникам для SRC = <%1>", ПутьККаталогуИсходников);
		_лог.Ошибка("Возможно используется формат конфигуратора. Будет использован единый каталог: <%1>", каталогПоУмолчанию.ПолноеИмя);
		
		КаталогИсходниковПоПроекту.Вставить("", каталогПоУмолчанию.ПолноеИмя);
		
	КонецЕсли;
	
	ГенераторПутейПоПроекту = Новый Соответствие;
	
	Для Каждого цПроектИКаталог Из КаталогИсходниковПоПроекту Цикл
		
		ГенераторПутейПоПроекту.Вставить(цПроектИКаталог.Ключ, Новый Путь1СПоМетаданным(цПроектИКаталог.Значение));
		
	КонецЦикла;
	
	// Путь по умолчанию
	Если ГенераторПутейПоПроекту[""] = Неопределено Тогда
		
		ГенераторПутейПоПроекту.Вставить("", Новый Путь1СПоМетаданным(каталогПоУмолчанию.ПолноеИмя));
		
	КонецЕсли;
	
КонецПроцедуры

Функция ТаблицаПоФайлуРезультата()
	
	разделительВФайле = "	";
	кодировкаФайла = КодировкаТекста.UTF8;
	
	_Лог.Отладка("Чтение файла результата %1", _РезультатПроверки);
	
	тз = Новый ТаблицаЗначений;
	тз.Колонки.Добавить("ДатаОбнаружения");
	тз.Колонки.Добавить("Тип");
	тз.Колонки.Добавить("Серьезность");
	тз.Колонки.Добавить("Проект");
	тз.Колонки.Добавить("Правило");
	
	тз.Колонки.Добавить("Метаданные");
	тз.Колонки.Добавить("Положение");
	тз.Колонки.Добавить("Описание");
	
	ЧтениеТекста = Новый ЧтениеТекста(_РезультатПроверки, кодировкаФайла);
	
	данныеФайла = ЧтениеCSV.ИзЧтенияТекста(ЧтениеТекста, разделительВФайле);
	
	ЧтениеТекста.Закрыть();
	
	всегоОшибок = 0;
	
	Если данныеФайла.Количество() = 0 Тогда
		
		_Лог.Информация("Из файла %1 прочитано %2 строк из %3", _РезультатПроверки, данныеФайла.Количество(), всегоОшибок);
		Возврат тз;
		
	КонецЕсли;
	
	именаПолей = ИменаПолей(данныеФайла);
	
	Для Каждого цПоля Из данныеФайла Цикл
		
		Если цПоля.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		всегоОшибок = всегоОшибок + 1;
		
		положение = цПоля[именаПолей.Положение];
		
		Если НЕ _ВыгружатьОшибкиОбъектов
			И (НЕ ЗначениеЗаполнено(положение)
				ИЛИ НЕ СтрНачинаетсяС(ВРег(положение), "СТРОКА ")) Тогда
			
			// Нас интересуют только ошибки в модулях, а у них есть положение.
			Продолжить;
			
		КонецЕсли;
		
		описание = цПоля[именаПолей.Описание];
		
		Если ЗначениеЗаполнено(описание)
			И СтрНачинаетсяС(описание, "[BSL LS]") Тогда
			
			// Пропускаем ошибки от плагина, т.к. BSL-LS отдельно выполняет проверку
			Продолжить;
			
		КонецЕсли;
		
		ДобавитьСтрокуВТаблицу(цПоля, тз, именаПолей);
		
	КонецЦикла;
	
	_Лог.Информация("Из файла %1 прочитано %2 строк из %3", _РезультатПроверки, тз.Количество(), всегоОшибок);
	
	// В отчете могут быть дубли
	
	тз.Свернуть("Проект,Правило,Серьезность,Тип,Метаданные,Положение,Описание");
	
	тз.Колонки.Добавить("ИдентификаторПравила");
	тз.Колонки.Добавить("НаименованиеПравила");
	тз.Колонки.Добавить("ОписаниеПравила");

	Возврат тз;
	
КонецФункции

Функция ИменаПолей(данныеФайла)
	
	перваяСтрока = данныеФайла[0];
	
	именаПолей = Новый Структура();
	
	столбцовВ_2021_2 = 8;
	Если перваяСтрока.Количество() = столбцовВ_2021_2 Тогда
		
		// В 2021.2 добавили новую колонку и поменяли порядок
		именаПолей.Вставить("ДатаОбнаружения", 0);
		именаПолей.Вставить("Тип", 1);
		именаПолей.Вставить("Серьезность", 2);
		именаПолей.Вставить("Проект", 3);
		именаПолей.Вставить("Правило", 4);
		именаПолей.Вставить("Метаданные", 5);
		именаПолей.Вставить("Положение", 6);
		именаПолей.Вставить("Описание", 7);
		
	Иначе
		
		именаПолей.Вставить("ДатаОбнаружения", 0);
		именаПолей.Вставить("Тип", 1);
		именаПолей.Вставить("Проект", 2);
		именаПолей.Вставить("Метаданные", 3);
		именаПолей.Вставить("Положение", 4);
		именаПолей.Вставить("Описание", 5);
		
	КонецЕсли;
	
	Возврат именаПолей;
	
КонецФункции

Процедура ДобавитьСтрокуВТаблицу(СтрокаДанных, тз, именаПолей)
	
	новСтрока = тз.Добавить();
	
	Для Каждого цКлючИЗначение Из именаПолей Цикл
		
		новСтрока[цКлючИЗначение.Ключ] = СтрокаДанных[цКлючИЗначение.Значение];
		
	КонецЦикла;
	
	Если НЕ ЗначениеЗаполнено(новСтрока.Серьезность) Тогда
		
		новСтрока.Серьезность = "Ошибка";
		
	КонецЕсли;
	
	ПереопределитьПути(новСтрока);
	
КонецПроцедуры

Процедура ПереопределитьПути(СтрокаТаблицы)
	
	Если НЕ _ВыгружатьОшибкиОбъектов Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если СтрНачинаетсяС(ВРег(СтрокаТаблицы.Положение), "СТРОКА ") Тогда
		
		Возврат;
		
	КонецЕсли;
	
	путьПереопределен = Ложь;
	
	ПереопределитьПутьКФорме(СтрокаТаблицы, путьПереопределен);
	ПереопределитьПутьКМакету(СтрокаТаблицы, путьПереопределен);
	ПереопределитьПутьКОбъекту(СтрокаТаблицы, путьПереопределен);
	ПереопределитьПутьКПодсистеме(СтрокаТаблицы, путьПереопределен);
	
	Если НЕ путьПереопределен Тогда
		
		Если ВыведенныеСообщения.ПутьНеПереопределен[СтрокаТаблицы.Метаданные] = Неопределено Тогда
			
			_Лог.Предупреждение("Не переопределен путь для %1", СтрокаТаблицы.Метаданные);
			ВыведенныеСообщения.ПутьНеПереопределен.Вставить(СтрокаТаблицы.Метаданные, Истина);
			
		КонецЕсли;
		
		СтрокаТаблицы.Метаданные = "Конфигурация.МодульУправляемогоПриложения";
		СтрокаТаблицы.Описание = СтрокаТаблицы.Метаданные + ": " + СтрокаТаблицы.Описание;
		
	КонецЕсли;
	
	СтрокаТаблицы.Положение = "Строка 1";
	
КонецПроцедуры

#Область ПереопределениеПутей

Процедура ПереопределитьПутьКФорме(СтрокаТаблицы, ПутьПереопределен)
	
	Если путьПереопределен Тогда
		Возврат;
	КонецЕсли;
	
	Если СтрЗаканчиваетсяНа(ВРег(СтрокаТаблицы.Метаданные), ".ФОРМА") Тогда
		
		// Вешаем на модуль формы
		
		СтрокаТаблицы.Метаданные = СтрокаТаблицы.Метаданные + ".Модуль";
		
		путьПереопределен = Истина;
		Возврат;

	КонецЕсли;

	индексАтрибутовФормы = СтрНайти(СтрокаТаблицы.Метаданные, "Form.Attributes");

	Если индексАтрибутовФормы > 0 Тогда
		
		// Ошибка в дин. списке формы или еще в каких-то свойствах
		
		СтрокаТаблицы.Метаданные = Лев(СтрокаТаблицы.Метаданные, индексАтрибутовФормы - 1) + "Форма.Модуль";
		
		путьПереопределен = Истина;
		Возврат;
		
	КонецЕсли;
	
	Если СтрЗаканчиваетсяНа(ВРег(СтрокаТаблицы.Метаданные), ВРег(".Форма.УсловноеОформление")) Тогда
		
		// Вешаем на модуль формы
		
		СтрокаТаблицы.Метаданные = СтрЗаменить(СтрокаТаблицы.Метаданные, ".Форма.УсловноеОформление", ".Форма.Модуль");
		
		путьПереопределен = Истина;
		Возврат;

	КонецЕсли;
	
КонецПроцедуры

Процедура ПереопределитьПутьКМакету(СтрокаТаблицы, ПутьПереопределен)
	
	Если путьПереопределен Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ СтрЗаканчиваетсяНа(ВРег(СтрокаТаблицы.Метаданные), ".МАКЕТ") Тогда
		Возврат;
	КонецЕсли;
	
	// Вешаем на модуль объекта
	
	компонентыПути = СтрРазделить(СтрокаТаблицы.Метаданные, ".");
	компонентовВПутиДляОбъекта = 2;

	Если компонентыПути.Количество() < компонентовВПутиДляОбъекта Тогда
		Возврат;
	КонецЕсли;
	
	путьКОбъекту = компонентыПути[0] + "." + компонентыПути[1];
	проект = СтрокаТаблицы.Проект;

	Если ПутьКМетаданнымСуществует(проект, путьКОбъекту + ".МодульОбъекта") Тогда
			
		СтрокаТаблицы.Метаданные = путьКОбъекту + ".МодульОбъекта";
		
	ИначеЕсли ПутьКМетаданнымСуществует(проект, путьКОбъекту + ".МодульМенеджера") Тогда
		
		СтрокаТаблицы.Метаданные = путьКОбъекту + ".МодульМенеджера";
		
	ИначеЕсли ПутьКМетаданнымСуществует(проект, путьКОбъекту + ".МодульНабораЗаписей") Тогда
		
		СтрокаТаблицы.Метаданные = путьКОбъекту + ".МодульНабораЗаписей";
		
	Иначе
		
		// некуда вешать
		Возврат;
		
	КонецЕсли;
	
	путьПереопределен = Истина;
	
КонецПроцедуры

Процедура ПереопределитьПутьКОбъекту(СтрокаТаблицы, ПутьПереопределен)
	
	Если путьПереопределен Тогда
		Возврат;
	КонецЕсли;
	
	мета = СтрокаТаблицы.Метаданные;
	проект = СтрокаТаблицы.Проект;
	
	компонентовВПутиДляОбъекта = 2;
	
	Если СтрРазделить(мета, ".").Количество() = компонентовВПутиДляОбъекта Тогда
		
		Если ПутьКМетаданнымСуществует(проект, мета + ".МодульОбъекта") Тогда
			
			СтрокаТаблицы.Метаданные = мета + ".МодульОбъекта";
			
		ИначеЕсли ПутьКМетаданнымСуществует(проект, мета + ".МодульМенеджера") Тогда
			
			СтрокаТаблицы.Метаданные = мета + ".МодульМенеджера";
			
		ИначеЕсли ПутьКМетаданнымСуществует(проект, мета + ".МодульНабораЗаписей") Тогда
			
			СтрокаТаблицы.Метаданные = мета + ".МодульНабораЗаписей";
			
		ИначеЕсли ПутьКМетаданнымСуществует(проект, мета + ".МодульМенеджераЗначения") Тогда
			
			СтрокаТаблицы.Метаданные = мета + ".МодульМенеджераЗначения";
			
		ИначеЕсли ПутьКМетаданнымСуществует(проект, мета + ".МодульКоманды") Тогда
			
			СтрокаТаблицы.Метаданные = мета + ".МодульКоманды";
			
		Иначе
			
			СтрокаТаблицы.Метаданные = "Конфигурация.МодульУправляемогоПриложения";
			СтрокаТаблицы.Описание = мета + ": " + СтрокаТаблицы.Описание;
			
		КонецЕсли;
		
		ПутьПереопределен = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПереопределитьПутьКПодсистеме(СтрокаТаблицы, ПутьПереопределен)
	
	Если путьПереопределен Тогда
		Возврат;
	КонецЕсли;
	
	Если СтрНачинаетсяС(ВРег(СтрокаТаблицы.Метаданные), "ПОДСИСТЕМА.") Тогда
		
		СтрокаТаблицы.Метаданные = "Конфигурация.МодульУправляемогоПриложения";
		СтрокаТаблицы.Описание = СтрокаТаблицы.Метаданные + ": " + СтрокаТаблицы.Описание;
		
		путьПереопределен = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

Процедура ЗаполнитьВТаблицеРезультатовИсходныеПути(таблицаРезультатов)
	
	таблицаРезультатов.Колонки.Добавить("Путь");
	
	Для Каждого цСтрока Из таблицаРезультатов Цикл
		
		генераторПутей = ГенераторПутейПоИмениПроекта(цСтрока.Проект);
		
		цСтрока.Путь = генераторПутей.Путь(цСтрока.Метаданные);
		
		Если НЕ ПроверитьПуть(цСтрока.Путь, цСтрока.Метаданные) Тогда
			
			цСтрока.Путь = "";
			
		КонецЕсли;
		
	КонецЦикла;
	
	поискСтрокКУдалению = Новый Структура("Путь", "");
	
	Для Каждого цСтрокаКУдалению Из таблицаРезультатов.НайтиСтроки(поискСтрокКУдалению) Цикл
		
		таблицаРезультатов.Удалить(цСтрокаКУдалению);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьВТаблицеРезультатовНомераСтрок(таблицаРезультатов)
	
	таблицаРезультатов.Колонки.Добавить("НомерСтроки");
	
	Для Каждого цСтрока Из таблицаРезультатов Цикл
		
		цСтрока.НомерСтроки = СтрЗаменить(ВРег(цСтрока.Положение), "СТРОКА ", "");
		
	КонецЦикла;
	
КонецПроцедуры

Функция ГенераторПутейПоИмениПроекта(Знач ИмяПроекта)
	
	генераторПутей = ГенераторПутейПоПроекту[ИмяПроекта];
	
	Если генераторПутей = Неопределено Тогда
		
		генераторПутей = ГенераторПутейПоПроекту[""];
		ГенераторПутейПоПроекту.Вставить(имяПроекта, генераторПутей);
		
	КонецЕсли;
	
	Возврат генераторПутей;
	
КонецФункции

#Область ПереопределениеИдентификаторов

Процедура ПереопределитьИдентификаторыПравил(таблицаРезультатов)
	
	данныеПереопределения = ПрочитатьДанныеПереопределенияИдентификаторов();
	
	СловарьПравил = СловарьПравилДляПереопределения(данныеПереопределения);
	
	// переопределение в основной таблице
	новыеСинонимы = Новый Соответствие();
	
	Для Каждого цСтрокаРезультата Из таблицаРезультатов Цикл
		
		Если ПустаяСтрока(цСтрокаРезультата.Правило) Тогда

			цСтрокаРезультата.ИдентификаторПравила = ИдентификаторПравил(цСтрокаРезультата);
			цСтрокаРезультата.НаименованиеПравила = цСтрокаРезультата.ИдентификаторПравила;
			цСтрокаРезультата.ОписаниеПравила = цСтрокаРезультата.ИдентификаторПравила;
			
			Продолжить;
			
		КонецЕсли;
		
		ИмяПравила = СловарьПравил[цСтрокаРезультата.Правило];

		цСтрокаРезультата.ИдентификаторПравила = цСтрокаРезультата.Правило;
		цСтрокаРезультата.НаименованиеПравила = ИмяПравила;
		цСтрокаРезультата.ОписаниеПравила = ИмяПравила;
		
		Если ИмяПравила = Неопределено Тогда
			
			цСтрокаРезультата.Правило = АвтоСиноним(НовыеСинонимы, цСтрокаРезультата.Правило, цСтрокаРезультата.Описание, ДанныеПереопределения);
			
		Иначе
			
			цСтрокаРезультата.Правило = ИмяПравила;
			
		КонецЕсли;
		
	КонецЦикла;
	
	СообщитьОНовыхИдентификаторах(новыеСинонимы);
	
КонецПроцедуры

Функция ПрочитатьДанныеПереопределенияИдентификаторов()
	
	имяФайла = ОбъединитьПути("dict", "ruleID_edt.json");
	
	Файл = Новый Файл(ОбъединитьПути(ТекущийСценарий().Каталог, "..", "..", имяФайла));
	Если НЕ Файл.Существует() Тогда
		_Лог.Предупреждение("Файл %1 для переопределния идентификаторов не найден", имяФайла);
		Возврат Неопределено;
	КонецЕсли;
	
	ИмяСловаряИдентификаторовПравил = Файл.ПолноеИмя;
	
	Попытка
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.ОткрытьФайл(ИмяСловаряИдентификаторовПравил, "UTF-8");
		Данные = ПрочитатьJSON(ЧтениеJSON, Истина);
	Исключение
		_Лог.Предупреждение("Ошибка чтения словаря правил в файле %1
			|%2", ИмяСловаряИдентификаторовПравил, ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;
	
	ИсточникПравил = Данные["rulespaces"];
	СловарьПравил = Данные["rulename"];
	
	Если ТипЗнч(ИсточникПравил) <> Тип("Соответствие")
		ИЛИ ТипЗнч(СловарьПравил) <> Тип("Соответствие") Тогда
		_Лог.Предупреждение("Неверная структура словаря правил в файле %1", ИмяСловаряИдентификаторовПравил);
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Данные;
	
КонецФункции

Функция СловарьПравилДляПереопределения(Знач ДанныеПереопределения)
	
	ИсточникПравил = ДанныеПереопределения["rulespaces"];
	СловарьПравил = ДанныеПереопределения["rulename"];
	
	// Дополним имена правил префиксами
	_соотвКЗаполнению = Новый Соответствие();
	
	Для Каждого КЗсловарь Из СловарьПравил Цикл
		Для Каждого КЗисточник Из ИсточникПравил Цикл
			
			Если НЕ СтрНачинаетсяС(КЗсловарь.Ключ, КЗисточник.Ключ) Тогда
				Продолжить;
			КонецЕсли;
			
			мНовоеИмя = Новый Массив();
			Если НЕ ПустаяСтрока(КЗисточник.Значение) Тогда
				мНовоеИмя.Добавить(КЗисточник.Значение); // краткое имя плагина
			КонецЕсли;
			мЧастиИмени = СтрРазделить(КЗсловарь.Ключ, ":", Ложь);
			Если мЧастиИмени.Количество() = 2 Тогда
				мНовоеИмя.Добавить(Сред(СтрЗаменить(мЧастиИмени[0], КЗисточник.Ключ, ""), 2)); // имя "раздела" плагина
			КонецЕсли;
			мНовоеИмя.Добавить(КЗсловарь.Значение); //
			_соотвКЗаполнению[КЗсловарь.Ключ] = СтрСоединить(мНовоеИмя, ".");
			Прервать;
			
		КонецЦикла;
	КонецЦикла;
	
	Для Каждого КЗ Из _соотвКЗаполнению Цикл
		СловарьПравил[КЗ.Ключ] = КЗ.Значение;
	КонецЦикла;
	
	Возврат СловарьПравил;
	
КонецФункции

Функция АвтоСиноним(НовыеСинонимы, Знач Правило, Знач Описание, Знач ДанныеПереопределения)
	
	Если НЕ новыеСинонимы[Правило] = Неопределено Тогда
		Возврат новыеСинонимы[Правило];
	КонецЕсли;
	
	ИсточникПравил = ДанныеПереопределения["rulespaces"];
	
	новыйСиноним = Правило;
	
	Для Каждого КЗ Из ИсточникПравил Цикл
		
		Если НЕ СтрНачинаетсяС(Правило, КЗ.Ключ) Тогда
			Продолжить;
		КонецЕсли;
		
		// для однотипности для правил без синонима для заданных плагинов заменим имя плагина на синоним
		Если ПустаяСтрока(КЗ.Значение) Тогда
			новыйСиноним = СтрЗаменить(Правило, КЗ.Ключ + ".", "");
		Иначе
			новыйСиноним = СтрЗаменить(Правило, КЗ.Ключ, КЗ.Значение);
		КонецЕсли;
		
		Прервать;
		
	КонецЦикла;
	
	НовыеСинонимы[Правило] = Описание;
	
	Возврат новыйСиноним;
	
КонецФункции

Процедура СообщитьОНовыхИдентификаторах(Знач НовыеСинонимы)
	
	Если НовыеСинонимы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	сообщения = Новый СписокЗначений();
	
	Для Каждого КЗ Из НовыеСинонимы Цикл
		Если ЗначениеЗаполнено(КЗ.Значение) Тогда
			сообщения.Добавить("""" + КЗ.Ключ + """: """ + КЗ.Значение + """,");
		КонецЕсли;
	КонецЦикла;
	
	сообщения.СортироватьПоЗначению();
	ТекстСообщения = "Обнаружены новые идентификаторы правил, отсуствующие в словаре:
		|" + СтрСоединить(сообщения.ВыгрузитьЗначения(), Символы.ПС);
	_Лог.Информация(ТекстСообщения);
	
КонецПроцедуры

Функция ИдентификаторПравил(Знач пДанные)
	
	Если ЗначениеЗаполнено(пДанные.Правило) Тогда
		
		Возврат пДанные.Правило;
		
	КонецЕсли;
	
	текстОшибки = пДанные.Описание;
	
	// Контекст ошибки всегда в конце, просто обрежем все, что после [
	
	начало = СтрНайти(текстОшибки, "[");
	
	Если начало > 0 Тогда
		
		текстОшибки = Лев(текстОшибки, начало - 1);
		
	КонецЕсли;
	
	текстОшибки = ЗаменитьТекстВКавычках(текстОшибки, """", "%1");
	текстОшибки = ЗаменитьТекстВКавычках(текстОшибки, "'", "%1");
	
	// Пояснение к ошибке нам не нужно
	
	начало = СтрНайти(текстОшибки, ":", НаправлениеПоиска.СКонца);
	
	Если начало > 0 Тогда
		
		текстОшибки = СокрЛП(Лев(текстОшибки, начало - 1));
		
	КонецЕсли;
	
	// Сонар не любит запятые в тексте правил
	текстОшибки = СтрЗаменить(текстОшибки, ",", "_");
	
	Возврат СокрЛП(текстОшибки);
	
КонецФункции

// Заменяет в строке кавычки на переданный текст с учетом парности
//
// Параметры:
//   Строка - Строка - Строка для замены кавычек
//   Кавычка - Строка - текст, который нужно заменить
//   ТекстЗамены - Строка - текст на который нужно заменить
//
//  Возвращаемое значение:
//   Строка - результат замены
Функция ЗаменитьТекстВКавычках(Знач Строка, Знач Кавычка = """", Знач ТекстЗамены = "")
	
	ПозицияКавычки = СтрНайти(Строка, Кавычка);
	
	Пока ПозицияКавычки > 0 Цикл
		
		ПозицияЗакрывающейКавычки = СтрНайти(Сред(Строка, ПозицияКавычки + 1), Кавычка) + ПозицияКавычки;
		
		Если ПозицияЗакрывающейКавычки = 0 Тогда
			
			Прервать;
			
		КонецЕсли;
		
		Строка        = Лев(Строка, ПозицияКавычки - 1) + ТекстЗамены + Сред(Строка, ПозицияЗакрывающейКавычки + 1);
		ПозицияКавычки = СтрНайти(Строка, Кавычка);
		
	КонецЦикла;
	
	Возврат Строка;
	
КонецФункции

#КонецОбласти

Функция ПутьКМетаданнымСуществует(Знач Проект, Знач пМетаданные)
	
	генераторПутей = ГенераторПутейПоИмениПроекта(Проект);
	
	Путь = генераторПутей.Путь(пМетаданные);
	
	Возврат ПроверитьПуть(Путь, пМетаданные, Ложь);
	
КонецФункции

Функция ПроверитьПуть(Знач пПуть, Знач пМетаданные = "", Знач пСообщать = Истина)
	
	Если НЕ ЗначениеЗаполнено(пПуть) Тогда
		
		Если пСообщать
			И ВыведенныеСообщения.ПутьНеПолучен[пМетаданные] = Неопределено Тогда
			
			_лог.Предупреждение(СтрШаблон("Путь для <%1> не получен", пМетаданные));
			ВыведенныеСообщения.ПутьНеПолучен.Вставить(пМетаданные, Истина);
			
		КонецЕсли;
		
		Возврат Ложь;
		
	ИначеЕсли НЕ ОбщегоНазначения.ФайлСуществует(пПуть) Тогда
		
		Если пСообщать
			И ВыведенныеСообщения.ПутьНеСуществует[пПуть] = Неопределено Тогда
			
			_лог.Предупреждение(СтрШаблон("Путь <%1> для <%2> не существует", пПуть, пМетаданные));
			ВыведенныеСообщения.ПутьНеСуществует.Вставить(пПуть, Истина);
			
		КонецЕсли;
		
		Возврат Ложь;
		
	Иначе
		
		Возврат Истина;
		
	КонецЕсли;
	
КонецФункции

Функция ИмяЛога() Экспорт
	
	Возврат "oscript.app." + ОПриложении.Имя();
	
КонецФункции

_Лог = Логирование.ПолучитьЛог(ИмяЛога());