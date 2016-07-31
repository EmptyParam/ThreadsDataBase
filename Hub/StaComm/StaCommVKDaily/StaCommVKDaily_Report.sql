use Hub
go

set nocount on
set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
set numeric_roundabort off
set transaction isolation level read uncommitted
set xact_abort on
go

exec dbo.sp_object_create 'dbo.StaCommVKDaily_Report', 'P'
go

alter procedure dbo.StaCommVKDaily_Report
   @ownerHubID bigint = null
  ,@isPast     bit    = null
as
begin
------------------------------------------------
-- v1.0: Created by Cova Igor 24.04.2016
------------------------------------------------
  set nocount on
  set quoted_identifier, ansi_nulls, ansi_warnings, arithabort,
      concat_null_yields_null, ansi_padding on
  set numeric_roundabort off
  set transaction isolation level read uncommitted
  set xact_abort on
  ----------------------------------------------------------------
  exec dbo.Getter_Save @ownerHubID, 'GetReport', 'dbo.StaCommVKDaily_Report'
  -----------------------------------------------------------------
  set @ownerHubID = iif(@ownerHubID in (1,2,80) , 3, @ownerHubID)
  declare 
     @startDate date = iif(@isPast = 1, cast(getdate()-1 as date),  cast(getdate() as date))
    ,@endDate   date = iif(@isPast = 1, cast(getdate()-2 as date),  cast(getdate() -1 as date))
    ,@preDate   date = iif(@isPast = 1, cast(getdate()-3 as date),  cast(getdate() -2 as date))
    
    ,@teamHubID bigint

  select top 1 
       @teamHubID = t.teamHubID
    from dbo.OwnerHub as t       
    where t.id = @ownerHubID
  
  declare @ownersTeam table (id bigint)
  insert into @ownersTeam ( id ) values (@ownerHubID)
  insert into @ownersTeam ( id )
  select
       t.id
    from dbo.OwnerHub as t       
    where t.TeamHubID = @teamHubID
     and t.id <> @ownerHubID

  select
       projectHub_id             = t.projectHubID
      ,projectHub_name           = r.name
      ,comm_id                   = t.id
      ,comm_name                 = t.name
      ,comm_photoLink            = isnull(t.photoLink , '')
      ,comm_photoLinkBig          = isnull(t.photoLinkBig , '')
      ,comm_groupID              = t.groupID
 
      ,subjectComm_name          = b.name
      ,areaComm_code             = a.code

      ,adminComm_fullName        = concat(d.firstName + ' ', d.lastName)
      ,adminComm_linkFB          = d.linkFB
      ,lastRequestDate           = s.requestDate

      ---------------------------------------------------------------------------------------------------------------------------------------------------
      -- Periodically +
      ,increase                  = isnull(s.commSubscribed - s.commUnsubscribed, 0)
      ,increaseNew               = isnull(s.commSubscribed, 0)
      ,increaseOld               = isnull(s.commUnsubscribed, 0)
      ,increaseDifPercent        = cast(isnull(isnull(s.commSubscribed - s.commUnsubscribed, 0) * 100.00 / nullif(isnull(v.commSubscribed - v.commUnsubscribed, 0), 0), 0) as int) 

      ,subscribed                = isnull(0, 0)     
      ,subscribedNew             = isnull(s.commSubscribed, 0)
      ,subscribedOld             = isnull(v.commSubscribed, 0)
      ,subscribedDif             = isnull(f.commSubscribed, 0)
      ,subscribedDifPercent      = cast(isnull(f.commSubscribed * 100.00 / nullif(v.commSubscribed, 0), 0) as int)

      ,unsubscribed              = isnull(0, 0)
      ,unsubscribedNew           = isnull(s.commUnsubscribed, 0)
      ,unsubscribedOld           = isnull(v.commUnsubscribed, 0)
      ,unsubscribedDif           = isnull(f.commUnsubscribed, 0)
      ,unsubscribedDifPercent    = cast(isnull(f.commUnsubscribed * 100.00 / nullif(v.commUnsubscribed, 0), 0) as int)

      ,visitors                  = isnull(0, 0)
      ,visitorsNew               = isnull(s.commVisitors, 0)
      ,visitorsOld               = isnull(v.commVisitors, 0)
      ,visitorsDif               = isnull(f.commVisitors, 0)
      ,visitorsDifPercent        = cast(isnull(f.commVisitors * 100.00 / nullif(v.commVisitors, 0), 0) as int)

      ,views                     = isnull(0, 0)
      ,viewsNew                  = isnull(s.commViews, 0)
      ,viewsOld                  = isnull(v.commViews, 0)
      ,viewsDif                  = isnull(f.commViews, 0)
      ,viewsDifPercent           = cast(isnull(f.commViews * 100.00 / nullif(v.commViews, 0), 0) as int)

      ,reach                     = isnull(0, 0)
      ,reachNew                  = isnull(s.commReach, 0)
      ,reachOld                  = isnull(v.commReach, 0)
      ,reachDif                  = isnull(f.commReach, 0)
      ,reachDifPercent           = cast(isnull(f.commReach * 100.00 / nullif(v.commReach, 0), 0) as int)

      ,reachSubscribers          = isnull(0, 0)
      ,reachSubscribersNew       = isnull(s.commReachSubscribers, 0)
      ,reachSubscribersOld       = isnull(v.commReachSubscribers, 0)
      ,reachSubscribersDif       = isnull(f.commReachSubscribers, 0)
      ,reachSubscribersDifPercent= cast(isnull(f.commReachSubscribers * 100.00 / nullif(v.commReachSubscribers, 0), 0) as int)

      ,postCount                 = isnull(0, 0)
      ,postCountNew              = isnull(s.commPostCount, 0)
      ,postCountOld              = isnull(v.commPostCount, 0)
      ,postCountDif              = isnull(f.commPostCount, 0)
      ,postCountDifPercent       = cast(isnull(f.commPostCount * 100.00 / nullif(v.commPostCount, 0), 0) as int)
      -- Periodically +
      ---------------------------------------------------------------------------------------------------------------------------------------------------

      ---------------------------------------------------------------------------------------------------------------------------------------------------
      -- Summary +
      ,members                   = isnull(s.commMembers, 0)
      ,membersNew                = isnull(st.commMembers, 0)
      ,membersOld                = isnull(vt.commMembers, 0)
      ,membersDif                = isnull(f.commMembers, 0)
      ,membersDifPercent         = cast(isnull(f.commMembers * 100.00 / nullif(vt.commMembers, 0), 0) as int)
      -- Summary -
      ---------------------------------------------------------------------------------------------------------------------------------------------------

      ---------------------------------------------------------------------------------------------------------------------------------------------------
      -- Wall +
      ,likes                     = isnull(st.commLikes , 0)     
      ,likesNew                  = isnull(st.commLikes, 0)
      ,likesOld                  = isnull(vt.commLikes, 0)
      ,likesDif                  = isnull(f.commLikes, 0)
      ,likesDifPercent           = cast(isnull(f.commLikes * 100.00 / nullif(vt.commLikes, 0), 0) as int)

      ,comments                  = isnull(st.commComments, 0)
      ,commentsNew               = isnull(st.commComments, 0)
      ,commentsOld               = isnull(vt.commComments, 0)
      ,commentsDif               = isnull(f.commComments, 0)
      ,commentsDifPercent        = cast(isnull(f.commComments * 100.00 / nullif(vt.commComments, 0), 0) as int)

      ,reposts                   = isnull(st.commShare, 0)
      ,repostsNew                = isnull(st.commShare, 0)
      ,repostsOld                = isnull(vt.commShare, 0)
      ,repostsDif                = isnull(f.commShare, 0)
      ,repostsDifPercent         = cast(isnull(f.commShare * 100.00 / nullif(vt.commShare, 0), 0) as int)
      -- Wall +
      ---------------------------------------------------------------------------------------------------------------------------------------------------      
    from dbo.Comm             as t
    left join dbo.AreaComm    as a on a.id = t.areaCommID
    left join dbo.SubjectComm as b on b.id = t.subjectCommID
    left join dbo.AdminComm   as d on d.id = t.adminCommID
    left join dbo.ProjectHub  as r on r.id = t.projectHubID
    outer apply (
      select top 1 
           st.commLikes
          ,st.commComments
          ,st.commShare
          ,cast(st.commMembers as int) as commMembers
          ,cast(st.commMembersLost as int) as commMembersLost
        from dbo.StaCommVKGraph as st 
        where st.dayDate = @startDate
          and st.groupID = t.groupID
    ) as st

    outer apply (
      select top 1 
           st.commLikes
          ,st.commComments
          ,st.commShare
          ,cast(st.commMembers as int) as commMembers
          ,cast(st.commMembersLost as int) as commMembersLost
        from dbo.StaCommVKGraph as st 
        where st.dayDate = @endDate
          and st.groupID = t.groupID
    ) as vt

    outer apply (
      select          
           s.commSubscribed        as commSubscribed
          ,s.commUnsubscribed      as commUnsubscribed
          ,s.commViews             as commViews
          ,s.commVisitors          as commVisitors
          ,s.commReach             as commReach
          ,s.commReachSubscribers  as commReachSubscribers
          ,s.commPostCount         as commPostCount
          ,s.commMembers           as commMembers
          ,s.requestDate           as requestDate
        from dbo.StaCommVKDaily as s
        where s.commID = t.id
          and s.dayDate = @startDate
    ) as s

    outer apply (
      select          
           s.commSubscribed        as commSubscribed
          ,s.commUnsubscribed      as commUnsubscribed
          ,s.commViews             as commViews
          ,s.commVisitors          as commVisitors
          ,s.commReach             as commReach
          ,s.commReachSubscribers  as commReachSubscribers
          ,s.commPostCount         as commPostCount
          ,s.commMembers           as commMembers
          ,s.requestDate           as requestDate
        from dbo.StaCommVKDaily as s      
        where s.commID = t.id 
          and s.dayDate = @endDate
    ) as v

    outer apply (
      select          
           s.commSubscribed        as commSubscribed
          ,s.commUnsubscribed      as commUnsubscribed
          ,s.commViews             as commViews
          ,s.commVisitors          as commVisitors
          ,s.commReach             as commReach
          ,s.commReachSubscribers  as commReachSubscribers
          ,s.commPostCount         as commPostCount
          ,s.commMembers           as commMembers
          ,s.requestDate           as requestDate
        from dbo.StaCommVKDaily as s      
        where s.commID = t.id 
          and s.dayDate = @preDate
    ) as p
    
    outer apply (
      select
           commLikes            = cast((st.commLikes    - vt.commLikes   ) as int) 
          ,commComments         = cast((st.commComments - vt.commComments) as int)
          ,commShare            = cast((st.commShare    - vt.commShare   ) as int)

          ,commMembers          = cast((st.commMembers  - vt.commMembers ) as int)

          ,commSubscribed       = cast((s.commSubscribed       - v.commSubscribed)       as int)
          ,commUnsubscribed     = cast((s.commUnsubscribed     - v.commUnsubscribed)     as int)
          ,commViews            = cast((s.commViews            - v.commViews)            as int)
          ,commVisitors         = cast((s.commVisitors         - v.commVisitors)         as int)
          ,commReach            = cast((s.commReach            - v.commReach)            as int)
          ,commReachSubscribers = cast((s.commReachSubscribers - v.commReachSubscribers) as int)
          ,commPostCount        = cast((s.commPostCount        - v.commPostCount)        as int)
          
    ) as f
    where ((t.ownerHubID = iif(@ownerHubID = 1, t.ownerHubID, @ownerHubID)) or
       (t.ownerHubID in (select id from @ownersTeam)))
      and t.areaCommID = 1 -- VK only
      and t.groupID <> 0
    order by t.name asc
-----------------------------------------------------------
  -- End Point
end
go

----------------------------------------------
-- <NativeCheck>
----------------------------------------------
exec dbo.[NativeCheck] 'dbo.StaCommVKDaily_Report'
go

----------------------------------------------
 -- <Fill Extended Property of db object>
----------------------------------------------
exec dbo.FillExtendedProperty
   @ObjSysName  = 'dbo.StaCommVKDaily_Report'
  ,@Author      = 'Cova Igor'
  ,@Description = 'procedure for read report with day dynamic statistic on Vkontakte by owner Hub id.'
  ,@Params      = '@ownerHubID = owner Hub id \n
                   @isPast = for past period \n'
go

/* �������:
declare @ret int, @err int, @runtime datetime

select @runtime = getdate()
exec @ret = dbo.StaCommVKDaily_Report 
   @ownerHubId = 1
  ,@isPast = 0

select @err = @@error

select @ret as [RETURN], @err as [ERROR], convert(varchar(20), getdate()-@runtime, 114) as [RUN_TIME]
--*/
go
grant execute on dbo.StaCommVKDaily_Report to [public]
/*
select * from dbo.StaCommVKDaily as scv
order by scv.commID, dayDate desc*/--select * from dbo.OwnerHub as oh