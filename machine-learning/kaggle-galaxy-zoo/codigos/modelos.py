# coding: utf-8

from keras.models import Sequential
from keras.layers.convolutional import Conv2D
from keras.layers.convolutional import MaxPooling2D
from keras.preprocessing.image import ImageDataGenerator
from keras.callbacks import ModelCheckpoint
from keras.layers.core import Activation
from keras.layers.core import Flatten
from keras.layers.core import Dense
from keras.optimizers import Nadam
import time

##==============================================================================
## Variables globales
##==============================================================================
#Para hacer data augmentation
datagen = ImageDataGenerator(rotation_range = 180, width_shift_range=0.1, height_shift_range=0.1, horizontal_flip=True, vertical_flip = True, zoom_range = [1.0,3.0])

#Optimizador (Nesterov + Adam)
learning_rate = 0.002
opt = Nadam(learning_rate)

##==============================================================================
## Función para crear el modelo
##==============================================================================
def crea_modelo(inputShape = (1, 128, 128)):
    '''
    ENTRADA
    inputShape: Tupla. Dimensiones los arreglos de entrada. Por default se
    utiliza la forma channels_first
    '''
    model = Sequential()
    #Convolucional con 48 filtros de 5x5 cada uno
    model.add(Conv2D(filters = 48, kernel_size = (5,5), padding = 'same', input_shape = inputShape, data_format = 'channels_first'))
    #Función de activación ReLu
    model.add(Activation("relu"))
    #Max pooling
    model.add(MaxPooling2D(pool_size=(3,3), strides=(3, 3), padding = 'same', data_format = 'channels_first'))

    model.add(Conv2D(filters = 96, kernel_size = (5,5), padding = 'same'))
    model.add(Activation("relu"))
    model.add(MaxPooling2D(pool_size=(2,2), strides=(2, 2), padding = 'same', data_format = 'channels_first'))

    model.add(Conv2D(filters = 192, kernel_size = (3,3), padding = 'same', data_format = 'channels_first'))
    model.add(Activation("relu"))

    #model.add(Conv2D(filters = 192, kernel_size = (3,3), padding = 'same', data_format = 'channels_first'))
    #model.add(Activation("relu"))

    #model.add(Conv2D(filters = 384, kernel_size = (3,3), padding = 'same', data_format = 'channels_first'))
    #model.add(Activation("relu"))

    model.add(Conv2D(filters = 384, kernel_size = (3,3), padding = 'same', data_format = 'channels_first'))
    model.add(Activation("relu"))
    model.add(MaxPooling2D(pool_size=(3,3), strides=(3, 3), padding = 'same', data_format = 'channels_first'))

    #Fully connected
    model.add(Flatten())
    model.add(Dense(2048))
    model.add(Activation("relu"))

    #model.add(Dense(2048))
    #model.add(Activation("relu"))

    #Última capa para predecir las probabilidades
    model.add(Dense(37))
    model.add(Activation("relu"))

    return model
##==============================================================================
## Función para entrenar un modelo
##==============================================================================
def entrena_modelo(model, x_train, y_train, epochs=50, loss='mean_squared_error', datagen=datagen, batch=100, optim=opt, epochs_save= 10):
    '''
    ENTRADA
    model: Modelo creado con la función crea_modelo

    x_train, y_train numpy arrays creados con la función crea_entrenamiento del modulo preprocesamiento

    epochs: Entero, número de épocas.

    loss: String función de pérdida

    datagen: Objeto de la clase ImageDataGenerator

    batch: Tamaño del bloque de entrenamiento

    optim: Objeto que representa algún método para optimizar

    epochs_save: Entero que representa cada cuantas épocas se guarda el modelo

    SALIDA
    modelo entrenado
    historia: Objeto con la historia del entrenamiento
    '''

    #Compila el modelo
    model.compile(loss = loss, optimizer = optim)

    #entrena
    archivo_modelo = 'modelo-{epoch:02d}.hdf5' #nombre del archivo con el checkpoint del modelo
    checkpoint = ModelCheckpoint(archivo_modelo, save_best_only=True, period = epochs_save)
    inicio = time.ctime()
    historia = model.fit_generator(datagen.flow(x_train, y_train, batch_size = batch),
     steps_per_epoch = int(len(x_train) / batch), epochs = epochs, callbacks = [checkpoint], use_multiprocessing=True, workers = 4, verbose = 1)
    fin = time.ctime()

    print 'Inicio ' + inicio + ' Fin ' + fin

    return model, historia
