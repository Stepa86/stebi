#Использовать logos

Перем _Лог;
Перем _файлыОшибок;
Перем _ФайлНастроек;
Перем _ФорматОтчета; // Используемый формат отчета

Перем _ЧтениеНастроек; // Интерфейс чтения настроек нужного формата

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Аргумент("GENERIC_ISSUE_SETTINGS_JSON", "", "Путь к файлу настроек. Если файл существует, то он будет обновлен. Например ./generic-issue-settings.json")
		.ТСтрока()
		.ВОкружении("GENERIC_ISSUE_SETTINGS_JSON");
	
	Команда.Аргумент("GENERIC_ISSUE_JSON", "", "Путь к файлам generic-issue.json, на основе которых будет создан файл настроек. Например ./edt-json.json,./acc-generic-issue.json")
		.ТСтрока()
		.ВОкружении("GENERIC_ISSUE_JSON");
	
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
	
	таблицаНастроек = ОбщегоНазначения.ПолучитьТаблицуНастроек(_ФайлНастроек, _Лог);
	_лог.Отладка("Из файла настроек прочитано: " + таблицаНастроек.Количество());
	
	Настройки = ПрочитатьЗначенияИзФайлов();
	
	структПоиска = Новый Структура("ruleId,message,filePath", "", "", "");
	
	Для Каждого цЭлемент Из Настройки.Ишузы Цикл
		
		структПоиска.ruleId = цЭлемент.Ключ;
		
		Если таблицаНастроек.НайтиСтроки(структПоиска).Количество() = 0 Тогда
			
			новСтрока = таблицаНастроек.Добавить();
			
			ЗаполнитьЗначенияСвойств(новСтрока, цЭлемент.Значение);
			новСтрока.ruleId = цЭлемент.Ключ;
			новСтрока.message = "";
			новСтрока.filePath = "";
			
			данныеПравила = Настройки.Правила.Получить(цЭлемент.Ключ);
			
			Если НЕ данныеПравила = Неопределено Тогда
				ЗаполнитьЗначенияСвойств(новСтрока, данныеПравила);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	структПоиска.ruleId = "";
	
	Если таблицаНастроек.НайтиСтроки(структПоиска).Количество() = 0 Тогда
		
		новСтрока = таблицаНастроек.Добавить();
		
		новСтрока.ruleId = "";
		новСтрока.message = "";
		новСтрока.filePath = "";
		
	КонецЕсли;
	
	таблицаНастроек.Сортировать("ruleId,message,filePath");
	
	_лог.Отладка("Различных настроек: " + таблицаНастроек.Количество());
	
	настройкиКЗаписи = Новый Массив;
	
	Для Каждого цСтрокаНастройки Из таблицаНастроек Цикл
		
		структНастройка = _ЧтениеНастроек.ЭлементНастройки_Generic_Issue();
		ЗаполнитьЗначенияСвойств(структНастройка, цСтрокаНастройки);
		настройкиКЗаписи.Добавить(структНастройка);
		
	КонецЦикла;
	
	_лог.Отладка("К записи в файл: " + настройкиКЗаписи.Количество());
	
	ОбщегоНазначения.ЗаписатьJSONВФайл(настройкиКЗаписи, _ФайлНастроек, _Лог);
	
КонецПроцедуры

Процедура ИнициализацияПараметров(Знач Команда)
	
	Если Команда.ЗначениеОпции("debug") Тогда
		_Лог.УстановитьУровень(УровниЛога.Отладка);
	КонецЕсли;

	путьКФайлуНастроек = Команда.ЗначениеАргумента("GENERIC_ISSUE_SETTINGS_JSON");
	файлыОшибок = Команда.ЗначениеАргумента("GENERIC_ISSUE_JSON");
	
	_ФорматОтчета = Команда.ЗначениеОпции("Format");
	_лог.Отладка("Формат отчета = " + _ФорматОтчета);
	
	Если _ФорматОтчета = ТипыФорматаОтчетаСонар.Generic_Issue_10_3 Тогда
		
		_ЧтениеНастроек = Настройки_Generic_Issue_10_3;
		
	Иначе
		
		_ЧтениеНастроек = Настройки_Generic_Issue;
		
	КонецЕсли;
	
	_ФайлНастроек = ОбщегоНазначения.АбсолютныйПуть(путьКФайлуНастроек);
	_лог.Отладка("Файл настроек = " + _ФайлНастроек);
	
	_файлыОшибок = Новый Массив;
	
	Для Каждого цПутьКФайлу Из СтрРазделить(файлыОшибок, ",") Цикл
		
		Если ОбщегоНазначения.ФайлСуществует(цПутьКФайлу) Тогда
			
			файлСОшибками = ОбщегоНазначения.АбсолютныйПуть(цПутьКФайлу);
			
			_файлыОшибок.Добавить(файлСОшибками);
			
			_лог.Отладка("Добавлен файл generic-issue = " + файлСОшибками);
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПрочитатьЗначенияИзФайлов()
	
	Настройки = Новый Структура;
	Настройки.Вставить("Ишузы", Новый Соответствие);
	Настройки.Вставить("Правила", Новый Соответствие);
	
	Для Каждого цФайл Из _файлыОшибок Цикл
		
		_ЧтениеНастроек.ДобавитьВНастройкиЗначенияИзФайла(Настройки, цФайл, _Лог);
		
	КонецЦикла;
	
	_лог.Отладка("Формата отчета: " + _ФорматОтчета);
	_лог.Отладка("Из файлов прочитано различных ошибок: " + Настройки.Ишузы.Количество());
	_лог.Отладка("Из файлов прочитано различных правил: " + Настройки.Правила.Количество());
	
	Возврат Настройки;
	
КонецФункции

Функция ИмяЛога() Экспорт
	
	Возврат "oscript.app." + ОПриложении.Имя();
	
КонецФункции

_Лог = Логирование.ПолучитьЛог(ИмяЛога());