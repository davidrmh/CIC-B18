# coding: utf-8

from keras.models import Sequential
from keras.layers.convolutional import Conv2D
from keras.layers.convolutional import MaxPooling2D
from keras.callbacks import ModelCheckpoint
from keras.layers.core import Activation
from keras.layers.core import Flatten
from keras.layers.core import Dense
from keras.optimizers import Nadam
import time
import preprocesamiento as pre

##==============================================================================
## Variables globales
##==============================================================================

#Optimizador (Nesterov + Adam)
learning_rate = 0.002
opt = Nadam(learning_rate)

##==============================================================================
## Función para crear el modelo
##==============================================================================
def crea_modelo(inputShape = (1, 120, 120)):
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
def entrena_modelo(model, ruta_entrenamiento, csv_target, epochs=20, loss='mean_squared_error', batch=100, optim=opt, epochs_save= 10, ext = '.jpg'):
    '''
    ENTRADA
    model: Modelo creado con la función crea_modelo

    ruta_entrenamiento: String con la ruta de la carpeta con el conjunto de entrenamiento

    csv_target: pandas dataframe cuya primer columna es el id de la imagen
    y el resto de las columnas son las cantidades objetivo

    epochs: Entero, número de épocas.

    loss: String función de pérdida

    batch: Tamaño del bloque de entrenamiento

    optim: Objeto que representa algún método para optimizar

    epochs_save: Entero que representa cada cuantas épocas se guarda el modelo

    ext: String con la extensión de los archivos (imágenes)s

    SALIDA
    modelo entrenado
    historia: Objeto con la historia del entrenamiento
    '''

    #Compila el modelo
    model.compile(loss = loss, optimizer = optim)

    #listas con las rutas de los archivos
    arch_entrena = pre.lista_archivos(ruta_entrenamiento, ext)
    #arch_valida = pre.lista_archivos(ruta_validacion, ext)

    #entrena
    archivo_modelo = 'modelo-{epoch:02d}.hdf5' #nombre del archivo con el checkpoint del modelo
    checkpoint = ModelCheckpoint(archivo_modelo, save_best_only=True, period = epochs_save)
    inicio = time.ctime()
    historia = model.fit_generator(generator = pre.generador(arch_entrena, csv_target, batch)
        ,steps_per_epoch = int(len(arch_entrena) / batch), epochs = epochs
        ,callbacks = [checkpoint],use_multiprocessing=True, workers = 8, verbose = 1)
    fin = time.ctime()

    print 'Inicio ' + inicio + ' Fin ' + fin

    return model, historia


##==============================================================================
## Funcion para evaluar un conjunto de imagenes de acuerdo a un modelo dado
## CARGA EN MEMORIA
##==============================================================================
def carga_imagenes_arreglo(ruta, model, num_imagenes = 100, ext = '.jpg'):
    '''
    ENTRADA
    ruta: String con la ruta de la carpeta que contiene las imagenes

    model: Modelo entrenado

    num_imagenes: Entero que indica la cantidad de imagenes que se tomaran
    de la carpeta. si num_imagenes = '' entonces obtiene todos los archivos

    ext: String con la extension de las imagenes

    SALIDA
    Arreglo de numpy con las imagenes
    '''

    #Obtiene la ruta de cada archivo en la carpeta
    lista_arch = pre.lista_archivos(ruta, ext)

    #Selecciona los archivos a utilizar
    if num_imagenes != '':
        lista_arch = pre.np.random.choice(lista_arch, size = num_imagenes, replace = False)

    #para almacenar cada imagen y cada id
    x_test = []
    ids = []

    for arch in lista_arch:
        #Abre la imagen
        imagen = pre.Image.open(arch)

        #determina si es una imagen a color
        if 'BW' in arch:
            col = False
        else:
            col = True

        #Convierte la imagen en un arreglo numerico
        arreglo = pre.imagen_a_arreglo(imagen, col)

        #redimensiona el arreglo para considerar el numero de canales
        if col:
            arreglo.shape = (3, arreglo.shape[0], arreglo.shape[1])
        else:
            arreglo.shape = (1, arreglo.shape[0], arreglo.shape[1])

        #agrega el arreglo a x_test
        x_test.append(arreglo)

        #cierra la imagen
        imagen.close()

        #obtiene el Id de la imagen
        id_imagen = arch.split('/')[-1].split('.')[0]
        ids.append(id_imagen)

    #convierte x_test en un numpy array
    x_test = pre.np.array(x_test)
    ids = pre.np.array(ids)

    #columnas
    columnas = ['Class1.1', 'Class1.2', 'Class1.3', 'Class2.2', 'Class2.2', 'Class3.1',
    'Class3.2', 'Class4.1', 'Class4.2', 'Class5.1', 'Class5.2', 'Class5.3', 'Class5.4',
    'Class6.1', 'Class6.2', 'Class7.1', 'Class7.2', 'Class7.3', 'Class8.1', 'Class8.2',
    'Class8.3', 'Class8.4', 'Class8.5', 'Class8.6', 'Class8.7', 'Class9.1', 'Class9.2',
    'Class9.3', 'Class10.1', 'Class10.2', 'Class10.3', 'Class11.1', 'Class11.2',
    'Class11.3', 'Class11.4', 'Class11.5', 'Class11.6']

    #hace las predicciones
    pred = model.predict(x_test)

    return [pred, ids]