############################################################
# APLICACIÓN DE TEXT MINING EN COMENTARIOS DE YOUTUBE
# Proyecto: Posible desinformación política en YouTube
############################################################


# ============================================================
# 0. LIMPIEZA DEL ENTORNO Y CONFIGURACIÓN INICIAL
# ============================================================

rm(list = ls())
graphics.off()
cat("\014")

options(scipen = 999)
options(digits = 3)

if (!require("pacman")) install.packages("pacman")
library(pacman)

p_load(
  tidyverse,
  tidytext,
  readxl,
  stringi,
  wordcloud2,
  htmlwidgets,
  webshot2,
  rstudioapi
)

if (rstudioapi::isAvailable()) {
  ruta_script <- tryCatch(
    dirname(rstudioapi::getActiveDocumentContext()$path),
    error = function(e) NA
  )
  
  if (!is.na(ruta_script) && ruta_script != "." && ruta_script != "") {
    setwd(ruta_script)
  }
}

getwd()


# ============================================================
# 1. CONFIGURAR MICROSOFT EDGE PARA WEBSHOT2
# ============================================================

rutas_edge <- c(
  "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
  "C:/Program Files/Microsoft/Edge/Application/msedge.exe"
)

ruta_edge <- rutas_edge[file.exists(rutas_edge)][1]

if (!is.na(ruta_edge)) {
  Sys.setenv(CHROMOTE_CHROME = ruta_edge)
}


# ============================================================
# 2. LECTURA DEL ARCHIVO CSV
# ============================================================

comentarios_raw <- read_csv(
  "comentarios_youtube_raw.csv",
  show_col_types = FALSE
)

names(comentarios_raw)


# ============================================================
# 3. SELECCIÓN DE COMENTARIOS
# ============================================================

comentarios_texto <- comentarios_raw %>%
  select(texto_comentario) %>%
  filter(!is.na(texto_comentario)) %>%
  mutate(
    id_comentario = row_number(),
    texto_comentario = str_squish(texto_comentario)
  )

head(comentarios_texto)


# ============================================================
# 4. NORMALIZACIÓN PREVIA DEL TEXTO
# Se unen frases útiles antes de tokenizar
# ============================================================

comentarios_texto <- comentarios_texto %>%
  mutate(
    texto_limpio = texto_comentario,
    texto_limpio = str_to_lower(texto_limpio),
    texto_limpio = stri_trans_general(texto_limpio, "Latin-ASCII"),
    texto_limpio = str_replace_all(texto_limpio, "http\\S+|www\\S+", " "),
    
    texto_limpio = str_replace_all(
      texto_limpio,
      "\\bvoto\\s+viciado\\b|\\bvotos\\s+viciados\\b",
      "voto_viciado"
    ),
    
    texto_limpio = str_replace_all(
      texto_limpio,
      "\\bvoto\\s+en\\s+blanco\\b|\\bvoto\\s+blanco\\b|\\bvotos\\s+blancos\\b",
      "voto_blanco"
    ),
    
    texto_limpio = str_replace_all(
      texto_limpio,
      "\\bsegunda\\s+vuelta\\b|\\b2da\\s+vuelta\\b",
      "segunda_vuelta"
    ),
    
    texto_limpio = str_replace_all(
      texto_limpio,
      "\\bfuerza\\s+popular\\b",
      "fuerza_popular"
    ),
    
    texto_limpio = str_replace_all(
      texto_limpio,
      "\\bjuntos\\s+por\\s+el\\s+peru\\b",
      "juntos_por_el_peru"
    ),
    
    texto_limpio = str_replace_all(texto_limpio, "[^a-z_\\s]", " "),
    texto_limpio = str_squish(texto_limpio)
  )

head(comentarios_texto)


# ============================================================
# 5. TOKENIZACIÓN
# ============================================================

tokens_comentarios <- comentarios_texto %>%
  select(id_comentario, texto_limpio) %>%
  unnest_tokens(
    output = palabra,
    input = texto_limpio,
    token = "regex",
    pattern = "\\s+"
  )

head(tokens_comentarios, 20)


# ============================================================
# 6. LECTURA Y NORMALIZACIÓN DE STOPWORDS PERSONALIZADAS
# Archivo requerido: CustomStopWords.xlsx
# ============================================================

stopwords_custom <- read_excel("CustomStopWords.xlsx")

stopwords_custom <- stopwords_custom %>%
  rename(palabra = 1) %>%
  mutate(
    palabra = str_to_lower(palabra),
    palabra = str_squish(palabra),
    palabra = stri_trans_general(palabra, "Latin-ASCII")
  ) %>%
  filter(!is.na(palabra), palabra != "") %>%
  distinct(palabra)

