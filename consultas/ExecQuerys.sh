#!/bin/bash

# Definição das Funções de apoio
#--------------------------------------------------------------------------------------------------------------------------
# função de execução de query
exec_query(){

	QUESTAO=$1
	SUBQUESTAO=$2
	MODELO=$3
	INDICE=$4
	QUERY=$5
	
	if [ "$MODELO" = "R" ] ; then
		MDB="fies_linked"
	else
		MDB="fies_embedded"
	fi 
	
	START_TIME=$SECONDS
	docker exec -it mongos1 bash -c "echo '${QUERY}' | mongo ${MDB}" > /dev/null
	ELAPSED_TIME=$(($SECONDS - $START_TIME))
	echo "${QUESTAO}|${SUBQUESTAO}|${MODELO}|${INDICE}|\"${QUERY}\"|${ELAPSED_TIME}"
}

# função de criação de indice
exec_cri_indices(){

	DATABASE=$1
	QUERY=$2
	
	docker exec -it mongos1 bash -c "echo '${QUERY}' | mongo ${DATABASE}" > /dev/null
}

# sequencia de execução das querys sem indice
exec_querys_sinid(){

	# header
	echo "nu_questao|nu_sub_questao|tp_modelo|in_indice|ds_questao|ds_questao|nu_tempo" 

	# Questao1
	exec_query 1 1 E N "$Q1S1M1"
	exec_query 1 2 E N "$Q1S2M1"
	exec_query 1 1 R N "$Q1S1M2"
	exec_query 1 2 R N "$Q1S2M2"
	exec_query 1 1 H N "$Q1S1M3"
	exec_query 1 2 H N "$Q1S2M3"
					   
	# Questao2          
	exec_query 2 1 E N "$Q2S1M1"
	exec_query 2 1 R N "$Q2S1M2"
	exec_query 2 1 H N "$Q2S1M3"
					   
	# Questao3          
	exec_query 3 1 E N "$Q3S1M1"
	exec_query 3 1 R N "$Q3S1M2"
	exec_query 3 1 H N "$Q3S1M3"
					   
	# Questao4          
	exec_query 4 1 E N "$Q4S1M1"
	exec_query 4 2 E N "$Q4S2M1"
	exec_query 4 1 R N "$Q4S1M2"
	exec_query 4 2 R N "$Q4S2M2"
	exec_query 4 1 H N "$Q4S1M3"
	exec_query 4 2 H N "$Q4S2M3"
					   
	# Questao5          
	exec_query 5 1 E N "$Q5S1M1"
	exec_query 5 2 E N "$Q5S2M1"
	exec_query 5 1 R N "$Q5S1M2"
	exec_query 5 2 R N "$Q5S2M2"
	exec_query 5 1 H N "$Q5S1M3"
	exec_query 5 2 H N "$Q5S2M3"
					   
	# Questao6          
	exec_query 6 1 E N "$Q6S1M1"
	exec_query 6 1 R N "$Q6S1M2"
	exec_query 6 1 H N "$Q6S1M3"
}

# sequencia de execução das querys com indice
exec_querys_ind(){

	#header
	 echo "nu_questao|nu_sub_questao|tp_modelo|in_indice|ds_questao|ds_questao|nu_tempo" 

	#Questao1
	exec_query 1 1 E S "$Q1S1M1"
	exec_query 1 2 E S "$Q1S2M1"
	exec_query 1 1 R S "$Q1S1M2"
	exec_query 1 2 R S "$Q1S2M2"
	exec_query 1 1 H S "$Q1S1M3"
	exec_query 1 2 H S "$Q1S2M3"
					  
	#Questao2         
	exec_query 2 1 E S "$Q2S1M1"
	exec_query 2 1 R S "$Q2S1M2"
	exec_query 2 1 H S "$Q2S1M3"
					  
	#Questao3         
	exec_query 3 1 E S "$Q3S1M1"
	exec_query 3 1 R S "$Q3S1M2"
	exec_query 3 1 H S "$Q3S1M3"
					  
	#Questao4         
	exec_query 4 1 E S "$Q4S1M1"
	exec_query 4 2 E S "$Q4S2M1"
	exec_query 4 1 R S "$Q4S1M2"
	exec_query 4 2 R S "$Q4S2M2"
	exec_query 4 1 H S "$Q4S1M3"
	exec_query 4 2 H S "$Q4S2M3"
					  
	#Questao5         
	exec_query 5 1 E S "$Q5S1M1"
	exec_query 5 2 E S "$Q5S2M1"
	exec_query 5 1 R S "$Q5S1M2"
	exec_query 5 2 R S "$Q5S2M2"
	exec_query 5 1 H S "$Q5S1M3"
	exec_query 5 2 H S "$Q5S2M3"
					  
	#Questao6         
	exec_query 6 1 E S "$Q6S1M1"
	exec_query 6 1 R S "$Q6S1M2"
	exec_query 6 1 H S "$Q6S1M3"
}

