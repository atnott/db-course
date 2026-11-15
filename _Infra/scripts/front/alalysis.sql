
-- 1. закупка продукции

-- 1.1 смотрим какие вообще типы документов есть и какой из них означает закупку
select dt.ID as type_id, dt.Description as document_type,
       count(*) as documents, sum(d.Amount) as amount,
       min(d.Period) as first_date, max(d.Period) as last_date
from bm_JournalBarnetDocs d
join bm_JournalTypeDocuments dt on dt.ID = d.DocumentTypeID
group by dt.ID, dt.Description
order by documents desc;
-- вывод: всего 7 типов документов. закупка - тип 4 "Поступление продуктов":
-- 3175 документов на 19 657 112,54, период 26.10.2020-02.12.2023.
-- самый массовый тип 6 "Товарный чек" (43 586 док, 42 952 911,92) - это продажи, не закупка.
-- тип 5 "Списание продуктов" (3654 док, 821 196,25) ведется с 2014 года.
-- у типов 1, 2, 3 (рецепты и установка цен) и 8 (инвентаризация, всего 1 док) сумма 0,
-- денежных движений они не несут и для анализа закупок не подходят.

-- 1.2 в каких типах документов встречается операция поступления (OperationID = 1),
-- чтобы понять можно ли отбирать закупки только по операции
select d.DocumentTypeID, count(*) as storage_rows, sum(o.Amount) as amount
from bm_StorageOperations o
join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1
group by d.DocumentTypeID;
-- вывод: операция 1 есть только в двух типах: 4 (11 358 строк, 19 657 112,54)
-- и 6 (10 658 строк, 361 577,74). отбирать закупки только по OperationID = 1 нельзя,
-- нужен еще и тип документа 4.

-- 1.3 сверяем суммы шапок закупки с суммами их складских строк
select
    (select sum(Amount) from bm_JournalBarnetDocs where DocumentTypeID = 4) as documents_amount,
    (select sum(o.Amount)
     from bm_StorageOperations o
     join bm_JournalBarnetDocs d on d.ID = o.DocumentID
     where d.DocumentTypeID = 4) as storage_rows_amount;
-- вывод: обе суммы совпали до копейки - 19 657 112,54. связь шапка-строки по DocumentID
-- работает, сумму закупки можно брать из любой из двух таблиц.

-- 1.4 закупки по месяцам: сколько документов и на какую сумму
select format(d.Period, 'yyyy-MM') as month,
       count(*) as documents, sum(d.Amount) as amount
from bm_JournalBarnetDocs d
where d.DocumentTypeID = 4
group by format(d.Period, 'yyyy-MM')
order by month;
-- вывод: 39 месяцев (2020-10 - 2023-12). первый месяц неполный: 2 документа на 11 426.
-- дальше обычно 50-156 документов и 310-730 тыс в месяц.
-- резкий выброс март 2021: 131 документ на 3 030 946,76, в 5-6 раз выше соседних месяцев.
-- максимум по числу документов - апрель 2021 (156).

-- 1.5 есть ли поставщик в строках поступления: закупка (тип 4) против товарного чека (тип 6)
select d.DocumentTypeID, count(*) as storage_rows,
       sum(case when o.VendorID = 0 then 1 else 0 end) as rows_without_vendor,
       count(distinct o.VendorID) as distinct_vendors,
       sum(o.Amount) as amount
from bm_StorageOperations o
join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1
group by d.DocumentTypeID;
-- вывод: в закупках (тип 4) у всех 11 358 строк заполнен поставщик, уникальных 21.
-- в чеках (тип 6) у всех 10 658 строк VendorID = 0 (distinct_vendors = 1 - это и есть ноль),
-- сумма 361 577,74. поступление в чеке внутреннее, без поставщика, закупкой не считается.
