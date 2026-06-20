<h1 align="center"> <b>UNIVERSIDAD NACIONAL AGRARIA LA MOLINA</b> </h3>
<h2 align="center"> <b>DEPARTAMENTO ACADÉMICO DE ESTADÍSTICA E INFORMÁTICA</b> </h2>
<p align="center">
  <img src="https://seeklogo.com/images/U/universidad-nacional-agraria-la-molina-logo-5BF0B8D973-seeklogo.com.png" 
       alt="La Molina Perú" 
       width="170" 
       height="170">
</p>
<h3 align="center">
  <b>PROTOTIPO DE ANÁLISIS DE POSIBLE DESINFORMACIÓN POLÍTICA EN COMENTARIOS DE YOUTUBE MEDIANTE EXTRACCIÓN DE DATOS Y TEXT MINING</b>
</h3>

<h3> <b>Integrantes del equipo:</b> </h3>

<ul>
  <li>Cardenas Panduro, Ricardo Gabriel (Rick2425) (20241376) </li>
  <li>Meza Mitma, Liz Maritza (Mezaliz96) (20220771) </li>
  <li>Tuppia Paitan, Joaquin Francisco (JTPXD) (20241405)</li>
  <li>Quispe Garcia Francisco Alberto (panchop35) (20240729)</li>
</ul>

</ul> 

## 1. Planteamiento y justificación del problema 

### 1.1. Descripción del problema 

Youtube se ha convertido en una plataforma relevante para la difusión de contenido político, especialmente a través de transmisiones en vivo, entrevistas, debates, reportajes y coberturas de coyuntura. En estos espacios, los comentarios de los usuarios pueden reflejar opiniones, rumores, afirmaciones no verificadas, discursos alarmistas o mensajes repetidos que contribuyen a la circulación de posible desinformación política. 

El problema no se limita al contenido publicado por los canales, sino tambien a la interacción generada en torno a los videos. Los comentarios pueden amplificar narrativas como fraude, manipulación, censura, corrupción o desconfianza institucional, muchas veces sin citar fuentes verificables. Además, el uso de LLMs y herramientas automatizadas facilita la generación masiva de mensajes persuasivos o repetitivos, lo que dificulta la revisión manual. 

Por ello, se plantea un prototipo que extrae comentarios públicos de videos políticos en Youtube mediante la Youtube Data API v3, los almacena en formato CSV y aplica técnicas de tex mining para identificar patrones lingüisticos asociados a posible desinformación política. El sistema no busca determinar de forma absoluta si un comentario es falso, sino detectar señales de riesgo que puedan orientar una revisión humana posterior. 

## 2. Objetivos 

### 2.1. Objetivo General 

Diseñar un prototipo para recopilar y analizar comentarios públicos de videos políticos en Youtube, con el fin de identificar señales textuales asociados a posible desinformación política mediante text mining y un sistema de puntaje de riesgo. 

### 2.2. Objetivos Específicos

* Extraer comentarios públicos de videos políticos de Youtube mediante la Youtube Data API v3. 

* Construir un dataset en formato CSV con metadatos del video y comentarios anonimizados. 

* Aplicar técnicas de text mining en R, como tokenización, eliminación de stopwords, frecuencia de palabras, análisis de sentimientos y nube de palabras. 

* Implementar en Python un sistema de puntaje para clasificar comentarios según señales de posible desinformación.

* Evaluar los resultados mediante tablas, fráficos y revisión manual de una muestra de comentarios.

### 2.3. Alcance del prototipo

El prototipo se limita al análisis de comentarios públicos de una muestra de videos polítivos de Youtube. La extracción se realiza por lotes, no en tiempo real, y considera un máximo aproximado de 300 comentarios por video. El sistema no acusa a usuarios ni determina la falsedad absoluta de los mensajes; unicamente identifica indicadores de riesgo, como lenguaje alarmista, menciones a fraude, llamados a compartir, ausencia de fuentes verificables, alta carga emocional o repetición de términos asociados a desinformación. 

## 3. Fuentes de información y variables extraídas

### 3.1. Fuentes usadas

Para el desarrollo de este estudio sobre desinformación y polarización política, se utiliza como fuente de información primaria la plataforma digital YouTube, específicamente a través de su interfaz de programación de aplicaciones oficial: YouTube Data API v3.
La captura y almacenamiento de los datos en bruto se ejecuta mediante un entorno de desarrollo en Python (.ipynb), conectándose directamente a la API para realizar el raspado (scraping) automatizado de los comentarios públicos alojados en videos con alta relevancia dentro de la coyuntura electoral y política peruana.

### 3.2. Utilidad

La elección de los comentarios de YouTube como fuente de información es fundamental por las siguientes razones analíticas:

* Reflejo de la opinión pública directa: A diferencia de las encuestas tradicionales, las plataformas de video capturan las reacciones espontáneas, orgánicas y en tiempo real de la ciudadanía frente a eventos políticos de alta tensión.

* Foco de desinformación y cámaras de eco: YouTube es uno de los principales canales audiovisuales consumidos en el Perú para el debate político. Esto la convierte en una mina de datos ideal para rastrear cómo se propagan los vectores de desinformación (como las teorías de fraude electoral) y la polarización discursiva.

 * Viabilidad técnica para Minería de Texto (Text Mining): Al ser datos de naturaleza textual no estructurada, permiten aplicar técnicas avanzadas de normalización semántica, análisis de frecuencias y diccionarios de sentimientos para cuantificar fenómenos sociales abstractos de manera matemática y científica.

