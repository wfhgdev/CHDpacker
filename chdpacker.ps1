<#
.SYNOPSIS
    CHDPacker v1.0 - Automatizacion de compresion masiva con CHDMAN.
    Detecta formatos, salta archivos existentes y realiza limpieza segura.
    Version: 1.0
    Creado por: William Hernandez
#>

# Forzar codificacion estandar UTF-8 para evitar problemas de caracteres
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Cargar ensamblado para la interfaz grafica de carpetas
Add-Type -AssemblyName System.Windows.Forms

function Seleccionar-Carpeta($titulo) {
    $dialogo = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialogo.Description = $titulo
    $dialogo.ShowNewFolderButton = $true
    if ($dialogo.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialogo.SelectedPath
    }
    return $null
}

# Funcion para leer archivos .cue / .gdi y extraer unicamente sus pistas reales (.bin, .raw, etc.)
function Obtener-ArchivosVinculados($archivoReferencia) {
    $lista = @($archivoReferencia.FullName) # Incluye el propio archivo indice (.cue/.gdi/.iso/.cdr)
    $directorio = $archivoReferencia.DirectoryName
    
    if ($archivoReferencia.Extension.ToLower() -in @(".cue", ".gdi")) {
        if (Test-Path $archivoReferencia.FullName) {
            $lineas = Get-Content -Path $archivoReferencia.FullName
            foreach ($linea in $lineas) {
                # Caso 1: Nombres de archivo envueltos entre comillas dobles
                if ($linea -match '"([^"\r\n]+)"') {
                    $fName = $Matches[1]
                    $fullPath = Join-Path $directorio $fName
                    if (Test-Path $fullPath) { $lista += $fullPath }
                } else {
                    # Caso 2: Estructuras sin comillas (comun en algunos .gdi por columnas)
                    $partes = $linea.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
                    foreach ($parte in $partes) {
                        if ($parte -match '\.(bin|raw|wav|img|iso|track)$' -and ($parte -notmatch '\.(cue|gdi)$')) {
                            $fullPath = Join-Path $directorio $parte
                            if (Test-Path $fullPath) { $lista += $fullPath }
                        }
                    }
                }
            }
        }
    }
    return $lista | Select-Object -Unique
}

Clear-Host

# Banner Oficial solicitado por el usuario
$Banner = @'
======================================================
     _____ _    _ _____                   _             
    / ____| |  | |  __ \                 | |            
   | |    | |__| | |  | |_ __   __ _  ___| | _____ _ __ 
   | |    |  __  | |  | | '_ \ / _` |/ __| |/ / _ \ '__|
   | |____| |  | | |__| | |_) | (_| | (__|   <  __/ |   
    \_____|_|  |_|_____/| .__/ \__,_|\___|_|\_\___|_|   
                        | |                             
                        |_|                             
                                                
 >> Automatizacion de compresion CHDMAN
 >> Comprime imagenes de discos (como archivos .cue y .bin o ,cdi, .iso) en un unico archivo
 >> con formato CHD (Compressed Hunks of Data) sin perder ningun tipo de calidad.
 >> Creado por: William Hernandez
======================================================
'@

Write-Host $Banner -ForegroundColor Cyan
Write-Host ""

# 1. Seleccion de la carpeta de trabajo
Write-Host "[1/4] Selecciona la carpeta que contiene tus juegos (BIN/CUE, GDI, ISO, CDR)..." -ForegroundColor Yellow
$rutaTrabajo = Seleccionar-Carpeta "Selecciona la carpeta con las imagenes de disco (Se incluiran subcarpetas)"
if (-not $rutaTrabajo) {
    Write-Host "Operacion cancelada por el usuario." -ForegroundColor Red; exit
}
$rutaTrabajo = $rutaTrabajo.TrimEnd('\')
Write-Host "Carpeta de trabajo seleccionada: $rutaTrabajo" -ForegroundColor Green
Write-Host ""

# 2. Descarga y validacion de CHDMAN con mensaje de precaucion (Corregido color y caracteres)
$chdmanUrl = "https://github.com/wfhgdev/CHDpacker/raw/main/chdman.exe"
$chdmanExe = Join-Path $rutaTrabajo "chdman.exe"

if (-not (Test-Path $chdmanExe)) {
    Write-Host "==========================================================" -ForegroundColor Gray
    Write-Host " [PRECAUCION / WARNING NOTICE]" -ForegroundColor Yellow
    Write-Host " El script no detecto 'chdman.exe' en la carpeta elegida." -ForegroundColor Yellow
    Write-Host " Se procedera a descargar el ejecutable directamente desde" -ForegroundColor Yellow
    Write-Host " el repositorio oficial de GitHub de CHDpacker." -ForegroundColor Yellow
    Write-Host " Verifique que su conexion a Internet se encuentre activa." -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Gray
    Write-Host ""
    
    try {
        Write-Host "Descargando chdman.exe... Por favor, espera." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $chdmanUrl -OutFile $chdmanExe -ErrorAction Stop
        Write-Host "Descarga completada con exito! El archivo se movio a: $rutaTrabajo`n" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Hubo un problema al descargar chdman.exe automaticamente." -ForegroundColor Red
        Write-Host "Asegurate de tener conexion a internet o coloca chdman.exe manualmente." -ForegroundColor Red
        Pause; exit
    }
} else {
    Write-Host "[OK] chdman.exe ya se encuentra presente en la carpeta de trabajo." -ForegroundColor Green
    Write-Host ""
}

# 3. Preguntar por la eliminacion de archivos originales
$borrarOriginales = ""
while ($borrarOriginales -notin @("S", "N")) {
    $borrarOriginales = (Read-Host "[2/4] Deseas eliminar los archivos originales (.bin, .cue, .gdi, etc.) tras una compresion correcta? (S/N)").ToUpper().Trim()
}
Write-Host ""

# 4. Analizar la carpeta y buscar los archivos de entrada (indices y contenedores principales)
Write-Host "[3/4] Analizando archivos de la carpeta y subcarpetas..." -ForegroundColor Yellow
$formatosValidos = @(".cue", ".gdi", ".iso", ".cdr")
$juegosEncontrados = Get-ChildItem -Path $rutaTrabajo -File -Recurse | Where-Object { $_.Extension.ToLower() -in $formatosValidos }

if ($juegosEncontrados.Count -eq 0) {
    Write-Host "No se encontraron archivos validos (.cue, .gdi, .iso, .cdr) para procesar." -ForegroundColor Yellow
    Pause; exit
}
Write-Host "Se detectaron $($juegosEncontrados.Count) objetivos potenciales para procesar.`n" -ForegroundColor Green

# 5. Bucle de procesamiento de compresion masiva
Write-Host "[4/4] Iniciando el proceso de procesamiento masivo..." -ForegroundColor Cyan
Write-Host "------------------------------------------------------" -ForegroundColor Cyan

foreach ($file in $juegosEncontrados) {
    # Definir la ruta del archivo .chd de salida justo al lado del original
    $chdSalida = Join-Path $file.DirectoryName "$($file.BaseName).chd"
    
    Write-Host "Procesando: $($file.Name)" -ForegroundColor White
    
    # CONTROL ANTI-SOBRESCRITURA: Validar si ya existe el juego comprimido
    if (Test-Path $chdSalida) {
        Write-Host "   [SALTADO] El archivo .chd ya existe. Saltando al siguiente juego para ahorrar tiempo." -ForegroundColor Yellow
        Write-Host "------------------------------------------------------" -ForegroundColor Gray
        continue
    }

    # DETECCION AUTOMATICA DE COMANDO: createhd para DVDs (.iso), createcd para el resto
    if ($file.Extension.ToLower() -eq ".iso") {
        $comandoChd = "createhd"
    } else {
        $comandoChd = "createcd"
    }

    # Definir los argumentos usando la compresion automatica optimizada por defecto
    $argumentos = @($comandoChd, "-i", "`"$($file.FullName)`"", "-o", "`"$chdSalida`"")

    # Ejecutar CHDMAN de manera sincrona en la ventana de consola actual
    $proceso = Start-Process -FilePath $chdmanExe -ArgumentList $argumentos -Wait -NoNewWindow -PassThru

    # Verificacion de exito
    if ($proceso.ExitCode -eq 0 -and (Test-Path $chdSalida)) {
        Write-Host "   [OK] Compresion completada exitosamente -> $(Split-Path $chdSalida -Leaf)" -ForegroundColor Green
        
        # Limpieza analitica y segura de originales si el usuario lo aprobo
        if ($borrarOriginales -eq "S") {
            Write-Host "   [LIMPIEZA] Analizando pistas vinculadas para eliminacion segura..." -ForegroundColor Yellow
            $archivosAElminar = Obtener-ArchivosVinculados $file
            
            foreach ($archivoBorrar in $archivosAElminar) {
                if (Test-Path $archivoBorrar) {
                    # Doble comprobacion: Jamas borrar chdman.exe ni el recien creado .chd
                    if ($archivoBorrar -ne $chdmanExe -and $archivoBorrar -ne $chdSalida) {
                        Remove-Item -Path $archivoBorrar -Force
                        Write-Host "      -> Eliminado original: $(Split-Path $archivoBorrar -Leaf)" -ForegroundColor Gray
                    }
                }
            }
        }
    } else {
        Write-Host "   [ERROR] Fallo la compresion de $($file.Name). Revisa los detalles de la imagen de origen." -ForegroundColor Red
    }
    Write-Host "------------------------------------------------------" -ForegroundColor Gray
}

Write-Host "`nProceso de CHDPacker finalizado por completo!" -ForegroundColor Cyan
Pause