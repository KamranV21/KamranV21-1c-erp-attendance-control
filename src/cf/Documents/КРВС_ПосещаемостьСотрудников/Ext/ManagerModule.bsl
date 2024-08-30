﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область Проведение

// Инициализация данных документа для последующего формирования движений.
// 
// Параметры:
//  ДокументСсылка - ДокументСсылка.ИНК_ПриемБанкнот - Документ ссылка
//  ДополнительныеСвойства - Структура - Дополнительные свойства
//  Регистры - Неопределено - Регистры
Процедура ИнициализироватьДанныеДокумента(ДокументСсылка, ДополнительныеСвойства, Регистры = Неопределено) Экспорт
	
	////////////////////////////////////////////////////////////////////////////
	// Создадим запрос инициализации движений

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", ДокументСсылка);
	
	////////////////////////////////////////////////////////////////////////////
	// Сформируем текст запроса

	ТекстыЗапроса = Новый СписокЗначений;
	ТекстЗапросаТаблицаПосещаемостьСотрудников(Запрос, ТекстыЗапроса, Регистры);
	ТекстЗапросаТаблицаВремяПриходаУходаСотрудников(Запрос, ТекстыЗапроса, Регистры);

	ПроведениеСерверУТ.ИнициализироватьТаблицыДляДвижений(Запрос, ТекстыЗапроса,
		ДополнительныеСвойства.ТаблицыДляДвижений, Истина);

КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Проведение

Функция ТекстЗапросаТаблицаПосещаемостьСотрудников(Запрос, ТекстыЗапроса, Регистры)

	ИмяРегистра = "КРВС_ПосещаемостьСотрудников";

	Если Не ПроведениеСерверУТ.ТребуетсяТаблицаДляДвижений(ИмяРегистра, Регистры) Тогда
		Возврат "";
	КонецЕсли;
	
	ШаблонТекстЗапроса =
	"ВЫБРАТЬ
	|	ДанныеОВремени.Ссылка.Дата КАК Период,
	|	ДанныеОВремени.Ссылка КАК Регистратор,
	|	ДанныеОВремени.Сотрудник КАК Сотрудник,
	|	ДанныеОВремени.Ссылка.ПериодРегистрации КАК ПериодРегистрации,
	|	ДОБАВИТЬКДАТЕ(НАЧАЛОПЕРИОДА(ДанныеОВремени.Ссылка.ПериодРегистрации, ДЕНЬ), ДЕНЬ, 31) КАК Дата,
	|	ДанныеОВремени.Часов31 КАК Часы
	|ИЗ
	|	Документ.КРВС_ПосещаемостьСотрудников.ДанныеОВремени КАК ДанныеОВремени
	|ГДЕ
	|	ДанныеОВремени.Ссылка = &Ссылка
	|	И ДанныеОВремени.Часов31 > 0";
	
	ТекстЗапроса = "";
	
	ЗначениеДнейВТекстеЗапроса = 31;
	
	Для День = 1 По 31 Цикл   
		ИндексДня = День - 1;
		ТекстЗапросаЗаполнен = ЗначениеЗаполнено(ТекстЗапроса);               
		ФрагментТекстаЗапроса = СтрЗаменить(ШаблонТекстЗапроса, "Часов" + ЗначениеДнейВТекстеЗапроса, "Часов" + День);
		ФрагментТекстаЗапроса = СтрЗаменить(ФрагментТекстаЗапроса, ЗначениеДнейВТекстеЗапроса, ИндексДня);
		ТекстЗапроса = ТекстЗапроса + ?(ТекстЗапросаЗаполнен, " ОБЪЕДИНИТЬ ВСЕ ", "") + ФрагментТекстаЗапроса;
	КонецЦикла;

	ТекстыЗапроса.Добавить(ТекстЗапроса, ИмяРегистра);

	Возврат ТекстЗапроса;

КонецФункции

Функция ТекстЗапросаТаблицаВремяПриходаУходаСотрудников(Запрос, ТекстыЗапроса, Регистры)

	ИмяРегистра = "КРВС_ВремяПриходаУходаСотрудников";

	Если Не ПроведениеСерверУТ.ТребуетсяТаблицаДляДвижений(ИмяРегистра, Регистры) Тогда
		Возврат "";
	КонецЕсли;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	тПосещаемость.Ссылка КАК Регистратор,
	|	тПосещаемость.Ссылка.Дата КАК Период,
	|	тПосещаемость.Ссылка.Организация КАК Организация,
	|	тПосещаемость.Сотрудник КАК Сотрудник,
	|	тПосещаемость.Дата КАК Дата,
	|	МИНИМУМ(тПосещаемость.Время) КАК ВремяПрихода,
	|	МАКСИМУМ(тПосещаемость.Время) КАК ВремяУхода
	|ИЗ
	|	Документ.КРВС_ПосещаемостьСотрудников.Посещаемость КАК тПосещаемость
	|ГДЕ
	|	тПосещаемость.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	тПосещаемость.Ссылка,
	|	тПосещаемость.Ссылка.Дата,
	|	тПосещаемость.Ссылка.Организация,
	|	тПосещаемость.Сотрудник,
	|	тПосещаемость.Дата";

	ТекстыЗапроса.Добавить(ТекстЗапроса, ИмяРегистра);

	Возврат ТекстЗапроса;	

КонецФункции

#КонецОбласти

#КонецОбласти

#КонецЕсли