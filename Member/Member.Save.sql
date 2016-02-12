set nocount on
set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
set numeric_roundabort off
set transaction isolation level read uncommitted
set xact_abort on
go

/*
///<description>
/// procedure for Save Member.
///</description>
*/
alter procedure [dbo].[Member.Save]
   @ID             bigint        = null out
  ,@Name           varchar(256)
  ,@Surname        varchar(256)  = null
  ,@UserName       varchar(32)   = null
  ,@About          varchar(1024) = null
  ,@Phone          varchar(32)   = null
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
  -----------------------------------------------------------------

  if not exists (
      select * 
        from dbo.Member as c 
        where c.ID = @ID)
  begin
    set @ID = next value for seq.Member

    insert into dbo.Member ( 
       ID
      ,Name
      ,Surname
      ,UserName
      ,About
      ,JoinedDate 
      ,Phone
    ) values (
       @ID
      ,@Name
      ,@Surname
      ,@UserName
      ,@About
      ,getdate() 
      ,@Phone
    )
  end
  else
  begin
    update t set    
         t.Name           = @Name
        ,t.Surname        = @Surname
        ,t.UserName       = @UserName
        ,t.About          = @About
        ,t.Phone          = @Phone
      from dbo.Member as t
      where t.ID = @ID
  end


  select
       m.ID
      ,m.Name
      ,m.Surname
      ,m.FullName
      ,m.UserName
      ,m.About
      ,m.Phone
      ,m.JoinedDate
    from dbo.[Member.View] as m       
    where m.ID = @ID

  -----------------------------------------------------------------
  -- End Point
  return (0)
end
go

----------------------------------------------
-- <[NativeCheck]>
----------------------------------------------
exec [dbo].[NativeCheck] '[dbo].[Member.Save]'
go

----------------------------------------------
 -- <Fill Extended Property of db object>
----------------------------------------------
exec dbo.FillExtendedProperty
   @ObjSysName  = '[dbo].[Member.Save]'
  ,@Author      = 'Cova Igor'
  ,@Description = 'procedure for Save Member'
  ,@Params = '
      @About = About community \n
     ,@ID = ID community \n
     ,@Name = Name \n
     ,@Surname = Surname \n
     ,@UserName = User Name \n
     ,@Phone = ����� ��������
     '
go

/* �������:
declare @ret int, @err int, @runtime datetime

select @runtime = getdate()
exec @ret = [dbo].[Member.Save] -- '[dbo].[Member.Save]'
   @debug_info      = 0xFF

select @err = @@error

select @ret as [RETURN], @err as [ERROR], convert(varchar(20), getdate()-@runtime, 114) as [RUN_TIME]
--*/
go
grant execute on [dbo].[Member.Save] to [public]