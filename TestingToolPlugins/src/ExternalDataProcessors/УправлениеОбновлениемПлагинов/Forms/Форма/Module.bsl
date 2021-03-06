
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастройкиПользователя = СценарноеТестированиеВызовСервера.ПолучитьСтруктуруНастроекПользователя(ПользователиВызовСервера.ТекущийПользователь(),ПользователиВызовСервера.ТекущееРабочееМесто());
	ПутьКаталогGIT =  НастройкиПользователя.ПутьКаталогGIT;
	
	Элементы.ТаблицаПлагиновТипХранения.СписокВыбора.Добавить("База1С");
	Элементы.ТаблицаПлагиновТипХранения.СписокВыбора.Добавить("КаталогGIT");				
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбновитьСостояниеПлагиновВообще();

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСостояниеПлагиновВообще()
	
	Перем НастройкиПользователя, ПутьКаталогGIT, ШаблонПоиска;
	
	ТаблицаПлагинов.Очистить();
	
	ЗаполнитьТаблицуПлагинов();
	
	Если ИскатьВКорнеGIT Тогда
		// найдем обработки в гит
		ШаблонПоиска = "*.epf";
		
		НастройкиПользователя = СценарноеТестированиеВызовСервера.ПолучитьСтруктуруНастроекПользователя(ПользователиВызовСервера.ТекущийПользователь(),ПользователиВызовСервера.ТекущееРабочееМесто());
		ПутьКаталогGIT =  НастройкиПользователя.ПутьКаталогGIT;
		
		НачатьПоискФайлов(Новый ОписаниеОповещения("ОбработкаПоискаФайловGIT", ЭтаФорма), ПутьКаталогGIT, ШаблонПоиска, Ложь);
		
		ШаблонПоиска = "*.erf";
		
		НастройкиПользователя = СценарноеТестированиеВызовСервера.ПолучитьСтруктуруНастроекПользователя(ПользователиВызовСервера.ТекущийПользователь(),ПользователиВызовСервера.ТекущееРабочееМесто());
		ПутьКаталогGIT =  НастройкиПользователя.ПутьКаталогGIT;
		
		НачатьПоискФайлов(Новый ОписаниеОповещения("ОбработкаПоискаФайловGIT", ЭтаФорма,новый Структура("Последний",Истина)), ПутьКаталогGIT, ШаблонПоиска, Ложь);
	Иначе
		ПолучитьДанныеИзИсточников();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	Для каждого стр из ТаблицаПлагинов Цикл
		стр.Выбрана = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СнятьФлажки(Команда)
	Для каждого стр из ТаблицаПлагинов Цикл
		стр.Выбрана = Ложь;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаПоискаФайловGIT(НайденныеФайлы, ДополнительныеПараметры) Экспорт

	Для каждого стр из НайденныеФайлы Цикл
		
		// мы не можем прочитать обработку, тогда будет проблема
		Если Найти(стр.ПолноеИмя,"УправлениеОбновлениемПлагинов") Тогда
			Продолжить;
		КонецЕсли;
		
		
		// попробуем загрузить обработку, чтобы прочитать
		Попытка
			Если Найти(стр.ПолноеИмя,".epf") ИЛИ Найти(стр.ПолноеИмя,".erf") Тогда
				ДвоичныеДанные = новый ДвоичныеДанные(стр.ПолноеИмя);
				АдресХранилища = ПоместитьВоВременноеХранилище(ДвоичныеДанные);
				Сведения = ПолучитьСведенияОбОбработке(АдресХранилища);
				
				Если НЕ Сведения=Неопределено Тогда
					стр_н = ТаблицаПлагинов.Добавить();
					стр_н.ИмяФайла = стр.Имя;
					стр_н.ПутьКФайлу = стр.ПолноеИмя;
					
					стр_н.ТипХранения = "КаталогGIT";
					
					стр_н.ВерсияБазы = Сведения.Версия;
					стр_н.Описание = Сведения.Информация;
					стр_н.Имя = Сведения.ИмяОбъекта;
					стр_н.Представление = Сведения.Наименование;
				КонецЕсли;
				
			КонецЕсли;
		Исключение
		Конецпопытки;
		
	КонецЦикла;
	
	// вызываем вконце второго запроса
	Если ДополнительныеПараметры<>Неопределено Тогда
		Если ДополнительныеПараметры.Свойство("Последний")
			И ДополнительныеПараметры.Последний=Истина Тогда
			ПолучитьДанныеИзИсточников();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСведенияОбОбработке(АдресХранилища)
	
	СвойстваСтруктура = Неопределено;
	
	Попытка
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресХранилища);
		ВременныйФайл = ПолучитьИмяВременногоФайла("epf");
		ДвоичныеДанные.Записать(ВременныйФайл);
		Обработка = ВнешниеОбработки.Создать(ВременныйФайл,Истина);
		Свойства = Обработка.СведенияОВнешнейОбработке();
		СвойстваСтруктура = новый Структура("Версия,Информация,Наименование,ИмяОбъекта");
		ЗаполнитьЗначенияСвойств(СвойстваСтруктура,Свойства);
		СвойстваСтруктура.ИмяОбъекта = Обработка.Метаданные().Имя;
		Обработка = Неопределено;
		Попытка
			УдалитьФайлы(ВременныйФайл);
		Исключение
		КонецПопытки;
	Исключение
	КонецПопытки;
	
	Возврат СвойстваСтруктура;
	
