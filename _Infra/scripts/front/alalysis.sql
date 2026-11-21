
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

-- 3. взаимоотношения с поставщиками

-- 3.1 поставщики по группам, проверка FK vendors.clientgroup -> vendorgroup
select g.vendorgroupid, g.description as vendor_group,
       count(*) as vendors, sum(v.IsUse) as active
from vendors v
join vendorgroup g on g.vendorgroupid = v.clientgroup
group by g.vendorgroupid, g.description;
-- вывод: 63 поставщика в двух группах: 31 "Поставщики" (59, активных 17)
-- и 32 "Без названия" (4, активных 3). внешний ключ работает.

-- 3.2 все ли VendorID в строках закупок указывают на существующего поставщика (без FK)
select count(*) as purchase_rows,
       sum(case when v.id is null then 1 else 0 end) as rows_without_vendor,
       count(distinct o.VendorID) as vendors_used
from bm_StorageOperations o
left join vendors v on v.id = o.VendorID
join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1 and d.DocumentTypeID = 4;
-- вывод: все 11 358 строк закупок имеют поставщика из vendors (потерь 0),
-- задействован 21 из 63. связь bm_StorageOperations.VendorID = vendors.id подтверждена.

-- 3.3 закупки по месяцам в разрезе поставщиков: сколько поставщиков, документов, сумма
select format(o.DateAdd, 'yyyy-MM') as month,
       count(distinct o.VendorID) as vendors,
       count(distinct o.DocumentID) as documents,
       sum(o.Amount) as amount
from bm_StorageOperations o
join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1 and d.DocumentTypeID = 4
group by format(o.DateAdd, 'yyyy-MM')
order by month;
-- вывод: 38 месяцев (2020-11 - 2023-12), обычно 11-16 поставщиков и 45-145 документов
-- на 280-790 тыс в месяц, выброс март 2021 (128 док, 3 022 371,81).
-- месяцев на один меньше, чем в 1.4: октябрь 2020 тут пропал, потому что месяц берется
-- по дате складской строки (DateAdd), а у тех документов она ноябрьская. последний месяц неполный.

-- 3.4 крупнейшие поставщики за весь период: насколько сконцентрированы закупки
select top 10 v.clientid as vendor,
       count(distinct o.DocumentID) as documents, sum(o.Amount) as amount,
       min(o.DateAdd) as first_date, max(o.DateAdd) as last_date
from bm_StorageOperations o
join vendors v on v.id = o.VendorID
join bm_JournalBarnetDocs d on d.ID = o.DocumentID
where o.OperationID = 1 and d.DocumentTypeID = 4
group by v.clientid
order by amount desc;
-- вывод: концентрация высокая: "Пятая Армия" 9 836 650,03 (50% всех закупок),
-- топ-10 вместе 18 582 408,56 (~94,5%). число документов с суммой не связано:
-- у "Покупка в розницу" больше всего доков (537), но сумма всего 515 тыс.
-- группировка по названию (clientid) склеивает дубли, см. 3.6.

-- 3.5 заполненность альтернативных каналов связи с поставщиком:
-- договоры, прайсы, карточка товара, ContractID в поступлениях
select
    (select count(*) from bm_Contracts) as contracts,
    (select count(*) from pricelist where vendorid <> 0) as pricelist_rows_with_vendor,
    (select count(*) from product where vendorid <> 0) as products_with_vendor,
    (select count(*) from bm_StorageOperations where OperationID = 1 and ContractID <> 0) as income_rows_with_contract;
-- вывод: bm_Contracts пустая (0), pricelist.vendorid не заполнен (0),
-- поставщик в карточке товара только у одного (1), ContractID в поступлениях не используется (0).
-- единственный рабочий канал связи с поставщиком - VendorID складских строк.

-- 3.6 дубли поставщиков: одно название под разными записями
select clientid, count(*) as records,
       min(clientgroup) as min_group, max(clientgroup) as max_group
