
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

-- 2. продажа товара

-- 2.1 состав кассового журнала по видам событий: что несет продажи, оплаты, итоги
select j.transtype, t.description, count(*) as records, sum(j.amount) as amount,
       min(j.dater) as first_date, max(j.dater) as last_date
from journal j
left join transtype t on t.transtypeid = j.transtype
group by j.transtype, t.description
order by records desc;
-- вывод: 8 видов записей, всего 225 681 строка. продажи - 101 "PLU Sales" (119 367, 42 306 984,17),
-- итог чека - 501 (45 014, 42 869 802,22), наличные - 211 (42 756, 42 275 294,67).
-- служебные: 386 начало работы (5774), 387 конец (5758), 301 вход (4316),
-- 111 списание по себестоимости (2676, 570 935,05), 216 Visa (20, 23 921).
-- продажи и оплаты идут с 11.11.2020 по 06.12.2023, смены (386/387) с 01.12.2020.
-- у 301 первая запись 01.01.2012 - служебная/тестовая, к периоду продаж не относится.

-- 2.2 сходится ли итог чека (501) с суммой его позиций (101)
select count(*) as receipts,
       sum(case when abs(items - total) < 0.01 then 1 else 0 end) as equal_receipts,
       sum(case when abs(items - total) >= 0.01 then 1 else 0 end) as different_receipts
from (
    select receiptn,
           sum(case when transtype = 101 then amount end) as items,
           sum(case when transtype = 501 then amount end) as total
    from journal
    where transtype in (101, 501)
    group by receiptn
) r
where items is not null and total is not null;
-- вывод: из 43 035 чеков, где есть и позиции и итог, у 43 024 итог равен сумме позиций,
-- у 11 расходится (0,03%, похоже скидки/округление). чек можно считать и по позициям, и по итогу.
-- итогов 501 всего 45 014, то есть у ~2 тыс чеков итог есть, а позиций 101 нет -
-- поэтому общая сумма 501 чуть больше суммы 101.

-- 2.3 к каким видам записей журнала привязан состав блюд (bm_Journal_Details),
-- заодно смотрим только ли продажи имеют состав
select j.transtype, count(*) as detail_rows, count(distinct d.SourceID) as journal_rows
from bm_Journal_Details d
join journal j on j.transnumber = d.SourceID
group by j.transtype;
-- вывод: все 1 089 641 строка состава нашлись в журнале по SourceID. из них 1 061 948 (97%)
-- к продажам 101, 17 551 к списаниям 111, 10 142 к итогам 501 - состав привязан не только к проданным позициям.
-- при этом состав есть не у всех продаж: 103 884 уникальные позиции из 119 367
-- (остальные, видимо, товары без рецепта); у итогов 411, у списаний 2616.

-- 2.4 продажи по месяцам: чеки, позиции, сумма
select format(dater, 'yyyy-MM') as month,
       count(distinct receiptn) as receipts, count(*) as positions, sum(amount) as amount
from journal
where transtype = 101
group by format(dater, 'yyyy-MM')
order by month;
-- вывод: 38 месяцев (2020-11 - 2023-12), обычно 900-1700 чеков и 0,9-1,5 млн в месяц.
-- пики: декабрь 2022 (1619 чеков, 1 717 192,50) и январь 2021 (1737 чеков, 1 527 536,75);
-- минимум август 2022 (884 чека, 939 973,75) - летний спад.
-- первый (2020-11) и последний (2023-12) месяцы неполные.

-- 2.5 каждый ли документ "Товарный чек" (тип 6) имеет свой чек в кассовом журнале,
-- связь без FK: bm_JournalBarnetDocs.TicketNumber = journal.receiptn (запись 501)
select count(*) as documents_type6,
       sum(case when j.receiptn is not null then 1 else 0 end) as found_in_journal
from bm_JournalBarnetDocs d
left join (select distinct receiptn from journal where transtype = 501) j
    on j.receiptn = d.TicketNumber
where d.DocumentTypeID = 6;
-- вывод: все 43 586 документов типа 6 нашлись в журнале по номеру чека,
-- связь подтверждена полностью, хотя внешнего ключа нет.

-- 2.6 связи журнала со справочниками оплат и клиентов (обе без FK)
select 'paymenttype' as link, count(*) as rows_checked,
       sum(case when p.paymenttypeid is null then 1 else 0 end) as not_found
from journal j
left join paymenttype p on p.paymenttypeid = j.transtype
where j.transtype in (211, 216)
union all
select 'clients', count(*), sum(case when c.id is null then 1 else 0 end)
from journal j
left join clients c on c.clientid = j.customerid
where j.transtype = 101 and j.customerid <> '';
-- вывод: все 42 776 оплат (211 и 216) нашли вид оплаты (not_found 0); из 35 632 позиций
-- с клиентом у 5 клиент не найден (99,99% совпадений). обе связи рабочие.

-- 2.7 связь журнала с номенклатурой по коду товара (без FK): journal.id = product.productid
select count(*) as sales_rows,
       sum(case when p.id is null then 1 else 0 end) as not_found
from journal j
left join product p on p.productid = j.id
where j.transtype = 101 and j.id <> '';
-- вывод: все 119 367 проданных позиций находят товар в product по коду (not_found 0),
-- связь journal.id = product.productid подтверждена полностью, внешнего ключа нет