# Definição das Questões
#--------------------------------------------------------------------------------------------------------------------------
#Output de saida 
# nu_questao - Numero da questão. Varia de 1 a 6 .
# nu_sub_questao - Numero da sub-questão, para os casos de uma questão para o mesmo modelo ter mais de uma pergunta.Varia de 1 a 2
# tp_modelo - Sigla do tipo de modelo, variamdo de E (EMBEDDED) ou (REFERENCES) ou (HIBRIDO)
# in_indice - Indica se no momento da query já haviam sido criados os indices, varia de S (Sim) ou N (Não)
# query - a query que foi executada
# ds_questao - A query executada em si.
# nu_tempo - Duração de execução da query em segundos. - Duraçao da query

#--------------------------------------------------------------------------------------------------------------------------
#Questao1
#Quantos estudantes foram financiados pelo Banco do Brasil e quantos foram financiados pela Caixa Econômica?
#Modelo 1 - EMBEDDED
Q1S1M1='db.fies.count({ "financiamento.CO_AGENTE_FINANCEIRO":1} )' #Banco do Brasil
Q1S2M1='db.fies.count({ "financiamento.CO_AGENTE_FINANCEIRO":2} )' #Caixa Econômica Federal

#Modelo 2 - REFERENCES
Q1S1M2='db.financiamento.count({CO_AGENTE_FINANCEIRO:1})' #Banco do Brasil
Q1S2M2='db.financiamento.count({CO_AGENTE_FINANCEIRO:2})' #Caixa Econômica Federal

#Modelo 3 - HIBRIDO
Q1S1M3='db.fies_hibrido.count({ "financiamento.CO_AGENTE_FINANCEIRO":1} )' #Banco do Brasil
Q1S2M3='db.fies_hibrido.count({ "financiamento.CO_AGENTE_FINANCEIRO":2} )' #Caixa Econômica Federal

#--------------------------------------------------------------------------------------------------------------------------
#Questão 2
#Quantos estudantes possuem necessidades especiais?
#Modelo 1 - EMBEDDED
Q2S1M1='db.fies.count({ "estudante.ST_DEFICIENCIA":"S"} )'

#Modelo 2 - REFERENCES
Q2S1M2='db.estudante.count({ST_DEFICIENCIA:"S"})'

#Modelo 3 - HIBRIDO
Q2S1M3='db.fies_hibrido.count({ ST_DEFICIENCIA:"S"} )'

#--------------------------------------------------------------------------------------------------------------------------
#Questao 3
#Quantos estudantes cursaram o ensino médio em Escola Pública?
#Modelo 1 - EMBEDDED
Q3S1M1='db.fies.count({ "estudante.ST_ENSINO_MEDIO_ESCOLA_PUBLICA":"S"} )'

#Modelo 2 - REFERENCES
Q3S1M2='db.estudante.count({ST_ENSINO_MEDIO_ESCOLA_PUBLICA:"S"})'

#Modelo 3 - HIBRIDO
Q3S1M3='db.fies_hibrido.count({ ST_ENSINO_MEDIO_ESCOLA_PUBLICA:"S"} )'

#--------------------------------------------------------------------------------------------------------------------------
#Questao 4
#Quantos estudantes são do sexo feminino e masculino?
#Modelo 1 - EMBEDDED
Q4S1M1='db.fies.count({ "estudante.SG_SEXO":"F"} )' #feminino
Q4S2M1='db.fies.count({ "estudante.SG_SEXO":"M"} )' #masculino

#Modelo 2 - REFERENCES
Q4S1M2='db.estudante.count({SG_SEXO:"M"})' #feminino
Q4S2M2='db.estudante.count({SG_SEXO:"F"})' #masculino

#Modelo 3 - HIBRIDO
Q4S1M3='db.fies_hibrido.count({ SG_SEXO:"F"} )' #feminino
Q4S2M3='db.fies_hibrido.count({ SG_SEXO:"M"} )' #masculino

