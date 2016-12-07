--20160701
CREATE TABLE EMP_TEMP AS SELECT * FROM EMP;
CREATE INDEX IDX_MGR_TEMP ON EMP_TEMP(MGR);
CREATE INDEX IDX_DEPTNO_TEMP ON EMP_TEMP(DEPTNO);
--CBO 基于成本，RBO 基于规则
alter session set optimizer_mode = 'RULE';
set autotrace traceonly explain;
select * from emp_temp where mgr>100 and deptno>100;--走deptno的索引
select * from emp_temp where mgr>100 and deptno+0>100;--改写等价目标sql（加0或者空串）
--先建索引mgr后建deptno，在数据字典缓存中的缓存顺序是先缓存idx_mgr后缓存idx_deptno。
drop index IDX_MGR_TEMP;
drop index IDX_DEPTNO_TEMP;

--将AutoTrace的权限分配给其他普通用户,注意只在SQL*PLUS中有效！！
--@/u/oracle/product/11.2/rdbms/admin/utlxplan.sql
START D:/app/Administrator/product/11.2.0/dbhome_1/RDBMS/ADMIN/utlxplan.sql
create public synonym plan_table for plan_table;
grant all on plan_table to public;
--@/u/oracle/product/11.2/sqlplus/admin/plustrce.sql
START D:/app/Administrator/product/11.2.0/dbhome_1/sqlplus/admin/plustrce.sql

grant plustrace to public;
set autotrace off
set autotrace on explain--只显示优化器执行路径报告
set autotrace on statistics--只显示执行统计信息
set autotrace on --显示执行计划和统计信息
set autotrace traceonly --同 SET AUTOTRACE ON 一样，但不显示查询输出

--20160708
--索引跳跃式扫描
create table employee(gender varchar2(1), employee_id number);
alter table employee modify(employee_id not null);
create index idx_employee(gender,employee_id);
--目标索引前导列的distinct值数量较少，后续非前导列的可选择性又非常好的情形。

--表连接
create table t1(col1 number,col2 varchar2(1));
create table t2(col2 varchar2(1),col3 varchar2(2));

insert into t1 values(1,'A');
insert into t1 values(2,'B');
insert into t1 values(3,'C');
insert into t2 values('A','A2');
insert into t2 values('B','B2');
insert into t2 values('D','D2');

select t1.col1, t1.col2, t2.col3
  from t1, t2
 where t1.col2(+) = t2.col2
   and t1.col1(+) = 1; --在做外连接之前应用于表T1 列上
   
   and t1.col1 = 1; --在做外连接之后应用于结果集的t1.col1 列上
   
--20160711
--查看优化器的模式
select name,value from v$parameter where name = 'optimizer_mode';
column empno format a15/999999
set linesize 100
set pagesize 200
--查看执行计划
explain plan for + sql_txt
select * from table(dbms_xplan.display)
select * from table(dbms_xplan.display_cursor(null,null,'advanced'))/'all'
       select sql_text,sql_id,hash_value,child_number from v$sql where sql_text like 'select empno%';

--手工采集一下AWR报告
exec dbms_workload_repository.create_snapshot();
alter system flush shared_pool;//请勿在生产环境执行此语句。清空Shared Pool

select * from table(dbms_xplan.display_awr('sql_id'));
       select sql_text, sql_id, version_count, executions from v$sqlarea where sql_text like 'select empno%';
sqlplus中
set autot on
set autot off
set autot trace
set autot trace exp
set autot trace stat

--20160712 
--开启--执行sql--关闭
--开启10046事件
alter session set events '10046 trace name context forever,level 12'
oradebug event 10046 trace name context forever,level 12
--关闭10046事件
alter session set events '10046 trace name context off'
oradebug event 10046 trace name context off
--准备对当前Session使用oradebug命令
oradebug setmypid
--查看trace文件路径和名称
oradebug tracefile_name
--tkprof翻译裸trace文件
c:/>tkprof 路径 翻译后文件路径
--几个包 http://www.dbsnake.net/books
xplan.sql

--20160719
create table customer
(
customer# number,
marital_status varchar2(10),
region varchar2(10),
gender varchar2(10),
income_level varchar2(10)
);
insert into customer values(101,'single','east','male','bracket_1');
insert into customer values(102,'married','central','female','bracket_4');
insert into customer values(103,'married','west','female','bracket_2');
insert into customer values(104,'divorced','west','male','bracket_4');
insert into customer values(105,'single','central','female','bracket_2');
insert into customer values(106,'married','central','female','bracket_3');
create bitmap index idx_b_region on customer(region);
create bitmap index idx_b_maritalstatus on customer(marital_status);
exec dbms_stats.gather_table_stats(ownname => 'SCOTT',tabname => 'CUSTOMER',estimate_percent => 100,cascade => true);
select count(*) from customer where marital_status = 'married' and region in ('central','west');
select /*+ index(customer IDX_B_REGION) */ customer# from customer where region = 'east';