from vendors
group by clientid
having count(*) > 1
order by records desc;
-- вывод: дубли есть: "Габур" (2 записи, группы 31 и 32), "Столярская" (2 записи в группе 31).
-- при группировке по названию (как в 3.4) они складываются, по id остались бы разными поставщиками.

-- 4. работа персонала

-- 4.1 сотрудники по ролям и признаку удаления: можно ли доверять этим полям
select s.description as role, p.deleteflag, count(*) as employees
from personnel p
left join securityaccess s on s.securityaccessid = p.securityaccess
group by s.description, p.deleteflag
order by employees desc;
-- вывод: все 109 сотрудников с deleteflag = 1, активных по нему не отличить.
-- у 102 роль не нашлась в securityaccess (NULL), у 5 "Special Access", у 2 "Manager/Adm".

-- 4.2 все ли loginid в продажах указывают на сотрудника (без FK)
select count(*) as sales_rows,
       sum(case when p.personid is null then 1 else 0 end) as rows_without_employee
from journal j
left join personnel p on p.personid = try_cast(j.loginid as int)
where j.transtype = 101;
-- вывод: все 119 367 проданных позиций имеют loginid из personnel (потерь 0), связь подтверждена.

-- 4.3 выручка по сотрудникам: кто фактически оформляет продажи
select j.loginid as employee_id,
       count(distinct j.receiptn) as receipts, sum(j.amount) as amount
from journal j
where j.transtype = 101
group by j.loginid
order by amount desc;
-- вывод: вся выручка на одном сотруднике 906 ("Доставка"): 43 043 чека на 42 306 984,17.
-- продажи идут под общей учетной записью, сравнивать кассиров по выручке нельзя.

-- 4.4 смены по событиям начала (386) и окончания (387) работы: кто и сколько работал
select j.loginid as employee_id,
       sum(case when j.transtype = 386 then 1 else 0 end) as work_started,
       sum(case when j.transtype = 387 then 1 else 0 end) as work_finished,
       min(j.dater) as first_date, max(j.dater) as last_date
from journal j
where j.transtype in (386, 387)
group by j.loginid
order by work_started desc;
-- вывод: смены ведут 35 сотрудников, от 1 до 707 смен (больше всех у 1029: 707 начал / 708 окончаний).
-- начала и окончания почти совпадают, у части сотрудников окончаний даже больше (1044: 338/345,
-- 1060: 175/181). по первой/последней дате видна текучесть: 1029/1020/1047 работают с 12.2020 по 12.2023,
-- а 1044 закончил в 06.2022, 1046 в 10.2021.

-- 4.5 все ли документы привязаны к сотруднику через PersonID (без FK)
select count(*) as documents,
       sum(case when p.personid is null then 1 else 0 end) as documents_without_employee
from bm_JournalBarnetDocs d
left join personnel p on p.personid = d.PersonID;
-- вывод: из 55 149 документов у 55 148 PersonID найден в personnel, один без сотрудника.
-- связь подтверждена почти полностью.

-- 4.6 права доступа: сколько прав у сотрудника, FK на bm_SecurityObjects и связь с personnel
select p.personid, p.firstname, count(*) as rights
from bm_PersonnelSecurity ps
join bm_SecurityObjects o on o.ID = ps.ObjectID
join personnel p on p.personid = ps.PersonID
where ps.IsUse = 1
group by p.personid, p.firstname
order by rights desc;
-- вывод: права у 48 сотрудников, у большинства по 16, у администратора Barnet (897) 24,
-- у 1022 - 22, у нескольких 17 (в т.ч. 906 "Доставка"). обе связи (FK на объекты и без FK
-- на personnel) работают

-- 5. остатки

-- 5.1 заполненность таблиц с готовыми остатками: можно ли на них опираться
select 'stock' as table_name, count(*) as row_count, cast(null as datetime) as last_date from stock
union all select 'onhand', count(*), null from onhand
union all select 'closingcount', count(*), null from closingcount
union all select 'storagesonhand', count(*), null from storagesonhand
union all select 'stockperiod', count(*), max(datefinish) from stockperiod;
-- вывод: stock, onhand, closingcount, storagesonhand пустые (0 строк);
-- stockperiod - 56 строк, последняя от 18.02.2015. готовые остатки непригодны, считаем по движениям склада.