head(stopwords_custom)


# ============================================================
# 7. LIMPIEZA 1: ELIMINAR STOPWORDS PERSONALIZADAS
# ============================================================

tokens_filtrados <- tokens_comentarios %>%
  mutate(
    palabra = str_to_lower(palabra),
    palabra = str_squish(palabra),
    palabra = stri_trans_general(palabra, "Latin-ASCII")
  ) %>%
  anti_join(stopwords_custom, by = "palabra") %>%
  filter(
    !is.na(palabra),
    palabra != "",
    str_detect(palabra, "^[a-z_]+$")
  )

resumen_limpieza1 <- tibble(
  tokens_iniciales = nrow(tokens_comentarios),
  tokens_despues_stopwords = nrow(tokens_filtrados),
  tokens_eliminados = nrow(tokens_comentarios) - nrow(tokens_filtrados)
)

resumen_limpieza1


# ============================================================
# 8. DICCIONARIO DE EQUIVALENCIAS POLÍTICAS
# Los términos útiles se agrupan, no se eliminan
# ============================================================

diccionario_equivalencias <- tibble(
  palabra = c(
    # Fuerza Popular / fujimorismo
    "keiko",
    "fujimori",
    "fujimorismo",
    "fujimorista",
    "fujimoristas",
    "fp",
    "fuerza",
    "popular",
    "fuerza_popular",
    
    # Juntos por el Perú
    "jp",
    "juntos",
    "juntos_por_el_peru",
    
    # Perú / población peruana
    "peru",
    "peruanos",
    "peruanas",
    "peruano",
    "peruana",
    
    # Voto
    "voto",
    "votos",
    "votar",
    
    # Voto viciado
    "viciado",
    "viciados",
    "voto_viciado",
    
    # Voto blanco
    "blanco",
    "blancos",
    "voto_blanco",
    
    # Segunda vuelta
    "vuelta",
    "segunda_vuelta",
    
    # Elecciones
    "eleccion",
    "elecciones",
    "electoral",
    "electorales",
    
    # Fraude
    "fraude",
    "fraudes",
    "fraudulento",
    "fraudulenta"
  ),
  
  termino = c(
    rep("fuerza_popular", 9),
    rep("juntos_por_el_peru", 3),
    rep("peru", 5),
    rep("voto", 3),
    rep("voto_viciado", 3),
    rep("voto_blanco", 3),
    rep("segunda_vuelta", 2),
    rep("elecciones", 4),
    rep("fraude", 4)
  ),
  
  categoria = c(
    rep("partido_politico", 9),
    rep("partido_politico", 3),
    rep("pais_poblacion", 5),
    rep("tema_electoral", 3),
    rep("tema_electoral", 3),
    rep("tema_electoral", 3),
    rep("tema_electoral", 2),
    rep("tema_electoral", 4),
    rep("riesgo_desinformacion", 4)
  )
) %>%
  mutate(
    palabra = str_to_lower(palabra),
    palabra = str_squish(palabra),
    palabra = stri_trans_general(palabra, "Latin-ASCII")
  )


# ============================================================
# 9. STOPWORDS CONTEXTUALES
# No colocar aquí: jp, peru, fujimori, fujimorismo, fuerza, popular,
# voto, votos, votar, fraude, elecciones, etc.
# ============================================================

stopwords_contextuales <- c(
  # Nombres o personajes que no se analizarán como categoría propia
  "castillo",
  "dina",
  "boluarte",
  "vizcarra",
  "sagasti",
  "alan",
  "garcia",
  "toledo",
  "ollanta",
  "humala",
  "acuna",
  "lopez",
  "aliaga",
  "sanchez",
  "nieto",
  "curwen",
  "hildebrandt",
  "marisol",
  "cesar",
  "rosa",
  "tello",
  "chau",
  "rmp",
  "jorge",
  "maria",
  "roberto",
  "perez",
  
  # Lugares específicos
  "lima",
  
  # Palabras poco informativas
  "sr",
  "sra",
  "senor",
  "senora",
  "gracias",
  "ud",
  "don",
  "jaja",
  "jajaja",
  "xd",
  "xq",
  "q",
  "k",
  "kk",
  "anos",
  "entrevista",
  "tio",
  "persona",
  "seguir",
  "canal",
  "programa"
)

stopwords_contextuales <- tibble(
  palabra = stopwords_contextuales
) %>%
  mutate(
    palabra = str_to_lower(palabra),
    palabra = str_squish(palabra),
    palabra = stri_trans_general(palabra, "Latin-ASCII")
  ) %>%
  distinct(palabra)


# ============================================================
# 10. LIMPIEZA FINAL Y NORMALIZACIÓN SEMÁNTICA
# ============================================================

