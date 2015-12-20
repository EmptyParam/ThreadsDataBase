set nocount on
set quoted_identifier, ansi_nulls, ansi_warnings, arithabort, concat_null_yields_null, ansi_padding on
set numeric_roundabort off
set transaction isolation level read uncommitted
set xact_abort on
go

----------------------------------------------
-- <PROC> [dbo].[FillExtendedProperty]
----------------------------------------------
/*
///<description>
///�������� ���������������� �������� � MS SQL Server. 
  ���������� Extended Property �������.
///</description>
*/
alter procedure [dbo].[FillExtendedProperty]
-- v1.0
  -- of(Object):   
   @ObjSysName     sysname       = null
  ,@ObjWrapName    sysname       = null
  ,@Author         varchar(512)  = null
  ,@Description    varchar(4000) = null
  ,@Params         varchar(max)  = null
  ,@RowSets        varchar(4000) = null
  ,@Errors         varchar(4000) = null

  ,@debug_info     int           = null
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
    ,@InfoMsg varchar(1000) -- ��� ������������ �������������� ���������
    ,@El      varchar(2) = char(13)+char(10) -- ������� ������ � ������� �������
    
    ,@InfoMsgPrms   varchar(1000)   
    ,@ParamName     sysname  
    ,@ParamValue    varchar(4000)       
    ,@ObjName       sysname   
    ,@ObjSchema     sysname  
    ,@ObjType       char(2)
    ,@ObjTypeName   nvarchar(60)
    ,@ObjSchemaId   int        
    ,@TemplateMsg   varchar(1000)    
  ---------------------------------------------------------
  --|| /*���������
  select 
       @ObjName     = o.Name
      ,@ObjSchema   = s.Name 
      ,@ObjSchemaId = s.[schema_id]
      ,@ObjType     = o.[type]
      ,@ObjTypeName = case o.[type] 
                        when 'P'  then 'Procedure' -- �������� ���������
                        when 'FN' then 'Function'  -- ��������� �������
                        when 'TF' then 'Function' -- ��������� �������
                        when 'V'  then 'View'       -- �������������
                        when 'FS' then 'Function'  -- ��������� ������� ������ (����� CLR)
                        when 'TR' then '' -- ������� DML SQL
                        when 'PC' then '' -- �������� ��������� ������ (����� CLR)
                        when 'SQ' then '' -- ������� ������������
                        when 'TT' then ''  -- ��������� ���
                        when 'S'  then 'Table' -- ��������� �������
                        when 'D'  then '' -- ����������� �� ��������� ��� DEFAULT
                        when 'IT' then 'Table'  -- ���������� �������
                        when 'F'  then '' -- ����������� FOREIGN KEY
                        when 'PK' then ''  -- ����������� PRIMARY KEY
                        when 'U'  then 'Table'  -- ���������������� �������
                        when 'IF' then 'Function'  -- ������������� ��������� �������
                        when 'C'  then '' -- ����������� CHECK
                        when 'UQ' then '' -- ����������� UNIQUE (type K)
                        when 'AF' then '' -- ���������� ������� (����� CLR)
                        when 'FT' then 'Function' -- ������� ������ � ��������� ��������� (����� CLR)  
                        when 'K'  then '' -- ����������� PRIMARY KEY ��� UNIQUE
                        when 'L'  then '' -- ������
                        when 'R'  then '' -- �������
                        when 'RF' then '' -- �������� ��������� ������� ����������
                        when 'SN' then '' -- �������
                        when 'TA' then '' -- ������� DML ������ (����� CLR)
                        when 'X'  then '' -- ����������� �������� ���������
                      end   
    from sys.objects as o 
    join sys.schemas as s on s.[schema_id] = o.[schema_id]   
    where o.[object_id] = object_id(@ObjSysName) 

  select
       @Params = isnull(fn.DelDoubleSpace(@Params), '')     
	  ,@TemplateMsg = '�������� ���������� �������: '   + @El + @El
	  + 'exec [dbo].[FillExtendedProperty]' + @El 
	  + ' @ObjSysName = ''�����.���������������'''   + @El
	  + ',@ObjWrapName = ''�����.���������������'''+ @El
	  + ',@Author = ''��������� �������'''+ @El
	  + ',@Description = ''�������� �������'''+ @El
	  + ',@Params = ''  ��������1 = �������� ���������1 \n' + @El
	  + '             ,��������2 = �������� ���������2 \n' + @El
	  + '             ,��������3 = �������� ���������3 \n' + @El
	  + '             ,��������N = �������� ���������N ''' + @El + @El
	  + '������������ ����� ����������� ������ �������� \n' + @El
	  + '������������ ����� ���������� � ��������� ���������� �������� ���� ='  + @El
	  + ',@RowSets = ''������������ ������ ������'''+ @El
	  + ',@Errors = ''��������� ������'''+ @El
	  + '@ObjWrapName �������� �� ������������. ����������� �������������.'  
  --|| */���������
  
  --||/* RAISERROR   
  if isnull(@ObjSysName, 'help') = 'help' 
  begin
    print (@TemplateMsg) 
    return                    
  end else if  isnull(@ObjSysName, '') = ''
    select @ErrMsg = '������� �������� ���������.'      

  else if  @Description = ''
    select @ErrMsg = '������� ��������\���������� ���������.' 

  else if  @Author = ''
    select @ErrMsg = '������� ��������� ������� @Author' 

  else if isnull(@ObjName, '') = ''
    select @ErrMsg = '������ � ������ ' + @ObjName + ' �� ����������!!!'                    
  
  --|| ������������ ��������� ������� � Wrapper'� �������
  declare @RequiredPrms table (Name sysname, Value varchar(4000))
  insert into @RequiredPrms (Name, Value) 
  select 'Description', isnull(fn.DelDoubleSpace(@Description), '')
  union 
  select 'Author',  isnull(fn.DelDoubleSpace(@Author), '')
  union 
  select 'DateCreate', master.dbo.fn_datetime_to_str_ForUser(getdate())
  union
  select 'Creator suser sname', suser_sname()
  union 
  select 'RowSets',  isnull(fn.DelDoubleSpace(@RowSets), '')
  union 
  select 'Errors',  isnull(fn.DelDoubleSpace(@Errors), '') 
     
  --|| ������� ���������
  declare @InParamsObj table(Name sysname, Value varchar(4000))  
  insert into @InParamsObj (Name, Value) 
  select 
       Name
      ,Value 
    from tf.ParamsOfStrToTable(@Params) 
    where isnull(Value, '') <> ''       
  union
  select 
       r.Name
      ,r.Value
    from @RequiredPrms as r  

  --|| ��� extended properties �������
  declare @ObjExtendedProp table (Name sysname, Value varchar(4000))
  insert into @ObjExtendedProp (Name, Value)
  select 
       p.Name                         as Name
      ,cast(p.Value as varchar(4000)) as Value
    from sys.extended_properties as p     
    where p.major_id = object_id(@ObjSysName)  
      and p.minor_id = 0
      and p.class = 1
      and p.Name is not null   
         
  ------------------------------------    
  --|| /*������ ���������� ��� ���������
  ------------------------------------
  
  --|| ������ ��� ��������
  declare @RemoveExtendedProp table (Name sysname, Value varchar(4000))
  insert into @RemoveExtendedProp (Name, Value)
  select 
       p.Name  as Name
      ,p.Value as Value
    from @ObjExtendedProp as p     
    where p.Name not in (select Name from @InParamsObj)

  --|| ������ ��� ����������
  declare @UpdateExtendedProp table (Name sysname, Value varchar(4000))
  insert into @UpdateExtendedProp (Name, Value)
  select 
       p.Name 
      ,r.Value
    from @ObjExtendedProp   as p  
    inner join @InParamsObj as r on r.Name = p.Name 
                                and r.Value <> p.Value
    where p.Name not in ('DateCreate', 'CreatorLoginDev')     
  
  --|| ������ ��� ���������� 
  declare @AddExtendedProp table (Name sysname, Value varchar(4000))
  insert into @AddExtendedProp (Name, Value)
  select 
       pr.Name    as Name  
      ,pr.Value   as Value 
    from @InParamsObj as pr 
    where  pr.Name not in (select Name from @ObjExtendedProp) 
  ------------------------------------  
  --|| */������ ���������� ��� ���������
  ------------------------------------
  ------------------
   --|| /*debug_info
  ------------------
  if @debug_info & 0x01 > 0       
  begin  
    select * from @InParamsObj
    
    select 
       @ObjSysName    as '@ObjSysName'        
      ,@ObjName       as '@ObjName'
      ,@ObjSchema     as '@ObjSchema'
      ,@ObjType       as '@ObjType'
      ,@ObjSchemaId   as '@ObjSchemaId'
      ,@ObjWrapName   as '@ObjWrapName'

    select 
         r.Name            as Name
        ,r.Value           as Value
        ,'�������� �����' as Status 
      from @RemoveExtendedProp as r
    union                 
    select 
         u.Name             as Name
        ,u.Value            as Value
        ,'�������� ��������� ��������' as Status
      from @UpdateExtendedProp as u
    union                 
    select 
         a.Name                           as Name
        ,a.Value                          as Value
        ,'�������� �������� � ���������'  as Status
      from @AddExtendedProp as a
    
  end 
  ------------------
  --|| /*debug_info
  ------------------
      
  -------------------------------------
  begin tran TRAN_ExtendedProperty
  -------------------------------------
    ---------------------------------------------
    --|| /* ��������� extended properties �������
    ---------------------------------------------
    if exists (select Name from @AddExtendedProp)
    begin 
      -----------------------------
      --|| /*���������� ����� ����������
      -----------------------------
      select  @cnt = 0
      declare cursor_for_add_param cursor local fast_forward for 
        select
             name
            ,value
          from @AddExtendedProp  

      open cursor_for_add_param
      fetch next from cursor_for_add_param into
         @ParamName  
        ,@ParamValue 
        
      while @@fetch_status = 0
      begin
        exec sys.sp_addextendedproperty 
           @Name       = @ParamName
          ,@Value      = @ParamValue
          ,@level0type = 'SCHEMA' 
          ,@level0Name = @ObjSchema
          ,@level1type = @ObjTypeName 
          ,@level1Name = @ObjName      

        select @err = @@error, @cnt = @cnt + 1  
        ------------------------------------       
        if (@res < 0 or @err != 0) 
        begin
          if @@trancount > 0 rollback
          raiserror (@ErrMsg, 16, 1)
          return (@ret)              
        end   
        ------------------------------------ 
        fetch next from cursor_for_add_param into
           @ParamName  
          ,@ParamValue
      end
      close cursor_for_add_param
      deallocate cursor_for_add_param  
      print '���������� ���������� � ��������� � Extended Property �������: '  + cast(@cnt as varchar) + ' ��.' + @El
      -----------------------------
      --|| */���������� ����� ���������� � Extended Property �������
      -----------------------------     
    end 
    --------------------------------------
    if exists (select * from @UpdateExtendedProp)
    begin 
      --------------------------------------
      --|| /*��������� ��������(values) ���������� � Extended Property
      --------------------------------------  
      select  @cnt = 0      
      declare cursor_for_update_param cursor
      for 
      select 
           Name
          ,Value
        from @UpdateExtendedProp 
      open cursor_for_update_param
      fetch next from cursor_for_update_param into
         @ParamName
        ,@ParamValue  

      while @@fetch_status = 0
      begin
        exec sys.sp_updateextendedproperty
           @Name       = @ParamName
          ,@Value      = @ParamValue
          ,@level0type = 'SCHEMA'
          ,@level0Name = @ObjSchema
          ,@level1type = @ObjTypeName   
          ,@level1Name = @ObjName   

        select @err = @@error, @cnt = @cnt +1
        ------------------------------------       
        if (@res < 0 or @err != 0) 
        begin
          select 
             @ret = case when @res = 0 then @err else @res end
            ,@ErrMsg = '��������� ������� ���������� Extended Property � �������� �������.' 
          if @@trancount > 0 rollback
          raiserror (@ErrMsg, 16, 1)
          return (@ret)             
        end
        ------------------------------------  
        fetch next from cursor_for_update_param into
           @ParamName  
          ,@ParamValue
      end
      close cursor_for_update_param
      deallocate cursor_for_update_param
      print '��������� �������� ���������� � Extended Property �������: '  + cast(@cnt as varchar) + ' ��.'  + @El 
      ------------------------------------
      --|| */��������� ��������(values) ���������� � Extended Property
      ------------------------------------ 
    end
    --------------------------------------
    if exists (select * from @RemoveExtendedProp as p)
    begin  
      --------------------------
      --|| /*�������� ���������� �� Extended Property �������    
      ---------------------------  
      select @cnt = 0
      declare cursor_for_rem_param cursor
      for 
      select Name
        from @RemoveExtendedProp          
      open cursor_for_rem_param
      fetch next from cursor_for_rem_param into
        @ParamName  

      while @@fetch_status = 0
      begin
        exec sys.sp_dropextendedproperty 
           @Name       = @ParamName
          ,@level0type = 'SCHEMA' 
          ,@level0Name = @ObjSchema
          ,@level1type = @ObjTypeName 
          ,@level1Name = @ObjName   

        select @err = @@error, @cnt = @cnt +1
        ------------------------------------       
        if (@res < 0 or @err != 0) 
        begin
          select 
             @ret = case when @res = 0 then @err else @res end
            ,@ErrMsg = '��������� ������� �������� ����������� Extended Property � �������� �������.' 
          if @@trancount > 0 rollback
          raiserror (@ErrMsg, 16, 1)
          return (@ret)
        end 
        ------------------------------------
        fetch next from cursor_for_rem_param into
           @ParamName  
      end
      close cursor_for_rem_param
      deallocate cursor_for_rem_param  
      print '�������� ���������� �� Extended Property �������: ' + cast(@cnt as varchar) + ' ��.' + @El 
      -------------------------
      --|| */�������� ���������� �� Extended Property �������         
      -------------------------    
    end
    ---------------------------------------------
    --|| */ ��������� extended properties �������
    ---------------------------------------------   
    -----------------------------------------------------
    --|| /* ��������� extended properties Wrapper'a �������
    -----------------------------------------------------   
    
    if    @ObjWrapName is not null 
    begin
      --|| ��� extended properties Wrapper'a �������
      declare @ObjWrapExtendedProp table (Name sysname, Value varchar(4000))
      insert into @ObjWrapExtendedProp (Name, Value)
      select 
           p.Name                         as Name
          ,cast(p.Value as varchar(4000)) as Value
        from sys.extended_properties as p     
        where p.major_id = object_id(@ObjWrapName)  
          and p.minor_id = 0
          and p.class = 1
          and p.Name is not null  
     
      --|| ��� extended properties ������� 
      delete from @ObjExtendedProp
      insert into @ObjExtendedProp (Name, Value)
      select 
           p.Name                         as Name
          ,cast(p.Value as varchar(4000)) as Value
        from sys.extended_properties as p     
        where p.major_id = object_id(@ObjSysName)  
          and p.minor_id = 0
          and p.class = 1
          and p.Name is not null     
         
      ------------------------------------    
      --|| /*������ ���������� ��� ���������
      ------------------------------------
      --|| ������ ��� ��������
      declare @RemoveWrapExtendedProp table (Name sysname)
      insert into @RemoveWrapExtendedProp (Name)
      select Name as Name
        from @ObjWrapExtendedProp        
        where Name not in (select Name from @ObjExtendedProp)
      
      --|| ������ �� ����������
      declare @AddWrapExtendedProp table (Name sysname, Value varchar(4000))
      insert into @AddWrapExtendedProp (Name, Value)
      select 
           p.Name    as Name
          ,p.Value   as Value
        from @ObjExtendedProp as p     
        where p.Name not in (select Name from @ObjWrapExtendedProp)

      --|| ������ �� ���������
      declare @UpdateWrapExtendedProp table (Name sysname, Value varchar(4000))
      insert into @UpdateWrapExtendedProp (Name, Value)
      select 
           p.Name    as Name
          ,p.Value   as Value         
        from @ObjExtendedProp as p    
        inner join @ObjWrapExtendedProp as r on r.Name = p.Name
        where p.Value <> r.Value       
      ------------------------------------    
      --|| */������ ���������� ��� ���������
      ------------------------------------
      
      if exists (select Name from @AddWrapExtendedProp)
      begin
      -----------------------------
      --|| /*���������� ����� ���������� � Extended Properties Wrapper'a �������      
      -----------------------------
        declare cursor_for_wrapadd_param cursor
        for 
        select 
             Name
            ,Value
          from @AddWrapExtendedProp  
        open cursor_for_wrapadd_param
        fetch next from cursor_for_wrapadd_param into
           @ParamName  
          ,@ParamValue 

        while @@fetch_status = 0
        begin
          exec sys.sp_addextendedproperty 
             @Name       = @ParamName
            ,@Value      = @ParamValue
            ,@level0type = 'SCHEMA' 
            ,@level0Name = @ObjWrapName
            ,@level1type = @ObjTypeName 
            ,@level1Name = @ObjWrapName      

          select @err = @@error  
          ----------------------------------------
          if (@res < 0 or @err != 0) 
          begin
            select
               @ret = case when @res = 0 then @err else @res end
              ,@ErrMsg = '��������� ������� ���������� ����������� ���������� � �������� wrapper �������.' 
            if @@trancount > 0 rollback
            raiserror (@ErrMsg, 16, 1)
            return (@ret)
          end           
          ----------------------------------------      
          fetch next from cursor_for_wrapadd_param into
             @ParamName  
            ,@ParamValue
        end
        close cursor_for_wrapadd_param
        deallocate cursor_for_wrapadd_param
      -----------------------------
      --|| /*���������� ����� ���������� � Extended Properties Wrapper'a �������  
      -----------------------------
      end
      
      if exists (select * from @UpdateWrapExtendedProp)
      begin 
      ------------------------------------
      --|| /*��������� ��������(value) ���������� � Extended Properties Wrapper'a �������  
      --------------------------------------            
        declare cursor_for_wrapupdate_param cursor
        for 
        select 
             Name
            ,Value
          from @UpdateWrapExtendedProp
        open cursor_for_wrapupdate_param
        fetch next from cursor_for_wrapupdate_param into
           @ParamName
          ,@ParamValue  

        while @@fetch_status = 0
        begin
          exec sys.sp_updateextendedproperty 
             @Name       = @ParamName
            ,@Value      = @ParamValue
            ,@level0type = 'SCHEMA'
            ,@level0Name = @ObjWrapName
            ,@level1type = @ObjTypeName   
            ,@level1Name = @ObjWrapName   

          select @err = @@error  
          ------------------------------------       
          if (@res < 0 or @err != 0) 
          begin
            select 
               @ret = case when @res = 0 then @err else @res end
              ,@ErrMsg = '��������� ������� ���������� Extended Property � �������� wrapper �������.' 
            if @@trancount > 0 rollback
            raiserror (@ErrMsg, 16, 1)
            return (@ret)
          end           
          ------------------------------------ 
          fetch next from cursor_for_wrapupdate_param into
             @ParamName  
            ,@ParamValue
        end
        close cursor_for_wrapupdate_param
        deallocate cursor_for_wrapupdate_param 
      ------------------------------------
      --|| */��������� ��������(value) ���������� � Extended Properties Wrapper'a �������  
      --------------------------------------      
      end
      
      if exists (select * from @RemoveWrapExtendedProp as p)
      begin  
      -------------------------
      --|| /*�������� ���������� �� Extended Properties Wrapper'a �������       
      -------------------------     
        declare cursor_for_wraprem_param cursor
        for 
        select Name
          from @RemoveWrapExtendedProp 
        open cursor_for_wraprem_param
        fetch next from cursor_for_wraprem_param into
          @ParamName  

        while @@fetch_status = 0
        begin
          exec sys.sp_dropextendedproperty 
             @Name       = @ParamName
            ,@level0type = 'SCHEMA' 
            ,@level0Name = @ObjWrapName
            ,@level1type = @ObjTypeName 
            ,@level1Name = @ObjWrapName   

          select @err = @@error  
          ------------------------------------------
          if (@res < 0 or @err != 0) 
          begin
            select
               @ret = case when @res = 0 then @err else @res end
              ,@ErrMsg = '��������� ������� �������� ����������� Extended Property � �������� wrapper �������.' 
            if @@trancount > 0 rollback
            raiserror (@ErrMsg, 16, 1)
            return (@ret) 
          end
          ------------------------------------------   
          fetch next from cursor_for_wraprem_param into
            @ParamName  
        end
        close cursor_for_wraprem_param
        deallocate cursor_for_wraprem_param 
      -------------------------
      --|| */�������� ���������� �� Extended Properties Wrapper'a �������    
      -------------------------    
      end  
    end   
    -----------------------------------------------------
    --|| */ ��������� extended properties Wrapper'a �������
    -----------------------------------------------------       
  ------------------------------------
  commit tran TRAN_ExtendedProperty
  ------------------------------------          
  --|| /* �������������� ���������   
  --|| ������� ��������� �� �������� � ������ ���������� �������
  declare @InNotIncludedParams table(Name sysname, Value varchar(4000))  
  insert into @InNotIncludedParams (Name, Value) 
  select 
       t.Name
      ,t.[Value]
    from @ObjExtendedProp as t
    where t.Name not in (select c.Name as Name
                           from syscolumns        as c
                           inner join sysobjects  as o on o.id = c.id
                           where  o.name = @ObjName
                         union
                         select s.Name as Name 
                           from @RequiredPrms as s)    
                          
  --|| ������ ������� ���������� ��� ��������
  select @InfoMsg = ( select '  ,' + c.Name + char(10) as 'data()' 
                        from sys.syscolumns               as c
                        left join sys.extended_properties as p on p.major_id = c.id
                                                              and p.minor_id = 0
                                                              and p.class = 1
                                                              and p.Name = c.Name   
                        where c.id = object_id(@ObjSysName) 
                          and c.Name not in (select Name from @InParamsObj)
                          and isnull(p.Value, '') = ''
                          and c.Name <> '@debug_info'
                        for xml path('')) + @el
                        
  --|| ��������� ������� ���� � Extended Properties �������, �� ��� � ������ ���������� ������ �������(������������ �������� � ���������)                       
  select @InfoMsgPrms =  ( select '  ,' + c.Name + ' = ' + c.Value + char(10) as 'data()' 
                             from @InNotIncludedParams as c
                             for xml path('')) + @el                      
  select @InfoMsg = '������ ������� ���������� ��� ��������: ' + @el + '    ' + right(@InfoMsg, len(@InfoMsg) - 3)   
  select @InfoMsgPrms =  '������ ���������� � ���������  (�� ��������������� � �������)' + @el + '    ' + right(@InfoMsgPrms, len(@InfoMsgPrms) - 3)                  
                        
  --���������� � ������������ ������� ������
  if (isnull(@InfoMsg, '') <> '') or (isnull(@InfoMsgPrms, '') <> '')   
    print isnull(@El + @InfoMsg, '') + isnull(@InfoMsgPrms, '')
    
  --|| */�������������� ���������
  -----------------------------------------------------------------
  -- End Point
  return (0)
