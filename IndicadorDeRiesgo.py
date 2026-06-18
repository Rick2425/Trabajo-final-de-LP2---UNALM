# ============================================================
# PROTOTIPO POO: SCORE DE IMPACTO EN COMENTARIOS DE YOUTUBE
# No guarda archivos. Solo muestra resultados en consola.
# ============================================================

import os
import re
import time
import unicodedata
from dataclasses import dataclass, field
from typing import List, Optional

import numpy as np
import pandas as pd


# ============================================================
# 1. CONFIGURACIÓN GENERAL
# ============================================================

@dataclass
class ConfiguracionProyecto:
    rutas_comentarios: List[str] = field(default_factory=lambda: [
        "data/raw/comentarios_youtube_raw.csv",
        "comentarios_youtube_raw.csv"
    ])

    columna_texto: str = "texto_comentario"
    columna_likes: str = "likes_comentario"
    columna_respuestas: str = "total_respuestas"
    columna_fecha: str = "fecha_comentario"
    columna_video: str = "titulo_video"
    columna_canal: str = "canal"


# ============================================================
# 2. UTILIDADES DE TEXTO
# ============================================================

class NormalizadorTexto:
    @staticmethod
    def quitar_tildes(texto: str) -> str:
        texto = str(texto)
        texto = unicodedata.normalize("NFD", texto)
        texto = texto.encode("ascii", "ignore")
        texto = texto.decode("utf-8")
        return texto

    @staticmethod
    def limpiar(texto: str) -> str:
        if pd.isna(texto):
            return ""

        texto = str(texto).lower()
        texto = NormalizadorTexto.quitar_tildes(texto)
        texto = re.sub(r"http\S+|www\S+", " ", texto)
        texto = re.sub(r"[^a-z0-9\s]", " ", texto)
        texto = re.sub(r"\s+", " ", texto).strip()

        return texto

    @staticmethod
    def contar_palabras(texto: str) -> int:
        texto = NormalizadorTexto.limpiar(texto)

        if texto == "":
            return 0

        return len(texto.split())

    @staticmethod
    def contar_exclamaciones_interrogaciones(texto: str) -> int:
        texto = str(texto)
        return (
            texto.count("!") +
            texto.count("¡") +
            texto.count("?") +
            texto.count("¿")
        )

    @staticmethod
    def proporcion_mayusculas(texto: str) -> float:
        texto = str(texto)
        letras = [c for c in texto if c.isalpha()]

        if len(letras) == 0:
            return 0

        mayusculas = [c for c in letras if c.isupper()]
        return len(mayusculas) / len(letras)

    @staticmethod
    def contiene_url(texto: str) -> bool:
        texto = str(texto).lower()
        return bool(re.search(r"http\S+|www\S+", texto))


# ============================================================
# 3. INTERFAZ DE CONSOLA
# ============================================================

class Consola:
    @staticmethod
    def cargar(mensaje: str, segundos: float = 1.2) -> None:
        pasos = 25
        pausa = segundos / pasos

        print(f"\n{mensaje}")
        print("[" + " " * pasos + "]", end="\r[")

        for _ in range(pasos):
            time.sleep(pausa)
            print("█", end="", flush=True)

        print("] 100%\n")

    @staticmethod
    def marco(titulo: str, contenido: str) -> None:
        ancho = 100
        print("\n" + "═" * ancho)
        print(titulo.center(ancho))
        print("═" * ancho)
        print(contenido)
        print("═" * ancho + "\n")


# ============================================================
# 4. CARGADOR DE DATOS
# ============================================================

class CargadorComentarios:
    def __init__(self, config: ConfiguracionProyecto):
        self.config = config

    def buscar_archivo(self) -> Optional[str]:
        for ruta in self.config.rutas_comentarios:
            if os.path.exists(ruta):
                return ruta

        return None

    def cargar(self) -> pd.DataFrame:
        ruta = self.buscar_archivo()

        if ruta is None:
            raise FileNotFoundError(
                "No se encontró comentarios_youtube_raw.csv. "
                "Colócalo en data/raw/ o en la carpeta actual."
            )

        datos = pd.read_csv(ruta)

        if self.config.columna_texto not in datos.columns:
            raise ValueError(
                f"El CSV debe contener la columna '{self.config.columna_texto}'."
            )

        return datos


# ============================================================
# 5. CALCULADOR DE SCORE DE IMPACTO
# ============================================================

