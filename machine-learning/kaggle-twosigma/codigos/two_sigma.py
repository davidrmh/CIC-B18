# coding: utf-8

import pandas as pd
import numpy as np
from sklearn import svm
from copy import deepcopy

#'returnsOpenNextMktres10' = r_{it}

#Función para obtener un los atributos y las clases
#para un assetName en específico
def obten_atributos(datos, assetName,atributos, universo_bool = True):
	'''
	ENTRADA
	datos: Pandas dataframe con los datos sin filtrar, pero ya etiquetados

	assetName: String con el assetName

	atributos: Tupla de strings con los atributos que se buscan obtener

	universo_bool: Booleano. True => Se considera la columna universe == 1
	(sólo para conjunto de entrenamiento)

	SALIDA
	atributos_filtrado: dataframe con los datos únicamente para el assetName y los atributos.

	clases: Pandas series con las clases correspondientes a atributos_filtrado

	'''

	#Si es conjunto de entrenamiento
	if universo_bool:
		filtrado = datos[datos['assetName'] == assetName]
		filtrado = filtrado[filtrado['universe'] == 1]
		clases = filtrado['clase']
		atributos_filtrado = filtrado.loc[:,atributos]
		return atributos_filtrado, clases

	#Si es conjunto de prueba	
	else:
		filtrado = datos[(datos['assetName'] == assetName)]
		atributos_filtrado = filtrado.loc[:,atributos]
		return atributos_filtrado

#Función para etiquetar el conjunto de entrenamiento
def etiqueta(datos):
	'''
	ENTRADA
	datos: Pandas dataframe con los datos sin etiquetar

	SALIDA
	El pandas dataframe 'datos' con la columna 'clase' añadida

	'''

	#copia los datos
	copia = deepcopy(datos)

	#índices en donde la variable 'returnsOpenNextMktres10' es positiva
	indices = datos[datos['returnsOpenNextMktres10'] > 0].index

	#agrega la columna clase
	copia['clase'] = -1
	copia.loc[indices,'clase'] = 1

	return copia

#Función para ajustar un modelo SVM	
def ajusta_svm(atributos_asset, clases_asset):
	'''
	ENTRADA
	atributos_asset: Pandas dataframe con los atributos para un assetName determinado

	clases_asset: Pandas series con las clases para un assetName determinado

	(Ver función obten_atributos con universo_bool = True)

	SALIDA
	modelo SVM ajustado
	'''
	#Define modelo e hiperparámetros
	modelo = svm.SVC(probability = True, kernel = 'rbf', C = 1.4)

	#ajusta modelo
	modelo.fit(atributos_asset, clases_asset)

	return modelo


#Función para predecir las probabilidades de pertenecer a una clase
#de acuerdo a un modelo (este modelo debe permitir el método predict_proba)	
def predice_confianza(modelo, atributos_asset):
	'''
	ENTRADA
	modelo: Modelo ajustado que permite el método predict_proba

	atributos_asset: Pandas dataframe con los atributos para un assetName determinado
	(idealmente, un dataframe con solamente un renglón)
	(Ver función obten_atributos con universo_bool = False)

	SALIDA
	confianza con signo.
	'''
	#Obtiene las probabilidades
	probas = modelo.predict_proba(atributos_asset)

	#argumento de proba más grande
	arg_proba_max = np.argmax(probas)

	#Obtiene la confianza (con signo)
	confianza = probas[0][arg_proba_max]*modelo.classes_[arg_proba_max]

	return confianza

#Función para crear un diccionario que contendrá un modelo para
#cada assetName
def diccionario_modelos(entrena, atributos):
	'''
	ENTRADA
	entrena: Pandas dataframe con el conjunto de entrenamiento etiquetado
	(ver función etiqueta)

	atributos: Tupla de strings con los atributos que se buscan obtener

	SALIDA
	diccionario de la siguiente con key un asset_name y valor un modelo ajustado
	'''

	#assetNames sin repeticiones
	nombres_unicos = np.unique(entrena['assetName'])

	dicc = {}

	for nombre in nombres_unicos:

		#Obtiene atributos y clases para ajustar el modelo
		atributos_asset, clases_asset = obten_atributos(entrena, nombre,atributos,True)

		#Revisa si se tiene información
		#y que se tengan dos clases
		if atributos_asset.shape[0]!=0 and len(np.unique(clases_asset))>1:

			#ajusta modelo
			modelo = ajusta_svm(atributos_asset, clases_asset)

			#agrega al diccionario
			dicc[nombre] = modelo

			print ('Modelo ajustado para ' + nombre)

	return dicc	

