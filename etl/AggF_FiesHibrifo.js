db.fies.aggregate(

	// Pipeline
	[
		// Stage 1
		{
			$project: {
			CO_PROCESSO : "$financiamento.CO_PROCESSO"
			,CO_CONTRATO_FIES : "$financiamento.CO_CONTRATO_FIES"
			,CO_ADITAMENTO : "$financiamento.CO_ADITAMENTO"
			,CO_AGENTE_FINANCEIRO : "$financiamento.CO_AGENTE_FINANCEIRO"
			,NU_MES : "$financiamento.NU_MES"
			,NU_SEMESTRE : "$financiamento.NU_SEMESTRE"
			,NU_ANO : "$financiamento.NU_ANO"
			,VL_MENSALIDADE : "$financiamento.VL_MENSALIDADE"
			,QT_SEMESTRE_FINANCIADO : "$financiamento.QT_SEMESTRE_FINANCIADO"
			,VL_SEMESTRE : "$financiamento.VL_SEMESTRE"
			,CO_CURSO : "$financiamento.CO_CURSO"
			,DS_CURSO : "$financiamento.DS_CURSO"
			,VL_PERC_FINANCIAMENTO : "$financiamento.VL_PERC_FINANCIAMENTO"
			,INSCRICAO_ID : "$financiamento.INSCRICAO_ID"
			
			}
		},

		// Stage 2
		{
			$out: "linked_financiamentro"
		},
	],

	// Options
	{
		cursor: {
			batchSize: 50
		}
	}

	// Created with Studio 3T, the IDE for MongoDB - https://studio3t.com/

);
