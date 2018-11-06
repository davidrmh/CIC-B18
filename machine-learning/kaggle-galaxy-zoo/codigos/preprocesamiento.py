# coding: utf-8

from PIL import Image
import numpy as np

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
