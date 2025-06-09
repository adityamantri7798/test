USE [EDW]
GO

/****** Object:  StoredProcedure [dbo].[spAllCommonDimClaimInsert]    Script Date: 7/4/2025 3:21:23 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- Description : insertion script for Claim Common Dimension
-- Create Date : 13-12-2017
-- Written by  : Richard
-- Amendment History :  
-- Mod Date		By			Description  
-- ------		----------	--------------  
-- 30-01-2018	Richard		Rewrite DimClaimType, DimClaimTypeMapping, DimClaimEventType, DimClaimEventTypeMapping to support IDENTITY Key

CREATE PROCEDURE [dbo].[spAllCommonDimClaimInsert]
AS
BEGIN

	SET NOCOUNT ON;

	PRINT 'DimClaimEventStatus Insert'

	DELETE FROM [dbo].[DimClaimEventStatus];

	INSERT INTO [dbo].[DimClaimEventStatus]
           ([ClaimEventStatusSeqID]
           ,[ClaimEventStatusDescription]
           ,[RecInsertDate]
           ,[RecUpdateDate])
	VALUES
	(-1,'UNKNOWN',GETDATE(),GETDATE());

	PRINT 'DimClaimEventStatus GIV3 Insert'
	INSERT INTO [dbo].[DimClaimEventStatus] ([ClaimEventStatusSeqID],[ClaimEventStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(1,'CLOSED',GetDate(),GetDate())

	INSERT INTO [dbo].[DimClaimEventStatus] ([ClaimEventStatusSeqID],[ClaimEventStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(2,'NEW',GetDate(),GetDate())

	INSERT INTO [dbo].[DimClaimEventStatus] ([ClaimEventStatusSeqID],[ClaimEventStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(3,'OPEN',GetDate(),GetDate())

	INSERT INTO [dbo].[DimClaimEventStatus] ([ClaimEventStatusSeqID],[ClaimEventStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(4,'REOPEN',GetDate(),GetDate())

	PRINT 'DimClaimEventStatus RDS Insert'
	INSERT INTO [dbo].[DimClaimEventStatus]
			   ([ClaimEventStatusSeqID]
			   ,[ClaimEventStatusDescription]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES
	(5,'CANCELLED',GETDATE(),GETDATE()),
	(6,'IN PROCESS',GETDATE(),GETDATE()),
	(7,'MIGRATED',GETDATE(),GETDATE()),
	(8,'NOTIFIED',GETDATE(),GETDATE()),
	(9,'REJECTED',GETDATE(),GETDATE()),
	(10,'SUSPENDED',GETDATE(),GETDATE()),
	(11,'VOID',GETDATE(),GETDATE())

	PRINT 'DimClaimEventStatus DPS Insert'
	INSERT INTO [dbo].[DimClaimEventStatus]
			   ([ClaimEventStatusSeqID]
			   ,[ClaimEventStatusDescription]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES
	(12,'PENDING',GETDATE(),GETDATE()),
	(13,'SETTLED',GETDATE(),GETDATE()),
	(14,'WITHDRAWN',GETDATE(),GETDATE()),
	(15,'REPORTING ONLY',GETDATE(),GETDATE());

	PRINT 'DimClaimEventStatus LIV2 Insert';
	DECLARE @maxIDDimClaimEventStatusLIV2 smallint;
	SELECT @maxIDDimClaimEventStatusLIV2 =  ISNULL(max(ClaimEventStatusSeqID),0) FROM DimClaimEventStatus

	INSERT INTO DimClaimEventStatus(ClaimEventStatusSeqID,  ClaimEventStatusDescription, RecInsertDate, RecUpdateDate)
	SELECT ClaimEventStatusSeqID = @maxIDDimClaimEventStatusLIV2 + row_number() over (order by STR_DESC)
	 ,UPPER(STR_DESC)
	 ,GetDate()
	 ,GetDate()
	FROM
	(
	 SELECT distinct STR_DESC
	 FROM RSRPT.LIV2.V_CODE_DESC
	 WHERE ORG_TABLE = 'T_CASE_STATUS'
	 AND STR_DESC NOT IN
	 (
	  SELECT ClaimEventStatusDescription FROM DimClaimEventStatus
	 ) 
	 AND STR_DESC <> 'CANCELLATION' --In DimClaimEventStatus, ""Cancelled"" is already there for GIV3.""Cancelled"" and ""Cancellation"" are the same meaning
	) t
	order by 1

	PRINT 'DimClaimEventStatusMapping Insert'

	DELETE FROM [dbo].[DimClaimEventStatusMapping]
	
	PRINT 'DimClaimEventStatusMapping GIV3 Insert'
	INSERT INTO [dbo].[DimClaimEventStatusMapping] ([ClaimEventStatusMappingSeqID],[RefClaimEventStatusSeqID],[ClaimEventStatusCode],[ClaimEventStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
			VALUES(1, 1, '0', 'CLOSED','GIV3', GetDate(), GetDate())         
	INSERT INTO [dbo].[DimClaimEventStatusMapping] ([ClaimEventStatusMappingSeqID],[RefClaimEventStatusSeqID],[ClaimEventStatusCode],[ClaimEventStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
			VALUES(2, 2, '1', 'NEW','GIV3', GetDate(), GetDate())           
	INSERT INTO [dbo].[DimClaimEventStatusMapping] ([ClaimEventStatusMappingSeqID],[RefClaimEventStatusSeqID],[ClaimEventStatusCode],[ClaimEventStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
			VALUES(3, 3, '2', 'OPEN','GIV3', GetDate(), GetDate())           
	INSERT INTO [dbo].[DimClaimEventStatusMapping] ([ClaimEventStatusMappingSeqID],[RefClaimEventStatusSeqID],[ClaimEventStatusCode],[ClaimEventStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
			VALUES(4, 4, '3', 'REOPEN','GIV3', GetDate(), GetDate())
    
	PRINT 'DimClaimEventStatusMapping RDS Insert'      
	INSERT INTO [dbo].[DimClaimEventStatusMapping]
			   ([ClaimEventStatusMappingSeqID]
			   ,[RefClaimEventStatusSeqID]
			   ,[ClaimEventStatusCode]
			   ,[ClaimEventStatusDescription]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES 
	(5,5,'cnl','Cancelled','RDS',GETDATE(),GETDATE()), 
	(6,1,'cld','Closed','RDS',GETDATE(),GETDATE()), 
	(7,6,'bCi','In Process','RDS',GETDATE(),GETDATE()), 
	(8,7,'migr','Migrated','RDS',GETDATE(),GETDATE()), 
	(9,8,'ntf','Notified','RDS',GETDATE(),GETDATE()), 
	(10,9,'j','Rejected','RDS',GETDATE(),GETDATE()),
	(11,10,'susP','Suspended','RDS',GETDATE(),GETDATE()),
	(12,11,'v','Void','RDS',GETDATE(),GETDATE());		   

	PRINT 'DimClaimEventStatusMapping DPS Insert' 	
	INSERT INTO [dbo].[DimClaimEventStatusMapping]
			   ([ClaimEventStatusMappingSeqID]
			   ,[RefClaimEventStatusSeqID]
			   ,[ClaimEventStatusCode]
			   ,[ClaimEventStatusDescription]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES 
	(13,12,'1','Pending','DPS',GETDATE(),GETDATE()), 
	(14,9,'2','Rejected','DPS',GETDATE(),GETDATE()), 
	(15,13,'3','Settled','DPS',GETDATE(),GETDATE()), 
	(16,14,'4','Withdrawn','DPS',GETDATE(),GETDATE()), 
	(17,4,'5','Reopen','DPS',GETDATE(),GETDATE()), 
	(18,15,'6','Reporting Only','DPS',GETDATE(),GETDATE());

	PRINT 'DimClaimEventStatusMapping WBISIS Insert' 	
	INSERT INTO [dbo].[DimClaimEventStatusMapping]
           ([ClaimEventStatusMappingSeqID]
           ,[RefClaimEventStatusSeqID]
           ,[ClaimEventStatusCode]
           ,[ClaimEventStatusDescription]
           ,[AppSource]
           ,[RecInsertDate]
           ,[RecUpdateDate])
	VALUES 
	(19,12,'1','Pending','WBISIS',GETDATE(),GETDATE()), 
	(20,9,'2','Rejected','WBISIS',GETDATE(),GETDATE()), 
	(21,13,'3','Settled','WBISIS',GETDATE(),GETDATE()), 
	(22,14,'4','Withdrawn','WBISIS',GETDATE(),GETDATE()), 
	(23,4,'5','Reopen','WBISIS',GETDATE(),GETDATE()), 
	(24,15,'6','Reporting Only','WBISIS',GETDATE(),GETDATE());

	PRINT 'DimClaimEventStatusMapping LIV2 Insert' 	
	DECLARE @maxIDDimClaimEventStatusMappingLIV2 smallint;
	SELECT @maxIDDimClaimEventStatusMappingLIV2 =  ISNULL(max([ClaimEventStatusMappingSeqID]),0) FROM DimClaimEventStatusMapping

	INSERT INTO [dbo].[DimClaimEventStatusMapping] ([ClaimEventStatusMappingSeqID],[RefClaimEventStatusSeqID],[ClaimEventStatusCode],[ClaimEventStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
	SELECT ClaimEventStatusMappingSeqID = @maxIDDimClaimEventStatusMappingLIV2 + row_number() over (order by STR_DESC)
	  ,RefClaimEventStatusSeqID = (SELECT ClaimEventStatusSeqID 
			  FROM DimClaimEventStatus 
			  WHERE ClaimEventStatusDescription = (CASE WHEN a.STR_DESC = 'CANCELLATION' THEN 'CANCELLED' ELSE a.STR_DESC END)
			  AND ClaimEventStatusSeqID <> -1)
	  ,a.STR_CODE
	  ,UPPER(a.STR_DESC)   
	  ,'LIV2'
	  ,GetDate()
	  ,GetDate()
	FROM RSRPT.LIV2.V_CODE_DESC a
	WHERE ORG_TABLE = 'T_CASE_STATUS'
	order by 1,2

	PRINT 'DimClaimStatus Insert'

	DELETE FROM [dbo].[DimClaimStatus]

	INSERT INTO [dbo].[DimClaimStatus]
           ([ClaimStatusSeqID]
           ,[ClaimStatusDescription]
           ,[RecInsertDate]
           ,[RecUpdateDate])
	VALUES
	(-1,'UNKNOWN',GETDATE(),GETDATE());

	PRINT 'DimClaimStatus GIV3 Insert'
	INSERT INTO [dbo].[DimClaimStatus] ([ClaimStatusSeqID],[ClaimStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(1,'CLOSED',GetDate(),GetDate())
	INSERT INTO [dbo].[DimClaimStatus] ([ClaimStatusSeqID],[ClaimStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(2,'NEW',GetDate(),GetDate())
	INSERT INTO [dbo].[DimClaimStatus] ([ClaimStatusSeqID],[ClaimStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(3,'OPEN',GetDate(),GetDate())
	INSERT INTO [dbo].[DimClaimStatus] ([ClaimStatusSeqID],[ClaimStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(4,'REOPEN',GetDate(),GetDate())

	PRINT 'DimClaimStatus RDS Insert'
	INSERT INTO [dbo].[DimClaimStatus]
			   ([ClaimStatusSeqID]
			   ,[ClaimStatusDescription]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES
	(5,'PAYMENT SUSPENDED',GETDATE(),GETDATE()),
	(6,'PAYMENT STOPPED',GETDATE(),GETDATE()),
	(7,'NOT PAYING',GETDATE(),GETDATE()),
	(8,'PAYMENT IN PROGRESS',GETDATE(),GETDATE()),
	(9,'FULLY PAID',GETDATE(),GETDATE()),
	(10,'APPROVED PENDING REQ',GETDATE(),GETDATE()),
	(11,'PAYMENT APPROVED',GETDATE(),GETDATE())

	PRINT 'DimClaimStatus DPS Insert'
	INSERT INTO [dbo].[DimClaimStatus]
			   ([ClaimStatusSeqID]
			   ,[ClaimStatusDescription]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES
	(12,'PENDING',GETDATE(),GETDATE()),
	(13,'REJECTED',GETDATE(),GETDATE()),
	(14,'SETTLED',GETDATE(),GETDATE()),
	(15,'WITHDRAWN',GETDATE(),GETDATE()),
	(16,'REPORTING ONLY',GETDATE(),GETDATE());

	PRINT 'DimClaimStatus LIV2 Insert'

	DECLARE @maxIDDimClaimStatusLIV2 smallint;
	SELECT @maxIDDimClaimStatusLIV2 =  ISNULL(max(ClaimStatusSeqID),0) FROM DimClaimStatus
	--print @maxIDLIV2;
	INSERT INTO DimClaimStatus(ClaimStatusSeqID,  ClaimStatusDescription, RecInsertDate, RecUpdateDate)
	SELECT ClaimStatusSeqID = @maxIDDimClaimStatusLIV2 + row_number() over (order by STR_DESC)
	 ,UPPER(STR_DESC)
	 ,GetDate()
	 ,GetDate()
	FROM
	(
	 SELECT distinct STR_DESC = (CASE WHEN STR_DESC = 'CANCELLATION' THEN 'CANCELLED' ELSE STR_DESC END)
	 FROM RSRPT.LIV2.V_CODE_DESC
	 WHERE ORG_TABLE = 'T_CASE_STATUS'
	 AND STR_DESC NOT IN
	 (
	  SELECT ClaimStatusDescription FROM DimClaimStatus
	 ) 
	 --AND STR_DESC <> 'CANCELLATION' --Required this filter only for DimClaimEventStatus 
	 --because In DimClaimEventStatus, ""Cancelled"" is already there for RDS.""Cancelled"" and ""Cancellation"" are the same meaning
	 --But RDS has no ""Cancelled"" for DimClaimStatus so ""Cancellation"" needs to be inserted for LIV2 into DimClaimStatus
	 --But will use ""Cancelled"" instead of ""Cancellation"" for LIV2 DimClaimStatus to be same as in DimClaimEventStaus
	) t
	order by 1


	PRINT 'DimClaimStatusMapping Insert'
	DELETE FROM [dbo].[DimClaimStatusMapping]

	PRINT 'DimClaimStatusMapping GIV3 Insert'
	INSERT INTO [dbo].[DimClaimStatusMapping] ([ClaimStatusMappingSeqID],[RefClaimStatusSeqID],[ClaimStatusCode],[ClaimStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
		 VALUES(1, 1, '0', 'CLOSED','GIV3', GetDate(), GetDate())
	INSERT INTO [dbo].[DimClaimStatusMapping] ([ClaimStatusMappingSeqID],[RefClaimStatusSeqID],[ClaimStatusCode],[ClaimStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
		 VALUES(2, 2, '1', 'NEW','GIV3', GetDate(), GetDate())          
	INSERT INTO [dbo].[DimClaimStatusMapping] ([ClaimStatusMappingSeqID],[RefClaimStatusSeqID],[ClaimStatusCode],[ClaimStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
		 VALUES(3, 3, '2', 'OPEN','GIV3', GetDate(), GetDate())           
	INSERT INTO [dbo].[DimClaimStatusMapping] ([ClaimStatusMappingSeqID],[RefClaimStatusSeqID],[ClaimStatusCode],[ClaimStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
		 VALUES(4, 4, '3', 'REOPEN','GIV3', GetDate(), GetDate())

	PRINT 'DimClaimStatusMapping RDS Insert'
	INSERT INTO [dbo].[DimClaimStatusMapping]
			   ([ClaimStatusMappingSeqID]
			   ,[RefClaimStatusSeqID]
			   ,[ClaimStatusCode]
			   ,[ClaimStatusDescription]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES
	(5,5,'susp','Payment Suspended','RDS',GETDATE(),GETDATE()), 
	(6,6,'stop','Payment Stopped','RDS',GETDATE(),GETDATE()), 
	(7,7,'no','Not Paying','RDS',GETDATE(),GETDATE()), 
	(8,8,'inprgrss','Payment in Progress','RDS',GETDATE(),GETDATE()), 
	(9,9,'full_paid','Fully Paid','RDS',GETDATE(),GETDATE()), 
	(10,10,'aprv_zreq','Approved Pending Req.','RDS',GETDATE(),GETDATE()),
	(11,11,'aprv','Payment Approved','RDS',GETDATE(),GETDATE());

	PRINT 'DimClaimStatusMapping DPS Insert'
	INSERT INTO [dbo].[DimClaimStatusMapping]
           ([ClaimStatusMappingSeqID]
           ,[RefClaimStatusSeqID]
           ,[ClaimStatusCode]
           ,[ClaimStatusDescription]
           ,[AppSource]
           ,[RecInsertDate]
           ,[RecUpdateDate])
	VALUES
	(12,12,'1','Pending','DPS',GETDATE(),GETDATE()), 
	(13,13,'2','Rejected','DPS',GETDATE(),GETDATE()), 
	(14,14,'3','Settled','DPS',GETDATE(),GETDATE()), 
	(15,15,'4','Withdrawn','DPS',GETDATE(),GETDATE()), 
	(16,4,'5','Reopen','DPS',GETDATE(),GETDATE()), 
	(17,16,'6','Reporting Only','DPS',GETDATE(),GETDATE());

	PRINT 'DimClaimStatusMapping WBISIS Insert'
	INSERT INTO [dbo].[DimClaimStatusMapping]
			   ([ClaimStatusMappingSeqID]
			   ,[RefClaimStatusSeqID]
			   ,[ClaimStatusCode]
			   ,[ClaimStatusDescription]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES
	(18,12,'1','Pending','WBISIS',GETDATE(),GETDATE()), 
	(19,13,'2','Rejected','WBISIS',GETDATE(),GETDATE()), 
	(20,14,'3','Settled','WBISIS',GETDATE(),GETDATE()), 
	(21,15,'4','Withdrawn','WBISIS',GETDATE(),GETDATE()), 
	(22,4,'5','Reopen','WBISIS',GETDATE(),GETDATE()), 
	(23,16,'6','Reporting Only','WBISIS',GETDATE(),GETDATE());

	PRINT 'DimClaimStatusMapping LIV2 Insert'
	DECLARE @maxIDDimClaimStatusMappingLIV2 smallint;
	SELECT @maxIDDimClaimStatusMappingLIV2 =  ISNULL(max([ClaimStatusMappingSeqID]),0) FROM DimClaimStatusMapping

	INSERT INTO [dbo].[DimClaimStatusMapping] ([ClaimStatusMappingSeqID],[RefClaimStatusSeqID],[ClaimStatusCode],[ClaimStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
	SELECT ClaimStatusMappingSeqID = @maxIDDimClaimStatusMappingLIV2 + row_number() over (order by STR_DESC)
	  ,RefClaimStatusSeqID = (SELECT ClaimStatusSeqID 
			  FROM DimClaimStatus 
			  WHERE ClaimStatusDescription = (CASE WHEN a.STR_DESC = 'CANCELLATION' THEN 'CANCELLED' ELSE a.STR_DESC END)
			  AND ClaimStatusSeqID <> -1)
	  ,a.STR_CODE
	  ,UPPER(a.STR_DESC)   
	  ,'LIV2'
	  ,GetDate()
	  ,GetDate()
	FROM RSRPT.LIV2.V_CODE_DESC a
	WHERE ORG_TABLE = 'T_CASE_STATUS'
	ORDER BY 1,2

	PRINT 'DimClaimEventType Insert'

	DELETE FROM [dbo].[DimClaimEventType]
	DBCC CHECKIDENT ('[dbo].[DimClaimEventType]', RESEED, 0);

	SET IDENTITY_INSERT DimClaimEventType ON;
	
	INSERT INTO DimClaimEventType(ClaimEventTypeSeqID, ClaimEventTypeName, RecInsertDate, RecUpdateDate)
	VALUES(-1, 'UNKNOWN', GetDate(), GetDate())

	SET IDENTITY_INSERT DimClaimEventType OFF;

	PRINT 'DimClaimEventType GIV3 Insert'
	INSERT INTO DimClaimEventType(ClaimEventTypeName, RecInsertDate, RecUpdateDate)
	SELECT ClaimEventTypeName = CASE WHEN LOSS_CAUSE_NAME = 'UNKNOWN' THEN 'UNKNOWN - BASE TABLE'
									ELSE LOSS_CAUSE_NAME END
		,GetDate()
		,GetDate()
	FROM (
		SELECT DISTINCT LOSS_CAUSE_NAME
		FROM RSRpt.GIV3.T_CLM_LOSSCAUSE a
		WHERE NOT EXISTS (SELECT 1 FROM DimClaimEventType b WHERE (CASE WHEN a.LOSS_CAUSE_NAME = 'UNKNOWN' THEN 'UNKNOWN - BASE TABLE'
									ELSE a.LOSS_CAUSE_NAME END)	
									= b.ClaimEventTypeName)
	) t
	ORDER BY 1

	PRINT 'DimClaimEventType RDS Insert'
	INSERT INTO [dbo].[DimClaimEventType]
			   ([ClaimEventTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
				[ClaimEventTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
		VALUES
		('IDAPE',GETDATE(),GETDATE()),
		('LIVING',GETDATE(),GETDATE())

	) AS X ([ClaimEventTypeName],[RecInsertDate],[RecUpdateDate])

	PRINT 'DimClaimEventType DPS Insert'
	INSERT INTO [dbo].[DimClaimEventType]
			   ([ClaimEventTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
				[ClaimEventTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (

	VALUES
	('AD',GETDATE(),GETDATE()),
	('AI',GETDATE(),GETDATE()),
	('AM',GETDATE(),GETDATE()),
	('AP',GETDATE(),GETDATE()),
	('AT',GETDATE(),GETDATE()),
	('CA',GETDATE(),GETDATE()),
	('CL',GETDATE(),GETDATE()),
	('COM',GETDATE(),GETDATE()),
	('DTH',GETDATE(),GETDATE()),
	('ELS',GETDATE(),GETDATE()),
	('IC',GETDATE(),GETDATE()),
	('IH',GETDATE(),GETDATE()),
	('IS',GETDATE(),GETDATE()),
	('ISX',GETDATE(),GETDATE()),
	('MB',GETDATE(),GETDATE()),
	('MC',GETDATE(),GETDATE()),
	('MD',GETDATE(),GETDATE()),
	('MF',GETDATE(),GETDATE()),
	('MI',GETDATE(),GETDATE()),
	('MIC',GETDATE(),GETDATE()),
	('MK',GETDATE(),GETDATE()),
	('MN',GETDATE(),GETDATE()),
	('MOC',GETDATE(),GETDATE()),
	('MS',GETDATE(),GETDATE()),
	('MT',GETDATE(),GETDATE()),
	('MW',GETDATE(),GETDATE()),
	('MX',GETDATE(),GETDATE()),
	('NC',GETDATE(),GETDATE()),
	('OC',GETDATE(),GETDATE()),
	('PEO',GETDATE(),GETDATE()),
	('PER',GETDATE(),GETDATE()),
	('PI',GETDATE(),GETDATE()),
	('SB',GETDATE(),GETDATE()),
	('TIL',GETDATE(),GETDATE())

	) AS X ([ClaimEventTypeName],[RecInsertDate],[RecUpdateDate])	

	PRINT 'DimClaimEventType WBISIS Insert'
	INSERT INTO [dbo].[DimClaimEventType]
			   ([ClaimEventTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
				[ClaimEventTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (

	VALUES
	('DAY SURGERY',GETDATE(),GETDATE()),
	('INPATIENT',GETDATE(),GETDATE()),
	('INTERMEDIATE PATIENT',GETDATE(),GETDATE()),
	('OUTPATIENT',GETDATE(),GETDATE()),
	('PRE/POST HOSP',GETDATE(),GETDATE())

	) AS X ([ClaimEventTypeName],[RecInsertDate],[RecUpdateDate])	

	PRINT 'DimClaimEventTypeMapping Insert'

	DELETE FROM [dbo].[DimClaimEventTypeMapping]
	DBCC CHECKIDENT ('[dbo].[DimClaimEventTypeMapping]', RESEED, 0);

	PRINT 'DimClaimEventTypeMapping GIV3 Insert'
	INSERT INTO DimClaimEventTypeMapping(RefClaimEventTypeSeqID, ClaimEventTypeCode, ClaimEventTypeName, ProductLineCode, ClaimEventTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT RefClaimTEventypeSeqID = (SELECT ClaimEventTypeSeqID 
									FROM DimClaimEventType 
									WHERE ClaimEventTypeName = 
									(CASE WHEN a.LOSS_CAUSE_NAME = 'UNKNOWN' THEN 'UNKNOWN - BASE TABLE'
									ELSE a.LOSS_CAUSE_NAME END)	
								)
		,a.LOSS_CAUSE_CODE
		,a.LOSS_CAUSE_NAME
		,a.PRODUCT_LINE_CODE
		,a.LOSS_CAUSE_DESC  
		,'GIV3'
		,GetDate()
		,GetDate()
	FROM RSRpt.GIV3.T_CLM_LOSSCAUSE a
	ORDER BY 1,2

	PRINT 'DimClaimEventTypeMapping RDS Insert'
	INSERT INTO [dbo].[DimClaimEventTypeMapping]
			   ([RefClaimEventTypeSeqID]
			   ,[ClaimEventTypeCode]
			   ,[ClaimEventTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimEventTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
			   [RefClaimEventTypeSeqID] = (SELECT dcet.ClaimEventTypeSeqID FROM dbo.DimClaimEventType dcet WHERE dcet.ClaimEventTypeName = x.[ClaimEventTypeName])
			   ,[ClaimEventTypeCode]
			   ,[ClaimEventTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimEventTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
	VALUES		   
		('IDAPE','IDAPE',NULL,'IDAPE','RDS',GETDATE(),GETDATE()),
		('Living','Living',NULL,'Living','RDS',GETDATE(),GETDATE())
	) AS X ([ClaimEventTypeCode]
			,[ClaimEventTypeDescription]
			,[ProductLineCode]
			,[ClaimEventTypeName]
			,[AppSource]
			,[RecInsertDate]
			,[RecUpdateDate])

	PRINT 'DimClaimEventTypeMapping DPS Insert'
	INSERT INTO [dbo].[DimClaimEventTypeMapping]
			   ([RefClaimEventTypeSeqID]
			   ,[ClaimEventTypeCode]
			   ,[ClaimEventTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimEventTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
			   [RefClaimEventTypeSeqID] = (SELECT dcet.ClaimEventTypeSeqID FROM dbo.DimClaimEventType dcet WHERE dcet.ClaimEventTypeName = x.[ClaimEventTypeName])
			   ,[ClaimEventTypeCode]
			   ,[ClaimEventTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimEventTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
	VALUES		   
	('AD','AD',NULL,'AD','DPS',GETDATE(),GETDATE()),
	('AI','AI',NULL,'AI','DPS',GETDATE(),GETDATE()),
	('AM','AM',NULL,'AM','DPS',GETDATE(),GETDATE()),
	('AP','AP',NULL,'AP','DPS',GETDATE(),GETDATE()),
	('AT','AT',NULL,'AT','DPS',GETDATE(),GETDATE()),
	('CA','CA',NULL,'CA','DPS',GETDATE(),GETDATE()),
	('CL','CL',NULL,'CL','DPS',GETDATE(),GETDATE()),
	('COM','COM',NULL,'COM','DPS',GETDATE(),GETDATE()),
	('DTH','DTH',NULL,'DTH','DPS',GETDATE(),GETDATE()),
	('ELS','ELS',NULL,'ELS','DPS',GETDATE(),GETDATE()),
	('IC','IC',NULL,'IC','DPS',GETDATE(),GETDATE()),
	('IH','IH',NULL,'IH','DPS',GETDATE(),GETDATE()),
	('IS','IS',NULL,'IS','DPS',GETDATE(),GETDATE()),
	('ISX','ISX',NULL,'ISX','DPS',GETDATE(),GETDATE()),
	('MB','MB',NULL,'MB','DPS',GETDATE(),GETDATE()),
	('MC','MC',NULL,'MC','DPS',GETDATE(),GETDATE()),
	('MD','MD',NULL,'MD','DPS',GETDATE(),GETDATE()),
	('MF','MF',NULL,'MF','DPS',GETDATE(),GETDATE()),
	('MI','MI',NULL,'MI','DPS',GETDATE(),GETDATE()),
	('MIC','MIC',NULL,'MIC','DPS',GETDATE(),GETDATE()),
	('MK','MK',NULL,'MK','DPS',GETDATE(),GETDATE()),
	('MN','MN',NULL,'MN','DPS',GETDATE(),GETDATE()),
	('MOC','MOC',NULL,'MOC','DPS',GETDATE(),GETDATE()),
	('MS','MS',NULL,'MS','DPS',GETDATE(),GETDATE()),
	('MT','MT',NULL,'MT','DPS',GETDATE(),GETDATE()),
	('MW','MW',NULL,'MW','DPS',GETDATE(),GETDATE()),
	('MX','MX',NULL,'MX','DPS',GETDATE(),GETDATE()),
	('NC','NC',NULL,'NC','DPS',GETDATE(),GETDATE()),
	('OC','OC',NULL,'OC','DPS',GETDATE(),GETDATE()),
	('PEO','PEO',NULL,'PEO','DPS',GETDATE(),GETDATE()),
	('PER','PER',NULL,'PER','DPS',GETDATE(),GETDATE()),
	('PI','PI',NULL,'PI','DPS',GETDATE(),GETDATE()),
	('SB','SB',NULL,'SB','DPS',GETDATE(),GETDATE()),
	('TIL','TIL',NULL,'TIL','DPS',GETDATE(),GETDATE())
	) AS X ([ClaimEventTypeCode]
			,[ClaimEventTypeDescription]
			,[ProductLineCode]
			,[ClaimEventTypeName]
			,[AppSource]
			,[RecInsertDate]
			,[RecUpdateDate])

	PRINT 'DimClaimEventTypeMapping WBISIS Insert'
	INSERT INTO [dbo].[DimClaimEventTypeMapping]
			   ([RefClaimEventTypeSeqID]
			   ,[ClaimEventTypeCode]
			   ,[ClaimEventTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimEventTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
			   [RefClaimEventTypeSeqID] = (SELECT dcet.ClaimEventTypeSeqID FROM dbo.DimClaimEventType dcet WHERE dcet.ClaimEventTypeName = x.[ClaimEventTypeName])
			   ,[ClaimEventTypeCode]
			   ,[ClaimEventTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimEventTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
	VALUES		   
	('DY','Day Surgery',NULL,'Day Surgery','WBISIS',GETDATE(),GETDATE()),
	('IN','Inpatient',NULL,'Inpatient','WBISIS',GETDATE(),GETDATE()),
	('IP','Intermediate Patient',NULL,'Intermediate Patient','WBISIS',GETDATE(),GETDATE()),
	('OU','Outpatient',NULL,'Outpatient','WBISIS',GETDATE(),GETDATE()),
	('PP','Pre/Post Hosp',NULL,'Pre/Post Hosp','WBISIS',GETDATE(),GETDATE())
	) AS X ([ClaimEventTypeCode]
			,[ClaimEventTypeDescription]
			,[ProductLineCode]
			,[ClaimEventTypeName]
			,[AppSource]
			,[RecInsertDate]
			,[RecUpdateDate])

	PRINT 'DimClaimType Insert'

	DELETE FROM [dbo].[DimClaimType]
	DBCC CHECKIDENT ('[dbo].[DimClaimType]', RESEED, 0);

	SET IDENTITY_INSERT DimClaimType ON;

	INSERT INTO [dbo].DimClaimType
			   ([ClaimTypeSeqID]
			   ,[ClaimTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES
	(-1,'UNKNOWN',GETDATE(),GETDATE());

	SET IDENTITY_INSERT DimClaimType OFF;

	PRINT 'DimClaimType GIV3 Insert'
	INSERT INTO DimClaimType(ClaimTypeName, RecInsertDate, RecUpdateDate)
	SELECT LOSS_CONSEQUENCE_NAME
	 ,GetDate()
	 ,GetDate()
	FROM
	(
	 SELECT distinct LOSS_CONSEQUENCE_NAME
	 FROM RSRpt.GIV3.T_CLM_LOSS_CONSEQUENCE
	) t
	ORDER BY 1

	PRINT 'DimClaimType RDS Insert'
	INSERT INTO [dbo].[DimClaimType]
			   ([ClaimTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
			   [ClaimTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
		VALUES
		('IDAPE',GETDATE(),GETDATE()),
		('LIVING',GETDATE(),GETDATE())

	) AS X ([ClaimTypeName],[RecInsertDate],[RecUpdateDate])

	PRINT 'DimClaimType DPS Insert'
	INSERT INTO [dbo].[DimClaimType]
			   ([ClaimTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
			   [ClaimTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
		VALUES
	('AD',GETDATE(),GETDATE()),
	('AI',GETDATE(),GETDATE()),
	('AM',GETDATE(),GETDATE()),
	('AP',GETDATE(),GETDATE()),
	('AT',GETDATE(),GETDATE()),
	('CA',GETDATE(),GETDATE()),
	('CL',GETDATE(),GETDATE()),
	('COM',GETDATE(),GETDATE()),
	('DTH',GETDATE(),GETDATE()),
	('ELS',GETDATE(),GETDATE()),
	('IC',GETDATE(),GETDATE()),
	('IH',GETDATE(),GETDATE()),
	('IS',GETDATE(),GETDATE()),
	('ISX',GETDATE(),GETDATE()),
	('MB',GETDATE(),GETDATE()),
	('MC',GETDATE(),GETDATE()),
	('MD',GETDATE(),GETDATE()),
	('MF',GETDATE(),GETDATE()),
	('MI',GETDATE(),GETDATE()),
	('MIC',GETDATE(),GETDATE()),
	('MK',GETDATE(),GETDATE()),
	('MN',GETDATE(),GETDATE()),
	('MOC',GETDATE(),GETDATE()),
	('MS',GETDATE(),GETDATE()),
	('MT',GETDATE(),GETDATE()),
	('MW',GETDATE(),GETDATE()),
	('MX',GETDATE(),GETDATE()),
	('NC',GETDATE(),GETDATE()),
	('OC',GETDATE(),GETDATE()),
	('PEO',GETDATE(),GETDATE()),
	('PER',GETDATE(),GETDATE()),
	('PI',GETDATE(),GETDATE()),
	('SB',GETDATE(),GETDATE()),
	('TIL',GETDATE(),GETDATE())

	) AS X ([ClaimTypeName],[RecInsertDate],[RecUpdateDate])

	PRINT 'DimClaimType WBISIS Insert'
	INSERT INTO [dbo].[DimClaimType]
			   ([ClaimTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
				[ClaimTypeName]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
		VALUES
	('DAY SURGERY',GETDATE(),GETDATE()),
	('INPATIENT',GETDATE(),GETDATE()),
	('INTERMEDIATE PATIENT',GETDATE(),GETDATE()),
	('OUTPATIENT',GETDATE(),GETDATE()),
	('PRE/POST HOSP',GETDATE(),GETDATE())

	) AS X ([ClaimTypeName],[RecInsertDate],[RecUpdateDate])

	PRINT 'DimClaimTypeMapping Insert'
	
	DELETE FROM [dbo].[DimClaimTypeMapping]
	DBCC CHECKIDENT ('[dbo].[DimClaimTypeMapping]', RESEED, 0);

	PRINT 'DimClaimTypeMapping GIV3 Insert'
	INSERT INTO DimClaimTypeMapping(RefClaimTypeSeqID, ClaimTypeCode, ClaimTypeName, ProductLineCode, ClaimTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT RefClaimTypeSeqID = (SELECT ClaimTypeSeqID FROM DimClaimType WHERE ClaimTypeName = a.LOSS_CONSEQUENCE_NAME)
	  ,a.LOSS_CONSEQUENCE_CODE
	  ,a.LOSS_CONSEQUENCE_NAME
	  ,a.PRODUCT_LINE_CODE
	  ,a.LOSS_CONSEQUENCE_DESC  
	  ,'GIV3'
	  ,GetDate()
	  ,GetDate()
	FROM RSRpt.GIV3.T_CLM_LOSS_CONSEQUENCE a
	order by 1,2

	PRINT 'DimClaimTypeMapping RDS Insert'
	INSERT INTO [dbo].[DimClaimTypeMapping]
			   ([RefClaimTypeSeqID]
			   ,[ClaimTypeCode]
			   ,[ClaimTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
			   [RefClaimTypeSeqID] = (SELECT dcet.ClaimTypeSeqID FROM dbo.DimClaimType dcet WHERE dcet.ClaimTypeName = x.[ClaimTypeName])
			   ,[ClaimTypeCode]
			   ,[ClaimTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
	VALUES		   
		('IDAPE','IDAPE',NULL,'IDAPE','RDS',GETDATE(),GETDATE()),
		('Living','Living',NULL,'Living','RDS',GETDATE(),GETDATE())
	) AS X ([ClaimTypeCode]
			,[ClaimTypeDescription]
			,[ProductLineCode]
			,[ClaimTypeName]
			,[AppSource]
			,[RecInsertDate]
			,[RecUpdateDate])

	PRINT 'DimClaimTypeMapping DPS Insert'	
	INSERT INTO [dbo].[DimClaimTypeMapping]
			   ([RefClaimTypeSeqID]
			   ,[ClaimTypeCode]
			   ,[ClaimTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
			   [RefClaimTypeSeqID] = (SELECT dcet.ClaimTypeSeqID FROM dbo.DimClaimType dcet WHERE dcet.ClaimTypeName = x.[ClaimTypeName])
			   ,[ClaimTypeCode]
			   ,[ClaimTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
	VALUES		   
	('AD','AD',NULL,'AD','DPS',GETDATE(),GETDATE()),
	('AI','AI',NULL,'AI','DPS',GETDATE(),GETDATE()),
	('AM','AM',NULL,'AM','DPS',GETDATE(),GETDATE()),
	('AP','AP',NULL,'AP','DPS',GETDATE(),GETDATE()),
	('AT','AT',NULL,'AT','DPS',GETDATE(),GETDATE()),
	('CA','CA',NULL,'CA','DPS',GETDATE(),GETDATE()),
	('CL','CL',NULL,'CL','DPS',GETDATE(),GETDATE()),
	('COM','COM',NULL,'COM','DPS',GETDATE(),GETDATE()),
	('DTH','DTH',NULL,'DTH','DPS',GETDATE(),GETDATE()),
	('ELS','ELS',NULL,'ELS','DPS',GETDATE(),GETDATE()),
	('IC','IC',NULL,'IC','DPS',GETDATE(),GETDATE()),
	('IH','IH',NULL,'IH','DPS',GETDATE(),GETDATE()),
	('IS','IS',NULL,'IS','DPS',GETDATE(),GETDATE()),
	('ISX','ISX',NULL,'ISX','DPS',GETDATE(),GETDATE()),
	('MB','MB',NULL,'MB','DPS',GETDATE(),GETDATE()),
	('MC','MC',NULL,'MC','DPS',GETDATE(),GETDATE()),
	('MD','MD',NULL,'MD','DPS',GETDATE(),GETDATE()),
	('MF','MF',NULL,'MF','DPS',GETDATE(),GETDATE()),
	('MI','MI',NULL,'MI','DPS',GETDATE(),GETDATE()),
	('MIC','MIC',NULL,'MIC','DPS',GETDATE(),GETDATE()),
	('MK','MK',NULL,'MK','DPS',GETDATE(),GETDATE()),
	('MN','MN',NULL,'MN','DPS',GETDATE(),GETDATE()),
	('MOC','MOC',NULL,'MOC','DPS',GETDATE(),GETDATE()),
	('MS','MS',NULL,'MS','DPS',GETDATE(),GETDATE()),
	('MT','MT',NULL,'MT','DPS',GETDATE(),GETDATE()),
	('MW','MW',NULL,'MW','DPS',GETDATE(),GETDATE()),
	('MX','MX',NULL,'MX','DPS',GETDATE(),GETDATE()),
	('NC','NC',NULL,'NC','DPS',GETDATE(),GETDATE()),
	('OC','OC',NULL,'OC','DPS',GETDATE(),GETDATE()),
	('PEO','PEO',NULL,'PEO','DPS',GETDATE(),GETDATE()),
	('PER','PER',NULL,'PER','DPS',GETDATE(),GETDATE()),
	('PI','PI',NULL,'PI','DPS',GETDATE(),GETDATE()),
	('SB','SB',NULL,'SB','DPS',GETDATE(),GETDATE()),
	('TIL','TIL',NULL,'TIL','DPS',GETDATE(),GETDATE())
	) AS X ([ClaimTypeCode]
			,[ClaimTypeDescription]
			,[ProductLineCode]
			,[ClaimTypeName]
			,[AppSource]
			,[RecInsertDate]
			,[RecUpdateDate])

	PRINT 'DimClaimTypeMapping WBISIS Insert'	
	INSERT INTO [dbo].[DimClaimTypeMapping]
			   ([RefClaimTypeSeqID]
			   ,[ClaimTypeCode]
			   ,[ClaimTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])

	SELECT 
			   [RefClaimTypeSeqID] = (SELECT dcet.ClaimTypeSeqID FROM dbo.DimClaimType dcet WHERE dcet.ClaimTypeName = x.[ClaimTypeName])
			   ,[ClaimTypeCode]
			   ,[ClaimTypeDescription]
			   ,[ProductLineCode]
			   ,[ClaimTypeName]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate]
	FROM (
	VALUES		   
	('DY','Day Surgery',NULL,'Day Surgery','WBISIS',GETDATE(),GETDATE()),
	('IN','Inpatient',NULL,'Inpatient','WBISIS',GETDATE(),GETDATE()),
	('IP','Intermediate Patient',NULL,'Intermediate Patient','WBISIS',GETDATE(),GETDATE()),
	('OU','Outpatient',NULL,'Outpatient','WBISIS',GETDATE(),GETDATE()),
	('PP','Pre/Post Hosp',NULL,'Pre/Post Hosp','WBISIS',GETDATE(),GETDATE())
	) AS X ([ClaimTypeCode]
			,[ClaimTypeDescription]
			,[ProductLineCode]
			,[ClaimTypeName]
			,[AppSource]
			,[RecInsertDate]
			,[RecUpdateDate])

	PRINT 'DimClaimPaymentStatus Insert'
	
	DELETE FROM [dbo].[DimClaimPaymentStatus]

	INSERT INTO [dbo].[DimClaimPaymentStatus]
           ([ClaimPaymentStatusSeqID]
           ,[ClaimPaymentStatusDescription]
           ,[RecInsertDate]
           ,[RecUpdateDate])
	VALUES
	(-1,'UNKNOWN',GETDATE(),GETDATE());

	PRINT 'DimClaimPaymentStatus RDS Insert'
	INSERT INTO [dbo].[DimClaimPaymentStatus]
           ([ClaimPaymentStatusSeqID]
           ,[ClaimPaymentStatusDescription]
           ,[RecInsertDate]
           ,[RecUpdateDate])
	VALUES
	(1,'APPROVED',GETDATE(),GETDATE()), 
	(2,'CANCELLED',GETDATE(),GETDATE()), 
	(3,'CLOSED',GETDATE(),GETDATE()), 
	(4,'MIGRATED',GETDATE(),GETDATE()), 
	(5,'PENDING',GETDATE(),GETDATE()), 
	(6,'REJECTED',GETDATE(),GETDATE()),
	(7,'VOID',GETDATE(),GETDATE()),
	(8,'WITHDRAWN',GETDATE(),GETDATE()),
	(10,'REFUNDED',GETDATE(),GETDATE());
	
	PRINT 'DimClaimPaymentStatus GIV3 Insert'
	INSERT INTO [dbo].[DimClaimPaymentStatus] ([ClaimPaymentStatusSeqID],[ClaimPaymentStatusDescription],[RecInsertDate],[RecUpdateDate])
		VALUES(9,'PAID',GetDate(),GetDate())

	PRINT 'DimClaimPaymentStatusMapping Insert'
	
	DELETE FROM [dbo].[DimClaimPaymentStatusMapping]

	PRINT 'DimClaimPaymentStatusMapping RDS Insert'
	INSERT INTO [dbo].[DimClaimPaymentStatusMapping]
			   ([ClaimPaymentStatusMappingSeqID]
			   ,[RefClaimPaymentStatusSeqID]
			   ,[ClaimPaymentStatusCode]
			   ,[ClaimPaymentStatusDescription]
			   ,[AppSource]
			   ,[RecInsertDate]
			   ,[RecUpdateDate])
	VALUES
	(1,1,'apr','Approved','RDS',GETDATE(),GETDATE()), 
	(2,2,'cnl','Cancelled','RDS',GETDATE(),GETDATE()), 
	(3,3,'cld','Closed','RDS',GETDATE(),GETDATE()), 
	(4,4,'migr','Migrated','RDS',GETDATE(),GETDATE()), 
	(5,5,'z','Pending','RDS',GETDATE(),GETDATE()), 
	(6,6,'j','Rejected','RDS',GETDATE(),GETDATE()),
	(7,7,'v','Void','RDS',GETDATE(),GETDATE()),
	(8,8,'wtd','Withdrawn','RDS',GETDATE(),GETDATE()),
	(13,10,'refnded','Refunded','RDS',GETDATE(),GETDATE()),
	(14,9,'paid_o_bal','Paid','RDS',GETDATE(),GETDATE());

	PRINT  'DimClaimPaymentStatusMapping GIV3 Insert'
	INSERT INTO [dbo].[DimClaimPaymentStatusMapping] ([ClaimPaymentStatusMappingSeqID],[RefClaimPaymentStatusSeqID],[ClaimPaymentStatusCode],[ClaimPaymentStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
		VALUES(9,5,'10','PENDING','GIV3',GetDate(),GetDate())
	INSERT INTO [dbo].[DimClaimPaymentStatusMapping] ([ClaimPaymentStatusMappingSeqID],[RefClaimPaymentStatusSeqID],[ClaimPaymentStatusCode],[ClaimPaymentStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
		VALUES(10,2,'20','CANCELLED','GIV3',GetDate(),GetDate())
	INSERT INTO [dbo].[DimClaimPaymentStatusMapping] ([ClaimPaymentStatusMappingSeqID],[RefClaimPaymentStatusSeqID],[ClaimPaymentStatusCode],[ClaimPaymentStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
		VALUES(11,9,'40','PAID','GIV3',GetDate(),GetDate())
	INSERT INTO [dbo].[DimClaimPaymentStatusMapping] ([ClaimPaymentStatusMappingSeqID],[RefClaimPaymentStatusSeqID],[ClaimPaymentStatusCode],[ClaimPaymentStatusDescription],[AppSource],[RecInsertDate],[RecUpdateDate])
		VALUES(12,3,'80','CLOSED','GIV3',GetDate(),GetDate())   


	PRINT 'DimClaimLevel GIV3 Insert'
	
	DELETE FROM DimClaimLevel

	INSERT INTO DimClaimLevel(ClaimLevelSeqID, ClaimLevelCode, ClaimLevelDescription, AppSource, RecInsertDate, RecUpdateDate)
	VALUES(-1, '-1', 'UNKNOWN', 'GIV3',GetDate(), GetDate())

	INSERT INTO DimClaimLevel(ClaimLevelSeqID, ClaimLevelCode, ClaimLevelDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT  ClaimLevelSeqID = row_number() over (order by CODE_VALUE)
	 , CODE_VALUE
	 , CODE_DESCRIPTION
	 , 'GIV3'
	 , GetDate()
	 , GetDate()
	FROM RSRPT.GIV3.V_ICM_TP_CLAIM_LEVEL
	ORDER BY 1

	PRINT 'DimClaimSource GIV3 Insert'
	
	DELETE FROM DimClaimSource

	INSERT INTO DimClaimSource(ClaimSourceSeqID, ClaimSourceCode, ClaimSourceDescription, AppSource, RecInsertDate, RecUpdateDate)
	VALUES(-1, '-1', 'UNKNOWN', 'GIV3',GetDate(), GetDate())

	INSERT INTO DimClaimSource(ClaimSourceSeqID, ClaimSourceCode, ClaimSourceDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT  ClaimSourceSeqID = row_number() over (order by CODE_VALUE)
	 , CODE_VALUE
	 , CODE_DESCRIPTION
	 , 'GIV3'
	 , GetDate()
	 , GetDate()
	FROM RSRPT.GIV3.V_ICM_TP_CLAIM_SOURCE
	ORDER BY 1

	PRINT 'DimClaimDamageType GIV3 Insert'
	
	DELETE FROM DimClaimDamageType

	INSERT INTO DimClaimDamageType(ClaimDamageTypeSeqID, ClaimDamageTypeCode, ClaimDamageTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	VALUES(-1, '-1', 'UNKNOWN', 'GIV3',GetDate(), GetDate())

	INSERT INTO DimClaimDamageType(ClaimDamageTypeSeqID, ClaimDamageTypeCode, ClaimDamageTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT  DamageTypeSeqID = row_number() over (order by DAMAGE_TYPE_CODE)
	 , DAMAGE_TYPE_CODE
	 , DAMAGE_TYPE_DESC
	 , 'GIV3'
	 , GetDate()
	 , GetDate()
	FROM RSRPT.GIV3.T_CLM_DAMAGE_TYPE
	ORDER BY 1

	PRINT 'DimClaimInjuryType GIV3 Insert'

	DELETE FROM DimClaimInjuryType

	INSERT INTO DimClaimInjuryType(ClaimInjuryTypeSeqID, ClaimInjuryTypeCode, ClaimInjuryTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	VALUES(-1, '-1', 'UNKNOWN', 'GIV3',GetDate(), GetDate())

	INSERT INTO DimClaimInjuryType(ClaimInjuryTypeSeqID, ClaimInjuryTypeCode, ClaimInjuryTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT  InjuryTypeSeqID = row_number() over (order by CODE_VALUE)
	 , CODE_VALUE
	 , CODE_DESCRIPTION
	 , 'GIV3'
	 , GetDate()
	 , GetDate()
	FROM RSRPT.GIV3.V_ICM_TP_INJURY_TYPE
	ORDER BY 1

	PRINT 'DimClaimReserveType GIV3 Insert'
	
	DELETE FROM DimClaimReserveType

	INSERT INTO DimClaimReserveType(ClaimReserveTypeSeqID, ClaimReserveTypeCode, ClaimReserveTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	VALUES(-1, '-1', 'UNKNOWN', 'GIV3',GetDate(), GetDate())

	INSERT INTO DimClaimReserveType(ClaimReserveTypeSeqID, ClaimReserveTypeCode, ClaimReserveTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT ReserveTypeSeqID = row_number() over (order by RESERVE_TYPE_CODE) 
	 , RESERVE_TYPE_CODE AS ReserveType
	 , UPPER(REPLACE(RESERVE_TYPE_NAME, 'Subrogation','Recovery')) AS ReserveTypeDesc
	 , 'GIV3'
	 , GetDate()
	 , GetDate()
	FROM RSRpt.GIV3.T_CLM_RESERVE_TYPE
	order by 1

	PRINT 'DimClaimantType GIV3 Insert'

	DELETE FROM DimClaimantType

	INSERT INTO DimClaimantType(ClaimantTypeSeqID, ClaimantTypeCode, ClaimantTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	VALUES(-1, '-1', 'UNKNOWN', 'GIV3',GetDate(), GetDate())

	INSERT INTO DimClaimantType(ClaimantTypeSeqID, ClaimantTypeCode, ClaimantTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT  ClaimantTypeSeqID = row_number() over (order by CODE_VALUE)
	 , CODE_VALUE
	 , CODE_DESCRIPTION
	 , 'GIV3'
	 , GetDate()
	 , GetDate()
	FROM RSRPT.GIV3.V_ICM_TP_CLAIMANT_TYPE
	ORDER BY 1

	PRINT 'DimClaimPaymentType GIV3 Insert'

	DELETE FROM DimClaimPaymentType
	
	INSERT INTO DimClaimPaymentType(ClaimPaymentTypeSeqID, ClaimPaymentTypeCode, ClaimPaymentTypeName, ClaimPaymentTypeDescription,AppSource, RecInsertDate, RecUpdateDate)
	VALUES(-1, '-1', 'UNKNOWN', 'UNKNOWN', 'GIV3',GetDate(), GetDate())

	INSERT INTO DimClaimPaymentType(ClaimPaymentTypeSeqID, ClaimPaymentTypeCode, ClaimPaymentTypeName, ClaimPaymentTypeDescription, AppSource, RecInsertDate, RecUpdateDate)
	SELECT  PaymentTypeSeqID = row_number() over (order by PAYMENT_TYPE_CODE)
	 , PAYMENT_TYPE_CODE
	 , PAYMENT_TYPE_NAME
	 , PAYMENT_TYPE_DESC
	 , 'GIV3'
	 , GetDate()
	 , GetDate()
	FROM RSRpt.GIV3.T_CLM_PAYMENT_TYPE
	ORDER BY 1

END




GO


