// ******  Datos administrativos  *******************
// Nombre del archivo: constantes.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Buscaminas
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Define todas las constantes globales del proyecto:
// estados de celdas, mensajes de interfaz de usuario,
// y sus respectivas longitudes para syscalls.
// ******  Versión  **********************************
// 01 | 2025-10-13 | Roymar Castillo - Versión final
// ***************************************************

.section .data

// Estados de celda del tablero
    .global ESTADO_OCULTA, ESTADO_DESCUBIERTA, ESTADO_BANDERA
ESTADO_OCULTA:      .quad 0  // Estado inicial de celda sin revelar
ESTADO_DESCUBIERTA: .quad 1  // Celda revelada por el jugador
ESTADO_BANDERA:     .quad 2  // Celda marcada con bandera


// Mensaje de bienvenida y salida
.global Bienvenida, LargoBienvenidaVal
.global MensajeSalir, LargoMensajeSalirVal

Bienvenida:  // Mensaje de inicio del programa
    .asciz "==============================\nBIENVENIDO A BUSCAMINAS ARM64\n==============================\n"
LargoBienvenidaVal: .quad 92

MensajeSalir:  // Mensaje al terminar ejecución
    .asciz "\nSaliendo del juego...\n"
LargoMensajeSalirVal: .quad 23

// Menú principal
.global Menu, LargoMenuVal
.global MensajeErrorSeleccion, LargoMensajeErrorSeleccionVal

Menu:  // Menú de selección de dificultad
    .asciz "==============================\nSELECCIONE DIFICULTAD\n==============================\n1. Principiante (8x8, 10 minas)\n2. Intermedio   (16x16, 40 minas)\n3. Experto      (30x16, 99 minas)\n4. Personalizada\n5. Salir\n==============================\nOpción: "
LargoMenuVal: .quad 249

MensajeErrorSeleccion:  // Error al ingresar opción inválida
    .asciz "\nOpcion invalida. Intente de nuevo: "
LargoMensajeErrorSeleccionVal: .quad 36

// Configuración personalizada

.global MensajeFilas, LargoMensajeFilasVal
.global MensajeColumnas, LargoMensajeColumnasVal
.global MensajeMinas, LargoMensajeMinasVal
.global MensajeErrorCantidadFilas, LargoMensajeErrorCantidadFilasVal
.global MensajeErrorCantidadColumnas, LargoMensajeErrorCantidadColumnasVal
.global MensajeErrorCantidadMinas, LargoMensajeErrorCantidadMinasVal

MensajeFilas:  // Solicitud de cantidad de filas
    .asciz "Ingrese filas (8-30): "
LargoMensajeFilasVal: .quad 22

MensajeColumnas:  // Solicitud de cantidad de columnas
    .asciz "Ingrese columnas (8-24): "
LargoMensajeColumnasVal: .quad 25

MensajeMinas:  // Solicitud de cantidad de minas
    .asciz "Ingrese cantidad de minas: "
LargoMensajeMinasVal: .quad 27

MensajeErrorCantidadFilas:  // Error #01: Filas fuera de rango
    .asciz "\nLa cantidad de filas no está en el rango (8-30).\n"
LargoMensajeErrorCantidadFilasVal: .quad 50

MensajeErrorCantidadColumnas:  // Error #02: Columnas fuera de rango
    .asciz "\nLa cantidad de columnas no está en el rango (8-24).\n"
LargoMensajeErrorCantidadColumnasVal: .quad 53

MensajeErrorCantidadMinas:  // Error #03: Demasiadas minas para el tablero
    .asciz "\nLa cantidad de minas no debe ser mayor a (filas-1 * columnas-1).\n"
LargoMensajeErrorCantidadMinasVal: .quad 66


// Menú de acciones en partida
.global MenuAccion, LargoMenuAccionVal
.global MensajeFila, LargoMensajeFilaVal
.global MensajeColumna, LargoMensajeColumnaVal
.global MensajeErrorFila, LargoMensajeErrorFilaVal
.global MensajeErrorColumna, LargoMensajeErrorColumnaVal

MenuAccion:  // Opciones durante el juego
    .asciz "\n1. Descubrir celda\n2. Colocar/Quitar bandera\n3. Volver al menu\nOpcion: "
LargoMenuAccionVal: .quad 72

MensajeFila:  // Solicitud de número de fila
    .asciz "Fila: "
LargoMensajeFilaVal: .quad 6

MensajeColumna:  // Solicitud de número de columna
    .asciz "Columna: "
LargoMensajeColumnaVal: .quad 9

MensajeErrorFila:  // Error #04: Fila inválida durante juego
    .asciz "Fila invalida. Intente de nuevo.\n"
LargoMensajeErrorFilaVal: .quad 34

MensajeErrorColumna:  // Error #05: Columna inválida durante juego
    .asciz "Columna invalida. Intente de nuevo.\n"
LargoMensajeErrorColumnaVal: .quad 37


// Mensajes de fin de juego
.global MensajeDerrota, LargoMensajeDerrotaVal
.global MensajeVictoria, LargoMensajeVictoriaVal

MensajeDerrota:  // Mensaje al perder (pisar mina)
    .asciz "\nBOOM! Has pisado una mina. Juego terminado.\n"
LargoMensajeDerrotaVal: .quad 45

MensajeVictoria:  // Mensaje al ganar (despejar tablero)
    .asciz "\nFelicidades, has despejado todo el tablero. ¡Victoria!\n"
LargoMensajeVictoriaVal: .quad 57


// Símbolos del tablero
.global SimboloVacio, LargoSimboloVacioVal
.global SimboloMina, LargoSimboloMinaVal
.global SimboloBandera, LargoSimboloBanderaVal
.global NuevaLinea, LargoNuevaLineaVal
.global Espacio, LargoEspacioVal

SimboloVacio:  // Caracter para celda sin revelar
    .asciz "#"
LargoSimboloVacioVal: .quad 1

SimboloMina:  // Caracter para mina revelada
    .asciz "@"
LargoSimboloMinaVal: .quad 1

SimboloBandera:  // Caracter para bandera colocada
    .asciz "!"
LargoSimboloBanderaVal: .quad 1

NuevaLinea:  // Caracter de salto de línea
    .asciz "\n"
LargoNuevaLineaVal: .quad 1

Espacio:  // Caracter para celda vacía revelada
    .asciz "_"
LargoEspacioVal: .quad 1