class CalculadorImpacto:
    def __init__(self, config: ConfiguracionProyecto):
        self.config = config

    @staticmethod
    def normalizar_0_100(serie: pd.Series, log: bool = False) -> pd.Series:
        serie = pd.to_numeric(serie, errors="coerce").fillna(0)

        if log:
            serie = serie.apply(lambda x: max(x, 0))
            serie = pd.Series(
                np.log1p(serie),
                index=serie.index
            )

        minimo = serie.min()
        maximo = serie.max()

        if maximo == minimo:
            return pd.Series([0] * len(serie), index=serie.index)

        return 100 * (serie - minimo) / (maximo - minimo)

    @staticmethod
    def clasificar_score(score: float) -> str:
        if score >= 70:
            return "alto_impacto"
        elif score >= 40:
            return "impacto_medio"
        else:
            return "bajo_impacto"

    @staticmethod
    def detectar_perfil(row: pd.Series) -> str:
        if row["score_likes"] >= 75 and row["score_respuestas"] < 35:
            return "comentario_popular_sin_debate"

        if row["score_respuestas"] >= 70:
            return "comentario_con_debate"

        if row["score_intensidad"] >= 70:
            return "comentario_intenso"

        if row["numero_palabras"] >= 45 and row["score_intensidad"] < 40:
            return "comentario_extenso_argumentativo"

        if row["contiene_url"]:
            return "comentario_con_enlace"

        return "comentario_regular"

    def preparar_variables(self, datos: pd.DataFrame) -> pd.DataFrame:
        datos = datos.copy()

        if self.config.columna_likes not in datos.columns:
            datos[self.config.columna_likes] = 0

        if self.config.columna_respuestas not in datos.columns:
            datos[self.config.columna_respuestas] = 0

        if self.config.columna_fecha not in datos.columns:
            datos[self.config.columna_fecha] = pd.NaT

        datos[self.config.columna_likes] = pd.to_numeric(
            datos[self.config.columna_likes],
            errors="coerce"
        ).fillna(0)

        datos[self.config.columna_respuestas] = pd.to_numeric(
            datos[self.config.columna_respuestas],
            errors="coerce"
        ).fillna(0)

        datos["texto_limpio"] = datos[self.config.columna_texto].apply(
            NormalizadorTexto.limpiar
        )

        datos["numero_palabras"] = datos[self.config.columna_texto].apply(
            NormalizadorTexto.contar_palabras
        )

        datos["exclamaciones_interrogaciones"] = datos[self.config.columna_texto].apply(
            NormalizadorTexto.contar_exclamaciones_interrogaciones
        )

        datos["proporcion_mayusculas"] = datos[self.config.columna_texto].apply(
            NormalizadorTexto.proporcion_mayusculas
        )

        datos["contiene_url"] = datos[self.config.columna_texto].apply(
            NormalizadorTexto.contiene_url
        )

        datos["fecha_parseada"] = pd.to_datetime(
            datos[self.config.columna_fecha],
            errors="coerce",
            utc=True
        )

        return datos

    def calcular_recencia(self, datos: pd.DataFrame) -> pd.Series:
        fechas = datos["fecha_parseada"]

        if fechas.isna().all():
            return pd.Series([0] * len(datos), index=datos.index)

        fecha_maxima = fechas.max()
        dias = (fecha_maxima - fechas).dt.days

        dias = dias.fillna(dias.max())

        if dias.max() == dias.min():
            return pd.Series([100] * len(datos), index=datos.index)

        return 100 * (1 - (dias - dias.min()) / (dias.max() - dias.min()))

    def calcular(self, datos: pd.DataFrame) -> pd.DataFrame:
        datos = self.preparar_variables(datos)

        datos["score_likes"] = self.normalizar_0_100(
            datos[self.config.columna_likes],
            log=True
        )

        datos["score_respuestas"] = self.normalizar_0_100(
            datos[self.config.columna_respuestas],
            log=True
        )

        datos["score_longitud"] = datos["numero_palabras"].apply(
            lambda x: min((x / 60) * 100, 100)
        )

        datos["score_intensidad"] = (
            datos["exclamaciones_interrogaciones"] * 12 +
            datos["proporcion_mayusculas"] * 100
        ).clip(upper=100)

        datos["score_recencia"] = self.calcular_recencia(datos)

        datos["score_impacto"] = (
            0.40 * datos["score_likes"] +
            0.25 * datos["score_respuestas"] +
            0.15 * datos["score_intensidad"] +
            0.10 * datos["score_longitud"] +
            0.10 * datos["score_recencia"]
        ).round(2)

        datos["clasificacion_impacto"] = datos["score_impacto"].apply(
            self.clasificar_score
        )

        datos["perfil_comentario"] = datos.apply(
            self.detectar_perfil,
            axis=1
        )

        datos = datos.sort_values(
            by="score_impacto",
            ascending=False
        )

        return datos


# ============================================================
# 6. PIPELINE PRINCIPAL
# ============================================================

