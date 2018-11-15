# coding: utf-8

from PIL import Image
from shutil import copyfile
from copy import deepcopy
import numpy as np
import pandas as pd
import pickle
import glob

##==============================================================================
## Función para convertir una imagen en un arreglo numpy
##==============================================================================
def imagen_a_arreglo(imagen, col = False):
    '''
    ENTRADA
    imagen: Objeto creado con la clase Image del módulo PIL (Image.open)

    col: Boolean True =>Imagen a color (RGB) False => Imagen blanco y negro

    SALIDA
    arreglo: Arreglo de numpy con shape (w, h, 3)
    '''

    #Obtiene las dimensiones de la imagen
    width = imagen.size[0]
    height = imagen.size[1]

    #np.uint8 para tener compatibilidad con matplotlib
    if col:
        arreglo = np.array(imagen.getdata(), dtype = np.float32).reshape(width, height, 3)
    else:
        arreglo = np.array(imagen.getdata(), dtype = np.float32).reshape(width, height)

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
        dicc[galaxy_id]['imagen'] = imagen.copy()

        imagen.close()

    #guarda el diccionario
    arch_salida = open('diccionario_imagenes', 'wb')
    pickle.dump(dicc, arch_salida)
    arch_salida.close()

    return dicc

##==============================================================================
## Función para convertir las imágenes de una carpeta en imágenes blanco y negro
##==============================================================================
def convierte_bw(fuente, destino, ext='.jpg', size = (45,45), bw_flag = True):
    '''
    ENTRADA
    fuente: string con la ruta de la carpeta que contiene las imágenes a color
    (e.g. '../all/images_training_1000/')

    destino: string con las ruta de la carpeta en donde se guardarán las
    imágenes en blanco y negro
    (e.g. '../all/images_training_1000_BW/')

    ext: string con la extensión de las imágenes

    size: Tupla con el tamaño de las imágenes

    bw_flag: Boolean que indice si sólo considerar redimensionamiento de las 
    imágenes o considerar redimensión + blanco y negro

    '''

    #lista las imágenes en la ruta fuente
    imagenes_color = glob.glob(fuente + '*' + ext)

    #Abre cada imagen, la convierte en blanco y negro y la guarda en la ruta destino
    for ruta in imagenes_color:

        imagen_col = Image.open(ruta)

        if bw_flag:
            #convierte blanco y negro
            image_bw = imagen_col.convert('L')
        image_bw = image_bw.resize(size)

        #Obtiene el Id de la imagen
        #ruta = '../all/images_training_1000/737688.jpg'
        id_imagen = ruta.split('/')[-1].split('.')[0]

        #guarda en la ruta destino
        image_bw.save(destino + id_imagen + ext)

        #cierra la imagen
        imagen_col.close()

    print 'Imagenes convertidas'

##==============================================================================
## Crea el conjunto de entrenamiento (en memoria)
##==============================================================================
def crea_entrenamiento(fuente_imagenes, fuente_csv, ext = '.jpg', col = False):
    '''
    ENTRADA
    fuente_imagenes: string con la ruta de la carpeta que contiene las imágenes
    (e.g. '../all/images_training_1000/')

    fuente_csv: string con la ruta del archivo csv que contiene los IDs y
    las probabilidades objetivo

    ext: string con la extensión de las imágenes

    col: Boolean True => Imágenes a color, False => Imágenes en blanco y negro

    SALIDA
    x_train: Numpy array con dimensiónes [num_imagenes][1][width][height]

    y_train: Numpy array con dimensiones [num_imagenes][37]

    '''

    #abre el archivo archivo csv
    arch_csv = pd.read_csv(fuente_csv)

    #número de imágenes
    n = arch_csv.shape[0]

    x_train = []
    y_train = []

    for i in range(0,n):
        #id de la imagen
        id_imagen = str(arch_csv['GalaxyID'][i])

        #ruta de la imagen
        ruta = fuente_imagenes + id_imagen + ext

        #abre la imagen y la convierte en un arreglo
        imagen = Image.open(ruta)
        #imagen = imagen.resize((128,128))
        arreglo = imagen_a_arreglo(imagen, col)
        imagen.close()

        #obtiene las probabilidades objetivo correspondientes a la imagen
        prob = np.array(arch_csv.iloc[i,1:])

        #almacena
        x_train.append(arreglo)
        y_train.append(prob)

    #convierte a numpy array
    x_train = np.array(x_train)
    y_train = np.array(y_train)

    #redimensiona x_train
    x_train = x_train.reshape(x_train.shape[0],1,x_train.shape[1], x_train.shape[2])

    return x_train, y_train