-- 5.2 виды складских операций и в какой колонке лежит реальное количество
select t.ID, t.Description, t.Factor, count(*) as rows_count,
       sum(o.Quantity) as sum_quantity, sum(o.[Count]) as sum_count, sum(o.Amount) as amount
from bm_StorageOperations o
join bm_StorageOperationsType t on t.ID = o.OperationID
group by t.ID, t.Description, t.Factor
order by t.ID;
-- вывод: в данных только два вида операций: поступление (22 016 строк, Count +130 625,83, сумма 20 018 690,28)
-- и списание (1 009 182 строки, Count -728 963,85, сумма -86 096 814,10).
-- Quantity везде 0, реальное количество в Count, уже со знаком.

-- 5.3 остаток по движениям: сумма Count по товару, топ-20 по приходу
select top 20 p.description as product,
       sum(case when o.OperationID = 1 then o.[Count] else 0 end) as income,
       sum(case when o.OperationID = 2 then o.[Count] else 0 end) as writeoff,
       sum(o.[Count]) as balance
from bm_StorageOperations o
join product p on p.id = o.ProductID
group by p.description
order by income desc;
-- вывод: у большинства товаров списано больше, чем поступило, остаток отрицательный:
-- мука в/с приход 15 044,61 / списание -78 027,15 / остаток -62 982,54;
-- сыр голландский -55 359,44; мука итальянская -55 251,30; сок 1,0 -52 483,97.
-- у штучных товаров остаток положительный (булочка для гамбургера +876, яйцо перепелиное +406,
-- лепешка мексиканская +1398, лосось +503,73). минус по основным продуктам значит,
-- что приходы внесены не полностью и без инвентаризации реальный остаток не восстановить.

-- 5.4 заполнена ли колонка Rest (остаток после операции)
select count(*) as rows_count,
       sum(case when Rest <> 0 then 1 else 0 end) as rows_with_rest
from bm_StorageOperations;
-- вывод: Rest = 0 во всех 1 031 198 строках (rows_with_rest = 0), готового остатка в движениях нет.

-- 5.5 понедельная динамика движений склада, последние 15 недель
select top 15 w.week_start,
       sum(case when w.OperationID = 1 then 1 else 0 end) as incomes,
       sum(case when w.OperationID = 2 then 1 else 0 end) as writeoffs
from (
    select cast(dateadd(day, datediff(day, 0, DateAdd) / 7 * 7, 0) as date) as week_start, OperationID
    from bm_StorageOperations
) w
group by w.week_start
order by w.week_start desc;
-- вывод: последние 15 недель (28.08.2023 - 04.12.2023), приходов 34-196, списаний 4161-8194 в неделю.
-- всплеск списаний в неделе с 16.10 (8194). последняя неделя (с 04.12.2023) неполная: 6 приходов / 1700 списаний.

-- 5.6 причины списаний: связь ReasonID со справочником bm_ReasonDebit (без FK)
select top 10 o.ReasonID, r.Description as reason, count(*) as rows_count, sum(o.Amount) as amount
from bm_StorageOperations o
left join bm_ReasonDebit r on r.ID = o.ReasonID
where o.OperationID = 2
group by o.ReasonID, r.Description
order by rows_count desc;
-- вывод: у 978 381 из 1 009 182 списаний (97%) ReasonID = 0, причины нет (сумма -83 366 403,22 из -86 096 814,10) -
-- это автосписание по составу проданных блюд. среди остальных часть ID найдена в справочнике
-- (122 Лукьянов В.В., 138 КУРЬЕР, 164 Попова Галина, 198 Бяченко Тоня, 16 Запорожская Е.В. - похоже ФИО сотрудников),
-- часть нет (25, 179, 24, 18), причем у 25 и 24 сумма 0. связь частичная, причинам полностью доверять нельзя.