#Atributos
atributos = ('returnsClosePrevRaw1', 'returnsOpenPrevRaw1', 'returnsClosePrevMktres1', 
	'returnsOpenPrevMktres1', 'returnsClosePrevRaw10', 'returnsOpenPrevRaw10',
	 'returnsClosePrevMktres10', 'returnsOpenPrevMktres10')

from kaggle.competitions import twosigmanews
# You can only call make_env() once, so don't lose it!
env = twosigmanews.make_env()

#get_training_data
#Returns the training data DataFrames as a tuple of:
#* `market_train_df`: DataFrame with market training data
#* `news_train_df`: DataFrame with news training data
#all market and news data from February 2007 to December 2016
(market_train_df, news_train_df) = env.get_training_data()

#NOTA: Para el conjunto de entrenamiento con la información de mercado
#si utilizamos dropna(), se pierde menos del 3% de la información
#así que supongo que no perdemos nada si lo hacemos :p
market_train_df = market_train_df.dropna()

#Conjunto de datos etiquetado
etiquetado = etiqueta(market_train_df)

#Obtiene los assetCodes sin repeticiones
assetCodes_unicos = np.unique(market_train_df['assetCode'])

#Obtiene los assetNames sin repeticiones
assetNames_unicos = np.unique(market_train_df['assetName'])

#NOTA: len(assetCodes_unicos) no es igual a len(assetNames_unicos) :(
#len(assetCodes_unicos) = 3636
#len(assetNames_unicos) = 3387
#Por lo tanto hay compañías con mas de un assetCode

#Generador con la información del conjunto a predecir
dias_prediccion = env.get_prediction_days()

#Obtiene los datos del día t
(market_obs_df, news_obs_df, predictions_template_df) = next(dias_prediccion)

#Función para predicir el conjunto prueba
def predice_prueba(dicc_modelos, atributos, env):
	'''
	ENTRADA
	dicc_modelos: Diccionario creado con la función diccionario_modelos

	atributos: Tupla de strings con los atributos que se buscan obtener

	env: Ambiente con los datos (ver función twosigmanews.make_env())

	SALIDA
	csv con el formato requerido para la competencia
	'''

	#Obtiene el generador del conjunto de prueba
	dias_prediccion = env.get_prediction_days()

	#keys del diccionario (aquellos assetName con un modelo asociado)
	dicc_keys = dicc_modelos.keys()

	for (market_obs_df, news_obs_df, predictions_template_df) in dias_prediccion:

		#Obtiene los nombres del día en cuestión
		nombres_dia = market_obs_df['assetName']

		#auxiliar para el índice de la observación a predecir
		aux_index = 0

		for nombre in nombres_dia:

			#Obtiene los atributos
			atributos_asset = obten_atributos(market_obs_df, nombre,atributos, False)

			#Cambia NaN por cero
			atributos_asset = atributos_asset.fillna(0)

			#Revisa si se tiene un modelo asociado al assetName
			if nombre in dicc_keys:

				cofianza  = predice_confianza(diccionario_modelos[nombre], atributos_asset)

			else:

				if np.average(atributos_asset) > 0:
					confianza =np.random.uniform(low = 0.0, high = 1.0, size = 1)[0]
				if 	np.average(atributos_asset) < 0:
					confianza =np.random.uniform(low = -1.0, high = 0.0, size = 1)[0]

			#Agrega al dataframe plantilla
			predictions_template_df.loc[0,'confidenceValue'] = confianza

		#realiza la predicción del día
		env.predict(predictions_template_df)

	#Escribe el archivo
	env.write_submission_file()

	print "Predicciones terminadas"		

	return 0







