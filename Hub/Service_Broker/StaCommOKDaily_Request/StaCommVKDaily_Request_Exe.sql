Use hub
go

set nocount on
set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
set numeric_roundabort off
set transaction isolation level read uncommitted
set xact_abort on
go

----------------------------------------------
-- <PROC> sb.StaCommOKDaily_Request_Exe
----------------------------------------------
exec dbo.sp_object_create 'sb.StaCommOKDaily_Request_Exe', 'P'
go

/*
///<description>
/// Executer service broker for StaCommOKDaily_Request
///</description>
*/
alter procedure sb.StaCommOKDaily_Request_Exe
-- v1.0
as
begin
------------------------------------------------
-- v1.0: Created by Igor Cova 27.04.2016
------------------------------------------------
  set nocount on
  set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
  set numeric_roundabort off
  set transaction isolation level read uncommitted
  set xact_abort on
  ------------------------------------
  -----------------------------------------------------------------
  declare @Handle uniqueidentifier
  declare @isNew bit

  waitfor (
    receive top(1)
         @Handle = [conversation_handle]
        ,@isNew = cast(message_body as xml).value('*[1]/isNew [1]', 'bit')
      from dbo.que_StaCommOKDaily_Request
  ), timeout 30000

  if @Handle is not null
  begin

    if @isNew = cast(1 as bit)
      exec ws.OK_Sta_ForNew
    else 
      exec ws.OK_Sta

    end conversation @Handle with cleanup;
  end
  -----------------------------------------------------------------
  -- End Point 
  return (0)
end
go