tokens_final <- tokens_filtrados %>%
  anti_join(stopwords_contextuales, by = "palabra") %>%
  left_join(diccionario_equivalencias, by = "palabra") %>%
  mutate(
    palabra_final = if_else(is.na(termino), palabra, termino),
    categoria = if_else(is.na(categoria), "termino_general", categoria)
  ) %>%
  select(
    id_comentario,
    palabra_original = palabra,
    palabra_final,
    categoria
  )

resumen_limpieza2 <- tibble(
  tokens_despues_stopwords = nrow(tokens_filtrados),
  tokens_finales = nrow(tokens_final),
  tokens_eliminados_limpieza_contextual = nrow(tokens_filtrados) - nrow(tokens_final)
)

resumen_limpieza2

head(tokens_final, 20)


# ============================================================
# 11. FRECUENCIA GENERAL DE TÉRMINOS NORMALIZADOS
# ============================================================

frecuencia_general <- tokens_final %>%
  count(palabra_final, sort = TRUE)

head(frecuencia_general, 20)


# ============================================================
# 12. TOP 10 TÉRMINOS MÁS FRECUENTES
# ============================================================

top_10_palabras <- tokens_final %>%
  count(palabra_final, sort = TRUE) %>%
  slice_max(n, n = 10, with_ties = FALSE)

top_10_palabras


# ============================================================
# 13. GRÁFICO DE BARRAS: TOP 10 TÉRMINOS
# ============================================================

grafico_top10 <- ggplot(
  top_10_palabras,
  aes(x = reorder(palabra_final, n), y = n, fill = palabra_final)
) +
  geom_col(width = 0.75) +
  coord_flip(clip = "off") +
  geom_text(
    aes(label = n),
    hjust = -0.2,
    colour = "black",
    size = 3.5
  ) +
  labs(
    title = "Top 10 términos más frecuentes en comentarios de YouTube",
    subtitle = "Términos agrupados mediante normalización semántica",
    x = "Término",
    y = "Frecuencia"
  ) +
  scale_y_continuous(
    limits = c(0, max(top_10_palabras$n) + 10),
    expand = c(0, 0)
  ) +
  theme_bw() +
  theme(
    legend.position = "none",
    
    plot.title = element_text(
      size = 15,
      face = "bold",
      hjust = 0.5
    ),
    
    plot.subtitle = element_text(
      size = 10,
      hjust = 0.5
    ),
    
    axis.title.x = element_text(size = 10),
    axis.title.y = element_text(size = 10),
    
    axis.text.x = element_text(
      color = "gray25",
      size = 8
    ),
    
    axis.text.y = element_text(
      color = "blue4",
      size = 9,
      face = "bold"
    ),
    
    axis.ticks = element_line(color = "lightblue"),
    
    panel.background = element_rect(
      fill = "khaki1",
      color = NA
    ),
    
    plot.background = element_rect(
      fill = "white",
      color = NA
    ),
    
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    
    plot.margin = margin(10, 30, 10, 10)
  )

grafico_top10

ggsave(
  filename = "top_10_terminos_youtube.png",
  plot = grafico_top10,
  width = 9,
  height = 5,
  dpi = 300
)


# ============================================================
# 14. FRECUENCIA POR CATEGORÍA
# ============================================================

frecuencia_categorias <- tokens_final %>%
  count(categoria, sort = TRUE)

frecuencia_categorias


# ============================================================
# 15. PANORAMA ELECTORAL: FRECUENCIA DE PARTIDOS
# ============================================================

frecuencia_partidos <- tokens_final %>%
  filter(categoria == "partido_politico") %>%
  count(palabra_final, sort = TRUE)

frecuencia_partidos


# ============================================================
# 16. GRÁFICO DE REFERENCIAS PARTIDARIAS
# ============================================================

if (nrow(frecuencia_partidos) > 0) {
  
  grafico_partidos <- ggplot(
    frecuencia_partidos,
    aes(x = reorder(palabra_final, n), y = n, fill = palabra_final)
  ) +
    geom_col(width = 0.75) +
    coord_flip(clip = "off") +
    geom_text(
      aes(label = n),
      hjust = -0.2,
      colour = "black",
      size = 3.5
    ) +
    labs(
      title = "Referencias partidarias en comentarios de YouTube",
      subtitle = "Términos agrupados por partido político",
      x = "Partido político",
      y = "Frecuencia"
    ) +
    scale_y_continuous(
      limits = c(0, max(frecuencia_partidos$n) + 10),
      expand = c(0, 0)
    ) +
    theme_bw() +
    theme(
      legend.position = "none",
      plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5),
      axis.text.y = element_text(color = "blue4", size = 9, face = "bold"),
      panel.background = element_rect(fill = "khaki1", color = NA),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      plot.margin = margin(10, 30, 10, 10)
    )
  
  grafico_partidos
  
  ggsave(
    filename = "referencias_partidarias_youtube.png",
    plot = grafico_partidos,
    width = 8,
    height = 4.5,
    dpi = 300
  )
}