### 3.3. Qué variables van a extraer

A partir de la ejecución del script en Python y los archivos resultantes recopilados en el repositorio (`comentarios_youtube_raw.csv`), el proyecto extrae y clasifica las siguientes variables críticas organizadas en tres niveles:

| Nivel de Variable | Nombre de la Variable | Tipo de Dato | Descripción / Rol en el Proyecto |
| :--- | :--- | :--- | :--- |
| **Identificadores** | `id_comentario` | Numérico (Entero) | Índice correlativo generado automáticamente en R para asegurar la trazabilidad del comentario durante la limpieza. |
| **Texto Bruto** | `texto_comentario` | Alfanumérico (String) | El texto original y sin procesar ingresado por el usuario de YouTube. Es la materia prima de la investigación. |
| **Variables Textuales Procesadas** | `texto_limpio` | Alfanumérico (String) | Texto normalizado en minúsculas, sin tildes (ASCII), sin caracteres especiales ni enlaces web (URLs). |
| **Variables Textuales Procesadas** | `palabra_final` / `palabra_detectada` | Categórica (Nominal) | Tokens (palabras individuales) resultantes de la eliminación de stopwords genéricas y contextuales políticas. |
| **Variables de Análisis Semántico y Emocional** | `categoria` | Categórica (Nominal) | Clasificación de términos en dimensiones clave según el diccionario de equivalencias políticas: `partido_politico`, `tema_electoral` o `riesgo_desinformacion` (ej. "fraude"). |
| **Variables de Análisis Semántico y Emocional** | `sentimiento` | Categórica (Nominal) | La carga emocional asignada a cada término detectado mediante el cruce con el diccionario `sentimientos_2.txt` (ej. ira, miedo, confianza, alegría, tristeza). |

## 7. Ética, limitaciones y reflexión sobre LLMs

### 7.1. Consideraciones Éticas en el Manejo de Datos Textuales
* No extraer datos sensibles: Al momento de descargar los comentarios con la herramienta de YouTube, nos aseguramos de no guardar ningún dato privado de los usuarios, como correos electrónicos, ubicaciones exactas o datos personales que no fueran necesarios para el estudio.
* Anonimizar usuarios: En el archivo final donde trabajamos los textos, eliminamos por completo los nombres de usuario reales, las fotos de perfil y los enlaces a sus canales. A cada comentario le pusimos un número de orden (como un código anónimo) para analizar lo que decía el texto sin saber quién lo escribió, protegiendo así la privacidad de las personas.
* No acusar directamente a personas: Nuestro análisis se enfoca en ver el comportamiento del público en general (qué palabras o emociones se repiten más). En ningún momento señalamos, buscamos o acusamos a usuarios específicos de estar publicando noticias falsas o contenido malicioso.

### 7.2. Limitaciones Técnicas y Riesgos de Falsos Positivos
* Riesgos de falsos positivos: Como el programa analiza los comentarios buscando palabras exactas usando una lista predeterminada (diccionario), no es capaz de entender el sarcasmo, las bromas o la ironía. Por ejemplo, si alguien escribe un comentario de burla que dice: *"¡Claro, por supuesto que hubo un tremendo fraude electoral!"*, el programa leerá la palabra "fraude" y la clasificará automáticamente como un riesgo de desinformación, cuando en realidad el usuario estaba siendo irónico.
* Limitaciones técnicas: Al depender de una lista fija de palabras para medir los sentimientos, si los usuarios escriben palabras nuevas que no están en nuestra lista, o si cometen faltas de ortografía muy graves, el programa simplemente las ignorará y no podrá calcular la emoción de ese comentario.

### 7.3. Reflexión Metodológica sobre el Uso de LLMs 
* Qué partes se hicieron con LLMs: Usamos la Inteligencia Artificial principalmente como un asistente de programación. Nos ayudó a escribir códigos difíciles en R y Python, a limpiar los textos de forma rápida (como quitar enlaces de internet o símbolos extraños) y a diseñar los gráficos para que se vean ordenados y profesionales en el reporte web.
* Qué partes se revisaron manualmente: Toda la lista de palabras de partidos políticos peruanos (como agrupar "Keiko", "Fujimori" y "FP" bajo un mismo concepto) y la limpieza del archivo Excel de palabras comunes se revisaron a mano, uno por uno. Esto se hizo así porque una Inteligencia Artificial general no siempre entiende los modismos o el contexto político de nuestro país.
* Cómo ayudó o dificultó el LLM: 
  * *Cómo ayudó:* Nos ahorró muchísimo tiempo al momento de programar. Nos dio las fórmulas exactas para limpiar el texto y armar los gráficos sin que el código tuviera errores.
  * *Dificultad o riesgo:* Evaluamos la idea de que la IA leyera y clasificara las emociones de cada comentario por su cuenta, pero nos dimos cuenta de que las Inteligencias Artificiales a veces "inventan" respuestas (alucinan) o pueden tener opiniones sesgadas. Para que nuestro trabajo fuera transparente y cualquiera pudiera replicarlo con los mismos resultados, preferimos usar nuestra propia lista física de sentimientos en lugar de dejarle todo el control a una IA.