КонецФункции


&НаСервере
Процедура ЗаполнитьТаблицуПлагинов()

	Запрос = новый Запрос;
	Запрос.Текст = ПолучитьТекстЗапросаДополнительныхОбработок();
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		стр_н = ТаблицаПлагинов.Добавить();
		ЗаполнитьЗначенияСвойств(стр_н,Выборка);
	КонецЦикла;
	
КонецПроцедуры	

&НаСервереБезКонтекста
Функция ПолучитьТекстЗапросаДополнительныхОбработок()
	
	ТекстЗапроса = "ВЫБРАТЬ
	|	ЛОЖЬ КАК Выбрана,
	|	ДополнительныеОтчетыИОбработки.Ссылка КАК ДополнительнаяОбработка,
	|	ДополнительныеОтчетыИОбработки.Версия КАК ВерсияБазы,
	|	ДополнительныеОтчетыИОбработки.ИмяФайла КАК ИмяФайла,
	|	ДополнительныеОтчетыИОбработки.ПометкаУдаления КАК ПометкаУдаления,
	|	""База1С"" КАК ТипХранения,
	|	ДополнительныеОтчетыИОбработки.ИмяОбъекта КАК Имя,
	|	ДополнительныеОтчетыИОбработки.Наименование КАК Представление,
	|	ДополнительныеОтчетыИОбработки.Информация КАК Описание
	|ИЗ
	|	Справочник.ДополнительныеОтчетыИОбработки КАК ДополнительныеОтчетыИОбработки
	|ГДЕ
	|	ДополнительныеОтчетыИОбработки.ЭтоГруппа = ЛОЖЬ";
	
	Возврат ТекстЗапроса;
	
КонецФункции

