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

