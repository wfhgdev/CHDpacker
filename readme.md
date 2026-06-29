# CHDPacker 🚀

```text
======================================================
     _____ _    _ _____                    _             
    / ____| |  | |  __ \                  | |            
   | |    | |__| | |  | |_ __   __ _  ___| | _____ _ __ 
   | |    |  __  | |  | | '_ \ / _` |/ __| |/ / _ \ '__|
   | |____| |  | | |__| | |_) | (_| | (__|   <  __/ |   
    \_____|_|  |_|_____/| .__/ \__,_|\___|_|\_\___|_|   
                        | |                             
                        |_|                             
                                                
 >> Automatización de compresión CHDMAN
 >> Creado por: William Hernandez
======================================================

```

CHDPacker es un script avanzado e interactivo de PowerShell diseñado para automatizar la compresión masiva de imágenes de disco al formato **CHD** utilizando el motor de **CHDMAN**. Es la herramienta ideal para entusiastas del retro-gaming y la emulación (PlayStation 1, Saturn, Dreamcast, PlayStation 2, etc.) que buscan ahorrar hasta un 60% de espacio en disco de forma segura, rápida y organizada.

---

## ✨ Características Principales

* **Descarga Automática Inteligente:** Si el script no detecta el archivo `chdman.exe` en tu directorio de trabajo, lo descarga de manera automática y segura en segundo plano desde el repositorio oficial.
* **Interfaz Gráfica Integrada (GUI):** Selecciona cómodamente la carpeta que deseas procesar mediante ventanas emergentes nativas de Windows, sin necesidad de escribir rutas manualmente.
* **Análisis Recursivo Completo:** Escanea minuciosamente y procesa todos los archivos válidos presentes en la carpeta raíz seleccionada y en todas sus subcarpetas anidadas.
* **Detección Automática de Comandos:** Identifica de forma inteligente el tipo de archivo de origen para aplicar el comando óptimo de CHDMAN (`createhd` para archivos `.iso` y `createcd` para formatos `.cue`, `.gdi` y `.cdr`).
* **Compresión Máxima por Defecto:** Utiliza el perfil de compresión automático optimizado de CHDMAN (con códecs LZMA, Deflate y FLAC), garantizando la mayor tasa de compresión matemáticamente estable sin pérdida de calidad.
* **Escudo Anti-Sobrescritura:** Si cancelas el proceso o lo ejecutas por segunda vez, el script detectará qué juegos ya disponen de su archivo `.chd` creado y saltará directamente a los nuevos para ahorrarte tiempo.
* **Mantenimiento de Estructura:** El script localiza los archivos sin importar qué tan profundo estén organizados y guardará el archivo `.chd` resultante justo al lado de las pistas originales.
* **Limpieza Analítica y Segura:** Si decides borrar los originales tras una compresión correcta, el script lee el índice interno del archivo `.cue` o `.gdi` para eliminar **únicamente** los archivos reales vinculados (`.bin`, `.raw`, etc.), protegiendo cualquier otro archivo que se encuentre en la misma carpeta.
* **Codificación UTF-8 Nativa:** Optimizado para evitar problemas visuales con acentos, eñes o caracteres especiales en la consola de Windows.

---

## 🛠️ Requisitos Previos

* **Sistema Operativo:** Windows 10 o Windows 11.
* **Consola:** Windows PowerShell 5.1 o superior.
* **Conexión a Internet:** Requerida únicamente si el script necesita descargar el ejecutable `chdman.exe` por primera vez.

---

## 🚀 Modo de Uso

1. **Descarga el script:** Guarda el archivo `CHDPacker.ps1` en tu equipo.
2. **Desbloquea el archivo (Opcional):** Si Windows bloquea el script por seguridad al haber sido descargado de Internet, haz clic derecho sobre `CHDPacker.ps1`, selecciona **Propiedades**, marca la casilla **Desbloquear** y haz clic en **Aceptar**.
3. **Ejecución:**
* Haz clic derecho sobre el archivo `CHDPacker.ps1` y selecciona **Ejecutar con PowerShell**.
* *Alternativa desde la consola:* Abre tu terminal de PowerShell, navega hasta la ubicación del script y ejecútalo con:
```powershell
.\CHDPacker.ps1

```


> 💡 **Nota sobre Políticas de Ejecución:** Si PowerShell muestra un error indicando que la ejecución de scripts está deshabilitada en tu sistema, puedes solucionarlo abriendo una consola de PowerShell (como Administrador) y ejecutando el siguiente comando una sola vez:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> 
> ```
> 
> 

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Siéntete libre de modificarlo, distribuirlo y adaptarlo a tus necesidades de preservación y emulación.

---

Desarrollado con ❤️ por **William Hernandez**

```

```