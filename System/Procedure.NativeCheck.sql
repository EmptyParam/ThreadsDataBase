set nocount on
set quoted_identifier, ansi_nulls, ansi_warnings, arithabort,
    concat_null_yields_null, ansi_padding on
set numeric_roundabort off
set transaction isolation level read uncommitted
set xact_abort on
go

-------------------------------------------------------------
-- <PROC> dbo.[Procedure.NativeCheck]
-------------------------------------------------------------
alter procedure dbo.[Procedure.NativeCheck]
   @procname    sysname
as
begin
-------------------------------------------------------------
-- v1.0: Created by Cova Igor 20.12.2015
-------------------------------------------------------------
  set nocount on
  set quoted_identifier, ansi_nulls, ansi_warnings, arithabort,
      concat_null_yields_null, ansi_padding on
  set numeric_roundabort off
  set transaction isolation level read uncommitted
  set xact_abort on
  -----------------------------------------------------------------
  declare 
     @res      int            -- ��� Return-����� ���������� ��������.
    ,@ret      int            -- ��� �������� Return-���� ������ ���������.
    ,@err      int            -- ��� �������� @@error-���� ����� ������� ��������.
    ,@cnt      int            -- ��� �������� ��������� �������������� �������.
    ,@ErrMsg   varchar(1000)  -- ��� ������������ ��������� �� �������

  ------------------------------------
  --|| � ����� ������ ����������� � ���������� Extended Properties �������
  exec dbo.GetBlankExtendedProperty
    @ObjSysName  = @procname
  
  ------------------------------------
  --|| � ����� ������ ������ ��� ���������� sql-������� � �������� ������������
 -- exec dbo.GetBlankUserActionSqlObject  
  --  @ObjSysName = @procname

    -----------------------------------------------------------------
  -- End Point
  select @ret = 0
  return (@ret)
end

-- exec db.object_SetSystem N'dbo.[Procedure.NativeCheck]', 1
go
----------------------------------------------
 -- <���������� Extended Property �������>
----------------------------------------------
/*exec dbo.FillExtendedProperty
   @ObjSysName  = 'dbo.[Procedure.NativeCheck]'
  ,@Author      = 'Cova Igor'
  ,@Description = '�������� ������� ���������'
  ,@Params = '
     @procname = �������� ��������� \n
    ,@wrapname = �������� �������� ��������� \n'
go*/
-------------------------------------------------------------
-- <WRAPPER>
-------------------------------------------------------------
--exec dbo.[Procedure.NativeCheck] @procname=N'dbo.[Procedure.NativeCheck]', @debug_info = 0x02
--exec sp_addmessage 55555, 13, '%s' -- ������� ��������� �� ������ � ������� 55555, ����� ����������� ���������������� ��������� �� ����� ������

go

/* �������:
declare @ret int, @err int, @runtime datetime, @procname sysname

select @procname = '[dbo].[HrSalesman.Create]' -- 'ui.[MenuItem.Create]'

select @runtime = getdate()
exec @ret = dbo.[Procedure.NativeCheck]
   @procname = @procname
  ,@debug_info = 0x02

select @err = @@error

select @ret as [RETURN], @err as [ERROR], convert(varchar(20), getdate()-@runtime, 114) as [RUN_TIME]
--*/
go
