# coding: utf-8

import pandas as pd
import numpy as np
from sklearn import svm


#Función para obtener un dataframe con los atributos
#para un assetName en específico
def obten_atributos(datos, assetName,atributos, universo_bool = True):
	'''
	ENTRADA
	datos: Pandas dataframe con los datos sin filtrar

	assetName: String con el assetName

	atributos: Tupla con los atributos que se buscan obtener

	universo_bool: Booleano. True => Se considera la columna universe == 1
	(sólo para conjunto de entrenamiento)

	SALIDA
	dataframe con los datos únicamente para el assetName y los atributos.

	'''

	if universo_bool:
		filtrado = datos[datos['assetName'] == assetName]
		filtrado = filtrado[filtrado['universe'] == 1].loc[:,atributos]
	else:
		fitlrado = datos[(datos['assetName'] == assetName)].loc[:,atributos]

	return filtrado	
		
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
