# coding: utf-8

from PIL import Image
import numpy as np
import pandas as pd
import pickle

##==============================================================================
## Función para convertir una imagen en un arreglo numpy
##==============================================================================
def imagen_a_arreglo(imagen):
    '''
    ENTRADA
    imagen: Objeto creado con la clase Image del módulo PIL (Image.open)

    SALIDA
    arreglo: Arreglo de numpy con shape (w, h, 3)
    '''

    #Obtiene las dimensiones de la imagen
    width = imagen.size[0]
    height = imagen.size[1]

    #np.uint8 para tener compatibilidad con matplotlib
    arreglo = np.array(imagen.getdata(), dtype = np.uint8).reshape(width, height, 3)

    return arreglo
##==============================================================================
## Función para rotar una imagen cierto número de grados (sentido contrario al reloj)
##==============================================================================
def rota_imagen(imagen, grados):
    '''
    ENTRADA
    imagen: Objeto creado con la clase Image del módulo PIL (Image.open)

    grados: Número de grados que se rotará la imange
    (sentido contrario a las manecillas del reloj)

    SALIDA
    Imagen rotada
    '''
    img_rot = imagen.rotate(grados)

    return img_rot

##==============================================================================
## Función para transponer una imagen
##==============================================================================
def transpon_imagen(imagen, tipo):
    '''
    ENTRADA
    imagen: Objeto creado con la clase Image del módulo PIL (Image.open)

    tipo: Alguna de las siguientes strings
    horizontal -> para FLIP_LEFT_RIGHT
    vertical -> para FLIP_TOP_BOTTOM

    SALIDA
    imagen transpuesta
    '''

    if tipo == 'horizontal':
        img_trans = imagen.transpose(Image.FLIP_LEFT_RIGHT)
    elif tipo == 'vertical':
        img_trans = imagen.transpose(Image.FLIP_TOP_BOTTOM)
    else:
        print 'Revisa el parametro tipo'

    return img_trans

##==============================================================================
## Función para recortar una imagen (PENDIENTE)
##==============================================================================
#def recorta_imagen(imagen, caja = (101, 101, 101, 101)):


##==============================================================================
## Función para crear un diccionario que contendrá los siguientes elementos
## GalaxyID (Key)
## .. target: Numpy array con las probabilidades del conjunto de entrenamiento
## .. imagen: Objeto creado con el módulo PIL (Image.open)
##==============================================================================
def diccionario_imagenes(real = False):
    '''
    ENTRADA
    real: Boolean, True => Obtener todas las imágenes del conjunto de entrenamiento
    False => Obtener sólamente las primeros 20 imágenes del conjunto de
    entrenamiento

    SALIDA
    diccionario con la información del target y las imágenes
    '''
    #lee el csv con los IDs y los targets
    arch_csv = pd.read_csv('../all/training_solutions_rev1.csv')

    if real:
        n = arch_csv.shape[0]
    else:
        n = 20

    #ruta en donde se guardan las imágenes
    ruta = '../all/images_training_rev1/'

    #ruta en donde se guardará la información del diccionario

    #Llena el diccionario
    dicc = {}
    for i in range(0, n):

        #obtiene la ruta de la imagen
        galaxy_id = str(arch_csv.iloc[i,0])
        ruta_imagen = ruta + galaxy_id + '.jpg'

        #abre la imagen
        imagen = Image.open(ruta_imagen)

        #obtiene las probabilidades objetivo
        targets = np.array(arch_csv.iloc[i,1:])

        #Llena el diccionario
        dicc[galaxy_id] = {}
        dicc[galaxy_id]['target'] = targets
        dicc[galaxy_id]['imagen'] = imagen

    #guarda el diccionario
    arch_salida = open('diccionario_imagenes', 'wb')
    pickle.dump(dicc, arch_salida)
    arch_salida.close()

    return dicc
