set nocount on
set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
set numeric_roundabort off
set transaction isolation level read uncommitted
set xact_abort on
go

----------------------------------------------
-- <PROC> [dbo].[GetBlankExtendedProperty]
----------------------------------------------

/*
///<description>
///��������� ��������� ������ ��� ������ ��������� 
 dbo.FillExtendedProperty � ������������ �����������
///</description>
*/
alter procedure [dbo].[GetBlankExtendedProperty]
   @ObjSysName     sysname

  ,@debug_info     int          = 0
as
begin
------------------------------------------------
-- v1.0: Created by Cova Igor 20.12.2015
------------------------------------------------
  set nocount on
  set quoted_identifier, ansi_nulls, ansi_warnings, arithabort,
      concat_null_yields_null, ansi_padding on
  set numeric_roundabort off
  set transaction isolation level read uncommitted
  set xact_abort on
  set ansi_padding on
  ------------------------------------
  -----------------------------------------------------------------
  declare
     @res     int      -- ��� Return-����� ���������� ��������.
    ,@ret     int      -- ��� �������� Return-���� ������ ���������.
    ,@err     int      -- ��� �������� @@error-���� ����� ������� ��������.
    ,@cnt     int      -- ��� �������� ��������� �������������� �������.
    ,@ErrMsg  varchar(1000) -- ��� ������������ ��������� �� �������  
    
    ,@El           varchar(2) = char(13) + char(10)
    ,@Params       varchar(max) 
    ,@Blank        varchar(max)
  --------------------------------------     
  if exists( select 
                  p.name
               from sys.objects as s
               inner join sys.extended_properties as p on p.major_id = s.object_id
                              and p.minor_id = 0
                              and p.class = 1
                              and p.name is not null
               where s.[object_id] = object_id(@ObjSysName)
                 and p.[value] is not null)
    return
  else
  --|| ���� � Extended Properties ������ �� �������
  begin 
    
    --|| ������ ������� ���������� ��� ��������
    select
         @Params =  (select '   ,' + c.Name + ' =  \n' + char(10) as 'data()' 
      from sys.syscolumns               as c
      left join sys.extended_properties as p on p.major_id = c.id
                                            and p.minor_id = 0
                                            and p.class = 1
                                            and p.Name = c.Name   
      where c.id = object_id(@ObjSysName)
        and isnull(p.Value, '') = ''
        and c.name <> '@debug_info'
      for xml path(''))     
      
    select 
       @Params       = '     ' + right(@Params, len(@Params) - 4) -- ��� ���� ����� ������ ������ ������� � ��������� 
    select @Blank = 
      '----------------------------------------------' + @El + 
      ' -- <���������� Extended Property �������>'     + @El + 
      '----------------------------------------------' + @El +       
      'exec dbo.FillExtendedProperty'                  + @El 
          + '   @ObjSysName  = ''' + @ObjSysName  + ''''   + @El  
          + '  ,@Author      = '''''  + @El  
          + '  ,@Description = '''''  + @El  
          + '  ,@Params = ''' + @El + isnull(left(@Params, len(@Params) - 1), '') + '''' + @El  
          + 'go'
    print @Blank
  end 
  -----------------------------------------------------------------
  -- End Point
  select @ret = 0
  return (@ret)
end
go
----------------------------------------------
-- <NativeCheck>
----------------------------------------------
exec [dbo].[Procedure.NativeCheck] '[dbo].[GetBlankExtendedProperty]'
go
----------------------------------------------
-- <Filling Extended Property>
----------------------------------------------
exec dbo.FillExtendedProperty
   @ObjSysName = '[dbo].[GetBlankExtendedProperty]'
  ,@Author = 'Cova Igor'
  ,@Description = '��������� ���������� ������ ��� ������ ��������� 
                   dbo.FillExtendedProperty � ������������ �����������'
  ,@Params = ' @ObjSysName  = ��� ������� � MS SQL Server.'             
            
go

/* �������: dbo.dbo_GetBlankExtendedProperty
declare @ret int, @err int, @runtime datetime = getdate()

exec @ret = [dbo].[GetBlankExtendedProperty] 
   @ObjSysName    = 'dbo.[GetBlankExtendedProperty]'       
  --,@debug_info      = 0xFF
  
select @err = @@error
select @ret as [RETURN], @err as [ERROR], convert(varchar(20), getdate()-@runtime, 114) as [RUN_TIME]
--*/
go