--20160701
CREATE TABLE EMP_TEMP AS SELECT * FROM EMP;
CREATE INDEX IDX_MGR_TEMP ON EMP_TEMP(MGR);
CREATE INDEX IDX_DEPTNO_TEMP ON EMP_TEMP(DEPTNO);
--CBO ���ڳɱ���RBO ���ڹ���
alter session set optimizer_mode = 'RULE';
set autotrace traceonly explain;
select * from emp_temp where mgr>100 and deptno>100;--��deptno������
select * from emp_temp where mgr>100 and deptno+0>100;--��д�ȼ�Ŀ��sql����0���߿մ���
--�Ƚ�����mgr��deptno���������ֵ仺���еĻ���˳�����Ȼ���idx_mgr�󻺴�idx_deptno��
drop index IDX_MGR_TEMP;
drop index IDX_DEPTNO_TEMP;

--��AutoTrace��Ȩ�޷����������ͨ�û�,ע��ֻ��SQL*PLUS����Ч����
--@/u/oracle/product/11.2/rdbms/admin/utlxplan.sql
START D:/app/Administrator/product/11.2.0/dbhome_1/RDBMS/ADMIN/utlxplan.sql
create public synonym plan_table for plan_table;
grant all on plan_table to public;
--@/u/oracle/product/11.2/sqlplus/admin/plustrce.sql
START D:/app/Administrator/product/11.2.0/dbhome_1/sqlplus/admin/plustrce.sql

grant plustrace to public;
set autotrace off
set autotrace on explain--ֻ��ʾ�Ż���ִ��·������
set autotrace on statistics--ֻ��ʾִ��ͳ����Ϣ
set autotrace on --��ʾִ�мƻ���ͳ����Ϣ
set autotrace traceonly --ͬ SET AUTOTRACE ON һ����������ʾ��ѯ���

--20160708
--������Ծʽɨ��
create table employee(gender varchar2(1), employee_id number);
alter table employee modify(employee_id not null);
create index idx_employee(gender,employee_id);
--Ŀ������ǰ���е�distinctֵ�������٣�������ǰ���еĿ�ѡ�����ַǳ��õ����Ρ�

--������
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
   and t1.col1(+) = 1; --����������֮ǰӦ���ڱ�T1 ����
   
   and t1.col1 = 1; --����������֮��Ӧ���ڽ������t1.col1 ����
   
--20160711
--�鿴�Ż�����ģʽ
select name,value from v$parameter where name = 'optimizer_mode';
column empno format a15/999999
set linesize 100
set pagesize 200
--�鿴ִ�мƻ�
explain plan for + sql_txt
select * from table(dbms_xplan.display)
select * from table(dbms_xplan.display_cursor(null,null,'advanced'))/'all'
       select sql_text,sql_id,hash_value,child_number from v$sql where sql_text like 'select empno%';

--�ֹ��ɼ�һ��AWR����
exec dbms_workload_repository.create_snapshot();
alter system flush shared_pool;//��������������ִ�д���䡣���Shared Pool

select * from table(dbms_xplan.display_awr('sql_id'));
       select sql_text, sql_id, version_count, executions from v$sqlarea where sql_text like 'select empno%';
sqlplus��
set autot on
set autot off
set autot trace
set autot trace exp
set autot trace stat

--20160712 
--����--ִ��sql--�ر�
--����10046�¼�
alter session set events '10046 trace name context forever,level 12'
oradebug event 10046 trace name context forever,level 12
--�ر�10046�¼�
alter session set events '10046 trace name context off'
oradebug event 10046 trace name context off
--׼���Ե�ǰSessionʹ��oradebug����
oradebug setmypid
--�鿴trace�ļ�·��������
oradebug tracefile_name
--tkprof������trace�ļ�
c:/>tkprof ·�� ������ļ�·��
--������ http://www.dbsnake.net/books
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