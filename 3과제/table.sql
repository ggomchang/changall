use dev;

create table employees(
emp_no int not null,
birth_date date not null,
first_name varchar(14) not null,
last_name varchar(16) not null,
gender enum('M','F') not null,
hire_date date not null,
primary key (emp_no)
);

create index name_index on employees(first_name,last_name);