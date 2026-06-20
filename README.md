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



