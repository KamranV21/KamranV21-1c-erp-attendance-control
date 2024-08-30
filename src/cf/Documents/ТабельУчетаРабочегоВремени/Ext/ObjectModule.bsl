﻿
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	  
#Область ОбработчикиСобытий
	  
&После("ОбработкаПроверкиЗаполнения")
Процедура КРВС_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	КРВС_ПроверитьЗаполнениеЧасовОтсутствийПоСотрудникам(Отказ);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура КРВС_ПроверитьЗаполнениеЧасовОтсутствийПоСотрудникам(Отказ)
		
	ДопустимыеЧасыБезОбоснований = КРВС_КонтрольРабочегоВремениСотрудников.ДопустимыеЧасыОтсутствийБезОбоснований(Организация, ДатаНачалаПериода, ДатаОкончанияПериода);	
	
	Для Каждого СтрокаДанныхВремени Из ДанныеОВремени Цикл 
		Если СтрокаДанныхВремени.КРВС_НеобоснованныеЧасы > ДопустимыеЧасыБезОбоснований Тогда
			ТекстСообщения = НСтр("ru = 'Количество необоснованных часов опозданий превышает допустимый предел.'; en = 'The number of unjustified hours of absence exceeds the permissible limit.'; az = 'Əsassız yoxluq saatlarının sayı icazə verilən limiti aşır.'");
			Поле = ОбщегоНазначенияКлиентСервер.ПутьКТабличнойЧасти("Объект.ДанныеОВремени", СтрокаДанныхВремени.НомерСтроки, "КРВС_НеобоснованныеЧасы");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,, Поле,, Отказ);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#КонецЕсли