&НаКлиенте
Процедура ТаблицаПлагиновПриАктивизацииСтроки(Элемент)
	
	ТекущиеДанные = Элементы.ТаблицаПлагинов.ТекущиеДанные;
	
	Если ТекущиеДанные=Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	СформироватьОписаниеПлагинаДляСтроки(ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура СформироватьОписаниеПлагинаДляСтроки(Источник)
	
	Style= " <style>
	| p {
	|  text-indent: 20px; /* Отступ первой строки в пикселах */
	| }
	| div {
	|  text-indent: 20px; /* Отступ первой строки в пикселах */
	|  padding: 2px; 
	| }
	|</style>";
	Описание = "<div>"+СтрЗаменить(Источник.Описание,Символы.ПС,"</div><div>")+"</div>";
	Описание = СтрЗаменить(Описание,"<div></div>","");
	html = "<html><head>"+Style+"<title>ОписаниеПлагина</title></head><body>";
	html = html+ "<h3>"+Источник.Имя+"</h3>";
	html = html +"<div style='text-align:right'>Версия: "+Источник.ВерсияБазы+"</div><br/>";
	html = html+ Описание;
	
	html = html+"</body></html>";
	ОписаниеHTML = html;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСостояниеПлагинов(Команда)
	ОбновитьСостояниеПлагиновВообще();
КонецПроцедуры


&НаКлиенте
Процедура ПолучитьДанныеИзИсточников()
	
	МассивСтруктураИсточников = ПолучитьМассивСтруктурИсточников();
	ТаблицаДанныхПоВнешнимПлагинам.Очистить();
	
	Для каждого стр из МассивСтруктураИсточников Цикл
		Если стр.ТипИсточника=ПредопределенноеЗначение("Перечисление.ТипыИсточниковПлагинов.АдресИнтернет") Тогда
			// загрузить данные
			ПутьКФайлу = ЗагрузитьФайлПоИнтернетАдресу(стр.АдресИнтернет+"/"+стр.ИмяФайла);
			// парсим данные
			ОбработатьФайлПлагинов(ПутьКФайлу);
			// добавляем в таблицу
		КонецЕсли;
	КонецЦикла;
	
	СопоставитьВнешниеТекущие();
	
КонецПроцедуры

&НаКлиенте
Процедура СопоставитьВнешниеТекущие()
	
	Для каждого стр из ТаблицаПлагинов Цикл
		
		мОтбор = новый Структура("Имя,Найден",стр.Имя,Ложь);
		
		н_строки = ТаблицаДанныхПоВнешнимПлагинам.НайтиСтроки(мОтбор);
		стр.ЦветовойИндекс = 0; // дефолтный
		
		Если н_строки.Количество()>=1 Тогда
			стр_п = н_строки[0];
			стр_п.Найден = Истина;
			стр.ВерсияВнешняя = стр_п.ВерсияВнешняя;
			стр.Автор = стр_п.Автор;
			стр.АдресИнтернет = стр_п.АдресИнтернет;
			стр.ДатаВнешняя = стр_п.ДатаВнешняя;
			
			// если версия больше, тогда выделяем цветом
			//Если стр.ВерсияВнешняя>стр.ВерсияБазы Тогда
			Если ОбщегоНазначенияКлиентСервер.СравнитьВерсииРазныеФорматы(стр.ВерсияБазы,стр.ВерсияВнешняя)>0 Тогда
				стр.ЦветовойИндекс=1;
			Иначе
				стр.ЦветовойИндекс=2;
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
	Для каждого стр из ТаблицаДанныхПоВнешнимПлагинам Цикл
		Если стр.Найден=Истина Тогда
			Продолжить;
		КонецЕсли;
		стр_н = ТаблицаПлагинов.Добавить();
		ЗаполнитьЗначенияСвойств(стр_н,стр);
		стр_н.ЦветовойИндекс = -1; // новые плагины
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьФайлПлагинов(Знач ПутьКФайлу)
	
	ЧтениеXML = Новый ЧтениеXML;
	НоваяЗаписьXML = Новый ЗаписьXML;
	НоваяЗаписьXML = Новый ЗаписьXML;
	НовыйЗаписьDOM = Новый ЗаписьDOM;
	НовыйПостроительDOM = Новый ПостроительDOM;
	
	Попытка
		
		НоваяЧтениеXML = Новый ЧтениеXML ;
		НоваяЧтениеXML.ОткрытьФайл(сокрЛП(ПутьКФайлу));
		НовыйДокументDOM = НовыйПостроительDOM.Прочитать(НоваяЧтениеXML);
		НоваяЧтениеXML.Закрыть();	
		
		НовыйСписокЭлементовDOM = НовыйДокументDOM.ПолучитьЭлементыПоИмени("plugins");
		Если НовыйСписокЭлементовDOM.Количество()=1 Тогда
			Для каждого Элемент из НовыйСписокЭлементовDOM[0].ДочерниеУзлы Цикл
				Если Элемент.ИмяУзла = "item" Тогда
					стр_н = ТаблицаДанныхПоВнешнимПлагинам.Добавить();
					стр_н.ТипХранения = "";
					Для каждого Атрибут из Элемент.Атрибуты Цикл	
						Если Атрибут.ИмяУзла="url" Тогда
							стр_н.АдресИнтернет = Атрибут.ТекстовоеСодержимое;
						ИначеЕсли Атрибут.ИмяУзла="vers" Тогда
							стр_н.ВерсияВнешняя = Атрибут.ТекстовоеСодержимое;
						ИначеЕсли Атрибут.ИмяУзла="name" Тогда
							стр_н.Имя = Атрибут.ТекстовоеСодержимое;
							стр_н.Представление = Атрибут.ТекстовоеСодержимое;
						ИначеЕсли Атрибут.ИмяУзла="author" Тогда
							стр_н.Автор = Атрибут.ТекстовоеСодержимое;
						ИначеЕсли Атрибут.ИмяУзла="infourl" Тогда
							стр_н.АдресИнтернетОписание = Атрибут.ТекстовоеСодержимое;
						ИначеЕсли Атрибут.ИмяУзла="date" Тогда
							стр_н.ДатаВнешняя = Атрибут.ТекстовоеСодержимое;
						КонецЕсли;
					КонецЦикла;
				КонецЕсли;
				
				
			КонецЦикла;
		КонецЕсли;	
		
	Исключение
		Сообщить("Ошибка обработки файла с инфорацией о плагинах! "+ОписаниеОшибки());
	КонецПопытки;
	
	
КонецПроцедуры

&НаКлиенте
Функция ЗагрузитьФайлПоИнтернетАдресу(Знач ПолныйАдресРесурса)
	
	ПутьКФайлу = "";
	
	СтруктураURI = СтруктураURI(ПолныйАдресРесурса); 
	
	Если Найти(ПолныйАдресРесурса,"https://") Тогда
		ЗащищенноеСоединение = новый ЗащищенноеСоединениеOpenSSL();
		HTTPСоединение = Новый HTTPСоединение(СтруктураURI.Хост, СтруктураURI.Порт,,,,,ЗащищенноеСоединение);
	Иначе
		
		HTTPСоединение = Новый HTTPСоединение(СтруктураURI.Хост, СтруктураURI.Порт);
	КонецЕсли;
	HTTPЗапрос = Новый HTTPЗапрос(СтруктураURI.ПутьНаСервере);
	ПутьКФайлу = ПолучитьИмяВременногоФайла();
	
	Попытка
		Результат =  HTTPСоединение.Получить(HTTPЗапрос,ПутьКФайлу);
	Исключение
		// исключение здесь говорит о том, что запрос не дошел до HTTP-Сервера
		Сообщить("Произошла сетевая ошибка!"+Символы.ПС+ОписаниеОшибки());
		Возврат ПутьКФайлу;
	КонецПопытки;	
	
	// Анализируем фатальные ошибки
	// В большинстве случаев нужно остановить работу и показать пользователю сообщение об ошибке,
	// включив в него HTTP-статус
	
	// Ошибки 4XX говорят о неправильном запросе - в широком смысле
	// Может быть неправильный адрес, ошибка аутентификации, плохой формат запроса
	// Подробнее смотри http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4
	Если Результат.КодСостояния >= 400 и Результат.КодСостояния < 500  Тогда
		Сообщить("Код статуса больше 4XX, ошибка запроса.  Код статуса: " + Результат.КодСостояния);
	КонецЕсли;
	
	// Ошибки 5XX говорят о проблемах на сервере (возможно, прокси-сервер)
	// Это может быть программная ошибка, нехватка памяти, ошибка конфигурации и т.д.
	// Подробнее смотри http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.5
	Если Результат.КодСостояния >= 500 и Результат.КодСостояния < 600  Тогда
		Сообщить("Код статуса больше 5XX, ошибка сервера. Код статуса: " + Результат.КодСостояния);
	КонецЕсли;
	
	// Обрабатываем перенаправление
	Если Результат.КодСостояния >= 300 и Результат.КодСостояния < 400  Тогда
		//Сообщить("Код статуса больше 3XX, Перенаправление. Код статуса: " + Результат.КодСостояния);
		Если Результат.КодСостояния = 302 Тогда
			//Сообщить("Код статуса 302, Постоянное перенаправление.");
			АдресРесурса = Результат.Заголовки.Получить("Location");
			Если АдресРесурса <> Неопределено Тогда
				//Сообщить("Выполняю запрос по новому адресу " + АдресРесурса);
				ПутьКФайлу = ЗагрузитьФайлПоИнтернетАдресу(АдресРесурса);
			Иначе
				Сообщить("Сервер не сообщил адрес ресурса!");
			КонецЕсли;
		ИначеЕсли Результат.КодСостояния = 301 Тогда
			//Сообщить("Код статуса 301, Временное перенаправление.");
			АдресРесурса = Результат.Заголовки.Получить("Location");
			Если АдресРесурса <> Неопределено Тогда
				//Сообщить("Выполняю запрос по новому адресу " + АдресРесурса);
				ПутьКФайлу = ЗагрузитьФайлПоИнтернетАдресу(АдресРесурса);
			Иначе
				Сообщить("Сервер не сообщил адрес ресурса!");
			КонецЕсли;
			
		КонецЕсли;
	КонецЕсли;
	
	// Статусы 1XX и 2XX считаем хорошими
	Если Результат.КодСостояния < 300 Тогда 
	КонецЕсли; 	
	
	Возврат ПутьКФайлу;
	
КонецФункции

&НаКлиенте
Функция СтруктураURI(Знач СтрокаURI) Экспорт
	
	СтрокаURI = СокрЛП(СтрокаURI);
	
	// схема
	Схема = "";
	Позиция = Найти(СтрокаURI, "://");
	Если Позиция > 0 Тогда
		Схема = НРег(Лев(СтрокаURI, Позиция - 1));
		СтрокаURI = Сред(СтрокаURI, Позиция + 3);
	КонецЕсли;

	// строка соединения и путь на сервере
	СтрокаСоединения = СтрокаURI;
	ПутьНаСервере = "";
	Позиция = Найти(СтрокаСоединения, "/");
	Если Позиция > 0 Тогда
		ПутьНаСервере = Сред(СтрокаСоединения, Позиция + 1);
		СтрокаСоединения = Лев(СтрокаСоединения, Позиция - 1);
	КонецЕсли;
		
	// информация пользователя и имя сервера
	СтрокаАвторизации = "";
	ИмяСервера = СтрокаСоединения;
	Позиция = Найти(СтрокаСоединения, "@");
	Если Позиция > 0 Тогда
		СтрокаАвторизации = Лев(СтрокаСоединения, Позиция - 1);
		ИмяСервера = Сред(СтрокаСоединения, Позиция + 1);
	КонецЕсли;
	
	// логин и пароль
	Логин = СтрокаАвторизации;
	Пароль = "";
	Позиция = Найти(СтрокаАвторизации, ":");
	Если Позиция > 0 Тогда
		Логин = Лев(СтрокаАвторизации, Позиция - 1);
		Пароль = Сред(СтрокаАвторизации, Позиция + 1);
	КонецЕсли;
	
	// хост и порт
	Хост = ИмяСервера;
	Порт = "";
	Позиция = Найти(ИмяСервера, ":");
	Если Позиция > 0 Тогда
		Хост = Лев(ИмяСервера, Позиция - 1);
		Порт = Сред(ИмяСервера, Позиция + 1);
	КонецЕсли;
	
	Результат = Новый Структура;
	Результат.Вставить("Схема", Схема);
	Результат.Вставить("Логин", Логин);
	Результат.Вставить("Пароль", Пароль);
	Результат.Вставить("ИмяСервера", ИмяСервера);
	Результат.Вставить("Хост", Хост);
	Результат.Вставить("Порт", ?(Порт <> "", Число(Порт), Неопределено));
	Результат.Вставить("ПутьНаСервере", ПутьНаСервере);
	
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьМассивСтруктурИсточников()
	
	МассивСтруктураИсточников = новый Массив;
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ИсточникиПлагинов.ИмяИсточника,
	|	ИсточникиПлагинов.Порядок КАК Порядок,
	|	ИсточникиПлагинов.ТипИсточника,
	|	ИсточникиПлагинов.ПутьКаталог,
	|	ИсточникиПлагинов.АдресИнтернет,
	|	ИсточникиПлагинов.ИмяФайла,
	|	ИсточникиПлагинов.Отключить
	|ИЗ
	|	РегистрСведений.ИсточникиПлагинов КАК ИсточникиПлагинов
	|ГДЕ
	|	НЕ ИсточникиПлагинов.Отключить = ИСТИНА
	|
	|УПОРЯДОЧИТЬ ПО
	|	Порядок";
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Структура = новый Структура("ИмяИсточника,ПутьКаталог,АдресИнтернет,ИмяФайла,ТипИсточника");
		ЗаполнитьЗначенияСвойств(Структура,Выборка);
		МассивСтруктураИсточников.Добавить(Структура);
		
	КонецЦикла;
	
	Возврат МассивСтруктураИсточников;
	
КонецФункции


&НаКлиенте
Процедура ЗагрузитьОбновления(Команда)
	
	ПоказатьОповещениеПользователя("Загрузка/обнволение плагинов",,"Начало загрузки ...",БиблиотекаКартинок.БегущийЧеловек);
	// по таблице грузим
	мОтбор = новый Структура("Выбрана",Истина);
	н_строки = ТаблицаПлагинов.НайтиСтроки(мОтбор);
	
	// проверим указание Типа хранения
	Для каждого стр из н_строки Цикл
		Если НЕ ЗначениеЗаполнено(стр.ТипХранения) Тогда
			Сообщить("Укажите куда загружать тип хранения (в базу1С, каталог git) прежде!");
			Возврат;
		КонецЕсли;
	КонецЦикла;
	
	// не будемгрузить обработку в базу
	Для каждого стр из н_строки Цикл
		Если стр.ТипХранения="База1С" и стр.Имя="УправлениеОбновлениемПлагинов" Тогда
			стр.Выбрана=Ложь;
			Сообщить("Из-за особенностей работы платформы 1с не возможно обновить текущую обработку в базе 1С.");
		КонецЕсли;
	КонецЦикла;
	
	ш=0;
	Для каждого стр из н_строки Цикл
		
		ш=ш+1;		
		Попытка
			// загрузка
			Если ЗначениеЗаполнено(стр.АдресИнтернет) Тогда
				ПутьКФайлу = ЗагрузитьФайлПоИнтернетАдресу(стр.АдресИнтернет);
				Если стр.ТипХранения="КаталогGIT" Тогда
					// копируем
					Если не ЗначениеЗаполнено(стр.ПутьКФайлу) Тогда
						стр.ПутьКФайлу = ПутьКаталогGIT+"\"+ПолучитьИмяФайлаПоАдресуИнтернет(стр.АдресИнтернет);
					КонецЕсли;
					ПереместитьФайл(ПутьКФайлу,стр.ПутьКФайлу);
				ИначеЕсли стр.ТипХранения="База1С" Тогда
					// надо обновить в базе
					ОбновитьДополнительнуюОбработку(ПутьКФайлу,стр.ДополнительнаяОбработка,ПолучитьИмяФайлаПоАдресуИнтернет(стр.АдресИнтернет));
				КонецЕсли;
				
				// почистим хвосты
				УдалитьФайлы(ПутьКФайлу);
				
			КонецЕсли;
		Исключение
			Сообщить("Не удалось обновить плагин. Причина:"+Символы.ПС+ОписаниеОшибки());
		КонецПопытки;
		ПоказатьОповещениеПользователя("Загрузка/обнволение плагинов",,"Процент загрузки: "+Строка(Окр(100*ш/н_строки.Количество(),0,РежимОкругления.Окр15как20)),БиблиотекаКартинок.БегущийЧеловек);
		
		
	КонецЦикла;
	
	ПоказатьОповещениеПользователя("Загрузка/обнволение плагинов",,"Обновление списка ...",БиблиотекаКартинок.БегущийЧеловек);
	
	// обновляем состояния
	ОбновитьСостояниеПлагиновВообще();
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьИмяФайлаПоАдресуИнтернет(Знач АдресИнтернет)
	
	ПутьКФайлу = "";
	
	Структура = СтруктураURI(АдресИнтернет);
	ПутьНаСервере = СтрЗаменить(Структура.ПутьНаСервере,"/","\");
	Разбор = СтрРазделить(ПутьНаСервере,"\",Ложь);
	
	Для каждого стр из Разбор Цикл
		
		Если Найти(стр,".epf") или Найти(стр,".epf") Тогда
			ПутьКФайлу = стр;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ПутьКФайлу;
	
КонецФункции

&НаКлиенте
Процедура ОбновитьДополнительнуюОбработку(Знач ПутьКФайлу,Знач Ссылка,Знач ИмяФайла)
	
	ДвоичныеДанные = новый ДвоичныеДанные(ПутьКФайлу);
	АдресХранилища = ПоместитьВоВременноеХранилище(ДвоичныеДанные);
	ОбновитьДополнительнуюОбработкуСервер(АдресХранилища,Ссылка,ИмяФайла);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОбновитьДополнительнуюОбработкуСервер(Знач АдресХранилища,Знач Ссылка, Знач ИмяФайла)
	
	// это все потом надо вынести в общий модуль, но так как в БСП куча всякой х... потом доработаем конфигурацию
	Попытка
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресХранилища);
		ВременныйФайл = ПолучитьИмяВременногоФайла("epf");
		ДвоичныеДанные.Записать(ВременныйФайл);
		Обработка = ВнешниеОбработки.Создать(ВременныйФайл,Истина);
		Свойства = Обработка.СведенияОВнешнейОбработке();
		
		// если существует
		Если ЗначениеЗаполнено(Ссылка) Тогда
			ОбработкаОбъект = Ссылка.ПолучитьОбъект();
		Иначе
			ОбработкаОбъект = Справочники.ДополнительныеОтчетыИОбработки.СоздатьЭлемент();
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ОбработкаОбъект.Вид) Тогда
			Если Найти(ИмяФайла,".epf") Тогда
				ОбработкаОбъект.Вид = Перечисления.ВидыДополнительныхОтчетовИОбработок.ДополнительнаяОбработка;
			Иначе
				ОбработкаОбъект.Вид = Перечисления.ВидыДополнительныхОтчетовИОбработок.ДополнительныйОтчет;
			КонецЕсли;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ОбработкаОбъект.Публикация) Тогда
			ОбработкаОбъект.Публикация=Перечисления.ВариантыПубликацииДополнительныхОтчетовИОбработок.Используется;
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ОбработкаОбъект.ИмяФайла) Тогда
			ОбработкаОбъект.ИмяФайла = ИмяФайла;
		КонецЕсли;
		
		ОбработкаОбъект.ХранилищеОбработки = ДвоичныеДанные;
		ОбработкаОбъект.ИмяОбъекта = Обработка.Метаданные().Имя;
		
		ЗаполнитьЗначенияСвойств(ОбработкаОбъект,Свойства);
		Если Свойства.Вид="ДополнительнаяОбработка" И ТипЗнч(Свойства.Вид)=Тип("Строка") И ЗначениеЗаполнено(Свойства.Вид) Тогда
			ОбработкаОбъект.Вид = Перечисления.ВидыДополнительныхОтчетовИОбработок[Свойства.Вид];
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ОбработкаОбъект.Ответственный) Тогда
			ОбработкаОбъект.Ответственный = Пользователи.ТекущийПользователь();
		КонецЕсли;
		
		// команды
		ТаблицаСтарыхКоманд = ОбработкаОбъект.Команды.Выгрузить();
		ОбработкаОбъект.Команды.Очистить();
		Для каждого стр из Свойства.Команды Цикл
			// новые данные
			стр_н = ОбработкаОбъект.Команды.Добавить();
			ЗаполнитьЗначенияСвойств(стр_н,стр);
			Если ТипЗнч(стр.Использование)=Тип("Строка") и ЗначениеЗаполнено(стр.Использование) Тогда
				стр_н.ВариантЗапуска = Перечисления.СпособыВызоваДополнительныхОбработок[стр.Использование];
			КонецЕсли;
			// может найдем в старой?
			мОтбор = новый Структура("Идентификатор",стр.Идентификатор);
			н_стр = ТаблицаСтарыхКоманд.НайтиСтроки(мОтбор);
			Если н_стр.Количество()=1 Тогда
				ЗаполнитьЗначенияСвойств(стр_н,н_стр[0]);
			КонецЕсли;
		КонецЦикла;
		
		ОбработкаОбъект.Записать();
		
		Обработка = Неопределено;
		
		
		Попытка
			УдалитьФайлы(ВременныйФайл);
		Исключение
		КонецПопытки;
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры