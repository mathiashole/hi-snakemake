# hi-snakemake

pipeline en Snakemake para validar archivos FASTA, calcular GC%, calcular largo de secuencia, obtener composición nucleotídica, combinar las tablas y generar un reporte automático en Quarto creando una web.

## Pixi entorno reproducible (opcional pero recomendado)

Pixi es un gestor de entornos simple y rápido, similar a Conda, que garantiza que Snakemake y todas las dependencias del pipeline funcionen igual en cualquier computadora.

## Instalar Pixi (1 comando)

```{bash, eval = FALSE}
curl -fsSL https://pixi.sh/install.sh | bash
```

y luego

```{bash, eval = FALSE}
echo 'export PATH="/ruta actual/.pixi/bin:$PATH"' >> ~/.bashrc # agrega pixi al PATH
source ~/.bashrc # recarga el .bashrc
```
Esto permite usar el comando `pixi` en cualquier lugar de la terminal. El método de instalación varía según el sistema operativo, para más detalles visita **pixi**[el sitio de pixi](https://pixi.sh/#/install)