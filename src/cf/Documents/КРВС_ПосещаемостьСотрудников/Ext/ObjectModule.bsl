﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Заполняет табличную часть "Данные о времени" по данным из таблицы "Посещаемость".
//
Процедура ЗаполнитьТаблицуДанныхОВремениПоДаннымПосещаемости() Экспорт
		
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	Посещаемость.Сотрудник КАК Сотрудник,
	                      |	Посещаемость.День КАК День,
	                      |	Посещаемость.Время КАК Время
	                      |ПОМЕСТИТЬ ВТ_Посещаемость
	                      |ИЗ
	                      |	&Посещаемость КАК Посещаемость
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ
	                      |	ВТ_Посещаемость.Сотрудник КАК Сотрудник,
	                      |	ВТ_Посещаемость.День КАК День,
	                      |	МАКСИМУМ(ВТ_Посещаемость.Время) КАК Приход,
	                      |	МИНИМУМ(ВТ_Посещаемость.Время) КАК Уход
	                      |ПОМЕСТИТЬ ВТ_ВремяПриходаУхода
	                      |ИЗ
	                      |	ВТ_Посещаемость КАК ВТ_Посещаемость
	                      |
	                      |СГРУППИРОВАТЬ ПО
	                      |	ВТ_Посещаемость.Сотрудник,
	                      |	ВТ_Посещаемость.День
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ
	                      |	ВТ_ВремяПриходаУхода.Сотрудник КАК Сотрудник,
	                      |	ВТ_ВремяПриходаУхода.День КАК День,
	                      |	РАЗНОСТЬДАТ(ВТ_ВремяПриходаУхода.Уход, ВТ_ВремяПриходаУхода.Приход, МИНУТА) / 60 КАК Часы
	                      |ИЗ
	                      |	ВТ_ВремяПриходаУхода КАК ВТ_ВремяПриходаУхода
	                      |
	                      |УПОРЯДОЧИТЬ ПО
	                      |	ВТ_ВремяПриходаУхода.Сотрудник
	                      |ИТОГИ ПО
	                      |	Сотрудник");
	Запрос.УстановитьПараметр("Посещаемость", Посещаемость.Выгрузить()); 
	
	ВыборкаСотрудник = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаСотрудник.Следующий() Цикл
		
		СтрокаТаблицыДанныхВремени = ДанныеОВремени.Добавить();     
		СтрокаТаблицыДанныхВремени.Сотрудник = ВыборкаСотрудник.Сотрудник; 

		Выборка = ВыборкаСотрудник.Выбрать();
		Пока Выборка.Следующий() Цикл
			СтрокаТаблицыДанныхВремени["Часов" + Выборка.День] = Выборка.Часы;
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	ПроведениеСерверУТ.УстановитьРежимПроведения(ЭтотОбъект, РежимЗаписи, РежимПроведения);

	ДополнительныеСвойства.Вставить("ЭтоНовый", ЭтоНовый());
	ДополнительныеСвойства.Вставить("РежимЗаписи", РежимЗаписи);     
	
	КраткийСоставДокумента = ЗарплатаКадры.КраткийСоставСотрудников(ДанныеОВремени.ВыгрузитьКолонку("Сотрудник"), Дата);

КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	// Инициализация дополнительных свойств для проведения документа
	ПроведениеСерверУТ.ИнициализироватьДополнительныеСвойстваДляПроведения(Ссылка, ДополнительныеСвойства,
		РежимПроведения);
	
	// Инициализация данных документа
	Документы.КРВС_ПосещаемостьСотрудников.ИнициализироватьДанныеДокумента(Ссылка, ДополнительныеСвойства);
	
	// Подготовка наборов записей
	ПроведениеСерверУТ.ПодготовитьНаборыЗаписейКРегистрацииДвижений(ЭтотОбъект);

	КРВС_КонтрольРабочегоВремениСотрудников.ОтразитьПосещаемостьСотрудников(ДополнительныеСвойства, Движения, Отказ);
	КРВС_КонтрольРабочегоВремениСотрудников.ОтразитьВремяПриходаУходаСотрудников(ДополнительныеСвойства, Движения, Отказ);

	СформироватьСписокРегистровДляКонтроля();

	ПроведениеСерверУТ.ЗаписатьНаборыЗаписей(ЭтотОбъект);

	ПроведениеСерверУТ.ВыполнитьКонтрольРезультатовПроведения(ЭтотОбъект, Отказ);

	ПроведениеСерверУТ.ОчиститьДополнительныеСвойстваДляПроведения(ДополнительныеСвойства);
	ПроведениеСерверУТ.СформироватьЗаписиРегистровЗаданий(ЭтотОбъект);

КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)

	// Инициализация дополнительных свойств для удаления проведения документа
	ПроведениеСерверУТ.ИнициализироватьДополнительныеСвойстваДляПроведения(Ссылка, ДополнительныеСвойства);
	
	// Подготовка наборов записей
	ПроведениеСерверУТ.ПодготовитьНаборыЗаписейКРегистрацииДвижений(ЭтотОбъект);

	СформироватьСписокРегистровДляКонтроля();

	ПроведениеСерверУТ.ЗаписатьНаборыЗаписей(ЭтотОбъект);

	ПроведениеСерверУТ.ВыполнитьКонтрольРезультатовПроведения(ЭтотОбъект, Отказ);

	ПроведениеСерверУТ.СформироватьЗаписиРегистровЗаданий(ЭтотОбъект);

	ПроведениеСерверУТ.ОчиститьДополнительныеСвойстваДляПроведения(ДополнительныеСвойства);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура СформироватьСписокРегистровДляКонтроля()

	Массив = Новый Массив;

	ДополнительныеСвойства.ДляПроведения.Вставить("РегистрыДляКонтроля", Массив);

КонецПроцедуры

#КонецОбласти

#КонецЕсли