# ============================================================
# 17. FRECUENCIA PARA NUBE DE PALABRAS 
# Usamos las palabras originales separadas y borramos el "no"
# ============================================================

frecuencia_palabras <- tokens_final %>%
  filter(palabra_original != "no") %>% 
  count(palabra_original, sort = TRUE) %>% # Contamos sin agrupar
  slice_max(n, n = 80, with_ties = FALSE)  # Top 80 

frecuencia_palabras

# ============================================================
# 18. NUBE DE PALABRAS CON ESTILO 
# ============================================================

frecuencia_nube <- frecuencia_palabras %>%
  rename(
    palabra = palabra_original,
    frecuencia = n
  )

# Le devolvemos los colores variados de tu diseño original
nube_youtube <- wordcloud2(
  data = frecuencia_nube,
  size = 0.8,
  shape = "cloud",
  color = "random-dark", 
  backgroundColor = "white",
  rotateRatio = 0.05,
  fontFamily = "sans-serif"
)

saveWidget(
  nube_youtube,
  file = "nube_palabras_youtube.html",
  selfcontained = TRUE
)

html_path <- normalizePath(
  "nube_palabras_youtube.html",
  winslash = "/",
  mustWork = TRUE
)

html_url <- paste0("file:///", html_path)

browseURL(html_url)

webshot2::webshot(
  url = html_url,
  file = "nube_palabras_youtube.png",
  vwidth = 1400,
  vheight = 900,
  delay = 3
)

browseURL(normalizePath("nube_palabras_youtube.png", winslash = "/"))




# ============================================================
# 19. OBJETOS PRINCIPALES
# ============================================================

tokens_final
frecuencia_general
top_10_palabras
frecuencia_categorias
frecuencia_partidos

# ============================================================
# 20. DASHBOARD INTERACTIVO DE RESULTADOS
# ============================================================
library(shiny)
library(shinydashboard)
library(DT)
library(wordcloud2)

# UI del Dashboard
ui <- dashboardPage(
  skin = "black",
  dashboardHeader(title = "Métricas y Text Mining"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Métricas Generales", tabName = "resumen", icon = icon("dashboard")),
      menuItem("Nube Política", tabName = "nube", icon = icon("cloud")),
      menuItem("Base de Tokens", tabName = "datos", icon = icon("table"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Pestaña 1: Gráfico de Ricardo ya diseñado
      tabItem(tabName = "resumen",
              fluidRow(
                valueBoxOutput("total_tokens", width = 6),
                valueBoxOutput("top_termino", width = 6)
              ),
              fluidRow(
                box(title = "Top 10 Términos (Diseño Salinas)", status = "primary", solidHeader = TRUE, width = 12,
                    plotOutput("grafico_ricardo", height = "450px"))
              )
      ),
      
      # Pestaña 2: La nube ya limpia
      tabItem(tabName = "nube",
              fluidRow(
                box(title = "Nube de Palabras Política", status = "warning", solidHeader = TRUE, width = 12,
                    wordcloud2Output("nube_plot", height = "500px"))
              )
      ),
      
      # Pestaña 3: Tabla de frecuencias generales
      tabItem(tabName = "datos",
              fluidRow(
                box(title = "Frecuencia de Términos", status = "info", solidHeader = TRUE, width = 12,
                    DTOutput("tabla_tokens"))
              )
      )
    )
  )
)

# Servidor del Dashboard
server <- function(input, output) {
  
  output$total_tokens <- renderValueBox({
    valueBox(nrow(tokens_final), "Tokens Analizados", icon = icon("check-circle"), color = "green")
  })
  
  output$top_termino <- renderValueBox({
    termino_estrella <- top_10_palabras$palabra_final[1]
    valueBox(termino_estrella, "Término más frecuente", icon = icon("star"), color = "yellow")
  })
  
  # Llama al gráfico tal cual lo dejó Ricardo (con fondo khaki1)
  output$grafico_ricardo <- renderPlot({
    grafico_top10 
  })
  
  # Llama a la nube que acabas de limpiar en la sección 18
  output$nube_plot <- renderWordcloud2({
    nube_youtube
  })
  
  output$tabla_tokens <- renderDT({
    datatable(frecuencia_general, 
              options = list(pageLength = 10, scrollX = TRUE),
              colnames = c("Término Normalizado", "Frecuencia"))
  })
}

shinyApp(ui, server)
