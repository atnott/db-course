-- единицы измерения
select 'insert into dim_ranges (external_id, name, factor, base_external_id, base_name) values ('
    + cast(s.id as varchar(20)) + ', '''
    + replace(isnull(s.sizeid, ''), '''', '''''') + ''', '
    + isnull(cast(cast(s.portionrate as decimal(18,4)) as varchar(40)), 'null') + ', '
    + isnull(cast(s.BaseSizeID as varchar(20)), 'null') + ', '
    + isnull('''' + replace(c.ShortName, '''', '''''') + '''', 'null') + ');' as [sql]
from size s
left join bm_classifierSizes c on c.ID = s.BaseSizeID
order by s.id;

-- категории товаров
select 'insert into dim_categories (external_id, name, parent_id) values ('
    + cast(c.id as varchar(20)) + ', '''
    + replace(isnull(c.description, ''), '''', '''''') + ''', '
    + isnull(cast(nullif(c.ParentID, 0) as varchar(20)), 'null') + ');' as [sql]
from category c
order by c.id;

-- товары
select 'insert into dim_products (external_id, code, name) values ('
    + cast(p.id as varchar(20)) + ', '
    + isnull('''' + replace(p.productid, '''', '''''') + '''', 'null') + ', '''
    + replace(isnull(p.description, ''), '''', '''''') + ''');' as [sql]
from product p
order by p.id;

-- поставщики
select 'insert into dim_vendors (external_id, name, group_external_id, group_name) values ('
    + cast(v.id as varchar(20)) + ', '''
    + replace(isnull(v.clientid, ''), '''', '''''') + ''', '
    + isnull(cast(v.clientgroup as varchar(20)), 'null') + ', '
    + isnull('''' + replace(g.description, '''', '''''') + '''', 'null') + ');' as [sql]
from vendors v
left join vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.id;

-- виды оплаты
select 'insert into dim_payment_types (external_id, name) values ('
    + cast(pt.paymenttypeid as varchar(20)) + ', '''
    + replace(isnull(pt.description, ''), '''', '''''') + ''');' as [sql]
from paymenttype pt
order by pt.paymenttypeid;

-- сотрудники
select 'insert into dim_employees (external_id, name) values ('
    + cast(p.personid as varchar(20)) + ', '''
    + replace(ltrim(rtrim(isnull(p.lastname, '') + ' ' + isnull(p.firstname, ''))), '''', '''''') + ''');' as [sql]
from personnel p
order by p.personid;

-- склады
select 'insert into dim_storages (external_id, name) values ('
    + cast(s.id as varchar(20)) + ', '''
    + replace(isnull(s.description, ''), '''', '''''') + ''');' as [sql]
from storages s
order by s.id;

-- причины списания
select 'insert into dim_reasons (external_id, name, parent_id) values ('
    + cast(r.ID as varchar(20)) + ', '''
    + replace(isnull(r.Description, ''), '''', '''''') + ''', '
    + isnull(cast(nullif(r.ParentID, 0) as varchar(20)), 'null') + ');' as [sql]
from bm_ReasonDebit r
order by r.ID;
