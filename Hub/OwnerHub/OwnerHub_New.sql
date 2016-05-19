use Hub
go

set nocount on
set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
set numeric_roundabort off
set transaction isolation level read uncommitted
set xact_abort on
go

exec dbo.sp_object_create 'dbo.OwnerHub_New', 'P'
go

alter procedure dbo.OwnerHub_New
   @id             bigint
  ,@phone          varchar(32)
as
begin
------------------------------------------------
-- v1.0: Created by Cova Igor 30.03.2016
------------------------------------------------
  set nocount on
  set quoted_identifier, ansi_nulls, ansi_warnings, arithabort,
      concat_null_yields_null, ansi_padding on
  set numeric_roundabort off
  set transaction isolation level read uncommitted
  set xact_abort on
  -----------------------------------------------------------------
  declare @adminCommId   bigint = next value for seq.AdminComm
  declare @subjectCommId bigint = next value for seq.SubjectComm

  set @phone = fn.ClearPhone(@phone)

  insert into dbo.OwnerHub ( 
     id
    ,firstName
    ,lastName
    ,phone
    ,linkFB 
    ,dateCreate
  ) values (
     @id
    ,''
    ,''
    ,@phone
    ,'' 
    ,getdate()
  )

  -----------------------------------------------------------------
  -- End Point
  return (0)
end
go
----------------------------------------------
 -- <Fill Extended Property of db object>
----------------------------------------------
exec dbo.FillExtendedProperty
   @ObjSysName  = 'dbo.OwnerHub_New'
  ,@Author      = 'Cova Igor'
  ,@Description = 'procedure for Save owner Hub.'
  ,@Params = '
      @phone = phone number \n'
go
----------------------------------------------
-- <NativeCheck>
----------------------------------------------
exec dbo.[NativeCheck] 'dbo.OwnerHub_New'
go
/* �������:
declare @ret int, @err int, @runtime datetime

select @runtime = getdate()
exec @ret = dbo.OwnerHub_New 

select @err = @@error

select @ret as [RETURN], @err as [ERROR], convert(varchar(20), getdate()-@runtime, 114) as [RUN_TIME]
--*/
go
grant execute on dbo.OwnerHub_New to [public]
