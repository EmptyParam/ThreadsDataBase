set nocount on
set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
set numeric_roundabort off
set transaction isolation level read uncommitted
set xact_abort on
go

----------------------------------------------
-- <PROC> sb.StaCommOKDaily_Request_Send
----------------------------------------------
exec dbo.sp_object_create 'sb.StaCommOKDaily_Request_Send', 'P'
go

alter procedure sb.StaCommOKDaily_Request_Send
as
begin
------------------------------------------------
-- v1.0: Created by Igor Cova 14.06.2016
------------------------------------------------
  set nocount on
  set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
  set numeric_roundabort off
  set transaction isolation level read uncommitted
  set xact_abort on
  ------------------------------------
  declare @Handle uniqueidentifier
  declare @xml xml

  set @xml = (select cast(0 as bit) as isNew for xml path)

  begin dialog conversation @Handle

    from service srv_StaCommOKDaily_Request to service 'srv_StaCommOKDaily_Request'
    on contract ct_StaCommOKDaily_Request
    with encryption = off
        ,lifetime = 900 -- 15 minutes
    ;

    send on conversation @Handle 
      message type msg_StaCommOKDaily_Request(@xml);

  end conversation @Handle with cleanup;    
  -----------------------------------------------------------------
  return (0)
end
go