#--------------------------------------------------------------------------------------------------------------------------
#Questao 5
#Quantos estudantes são solteiros e quantos são casados?
#Modelo 1 - EMBEDDED
Q5S1M1='db.fies.count({ "estudante.CO_ESTADO_CIVIL":1} )' #solteiro
Q5S2M1='db.fies.count({ "estudante.CO_ESTADO_CIVIL":2} )' #casado

#Modelo 2 - REFERENCES
Q5S1M2='db.estudante.count({CO_ESTADO_CIVIL:1})' #solteiro
Q5S2M2='db.estudante.count({CO_ESTADO_CIVIL:2})' #casado

#Modelo 3 - HIBRIDO
Q5S1M3='db.fies_hibrido.count({ CO_ESTADO_CIVIL:1} )' #solteiro
Q5S2M3='db.fies_hibrido.count({ CO_ESTADO_CIVIL:2} )' #casado

#--------------------------------------------------------------------------------------------------------------------------
#Questao 6
#Pesquisar pela string "Direito"
#Modelo 1 - EMBEDDED
Q6S1M1='db.fies.find({"financiamento.DS_CURSO":"Direito"})'

#Modelo 2 - REFERENCES
Q6S1M2='db.financiamento.find({"DS_CURSO":"Direito"})'

#Modelo 3 - HIBRIDO
Q6S1M3='db.fies_hibrido.find({"financiamento.DS_CURSO":"Direito"})'

#--------------------------------------------------------------------------------------------------------------------------
#execucao querys sem indice 

exec_querys_sinid
exec_querys_sinid
exec_querys_sinid
exec_querys_sinid


# ÍNDICES
#--------------------------------------------------------------------------------------------------------------------------
# DB fies_embedded
# Indices do modelo embedded
exec_cri_indices fies_embedded 'db.fies.createIndex({CO_AGENTE_FINANCEIRO:1})'
exec_cri_indices fies_embedded 'db.fies.createIndex({ST_DEFICIENCIA:"text"})'
exec_cri_indices fies_embedded 'db.fies.createIndex({ST_ENSINO_MEDIO_ESCOLA_PUBLICA:"text"})'
exec_cri_indices fies_embedded 'db.fies.createIndex({SG_SEXO:"text"})'
exec_cri_indices fies_embedded 'db.fies.createIndex({CO_ESTADO_CIVIL:1})'
exec_cri_indices fies_embedded 'db.fies.createIndex({DS_CURSO:"text"})'
exec_cri_indices fies_embedded 'db.fies.createIndex({ST_ENSINO_MEDIO_ESCOLA_PUBLICA:1})'
exec_cri_indices fies_embedded 'db.fies.createIndex({SG_SEXO:1})'
exec_cri_indices fies_embedded 'db.fies.createIndex({DS_CURSO:1})'

# Indices do modelo hibrido
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({CO_AGENTE_FINANCEIRO:1})'
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({ST_DEFICIENCIA:"text"})'
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({ST_ENSINO_MEDIO_ESCOLA_PUBLICA:"text"})'
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({SG_SEXO:"text"})'
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({CO_ESTADO_CIVIL:1})'
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({DS_CURSO:"text"})'
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({ST_ENSINO_MEDIO_ESCOLA_PUBLICA:1})'
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({SG_SEXO:1})'
exec_cri_indices fies_embedded 'db.fies_hibrido.createIndex({DS_CURSO:1})'

# DB fies_linked
# Indices do modelo linked
exec_cri_indices fies_linked 'db.estudante.createIndex({ST_DEFICIENCIA:"text"})'
exec_cri_indices fies_linked 'db.estudante.createIndex({ST_ENSINO_MEDIO_ESCOLA_PUBLICA:"text"})'
exec_cri_indices fies_linked 'db.estudante.createIndex({SG_SEXO:"text"})'
exec_cri_indices fies_linked 'db.estudante.createIndex({CO_ESTADO_CIVIL:1})'
exec_cri_indices fies_linked 'db.financiamento.createIndex({DS_CURSO:"text"})'
exec_cri_indices fies_linked 'db.financiamento.createIndex({CO_AGENTE_FINANCEIRO:1})'

#--------------------------------------------------------------------------------------------------------------------------
#execucao querys com indice 
exec_querys_ind
exec_querys_ind
exec_querys_ind
exec_querys_ind














