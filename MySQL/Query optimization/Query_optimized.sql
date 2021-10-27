	-- Declare variables
		DECLARE @TYPE NVARCHAR(5);
		DECLARE @TABLE NVARCHAR(50);
		DECLARE @FROMDATE DATETIME;
		DECLARE @ATDATE DATETIME

	-- Initialize variables
		SET @TYPE = 'New';
		SET @TABLE = 'Commesse';
		SET @FROMDATE = GETDATE();

		SELECT  
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
			ISNULL(N_PROG.[WkProgressPercentage], 0) [WkProgressPercentage],
			N_PROG.[wkInventoryDate],
			CASE WHEN ISNULL(N_JT.[Project Manager No_],'') <> '' THEN N_JT.[Project Manager No_] ELSE N_J.[Project Manager No_] END AS [wkWOManagerID],
			CASE WHEN ISNULL(N_JT.[Project Coordinator No_],'') <> '' THEN N_JT.[Project Coordinator No_] ELSE N_J.[Project Coordinator No_] END AS [IDMaster],
			N_J.[Creation Date] AS [WkOpenDate],
			N_J.Complete AS [WkFlagChiusa],
			CASE WHEN ISNULL(N_J.Complete,0) = 1 AND ISNULL([Closure Date],'01/01/1753') > '01/01/1900' THEN N_J.[Closure Date] ELSE NULL END AS [WkDataChiusa],
			CASE N_J.[County Code] WHEN '' THEN N_J.[Bill-to County] ELSE N_J.[County Code] END AS [Prov],
			N_SITE.[CodiceSito],
			N_J.[Cod_ Office] AS [CodiceOffice],
			N_J.[ID Lav_] AS [CodiceLavorazione],
			N_J.[Node Code] AS [CodiceNodo],
			N_NODO.[Description] AS [DescrizioneNodo],
			CASE WHEN ISNULL(N_J.[Starting Date], '01/01/1753') > '01/01/1900' THEN N_J.[Starting Date] ELSE NULL END AS [wkPrevisionalStartDate],
			CASE WHEN N_J.[Historical Job] = 1
				THEN
					(CASE WHEN ISNULL(N_J.[Hist_ Job Actual Starting Date],'01/01/1753') > '01/01/1900' THEN N_J.[Hist_ Job Actual Starting Date] ELSE NULL END)
				ELSE
					(CASE WHEN ISNULL(T7.[wkRealStartDate],'01/01/1753') > '01/01/1900' THEN T7.[wkRealStartDate] ELSE NULL END) END AS [wkRealStartDate],
			CASE WHEN ISNULL(N_J.[Ending Date],'01/01/1753') > '01/01/1900' THEN N_J.[Ending Date] ELSE NULL END AS [wkPrevisionalEndDate],
			CASE WHEN ISNULL(N_J.[Actual Ending Date],'01/01/1753') > '01/01/1900' THEN N_J.[Actual Ending Date] ELSE NULL END AS [wkRealEndDate],
			N_J.Principal AS [Mandante],
			ISNULL(N_JOBTYPE.[Description], CASE N_JT.[Old Job Type] WHEN 1 THEN 'Commessa' WHEN 2 THEN 'Appoggio' WHEN 3 THEN 'Sottocommessa' WHEN 4 THEN 'Extra' ELSE '' END) AS [TipoCommessa],
			N_J.[Intranet Note] AS [WkNote],
			N_J.[Note] AS [NoteCommerciali],
			ISNULL(TotaleManodopera, 0) TotaleManodopera,
			ISNULL(TotalePrestazioni, 0) TotalePrestazioni,
			ISNULL(TotaleNoli, 0) TotaleNoli,
			ISNULL(TotaleMateriali, 0) TotaleMateriali, 
			CAST(0 AS decimal(38, 20)) AS TotaleCosti,
			ISNULL(TotaleRegistratoManodopera, 0) TotaleRegistratoManodopera,
			ISNULL(TotaleRegistratoPrestazioni, 0) TotaleRegistratoPrestazioni,
			ISNULL(TotaleRegistratoNoli, 0) TotaleRegistratoNoli,
			ISNULL(TotaleRegistratoMateriali, 0) TotaleRegistratoMateriali,            
			ISNULL(SumNormalHours, 0) SumNormalHours,
			ISNULL(SumAuxiliaryHours, 0) SumAuxiliaryHours,
			ISNULL(SumRainHours, 0) SumRainHours,
			ISNULL(SumTravelHours, 0) SumTravelHours,
			ISNULL(SumOvertimeHours, 0) SumOvertimeHours,
			ISNULL(T5.wkPrevisionalLabourAmount, 0) wkPrevisionalLabourAmount,
			T5.wkPreventivoData,
			ISNULL(FlagConsuntivo, 0) FlagConsuntivo, 
			ISNULL(wkFinalLabourAmount, 0) wkFinalLabourAmount,
			T5.wkConsuntivoData,
			NumeroOrdine,
			NumeroOrdineCliente,
			DataOrdine,
			ISNULL(TotaleOrdinato, 0) TotaleOrdinato,
			ISNULL(TotaleDivisioneOrdinato,0 ) TotaleDivisioneOrdinato,
			ISNULL(TotaleFatturato, 0) TotaleFatturato,
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
			,N_JT.Description AS JobTaskDescription
			,CAST('' AS nvarchar(20)) AS BusinessUnitManager 
			,CAST('' AS nvarchar(100)) AS BusinessUnitManagerID

		FROM 
			[Job Task] N_JT WITH(NOLOCK)
			INNER  JOIN (SELECT * FROM [Job] WITH(NOLOCK) WHERE [Status] <> 0) N_J ON N_JT.[Job No_] = N_J.[No_]
			LEFT JOIN (
					SELECT [Job No_], [Job Task No_], SUM([Percentage]) [WkProgressPercentage], MAX([Date]) [wkInventoryDate]
						FROM [TBT Progress] WITH(NOLOCK)
						GROUP BY [Job No_], [Job Task No_]) N_PROG
						ON N_PROG.[Job No_] = N_JT.[Job No_] AND N_PROG.[Job Task No_] = N_JT.[Job Task No_]
			LEFT JOIN (
						SELECT [No_], [Site Code] AS [CodiceSito]
						FROM [TBT Site Code] WITH(NOLOCK)) N_SITE 
						ON N_SITE.[No_] = N_J.[Site No_]
			LEFT JOIN (
					SELECT [Job No_], [Job Task No_],
						SUM(CASE WHEN C.[Item Type Description] = 'PRESTAZIONE' THEN ([Totale Registrato]) ELSE 0 END) AS TotaleRegistratoPrestazioni,
						SUM(CASE WHEN C.[Item Type Description] = 'PRESTAZIONE' THEN ([Totale]) ELSE 0 END) AS TotalePrestazioni,
						SUM(CASE WHEN C.[Item Type Description] = 'NOLEGGIO' THEN ([Totale Registrato]) ELSE 0 END) AS TotaleRegistratoNoli,
						SUM(CASE WHEN C.[Item Type Description] = 'NOLEGGIO' THEN ([Totale]) ELSE 0 END) AS TotaleNoli,
						SUM(CASE WHEN C.[Item Type Description] = 'MATERIALE' THEN ([Totale Registrato]) ELSE 0 END) AS TotaleRegistratoMateriali,
						SUM(CASE WHEN C.[Item Type Description] = 'MATERIALE' THEN ([Totale]) ELSE 0 END) AS TotaleMateriali
						FROM [DataWarehouse].[dbo].WorkOrderCosts C WITH(NOLOCK)
						WHERE C.CostoEffettivo = 1 AND C.CompanyID = 1
						GROUP BY [Job No_], [Job Task No_]) T1 ON T1.[Job No_] = N_JT.[Job No_] COLLATE Latin1_General_CI_AS AND T1.[Job Task No_] = N_JT.[Job Task No_] COLLATE Latin1_General_CI_AS
			LEFT JOIN (
					SELECT [Job No_], [Job Task No_],
					SUM([Total Cost]) TotaleManodopera, SUM([Total Cost]) TotaleRegistratoManodopera,
					SUM(WuWorkedNormal) SumNormalHours, SUM(WuWorkedAuxliary) SumAuxiliaryHours,
					SUM(WuWorkedRainy) SumRainHours, SUM(WuWorkedTravel) SumTravelHours,
					SUM(WuWorkedExtra) SumOvertimeHours
						FROM [DataWarehouse].[dbo].[WorkOrderHours] H WITH(NOLOCK)
						WHERE H.CompanyID = 1  GROUP BY [Job No_], [Job Task No_]) T2 ON T2.[Job No_] = N_JT.[Job No_] AND T2.[Job Task No_] = N_JT.[Job Task No_]
			LEFT JOIN (
					SELECT P.[Job No_] , P.[Job Task No_], OD.[Division Code], SUM(OD.[Division Amount]) TotaleDivisioneOrdinato
					FROM [TBT Sales Order Line] P WITH(NOLOCK)
							INNER  JOIN [TBT Sales Order Division] OD WITH(NOLOCK) ON OD.[Sales Order No_] = P.[Sales Order No_]
					WHERE P.[Job Planning Line No_] > 0
					GROUP BY P.[Job No_], P.[Job Task No_], OD.[Division Code]) T3
					ON T3.[Job No_] = N_JT.[Job No_] AND T3.[Job Task No_] = N_JT.[Job Task No_] AND T3.[Division Code] = N_JT.[Division Code]
			LEFT JOIN (
					SELECT P.[Job No_], P.[Job Task No_], SUM(P.[Invoiced Amount (LCY)]) TotaleFatturato
					FROM [Job Planning Line Invoice] P WITH(NOLOCK)
					GROUP BY P.[Job No_], P.[Job Task No_]) T4
					ON T4.[Job No_] = N_JT.[Job No_] AND T4.[Job Task No_] = N_JT.[Job Task No_]
			LEFT JOIN [Customer] N_CUST WITH(NOLOCK) ON N_CUST.[No_] = N_J.[Bill-to Customer No_]
			LEFT JOIN [TBT Division] N_DIV WITH(NOLOCK) ON N_DIV.[Code] = N_JT.[Division Code] 
			LEFT JOIN (
					SELECT [Job No_], [Job Task No_],
					SUM([Quote Amount]) wkPrevisionalLabourAmount,
					CASE WHEN MAX(ISNULL([Planning Date],'01/01/1753')) > '01/01/1900' THEN MAX([Planning Date]) ELSE NULL END wkPreventivoData,
					CASE WHEN SUM([Final Check]) > 0 THEN 1 ELSE 0 END FlagConsuntivo,
					SUM([Final Amount]) wkFinalLabourAmount,
					CASE WHEN MAX(ISNULL([Final Date],'01/01/1753')) > '01/01/1900' THEN MAX([Final Date]) ELSE NULL END wkConsuntivoData
							FROM [Job Planning Line] WITH(NOLOCK)
					WHERE [Type]=2 /* Conto CG */ AND [Line Type]=1 /* Fatturabile */ GROUP BY [Job No_], [Job Task No_]) T5
					ON T5.[Job No_] = N_JT.[Job No_] AND T5.[Job Task No_] = N_JT.[Job Task No_]

			LEFT JOIN (
							 
					SELECT [Job No_], [Job Task No_], TotaleOrdinato, NumeroOrdine, [External Order No_] NumeroOrdineCliente, [Order Date] DataOrdine
					FROM (
							SELECT P.[Job No_], P.[Job Task No_],
							SUM(CASE WHEN P.[Job Planning Line No_] > 0 THEN (P.[Ordered Amount]) ELSE 0 END) TotaleOrdinato, 
							MAX([Sales Order No_]) NumeroOrdine
							FROM [TBT Sales Order Line] P WITH(NOLOCK)
							GROUP BY P.[Job No_], P.[Job Task No_]
							) TP INNER JOIN [TBT Sales Order] O WITH(NOLOCK) ON TP.NumeroOrdine = O.[No_] )	
					T6
					ON T6.[Job No_] = N_JT.[Job No_] AND T6.[Job Task No_] = N_JT.[Job Task No_]
			LEFT JOIN ( 
					SELECT [Job No_] , MIN([Posting Date]) [wkRealStartDate] 
					FROM [Job Ledger Entry] WITH(NOLOCK)
					GROUP BY [Job No_]) T7
					ON T7.[Job No_] = N_J.[No_]
			LEFT JOIN (SELECT * FROM [Job Task Dimension] N_DIM WITH(NOLOCK) WHERE N_DIM.[Dimension Code]='BUSINESS-UNIT')  N_DIM  ON N_DIM.[Job No_] = N_JT.[Job No_] AND N_DIM.[Job Task No_] = N_JT.[Job Task No_] 
			LEFT JOIN [TBT Work Type] N_WTY WITH(NOLOCK) ON N_WTY.[Code] = N_JT.[Work Type Code]
			LEFT JOIN [TBT Work Description] N_WDSC WITH(NOLOCK) ON N_WDSC.[Code] = N_JT.[Work Description Code] 
			LEFT JOIN (SELECT * FROM [General Table] N_NODO WITH(NOLOCK)  WHERE N_NODO.TableCode = 'TBT-NODO') N_NODO ON N_NODO.[Code] = N_J.[Node Code]
			LEFT JOIN (SELECT * FROM [General Table] N_JOBTYPE WITH(NOLOCK) WHERE N_JOBTYPE.TableCode = 'TBT-JOBTYPE') N_JOBTYPE ON N_JOBTYPE.[Code] = N_J.[Job Type]  
	        LEFT JOIN PreGest.dbo.WorkOrders P_WK WITH(NOLOCK) ON P_WK.wkNumber + '_' + CAST(P_WK.wkYear AS nvarchar(4)) = N_JT.[Old Job No_] COLLATE SQL_Latin1_General_CP1_CI_AS
 

