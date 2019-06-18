# DJS3
Donostia Java Suite 3. Pluggins de ImageJ  para controles de calidad en Radioterapia

COMPONENTES PRINCIPALES DE LA DONOSTIA JAVA SUITE 3


Donosita Java Suite


CR_Process: Herramientas para el procesado de imágenes CR. Realmente tambien se puede usar para imágenes EPID pero no explota los TAGs de las imagenes.
-DigInsert_Pro: Captura puntos de una imagen y los transpone para su captura en un Excel. Creado para capturar los puntos de un inserto de electrones dibujado sobre placa o papel, escaneado previamente con una escala conocida.
-LZ_RX: Macro diseñada para analizar una placa de coincidencia Luz_Rayos de un acelerador. Captura un punto central y 8 puntos del campo de luz y 8 puntos del campo de radiación (2 por lado). Después calcula la diferencia en mm. Se supone que no hay conversión de escala. Imagen en el Isocentro.

DICOM_RTs: Conjunto de macros para explotar los DICOM_RTs. Contiene muchas macros en proceso o abandonadas. Sólo se explican las dos que mas se usan
-OMP_Coronal_Dose_Convolucionator: Macro para extraer un corte de dosis de un archivo RT_Dose exportado desde un planificador Oncentra en formato DICOM. Extrae un corte a 10 cm de profundidad (dada unas dimensiones especificas de la matriz de calculo) y convoluciona el plano por un filtro simulando la respuesta de una cámara de ionización, en concreto las cámaras de una matriz 729-Octavius de PTW.
-DICOM_TAG_Extract: Extrae el valor de un DICOM TAG de cualquier archivo DICOM.

EBT_Process:
-Cal_Chanel_3v2.0: Calibra una placa EBT3 a partir de la irradiación de 8 campos 5x5 cm2 de posiciones y dosis conocidas. Customizado para trabajar con un escaner EPSON 10000XL y placas EBT3.
-Chanel_3v2.0: Paralelo a Cal_Chanel recoge los archivos de calibración de la primera macro y los usa para calibrar placas EBT3 y convertirlas a dosis en un fichero “imagen de texto” reconocible por imagen y Verisoft.

EPID_Process:
-MLC_PicketFence: Analizador universal de imágenes DICOM Picket Fence. Siguiendo el patrón recogido en los archivo .conf de la carpeta lib analiza la posición de los picos de ticket fence.
-Rad_iso: Analiza una serie de imágenes de EPID que contienen un BB con una tamaño de campo fijo para diferentes angulos de gantry, colimador y mesa y obtiene la posición del isocentro radiologico con respecto al BB.
