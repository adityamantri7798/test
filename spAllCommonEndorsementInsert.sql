USE [EDW]
GO

/****** Object:  StoredProcedure [dbo].[spAllCommonEndorsementInsert]    Script Date: 7/5/2025 6:55:11 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Description : insertion script for EndorsementType,EndorsementStatus Dimension
-- Create Date : 09-04-2019
-- Written by  : JA
-- Amendment History :  CRQ000000069821-New requirement for LI and IS
-- Mod Date		By			Description  
-- ------		----------	--------------  

CREATE     PROCEDURE [dbo].[spAllCommonEndorsementInsert]
AS
BEGIN

	SET NOCOUNT ON;

	PRINT 'DimEndorsementType Insert'

DELETE FROM [dbo].[DimEndorsementType];

	INSERT INTO [dbo].[DimEndorsementType]
           (EndorsementTypeSeqID
           ,EndorsementTypeDesc
           ,[RecInsertDate]
           ,[RecUpdateDate])
	VALUES
	(-1,'UNKNOWN',GETDATE(),GETDATE());

	PRINT 'DimEndorsementType LIV2 Insert'

	DECLARE @maxIDDimEndorsementTypeLIV2 smallint;
	SELECT @maxIDDimEndorsementTypeLIV2 =  ISNULL(max(EndorsementTypeSeqID),0) FROM [DimEndorsementType]
	--print @maxIDDimEndorsementTypeLIV2;
	INSERT INTO [DimEndorsementType](EndorsementTypeSeqID,  EndorsementTypeDesc, RecInsertDate, RecUpdateDate)
	SELECT EndorsementTypeSeqID = row_number() over (order by EndorsementTypeDesc)
	 ,UPPER(EndorsementTypeDesc)
	 ,GetDate()
	 ,GetDate()
	FROM
	(
	 SELECT distinct EndorsementTypeDesc = CODEDESC
	 FROM DimcodeLookup
	 WHERE CodeType = 'T_Service'
	 ) t
	order by 1

	PRINT 'DimEndorsementType WBISIS Insert'

	DECLARE @maxIDDimEndorsementTypeWBISIS smallint;
	SELECT @maxIDDimEndorsementTypeWBISIS =  ISNULL(max(EndorsementTypeSeqID),0) FROM [DimEndorsementType]
	--print @maxIDWBISIS;
	INSERT INTO [DimEndorsementType](EndorsementTypeSeqID,  EndorsementTypeDesc, RecInsertDate, RecUpdateDate)
	SELECT EndorsementTypeSeqID = @maxIDDimEndorsementTypeWBISIS + row_number() over (order by EndorsementTypeDesc)
	 ,UPPER(EndorsementTypeDesc)
	 ,GetDate()
	 ,GetDate()
	FROM
	(
	 SELECT distinct EndorsementTypeDesc = Description
	 FROM rsrpt.ISHealth.EndorsementType
	where  description not in (select EndorsementTypeDesc from DimEndorsementType)
	 ) t
	order by 1

	PRINT 'DimEndorsementTypeMapping Insert'
	DELETE FROM [dbo].[DimEndorsementTypeMapping]

	PRINT 'DimEndorsementTypeMappingLIV2 Insert'
	DECLARE @maxIDDimEndorsementTypeMappingLIV2 smallint;
	SELECT @maxIDDimEndorsementTypeMappingLIV2 =  ISNULL(max([EndorsementTypeMappingSeqID]),0) FROM DimEndorsementTypeMapping

	INSERT INTO [dbo].[DimEndorsementTypeMapping] 
	([EndorsementTypeMappingSeqID],[RefEndorsementTypeSeqID],[EndorsementTypeCode],[EndorsementTypeDesc],
	[AppSource],[RecInsertDate],[RecUpdateDate])
	SELECT EndorsementTypeMappingSeqID =@maxIDDimEndorsementTypeMappingLIV2 + row_number() over (order by CodeDesc)
	  ,RefEndorsementTypeSeqID = (SELECT EndorsementTypeSeqID 
			  FROM DimEndorsementType 
			    WHERE   EndorsementTypeDesc=a.CodeDesc and EndorsementTypeSeqID <> -1)
	  ,a.Codevalue
	  ,UPPER(a.CodeDesc)   
	  ,'LIV2'
	  ,GetDate()
	  ,GetDate()
	 FROM DimcodeLookup a
	 WHERE CodeType = 'T_Service'
	ORDER BY 1,2
	

		PRINT 'DimEndorsementTypeMappingWBISIS Insert'
	DECLARE @maxIDDimEndorsementTypeMappingWBISIS smallint;
	SELECT @maxIDDimEndorsementTypeMappingWBISIS =  ISNULL(max([EndorsementTypeMappingSeqID]),0) FROM DimEndorsementTypeMapping

	INSERT INTO [dbo].[DimEndorsementTypeMapping] 
	([EndorsementTypeMappingSeqID],[RefEndorsementTypeSeqID],[EndorsementTypeCode],[EndorsementTypeDesc],
	[AppSource],[RecInsertDate],[RecUpdateDate])
	SELECT EndorsementTypeMappingSeqID = @maxIDDimEndorsementTypeMappingWBISIS + row_number() over (order by description)
	  ,RefEndorsementTypeSeqID = (SELECT EndorsementTypeSeqID 
			  FROM DimEndorsementType 
			    WHERE   EndorsementTypeDesc=a.description and EndorsementTypeSeqID <> -1)
	  ,a.EndorsementTypeID
	  ,UPPER(a.description)   
	  ,'WBISIS'
	  ,GetDate()
	  ,GetDate()
	 FROM  rsrpt.ISHealth.EndorsementType a
	 ORDER BY 1,2

	PRINT 'DimEndorsementStatus Insert'

DELETE FROM [dbo].[DimEndorsementStatus];

	INSERT INTO [dbo].[DimEndorsementStatus]
           (EndorsementStatusSeqID
           ,EndorsementStatusDesc
           ,[RecInsertDate]
           ,[RecUpdateDate])
	VALUES
	(-1,'UNKNOWN',GETDATE(),GETDATE());

	PRINT 'DimEndorsementStatus LIV2 Insert'

	DECLARE @maxIDDimEndorsementStatusLIV2 smallint;
	SELECT @maxIDDimEndorsementStatusLIV2 =  ISNULL(max(EndorsementStatusSeqID),0) FROM [DimEndorsementStatus]
	--print @maxIDLIV2;
	INSERT INTO [DimEndorsementStatus](EndorsementStatusSeqID,  EndorsementStatusDesc, RecInsertDate, RecUpdateDate)
	SELECT EndorsementStatusSeqID =  row_number() over (order by EndorsementStatusDesc)
	 ,UPPER(EndorsementStatusDesc)
	 ,GetDate()
	 ,GetDate()
	FROM
	(
	 SELECT distinct EndorsementStatusDesc = CODEDESC
	 FROM DimcodeLookup
	 WHERE CodeType = 'T_Change_Status'
	 ) t
	order by 1


	PRINT 'DimEndorsementStatusMapping Insert'
	DELETE FROM [dbo].[DimEndorsementStatusMapping]

	PRINT 'DimEndorsementStatusMappingLIV2 Insert'
	DECLARE @maxIDDimEndorsementStatusMappingLIV2 smallint;
	SELECT @maxIDDimEndorsementStatusMappingLIV2 =  ISNULL(max([EndorsementStatusMappingSeqID]),0) FROM DimEndorsementStatusMapping

	INSERT INTO [dbo].[DimEndorsementStatusMapping] 
	([EndorsementStatusMappingSeqID],[RefEndorsementStatusSeqID],[EndorsementStatusCode],[EndorsementStatusDesc],
	[AppSource],[RecInsertDate],[RecUpdateDate])
	SELECT EndorsementStatusMappingSeqID = @maxIDDimEndorsementStatusMappingLIV2 + row_number() over (order by CodeDesc)
	  ,RefEndorsementStatusSeqID = (SELECT EndorsementStatusSeqID 
			  FROM DimEndorsementStatus 
			    WHERE  EndorsementStatusDesc=a.CodeDesc and EndorsementStatusSeqID <> -1)
	  ,a.Codevalue
	  ,UPPER(a.CodeDesc)   
	  ,'LIV2'
	  ,GetDate()
	  ,GetDate()
	 FROM DimcodeLookup a
	 WHERE CodeType = 'T_Change_Status'
	ORDER BY 1,2

	END
GO