class PipelineImpactoYouTube:
    def __init__(self, config: ConfiguracionProyecto):
        self.config = config
        self.cargador = CargadorComentarios(config)
        self.calculador = CalculadorImpacto(config)

    def resumen_impacto(self, datos: pd.DataFrame) -> pd.DataFrame:
        resumen = datos["clasificacion_impacto"].value_counts().reset_index()
        resumen.columns = ["clasificacion_impacto", "cantidad"]

        resumen["porcentaje"] = round(
            100 * resumen["cantidad"] / resumen["cantidad"].sum(),
            1
        )

        return resumen

    def resumen_perfiles(self, datos: pd.DataFrame) -> pd.DataFrame:
        resumen = datos["perfil_comentario"].value_counts().reset_index()
        resumen.columns = ["perfil_comentario", "cantidad"]

        resumen["porcentaje"] = round(
            100 * resumen["cantidad"] / resumen["cantidad"].sum(),
            1
        )

        return resumen

    def resumen_videos(self, datos: pd.DataFrame) -> pd.DataFrame:
        columnas = [
            self.config.columna_video,
            self.config.columna_canal
        ]

        columnas_existentes = [
            col for col in columnas
            if col in datos.columns
        ]

        if len(columnas_existentes) == 0:
            return pd.DataFrame()

        resumen = (
            datos
            .groupby(columnas_existentes, dropna=False)
            .agg(
                comentarios=("texto_limpio", "count"),
                likes_totales=(self.config.columna_likes, "sum"),
                respuestas_totales=(self.config.columna_respuestas, "sum"),
                score_promedio=("score_impacto", "mean"),
                score_maximo=("score_impacto", "max")
            )
            .reset_index()
        )

        resumen["score_promedio"] = resumen["score_promedio"].round(2)

        resumen = resumen.sort_values(
            by=["score_promedio", "likes_totales"],
            ascending=False
        )

        return resumen.head(5)

    def comentarios_destacados(self, datos: pd.DataFrame) -> pd.DataFrame:
        columnas = [
            self.config.columna_texto,
            self.config.columna_likes,
            self.config.columna_respuestas,
            "score_impacto",
            "clasificacion_impacto",
            "perfil_comentario"
        ]

        columnas = [
            col for col in columnas
            if col in datos.columns
        ]

        return datos[columnas].head(5)

    def metricas_generales(self, datos: pd.DataFrame) -> str:
        total_comentarios = len(datos)
        total_likes = int(datos[self.config.columna_likes].sum())
        total_respuestas = int(datos[self.config.columna_respuestas].sum())

        promedio_likes = round(datos[self.config.columna_likes].mean(), 2)
        promedio_respuestas = round(datos[self.config.columna_respuestas].mean(), 2)

        comentario_mas_likeado = int(datos[self.config.columna_likes].max())
        comentario_mas_respondido = int(datos[self.config.columna_respuestas].max())

        score_promedio = round(datos["score_impacto"].mean(), 2)
        score_maximo = round(datos["score_impacto"].max(), 2)

        return f"""
Comentarios analizados: {total_comentarios}
Likes totales en comentarios: {total_likes}
Respuestas totales en comentarios: {total_respuestas}

Promedio de likes por comentario: {promedio_likes}
Promedio de respuestas por comentario: {promedio_respuestas}

Máximo de likes en un comentario: {comentario_mas_likeado}
Máximo de respuestas en un comentario: {comentario_mas_respondido}

Score promedio de impacto: {score_promedio}
Score máximo de impacto: {score_maximo}
"""

    def mostrar_resultados(self, datos: pd.DataFrame, tiempo_total: float) -> None:
        resumen_impacto = self.resumen_impacto(datos)
        resumen_perfiles = self.resumen_perfiles(datos)
        resumen_videos = self.resumen_videos(datos)
        comentarios_top = self.comentarios_destacados(datos)

        contenido = f"""
TIEMPO DE EJECUCIÓN:
{tiempo_total:.2f} segundos

MÉTRICAS GENERALES:
{self.metricas_generales(datos)}

DISTRIBUCIÓN DEL SCORE DE IMPACTO:
{resumen_impacto.to_string(index=False)}

PERFILES DETECTADOS:
{resumen_perfiles.to_string(index=False)}

TOP 5 VIDEOS POR SCORE PROMEDIO:
{resumen_videos.to_string(index=False, max_colwidth=45)}

TOP 5 COMENTARIOS CON MAYOR IMPACTO:
{comentarios_top.to_string(index=False, max_colwidth=45)}
"""

        Consola.marco(
            "RESULTADOS DEL SCORE DE IMPACTO EN COMENTARIOS DE YOUTUBE",
            contenido
        )

    def ejecutar(self) -> pd.DataFrame:
        inicio = time.time()

        Consola.cargar("Cargando comentarios", segundos=1.0)
        datos = self.cargador.cargar()

        Consola.cargar("Calculando variables de interacción", segundos=1.2)
        datos = self.calculador.calcular(datos)

        Consola.cargar("Construyendo marco de resultados", segundos=0.8)

        fin = time.time()
        tiempo_total = fin - inicio

        self.mostrar_resultados(datos, tiempo_total)

        return datos


# ============================================================
# 7. EJECUCIÓN
# ============================================================

if __name__ == "__main__":
    config = ConfiguracionProyecto()
    pipeline = PipelineImpactoYouTube(config)
    resultado = pipeline.ejecutar()