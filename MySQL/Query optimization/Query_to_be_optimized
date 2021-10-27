	
	-- Declare variables	
		DECLARE @TYPE NVARCHAR(5);
		DECLARE @TABLE NVARCHAR(50);
		DECLARE @FROMDATE DATETIME;
		DECLARE @ATDATE DATETIME

	-- Initialize variables
		SET @TYPE = 'Old';
		SET @TABLE = 'Commesse';
		SET @FROMDATE = GETDATE();

		SELECT DISTINCT
			'1|' + N_J.[No_] + '|' + N_JT.[Job Task No_] AS WkID,
			1 AS [CompanyID], 
			N_J.[No_], 
			N_JT.[Job Task No_], 
			N_J.[No_] + '-' + N_JT.[Job Task No_] AS WkNumber,
			CASE ISNUMERIC(RIGHT(LEFT(N_J.[No_],3),2)) WHEN 1 THEN '20' + RIGHT(LEFT(N_J.[No_],3),2) ELSE NULL END AS WkYear,
			P_WK.wkID AS [PreGestWkID],
			N_JT.[Old Job No_] AS [GammaProjectName],
			N_J.[Description] AS [WkYard],
			N_J.[Bill-to Customer No_] AS [WkCustomerID],
			N_CUST.[Name] AS [cuName],
			N_JT.[Division Code] AS [wkDivisionID],
			ISNULL(N_DIV.[Description],'') AS [dvName],
			N_DIM.[Dimension Value Code] AS [BusinessUnit],
			N_JT.[Work Type Code] AS [wkWorkTypeID],
			ISNULL(N_WTY.[Description],'') AS [WtName],
			ISNULL(N_J.[Work Description Code],'') AS [WkActivityID],
			ISNULL(N_WDSC.[Description],'')  AS [WkActivityDescription],
			CASE WHEN ISNULL(N_JT.[Work Description Note],'') <> '' THEN N_JT.[Work Description Note] ELSE N_J.[Work Description Note] END AS [NoteDescrLavoro],
			ISNULL((SELECT SUM([Percentage]) FROM [TBT Progress] N_PROG WITH(NOLOCK) WHERE N_PROG.[Job No_] = N_JT.[Job No_] AND N_PROG.[Job Task No_] = N_JT.[Job Task No_]),0) AS [WkProgressPercentage],
			(SELECT MAX([Date]) FROM [TBT Progress] N_PROG WITH(NOLOCK) WHERE N_PROG.[Job No_] = N_JT.[Job No_] AND N_PROG.[Job Task No_] = N_JT.[Job Task No_])	AS [wkInventoryDate],
			CASE WHEN ISNULL(N_JT.[Project Manager No_],'') <> '' THEN N_JT.[Project Manager No_] ELSE N_J.[Project Manager No_] END AS [wkWOManagerID],
			CASE WHEN ISNULL(N_JT.[Project Coordinator No_],'') <> '' THEN N_JT.[Project Coordinator No_] ELSE N_J.[Project Coordinator No_] END AS [IDMaster],
			N_J.[Creation Date] AS [WkOpenDate],
			N_J.Complete AS [WkFlagChiusa],
			CASE WHEN ISNULL(N_J.Complete,0) = 1 AND YEAR(ISNULL([Closure Date],'01/01/1753')) > 1900 THEN N_J.[Closure Date] ELSE NULL END AS [WkDataChiusa],
			N_J.[Bill-to County] AS [Prov],
			(SELECT [Site Code] FROM [TBT Site Code] N_SITE WITH(NOLOCK) WHERE N_SITE.[No_] = N_J.[Site No_])	AS [CodiceSito],
			N_J.[Cod_ Office] AS [CodiceOffice],
			N_J.[ID Lav_] AS [CodiceLavorazione],
			N_J.[Node Code] AS [CodiceNodo],
			N_NODO.[Description] AS [DescrizioneNodo],
			CASE WHEN YEAR(ISNULL(N_J.[Starting Date],'01/01/1753')) > 1900 THEN N_J.[Starting Date] ELSE NULL END AS [wkPrevisionalStartDate],

			CASE
				WHEN N_J.[Historical Job] = 1 THEN (CASE WHEN YEAR(ISNULL(N_J.[Hist_ Job Actual Starting Date],'01/01/1753')) > 1900 THEN N_J.[Hist_ Job Actual Starting Date] ELSE NULL END)
				ELSE (SELECT (CASE WHEN YEAR(ISNULL(MIN([Posting Date]),'01/01/1753')) > 1900 THEN MIN([Posting Date]) ELSE NULL END) FROM [Job Ledger Entry] WITH(NOLOCK) WHERE [Job No_] = N_J.[No_])
			END AS [wkRealStartDate],
		
			CASE WHEN YEAR(ISNULL(N_J.[Ending Date],'01/01/1753')) > 1900 THEN N_J.[Ending Date] ELSE NULL END AS [wkPrevisionalEndDate],
			CASE WHEN YEAR(ISNULL(N_J.[Actual Ending Date],'01/01/1753')) > 1900 THEN N_J.[Actual Ending Date] ELSE NULL END AS [wkRealEndDate],
			N_J.Principal AS [Mandante],
			ISNULL(N_JOBTYPE.[Description], CASE N_JT.[Old Job Type] WHEN 1 THEN 'Commessa' WHEN 2 THEN 'Appoggio' WHEN 3 THEN 'Sottocommessa' WHEN 4 THEN 'Extra' ELSE '' END) AS [TipoCommessa],
			N_J.[Intranet Note] AS [WkNote],
			N_J.[Note] AS [NoteCommerciali],
			ISNULL((
				SELECT SUM([Total Cost])
				FROM [DataWarehouse].[dbo].[WorkOrderHours] H WITH(NOLOCK)
				WHERE H.CompanyID = 1 AND H.[Job No_] = N_JT.[Job No_] AND H.[Job Task No_] = N_JT.[Job Task No_]
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS TotaleManodopera,
			ISNULL((
				SELECT SUM([Totale])
				FROM [DataWarehouse].[dbo].WorkOrderCosts C WITH(NOLOCK)
				WHERE C.CostoEffettivo = 1 AND C.CompanyID = 1 AND C.[Job No_] = N_JT.[Job No_] COLLATE Latin1_General_CI_AS AND C.[Job Task No_] = N_JT.[Job Task No_] COLLATE Latin1_General_CI_AS AND C.[Item Type Description] = 'PRESTAZIONE'
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS TotalePrestazioni,
			ISNULL((
				SELECT SUM([Totale])
				FROM [DataWarehouse].[dbo].WorkOrderCosts C WITH(NOLOCK)
				WHERE C.CostoEffettivo = 1 AND C.CompanyID = 1 AND C.[Job No_] = N_JT.[Job No_] COLLATE Latin1_General_CI_AS AND C.[Job Task No_] = N_JT.[Job Task No_] COLLATE Latin1_General_CI_AS AND C.[Item Type Description] = 'NOLEGGIO'
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS TotaleNoli,
			ISNULL((
				SELECT SUM([Totale])
				FROM [DataWarehouse].[dbo].WorkOrderCosts C WITH(NOLOCK)
				WHERE C.CostoEffettivo = 1 AND C.CompanyID = 1 AND C.[Job No_] = N_JT.[Job No_] COLLATE Latin1_General_CI_AS AND C.[Job Task No_] = N_JT.[Job Task No_] COLLATE Latin1_General_CI_AS AND C.[Item Type Description] = 'MATERIALE'
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS TotaleMateriali,
			ISNULL((
				SELECT SUM([Total Cost])
				FROM [DataWarehouse].[dbo].[WorkOrderHours] H WITH(NOLOCK)
				WHERE H.CompanyID = 1 AND H.[Job No_] = N_JT.[Job No_] AND H.[Job Task No_] = N_JT.[Job Task No_]
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS TotaleRegistratoManodopera,
			ISNULL((
				SELECT SUM([Totale Registrato])
				FROM [DataWarehouse].[dbo].WorkOrderCosts C WITH(NOLOCK)
				WHERE C.CostoEffettivo = 1 AND C.CompanyID = 1 AND C.[Job No_] = N_JT.[Job No_] COLLATE Latin1_General_CI_AS AND C.[Job Task No_] = N_JT.[Job Task No_] COLLATE Latin1_General_CI_AS AND C.[Item Type Description] = 'PRESTAZIONE'
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS TotaleRegistratoPrestazioni,
			ISNULL((
				SELECT SUM([Totale Registrato])
				FROM [DataWarehouse].[dbo].WorkOrderCosts C WITH(NOLOCK)
				WHERE C.CostoEffettivo = 1 AND C.CompanyID = 1 AND C.[Job No_] = N_JT.[Job No_] COLLATE Latin1_General_CI_AS AND C.[Job Task No_] = N_JT.[Job Task No_] COLLATE Latin1_General_CI_AS AND C.[Item Type Description] = 'NOLEGGIO'
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS TotaleRegistratoNoli,
			ISNULL((
				SELECT SUM([Totale Registrato])
				FROM [DataWarehouse].[dbo].WorkOrderCosts C WITH(NOLOCK)
				WHERE C.CostoEffettivo = 1 AND C.CompanyID = 1 AND C.[Job No_] = N_JT.[Job No_] COLLATE Latin1_General_CI_AS AND C.[Job Task No_] = N_JT.[Job Task No_] COLLATE Latin1_General_CI_AS AND C.[Item Type Description] = 'MATERIALE'
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS TotaleRegistratoMateriali,
			ISNULL((
				SELECT SUM(WuWorkedNormal)
				FROM [DataWarehouse].[dbo].[WorkOrderHours] H WITH(NOLOCK)
				WHERE H.CompanyID = 1 AND H.[Job No_] = N_JT.[Job No_] AND H.[Job Task No_] = N_JT.[Job Task No_]
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS SumNormalHours,
			ISNULL((
				SELECT SUM(WuWorkedAuxliary)
				FROM [DataWarehouse].[dbo].[WorkOrderHours] H WITH(NOLOCK)
				WHERE H.CompanyID = 1 AND H.[Job No_] = N_JT.[Job No_] AND H.[Job Task No_] = N_JT.[Job Task No_]
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS SumAuxiliaryHours,
			ISNULL((
				SELECT SUM(WuWorkedRainy)
				FROM [DataWarehouse].[dbo].[WorkOrderHours] H WITH(NOLOCK)
				WHERE H.CompanyID = 1 AND H.[Job No_] = N_JT.[Job No_] AND H.[Job Task No_] = N_JT.[Job Task No_]
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS SumRainHours,
			ISNULL((
				SELECT SUM(WuWorkedTravel)
				FROM [DataWarehouse].[dbo].[WorkOrderHours] H WITH(NOLOCK)
				WHERE H.CompanyID = 1 AND H.[Job No_] = N_JT.[Job No_] AND H.[Job Task No_] = N_JT.[Job Task No_]
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS SumTravelHours,
			ISNULL((
				SELECT SUM(WuWorkedExtra)
				FROM [DataWarehouse].[dbo].[WorkOrderHours] H WITH(NOLOCK)
				WHERE H.CompanyID = 1 AND H.[Job No_] = N_JT.[Job No_] AND H.[Job Task No_] = N_JT.[Job Task No_]
				GROUP BY CompanyID, [Job No_], [Job Task No_]
			),0) AS SumOvertimeHours,
			ISNULL((
				SELECT SUM(P.[Quote Amount])
				FROM [Job Planning Line] P WITH(NOLOCK)
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_] AND [Type]=2 /* Conto CG */ AND [Line Type]=1 /* Fatturabile */
				GROUP BY P.[Job No_], P.[Job Task No_]
			),0) AS wkPrevisionalLabourAmount,
			(
				SELECT CASE WHEN YEAR(ISNULL(MAX(P.[Planning Date]),'01/01/1753')) > 1900 THEN MAX(P.[Planning Date]) ELSE NULL END
				FROM [Job Planning Line] P WITH(NOLOCK)
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_] AND [Type]=2 /* Conto CG */ AND [Line Type]=1 /* Fatturabile */
				GROUP BY P.[Job No_], P.[Job Task No_]
			) AS wkPreventivoData,
			ISNULL((
				SELECT CASE WHEN SUM(P.[Final Check]) > 0 THEN 1 ELSE 0 END 
				FROM [Job Planning Line] P WITH(NOLOCK)
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_] AND [Type]=2 /* Conto CG */ AND [Line Type]=1 /* Fatturabile */
				GROUP BY P.[Job No_], P.[Job Task No_]
			),0) AS FlagConsuntivo,
			ISNULL((
				SELECT SUM(P.[Final Amount])
				FROM [Job Planning Line] P WITH(NOLOCK)
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_] AND [Type]=2 /* Conto CG */ AND [Line Type]=1 /* Fatturabile */
				GROUP BY P.[Job No_], P.[Job Task No_]
			),0) AS wkFinalLabourAmount,
			(
				SELECT CASE WHEN YEAR(ISNULL(MAX(P.[Final Date]),'01/01/1753')) > 1900 THEN MAX(P.[Final Date]) ELSE NULL END
				FROM [Job Planning Line] P WITH(NOLOCK)
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_] AND [Type]=2 /* Conto CG */ AND [Line Type]=1 /* Fatturabile */
				GROUP BY P.[Job No_], P.[Job Task No_]
			) AS wkConsuntivoData,
			(
				SELECT TOP 1 [Sales Order No_]
				FROM [TBT Sales Order Line] P WITH(NOLOCK)
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_]
			) AS NumeroOrdine,
			(
				SELECT TOP 1 [External Order No_]
				FROM [TBT Sales Order Line] P WITH(NOLOCK)
					 INNER JOIN [TBT Sales Order] O WITH(NOLOCK) ON P.[Sales Order No_] = O.[No_]
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_]
			) AS NumeroOrdineCliente,
			(
				SELECT TOP 1 [Order Date]
				FROM [TBT Sales Order Line] P WITH(NOLOCK)
					 INNER JOIN [TBT Sales Order] O WITH(NOLOCK) ON P.[Sales Order No_] = O.[No_]
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_]
			) AS DataOrdine,
			ISNULL((
				SELECT SUM(P.[Ordered Amount])
				FROM [TBT Sales Order Line] P WITH(NOLOCK)
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_] AND P.[Job Planning Line No_] > 0
				GROUP BY P.[Job No_], P.[Job Task No_]
			),0) AS TotaleOrdinato,
			ISNULL((
				SELECT SUM(OD.[Division Amount])
				FROM [TBT Sales Order Line] P WITH(NOLOCK)
					 INNER JOIN [TBT Sales Order Division] OD WITH(NOLOCK) ON OD.[Sales Order No_] = P.[Sales Order No_]
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_] AND OD.[Division Code] = N_JT.[Division Code] AND P.[Job Planning Line No_] > 0
				GROUP BY P.[Job No_], P.[Job Task No_], OD.[Division Code]
			),0) AS TotaleDivisioneOrdinato,
			ISNULL((
				SELECT SUM(P.[Invoiced Amount (LCY)])
				FROM [Job Planning Line Invoice] P WITH(NOLOCK)
				WHERE P.[Job No_] = N_JT.[Job No_] AND P.[Job Task No_] = N_JT.[Job Task No_]
				GROUP BY P.[Job No_], P.[Job Task No_]
			),0) AS TotaleFatturato,
			CASE WHEN LEN(ISNULL(N_JT.[Old Job No_],'')) > 0 THEN N_JT.[Job No_] + '-' + N_JT.[Job Task No_] + ' (' + N_JT.[Old Job No_] + ')' ELSE N_JT.[Job No_] + '-' + N_JT.[Job Task No_] END AS SearchDescription,
			CAST(0 AS decimal(38, 20)) AS TotaleBefDaApprovare,
			CAST(0 AS decimal(38, 20)) AS TotaleBefDaApprovareNoleggi,
			CAST(0 AS decimal(38, 20)) AS TotaleManodoperaDaApprovare,
			CAST('' AS nvarchar(100)) AS ProjectManager,
			CAST('' AS nvarchar(100)) AS ProjectCoordinator,
			N_J.CIG, N_J.CUP, 0 AS AggregateLevel
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleCosti]
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleManodopera] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotalePrestazioni] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleNoli] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleMateriali] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleRegistratoManodopera]  
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleRegistratoPrestazioni] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleRegistratoNoli] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleRegistratoMateriali]  
			,CAST(0 AS decimal(38, 20)) AS [AggregateSumNormalHours] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateSumAuxiliaryHours]  
			,CAST(0 AS decimal(38, 20)) AS [AggregateSumRainHours] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateSumTravelHours] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateSumOvertimeHours] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateWkPrevisionalLabourAmount]  
			,CAST(0 AS decimal(38, 20)) AS [AggregateConsuntivata]  
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleOrdine] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleOrdineDivisione] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleFatturato] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleBefDaApprovare] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleBefDaApprovareNoleggi]  
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleManodoperaDaApprovare] 
			,CAST(0 AS decimal(38, 20)) AS [TotaleProduzione] 
			,CAST(0 AS decimal(38, 20)) AS [AggregateTotaleProduzione] 
			,CASE N_J.[Status] WHEN 2 THEN 'Aperto' WHEN 3 THEN 'Completato' WHEN 14 THEN 'Annullato' ELSE 'NoStatus' END AS Stato
		
		FROM 
			 [Job Task] N_JT WITH(NOLOCK)
			 INNER JOIN [Job] N_J WITH(NOLOCK) ON N_JT.[Job No_] = N_J.[No_]
			 LEFT JOIN [Customer] N_CUST WITH(NOLOCK) ON N_CUST.[No_] = N_J.[Bill-to Customer No_]
			 LEFT JOIN [TBT Division] N_DIV WITH(NOLOCK) ON N_DIV.[Code] = N_JT.[Division Code] 
			 LEFT JOIN [Job Task Dimension] N_DIM WITH(NOLOCK) ON N_DIM.[Job No_] = N_JT.[Job No_] AND N_DIM.[Job Task No_] = N_JT.[Job Task No_] AND N_DIM.[Dimension Code]='BUSINESS-UNIT' 
			 LEFT JOIN [TBT Work Type] N_WTY WITH(NOLOCK) ON N_WTY.[Code] = N_JT.[Work Type Code]
			 LEFT JOIN [TBT Work Description] N_WDSC WITH(NOLOCK) ON N_WDSC.[Code] = N_JT.[Work Description Code] 
			 LEFT JOIN [General Table] N_NODO WITH(NOLOCK) ON N_NODO.[Code] = N_J.[Node Code] AND N_NODO.TableCode = 'TBT-NODO'
			 LEFT JOIN [General Table] N_JOBTYPE WITH(NOLOCK) ON N_JOBTYPE.[Code] = N_J.[Job Type] AND N_JOBTYPE.TableCode = 'TBT-JOBTYPE'
			 LEFT JOIN WorkOrders P_WK WITH(NOLOCK) ON P_WK.wkNumber + '_' + CAST(P_WK.wkYear AS nvarchar(4)) = N_JT.[Old Job No_] COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE N_J.[Status] <> 0
