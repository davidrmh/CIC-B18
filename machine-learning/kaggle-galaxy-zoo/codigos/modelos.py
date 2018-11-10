# coding: utf-8

from keras.models import Sequential
from keras.layers.convolutional import Conv2D
from keras.layers.convolutional import MaxPooling2D
from keras.layers.core import Activation
from keras.layers.core import Flatten
from keras.layers.core import Dense
from keras.optimizers import Nadam

##==============================================================================
## Función para crear el modelo
##==============================================================================
def crea_modelo(inputShape = (1, 424, 424)):
    '''
    ENTRADA
    inputShape: Tupla. Dimensiones los arreglos de entrada. Por default se
    utiliza la forma channels_first
    '''
    model = Sequential()
    #Convolucional con 48 filtros de 5x5 cada uno
    model.add(Conv2D(48, (5,5), padding = 'same', input_shape = inputShape))

    #Función de activación ReLu
    model.add(Activation("relu"))

    #Max pooling
    #model.add(MaxPooling2D(pool_size=(2,2), strides=(2, 2)))

	#second set of CONV => RELU => POOL layers
    model.add(Conv2D(50, (5, 5), padding="same"))
    model.add(Activation("relu"))

    #Fully connected
    model.add(Flatten())
    model.add(Dense(100))
    model.add(Activation("relu"))

    #Última capa para predecir las probabilidades
    model.add(Dense(37))
    model.add(Activation("softmax"))

    return model