##==============================================================================
## Obtiene todos los archivos de cierta extensión en una carpeta
##==============================================================================
def lista_archivos(ruta, ext = '.jpg'):
    '''
    ENTRADA
    ruta: String con la ruta de la carpeta
    (e.g '../all/images_test_BW/')

    ext: string con la extensión de los archivos (e.g '.jpg')

    SALIDA
    rutas: lista con la ruta para cada archivo en la carpeta
    '''

    rutas = glob.glob(ruta + '*' + ext)

    return rutas

##==============================================================================
## Generador de imágenes
##==============================================================================
def generador(ruta_imagenes, csv_target, batch = 32):
    '''
    ENTRADA
    ruta_imagenes: lista con la ruta de cada imagen

    csv_target: pandas dataframe cuya primer columna es el id de la imagen
    y el resto de las columnas son las cantidades objetivo

    batch: Entero que representa el tamaño del lote

    SALIDA
    tupla de la forma (x_batch, y_batch)
    '''

    while True:

        #Selecciona los archivos del batch
        ruta_batch = np.random.choice(ruta_imagenes, size = batch)

        x_batch = []
        y_batch = []

        #Lee cada imagen

        for ruta in ruta_batch:

            #Abre la imagen y la guarda en un arreglo
            #Determina automáticamente el color
            if 'BW' in ruta:
                col = False
            else:
                col = True
            imagen = Image.open(ruta)
            arreglo = imagen_a_arreglo(imagen, col)

            #Cambia la forma del arreglo con el fin de considerar los canales
            #de acuerdo a si se usa o no imágenes con color
            if not col:
                arreglo.shape = (1, arreglo.shape[0], arreglo.shape[1])
            else:
                arreglo.shape = (3, arreglo.shape[0], arreglo.shape[1])
            imagen.close()

            #Obtiene el ID de la imagen
            id_imagen = int(ruta.split('/')[-1].split('.')[0])

            #Obtiene los target correspondientes
            indice = csv_target[csv_target['GalaxyID'] == id_imagen].index[0]
            target = np.array(csv_target.iloc[indice,1:])

            #almacena
            x_batch.append(arreglo)
            y_batch.append(target)

        x_batch = np.array(x_batch)
        y_batch = np.array(y_batch)

        yield (x_batch, y_batch)

##==============================================================================
## Crear conjuntos de entrenamiento y validación
##==============================================================================
def crea_validacion(ruta_imagenes, ruta_entrenamiento, ruta_validacion, csv_target, ext = '.jpg', prop = 0.9):
    '''
    ENTRADA
    ruta_imagenes: String con la ruta de la carpeta que contiene las imágenes
    (e.g. '../all/images_training_rev1/')

    ruta_entrenamiento: String con la ruta destino para las imágenes de entrenamiento

    ruta_validacion: String con la ruta destino para las imágenes de validación

    csv_target: Pandas dataframe con los galaxyID 

    ext: String que indica la extensión de los archivos (e.g. '.jpg')

    prop: float en (0,1) que representa la proporción del conjunto de entrenamiento

    '''

    #obtiene los IDs
    ids = np.array(csv_target['GalaxyID'], dtype = str)

    #obtiene los IDs del conjunto de entrenamiento
    num_entrenamiento = int(prop * len(ids))
    ids_entrenamiento = np.random.choice(ids, size = num_entrenamiento, replace = False)

    lista_imagenes = lista_archivos(ruta_imagenes, ext)

    #comienza a copiar cada imagen en su ruta correspondiente

    for imagen in lista_imagenes:

        #obtiene el id de la imagen
        id_imagen = imagen.split('/')[-1].split('.')[0]

        #revisa si está en el conjunto de entrenamiento
        if id_imagen in ids_entrenamiento:
            dest = ruta_entrenamiento + id_imagen + ext
        else:
            dest = ruta_validacion  + id_imagen + ext

        #copia el archivo en su destino correspondiente
        copyfile(imagen, dest)

    
    print 'Conjuntos de valiadcion y entrenamiento creados'

##==============================================================================
## Copiar archivos de una carpeta origen a una destino
##==============================================================================
def copia_archivos(ruta_origen, ruta_destino, cantidad= 500, ext = '.jpg'):
    '''
    ENTRADA

    ENTRADA
    ruta_origen: String con la ruta de la carpeta que contiene las imágenes
    (e.g. '../all/images_training_rev1/')

    ruta_destino: String con la ruta destino para las imágenes

    cantidad: Entero que representa el número de archivos a copiar

    ext: String con la extensión de los archivos

    '''

    #lista de los archivos en ruta_origen
    lista_arch = lista_archivos(ruta_origen)

    #Selecciona al azar los archivos a copiar
    lista_arch_copiar = np.random.choice(lista_arch, size = cantidad, replace = False)

    #copia archivos
    for archivo in lista_arch_copiar:

        #nombre del archivo
        nombre = archivo.split('/')[-1].split('.')[0]

        #destino
        dest = ruta_destino + nombre + ext

        copyfile(archivo, dest)

    print "Archivos copiados"    