end
go

----------------------------------------------
-- <WRAPPER>
----------------------------------------------
--exec [dbo]. '[dbo].[FillExtendedProperty]'
go
----------------------------------------------
-- <Filling Extended Property>
----------------------------------------------
exec dbo.FillExtendedProperty
   @ObjSysName = 'dbo.[FillExtendedProperty]'
  ,@Author = 'Cova Igor'
  ,@Description = '�������� ���������������� �������� � MS SQL Server. 
                   ���������� Extendefdhd Property �������.'
  ,@Params = '@ObjSysName = ��� ������� � MS SQL Server. ������� ������ �� ������.\n
             ,@ObjWrapName =  ��� �������� �������. ������� ������ �� ������. �������� �� ������������. \n
             ,@Author =  ��������� ������� \n             
             ,@Params =  ������� ��������� ��� ������ �������\n
             ,@Description = �������� �������: ��������������\������ ������������� � ��� ��� �������� ����� ����� ��� ������������� ������� ������� \n
             ,@RowSets = �������� ������������ ������� ������ \n
             ,@Errors = �������� ��������� ������ \n
             ,@debug_info = ��� ������� \n
             '
go
------------------------------------------------
-- <View Extended Property>
------------------------------------------------
/*exec dbo.[Object.ExtendedProperty] 
  @ObjSysName = '[dbo].[FillExtendedProperty]'
go
*/
 /*�������: 
declare @ret int, @err int, @runtime datetime

select @runtime = getdate()
exec [dbo].[FillExtendedProperty] 
   @ObjSysName    = 'dbo.[RequestCar.Create]'      
  ,@Author        = '��������� �����'
  ,@Description   = '��������� �������� ������ � �����.'
  ,@Params        = 
     '@DateOfIssue =  ��������������� ���� ������ ���� (����� ��������) ����\n
     ,@DocumentsInTime = ��������� �� ������� \n
     ,@FileSpec =  ���� ������������ \n
     ,@IsClientInSalon = ������ � ������ (��/���) \n
     ,@IsDateOfIssue = ������ � ��������������� ���� ������ ���� (����� ��������) (��/���)\n
     ,@IsDocumentsInTime = ��������� �� �������, ���������� ������� (��/���) \n
     ,@IsRegistration = ���������� ���� �� ���� ��/���\n
     ,@IsSucces =  output ���������� true ��� �� �������� commit ��/��� \n
     ,@OrderOID =  OID ������\n
     ,@SaleHistoryNote = ������� ����� ������� �� ���� \n
     ,@SalesPrice = ���� ������� ���� �� 1� \n
     ,@TradeIn =  ����� ������ �� ������ ����, ���� ���� ��������� �������� TradeIn � ������ ����������� ���� \n '

  ,@debug_info = 1
  ,@debug_shift = null
  ,@log_sesid = null     

select @err = @@error

select @ret as [RETURN], @err as [ERROR], convert(varchar(20), getdate()-@runtime, 114) as [RUN_TIME]
--
go
*/