// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_constantes.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Define todas las constantes globales del proyecto:
// dimensiones del tablero, estados de celdas, tipos
// de embarcaciones, tipos de misiles, direcciones,
// y todos los mensajes de interfaz de usuario.
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

.section .data

// ============================================
// DIMENSIONES DEL TABLERO
// ============================================
.global FILAS, COLUMNAS, TOTAL_CELDAS
FILAS:          .quad 10    // Filas A-J
COLUMNAS:       .quad 14    // Columnas 1-14
TOTAL_CELDAS:   .quad 140   // 10 × 14

// ============================================
// ESTADOS DE CELDA - TABLERO PROPIO
// ============================================
// ESTADOS DE CELDA - TABLERO PROPIO (LEGACY - mantener compatibilidad)
// ============================================
.global ESTADO_VACIA, ESTADO_VACIA_IMPACTADA
.global ESTADO_BARCO, ESTADO_BARCO_IMPACTADO

ESTADO_VACIA:           .quad 0  // Agua sin impactar
ESTADO_VACIA_IMPACTADA: .quad 1  // Agua impactada por enemigo
ESTADO_BARCO:           .quad 2  // Barco sin impactar
ESTADO_BARCO_IMPACTADO: .quad 3  // Barco impactado

// ============================================
// NUEVA ESTRUCTURA DE CELDA [descubierto, tipo, id_barco]
// ============================================
.global CELDA_DESCUBIERTO_NO, CELDA_DESCUBIERTO_SI
CELDA_DESCUBIERTO_NO:   .quad 0  // No visible (barcos IA)
CELDA_DESCUBIERTO_SI:   .quad 1  // Visible (barcos jugador o explorado)

.global CELDA_TIPO_AGUA, CELDA_TIPO_AGUA_IMPACT
.global CELDA_TIPO_BARCO, CELDA_TIPO_BARCO_IMPACT
CELDA_TIPO_AGUA:        .quad 0  // Agua limpia
CELDA_TIPO_AGUA_IMPACT: .quad 1  // Agua impactada
CELDA_TIPO_BARCO:       .quad 2  // Barco intacto
CELDA_TIPO_BARCO_IMPACT:.quad 3  // Barco impactado

.global CELDA_ID_NINGUNO
CELDA_ID_NINGUNO:       .quad 0  // Sin barco (agua)

// ============================================
// ESTADOS DE CELDA - TABLERO ENEMIGO
// ============================================
.global ESTADO_DESCONOCIDA, ESTADO_ENEMIGO_AGUA, ESTADO_ENEMIGO_BARCO
ESTADO_DESCONOCIDA:     .quad 0  // Celda no explorada (fog of war)
ESTADO_ENEMIGO_AGUA:    .quad 1  // Disparo al agua
ESTADO_ENEMIGO_BARCO:   .quad 2  // Disparo a barco

// ============================================
// TIPOS DE EMBARCACIONES
// ============================================
.global TIPO_PORTAVIONES, TIPO_ACORAZADO, TIPO_DESTRUCTOR
.global TIPO_SUBMARINO, TIPO_PATRULLERO, NUM_BARCOS

TIPO_PORTAVIONES: .quad 0  // Aircraft Carrier - 5 celdas
TIPO_ACORAZADO:   .quad 1  // Battleship - 4 celdas
TIPO_DESTRUCTOR:  .quad 2  // Destroyer - 3 celdas
TIPO_SUBMARINO:   .quad 3  // Submarine - 3 celdas
TIPO_PATRULLERO:  .quad 4  // Patrol Boat - 2 celdas
NUM_BARCOS:       .quad 5  // Total de barcos por jugador

// ============================================
// IDs DE EMBARCACIONES (para tracking)
// ============================================
.global ID_PORTAVIONES, ID_ACORAZADO, ID_DESTRUCTOR
.global ID_SUBMARINO, ID_PATRULLERO

ID_PORTAVIONES: .quad 1  // ID único para Portaviones
ID_ACORAZADO:   .quad 2  // ID único para Acorazado
ID_DESTRUCTOR:  .quad 3  // ID único para Destructor
ID_SUBMARINO:   .quad 4  // ID único para Submarino
ID_PATRULLERO:  .quad 5  // ID único para Patrullero

// ============================================
// TAMAÑOS DE EMBARCACIONES
// ============================================
.global TAMANO_PORTAVIONES, TAMANO_ACORAZADO, TAMANO_DESTRUCTOR
.global TAMANO_SUBMARINO, TAMANO_PATRULLERO

TAMANO_PORTAVIONES: .quad 5
TAMANO_ACORAZADO:   .quad 4
TAMANO_DESTRUCTOR:  .quad 3
TAMANO_SUBMARINO:   .quad 3
TAMANO_PATRULLERO:  .quad 2

// Array de tamaños indexado por ID [0, 5, 4, 3, 3, 2]
.global TamanosPorID
TamanosPorID:
    .quad 0  // ID 0: ninguno
    .quad 5  // ID 1: Portaviones
    .quad 4  // ID 2: Acorazado
    .quad 3  // ID 3: Destructor
    .quad 3  // ID 4: Submarino
    .quad 2  // ID 5: Patrullero

// ============================================
// TIPOS DE MISILES
// ============================================
.global MISIL_ESTANDAR, MISIL_EXOCET, MISIL_TOMAHAWK
.global MISIL_APACHE, MISIL_TORPEDO

MISIL_ESTANDAR:  .quad 0  // Ilimitado - 1 celda
MISIL_EXOCET:    .quad 1  // Portaviones - 2 disponibles
MISIL_TOMAHAWK:  .quad 2  // Acorazado - 1 disponible
MISIL_APACHE:    .quad 3  // Destructor - 2 disponibles
MISIL_TORPEDO:   .quad 4  // Submarino - 2 disponibles

// ============================================
// MUNICIÓN INICIAL POR TIPO DE MISIL
// ============================================
.global MUNICION_EXOCET, MUNICION_TOMAHAWK
.global MUNICION_APACHE, MUNICION_TORPEDO

MUNICION_EXOCET:    .quad 2  // Portaviones
MUNICION_TOMAHAWK:  .quad 1  // Acorazado
MUNICION_APACHE:    .quad 2  // Destructor
MUNICION_TORPEDO:   .quad 2  // Submarino

// ============================================
// PATRONES DE ATAQUE
// ============================================
.global PATRON_EXOCET_1, PATRON_EXOCET_2
.global PATRON_APACHE_1, PATRON_APACHE_2

PATRON_EXOCET_1: .quad 1  // Patrón en X
PATRON_EXOCET_2: .quad 2  // Patrón en cruz
PATRON_APACHE_1: .quad 1  // Patrón horizontal
PATRON_APACHE_2: .quad 2  // Patrón vertical

// ============================================
// DIRECCIONES (para torpedos)
// ============================================
.global DIR_NORTE, DIR_SUR, DIR_ESTE, DIR_OESTE

DIR_NORTE: .quad 0  // Torpedo viene desde arriba (fila A) y viaja hacia abajo
DIR_SUR:   .quad 1  // Torpedo viene desde abajo (fila J) y viaja hacia arriba
DIR_ESTE:  .quad 2  // Torpedo viene desde derecha (columna 14) y viaja hacia izquierda
DIR_OESTE: .quad 3  // Torpedo viene desde izquierda (columna 1) y viaja hacia derecha

// ============================================
// ORIENTACIONES DE BARCOS
// ============================================
.global ORIENTACION_HORIZONTAL, ORIENTACION_VERTICAL

ORIENTACION_HORIZONTAL: .quad 0
ORIENTACION_VERTICAL:   .quad 1

// ============================================
// ESTADOS DE BARCO
// ============================================
.global BARCO_ACTIVO, BARCO_HUNDIDO

BARCO_ACTIVO:  .quad 0
BARCO_HUNDIDO: .quad 1

// ============================================
// SÍMBOLOS VISUALES - TABLERO PROPIO
// ============================================
.global SimboloAgua, SimboloAguaImpactada
.global SimboloBarco, SimboloBarcoImpactado

SimboloAgua:           .asciz "~"  // Agua
SimboloAguaImpactada:  .asciz "O"  // Agua con impacto enemigo
SimboloBarco:          .asciz "B"  // Barco propio
SimboloBarcoImpactado: .asciz "X"  // Barco propio impactado

// ============================================
// SÍMBOLOS VISUALES - TABLERO ENEMIGO
// ============================================
.global SimboloDesconocida, SimboloEnemigoAgua
.global SimboloEnemigoBarco, SimboloTorpedo

SimboloDesconocida:  .asciz "."  // Celda no explorada
SimboloEnemigoAgua:  .asciz "O"  // Disparo fallido
SimboloEnemigoBarco: .asciz "X"  // Barco enemigo impactado
SimboloTorpedo:      .asciz "T"  // Trayectoria de torpedo

// ============================================
// SÍMBOLOS DE INTERFAZ
// ============================================
.global Espacio, SaltoLinea, Separador, DosPuntos
.global MensajeDebugTamano, MensajeDebugImpactos

Espacio:     .asciz " "
SaltoLinea:  .asciz "\n"
Separador:   .asciz " | "
DosPuntos:   .asciz ": "

// Mensajes de debug
MensajeDebugTamano:   .asciz "Tamaño: "
MensajeDebugImpactos: .asciz "Impactos: "

// ============================================
// CÓDIGOS ANSI PARA COLORES (opcional)
// ============================================
.global ColorReset, ColorRojo, ColorVerde, ColorAzul, ColorAmarillo

ColorReset:    .asciz "\033[0m"
ColorRojo:     .asciz "\033[31m"
ColorVerde:    .asciz "\033[32m"
ColorAzul:     .asciz "\033[34m"
ColorAmarillo: .asciz "\033[33m"

// ============================================
// MENSAJE DE DEBUG
// ============================================
.global MensajeDebugRetorno, LargoMensajeDebugRetornoVal
.global DebugMsgStack1, LargoDebugMsgStack1Val
.global DebugMsgStack2, LargoDebugMsgStack2Val
.global DebugMsgStack3, LargoDebugMsgStack3Val
.global DebugMsgStack4, LargoDebugMsgStack4Val
.global DebugMsgEntry1, LargoDebugMsgEntry1Val
.global DebugMsgEntry2, LargoDebugMsgEntry2Val
.global MensajeDebugTablero, EncabezadoColumnas

MensajeDebugRetorno:
    .asciz "[DEBUG] Retorno exitoso de lanzar misil\n"
LargoMensajeDebugRetornoVal: .quad 41

MensajeDebugTablero:
    .asciz "\n[DEBUG] TABLERO ENEMIGO (revelado):\n"

EncabezadoColumnas:
    .asciz "    1  2  3  4  5  6  7  8  9 10 11 12 13 14\n"

DebugMsgEntry1:
    .asciz "[DEBUG ENTRY] x29 al entrar: "
LargoDebugMsgEntry1Val: .quad 29

DebugMsgEntry2:
    .asciz "[DEBUG ENTRY] x30 al entrar: "
LargoDebugMsgEntry2Val: .quad 29

DebugMsgStack1:
    .asciz "[DEBUG] SP actual: "
LargoDebugMsgStack1Val: .quad 19

DebugMsgStack2:
    .asciz "[DEBUG] x29 guardado en [sp,#0]: "
LargoDebugMsgStack2Val: .quad 33

DebugMsgStack3:
    .asciz "[DEBUG] x30 guardado en [sp,#8]: "
LargoDebugMsgStack3Val: .quad 33

DebugMsgStack4:
    .asciz "[DEBUG] Intentando retornar...\n"
LargoDebugMsgStack4Val: .quad 31

// ============================================
// MENSAJE DE BIENVENIDA
// ============================================
.global MensajeBienvenida, LargoMensajeBienvenidaVal

MensajeBienvenida:
    .asciz "\n============================================================\n                                                            \n            BATTLESHIP: ADVANCED MISSION                    \n                                                            \n              Version ARM64 Assembly                        \n                                                            \n============================================================\n\n"
LargoMensajeBienvenidaVal: .quad 429

// ============================================
// MENSAJE DE CRÉDITOS
// ============================================
.global MensajeCreditos, LargoMensajeCreditosVal

MensajeCreditos:
    .asciz "    Desarrollado por: Roymar Castillo\n    Institucion: Instituto Tecnologico de Costa Rica\n    Proyecto: Programacion en Bajo Nivel - ARM64\n    Ano: 2025\n\n"
LargoMensajeCreditosVal: .quad 155

// ============================================
// MENSAJE DE INSTRUCCIONES GENERALES
// ============================================
.global MensajeInstrucciones, LargoMensajeInstruccionesVal

MensajeInstrucciones:
    .asciz "============================================================\n                    COMO JUGAR?                            \n============================================================\n\n  OBJETIVO:\n    Hundir toda la flota enemiga antes de que destruyan la tuya\n\n  TABLERO:\n    - Dimensiones: 10 filas (A-J) x 14 columnas (1-14)\n    - Coordenadas: Letra + Numero (ejemplo: D7, A1, J14)\n\n  FASES DEL JUEGO:\n    1. PREPARACION: Coloca tus 5 barcos en el tablero\n    2. COMBATE: Alterna turnos con el enemigo atacando\n\n  SIMBOLOS:\n    ~  = Agua sin explorar\n    O  = Disparo al agua (fallo)\n    B  = Tu barco (sin dano)\n    X  = Impacto en barco\n    .  = Zona enemiga sin explorar (niebla de guerra)\n\n"
LargoMensajeInstruccionesVal: .quad 695

// ============================================
// DESCRIPCIÓN DE BARCOS
// ============================================
.global MensajeDescripcionBarcos, LargoMensajeDescripcionBarcosVal

MensajeDescripcionBarcos:
    .asciz "============================================================\n                    TUS EMBARCACIONES                       \n============================================================\n\n  1. PORTAVIONES (5 celdas)\n     - Armamento: 2 Misiles Exocet (patron especial)\n\n  2. ACORAZADO (4 celdas)\n     - Armamento: 1 Misil Tomahawk (area 3x3)\n\n  3. DESTRUCTOR (3 celdas)\n     - Armamento: 2 Misiles Apache (patron especial)\n\n  4. SUBMARINO (3 celdas)\n     - Armamento: 2 Torpedos (linea completa)\n\n  5. PATRULLERO (2 celdas)\n     - Armamento: Misiles estandar unicamente\n\n"
LargoMensajeDescripcionBarcosVal: .quad 567

// ============================================
// DESCRIPCIÓN DE MISILES
// ============================================
.global MensajeDescripcionMisiles, LargoMensajeDescripcionMisilesVal

MensajeDescripcionMisiles:
    .asciz "============================================================\n                   TIPOS DE ARMAMENTO                       \n============================================================\n\n   MISIL ESTANDAR\n      Alcance: 1 celda\n      Municion: ILIMITADA\n      Disponible en: Todos los barcos\n   MISIL EXOCET (del Portaviones)\n      Alcance: Patron especial de 5 celdas\n      Municion: 2 disparos\n      Patrones: X (esquinas) o + (cruz)\n   MISIL TOMAHAWK (del Acorazado)\n      Alcance: Area 3x3 (9 celdas)\n      Municion: 1 disparo\n      Efecto: Bombardeo masivo\n   MISIL APACHE (del Destructor)\n      Alcance: Patron especial de 3-4 celdas\n      Municion: 2 disparos\n      Patrones: Horizontal o Vertical\n   TORPEDO (del Submarino)\n      Alcance: Linea completa desde el borde\n      Municion: 2 disparos\n      Direcciones: Norte, Sur, Este, Oeste\n    NOTA: Los misiles especiales son limitados.\n            Usalos estrategicamente!\n"
LargoMensajeDescripcionMisilesVal: .quad 929

// ============================================
// MENSAJE DE DESPEDIDA
// ============================================
.global MensajeDespedida, LargoMensajeDespedidaVal

MensajeDespedida:
    .asciz "\n============================================================\n                                                            \n          Gracias por jugar Battleship ARM64                \n                                                            \n              Hasta la proxima batalla!                    \n                                                            \n============================================================\n\n"
LargoMensajeDespedidaVal: .quad 428

// ============================================
// MENSAJES DE COLOCACIÓN DE BARCOS
// ============================================
.global MensajeColocacion, LargoMensajeColocacionVal
.global MensajePortaviones, LargoMensajePortavionesVal
.global MensajeAcorazado, LargoMensajeAcorazadoVal
.global MensajeDestructor, LargoMensajeDestructorVal
.global MensajeSubmarino, LargoMensajeSubmarinoVal
.global MensajePatrullero, LargoMensajePatrulleroVal

MensajeColocacion:
    .asciz "\n========================================\n      FASE DE COLOCACION DE BARCOS      \n========================================\n\n"
LargoMensajeColocacionVal: .quad 125

MensajePortaviones:
    .asciz "\n PORTAVIONES (5 celdas)\n  Misiles: 2 Exocet\n"
LargoMensajePortavionesVal: .quad 45

MensajeAcorazado:
    .asciz "\n ACORAZADO (4 celdas)\n  Misiles: 1 Tomahawk (area 3x3)\n"
LargoMensajeAcorazadoVal: .quad 56

MensajeDestructor:
    .asciz "\n DESTRUCTOR (3 celdas)\n  Misiles: 2 Apache\n"
LargoMensajeDestructorVal: .quad 44

MensajeSubmarino:
    .asciz "\n SUBMARINO (3 celdas)\n  Armas: 2 Torpedos\n"
LargoMensajeSubmarinoVal: .quad 43

MensajePatrullero:
    .asciz "\n PATRULLERO (2 celdas)\n  Misiles: Solo estandar\n"
LargoMensajePatrulleroVal: .quad 49

// ============================================
// MENSAJES DE SOLICITUD DE COORDENADAS
// ============================================
.global MensajeProa, LargoMensajePraoVal
.global MensajePopa, LargoMensajePopaVal

MensajeProa:
    .asciz "  Ingrese coordenada de PROA (ej: A1): "
LargoMensajePraoVal: .quad 39

MensajePopa:
    .asciz "  Ingrese coordenada de POPA (ej: A5): "
LargoMensajePopaVal: .quad 39

// ============================================
// MENSAJES DE ERROR - COLOCACIÓN
// ============================================
.global ErrorFormatoCoord, LargoErrorFormatoCoorVal
.global ErrorFueraRango, LargoErrorFueraRangoVal
.global ErrorOrientacion, LargoErrorOrientacionVal
.global ErrorDistancia, LargoErrorDistanciaVal
.global ErrorSolapamiento, LargoErrorSolapamientoVal

ErrorFormatoCoord:
    .asciz "\n ERROR: Formato invalido. Use letra (A-J) + numero (1-14)\n"
LargoErrorFormatoCoorVal: .quad 59

ErrorFueraRango:
    .asciz "\n ERROR: Coordenada fuera del tablero (A-J, 1-14)\n"
LargoErrorFueraRangoVal: .quad 50

ErrorOrientacion:
    .asciz "\n ERROR: El barco debe estar horizontal o vertical (no diagonal)\n"
LargoErrorOrientacionVal: .quad 65

ErrorDistancia:
    .asciz "\n ERROR: La distancia no corresponde al tamano del barco\n"
LargoErrorDistanciaVal: .quad 57

ErrorSolapamiento:
    .asciz "\n ERROR: El barco se solapa con otra embarcacion existente\n"
LargoErrorSolapamientoVal: .quad 59

// ============================================
// MENSAJES DE COMBATE - MENÚ DE MISILES
// ============================================
.global MenuMisiles, LargoMenuMisilesVal
.global OpcionEstandar, LargoOpcionEstandarVal
.global OpcionExocet, LargoOpcionExocetVal
.global OpcionTomahawk, LargoOpcionTomahawkVal
.global OpcionApache, LargoOpcionApacheVal
.global OpcionTorpedo, LargoOpcionTorpedoVal

MenuMisiles:
    .asciz "\n========================================\n        SELECCIONE TIPO DE MISIL        \n========================================\n\n"
LargoMenuMisilesVal: .quad 125

OpcionEstandar:
    .asciz "  1. Misil Estandar (1 celda) [ILIMITADO]\n"
LargoOpcionEstandarVal: .quad 42

OpcionExocet:
    .asciz "  2. Misil Exocet (patron especial) [Disponibles: "
LargoOpcionExocetVal: .quad 50

OpcionTomahawk:
    .asciz "  3. Misil Tomahawk (area 3x3) [Disponibles: "
LargoOpcionTomahawkVal: .quad 45

OpcionApache:
    .asciz "  4. Misil Apache (patron especial) [Disponibles: "
LargoOpcionApacheVal: .quad 50

OpcionTorpedo:
    .asciz "  5. Torpedo (linea recta) [Disponibles: "
LargoOpcionTorpedoVal: .quad 41

// ============================================
// MENSAJES DE SELECCIÓN DE PATRÓN
// ============================================
.global MenuPatronExocet, LargoMenuPatronExocetVal
.global MenuPatronApache, LargoMenuPatronApacheVal

MenuPatronExocet:
    .asciz "\n  Seleccione patron de Exocet:\n    1. Patron + (cruz)\n    2. Patron X (diagonal)\n  Opcion: "
LargoMenuPatronExocetVal: .quad 92

MenuPatronApache:
    .asciz "\n  Seleccione patron de Apache:\n    1. Patron horizontal\n    2. Patron vertical\n  Opcion: "
LargoMenuPatronApacheVal: .quad 90

// ============================================
// MENSAJES DE TORPEDO
// ============================================
.global MenuDireccionTorpedo, LargoMenuDireccionTorpedoVal
.global ErrorOrigenTorpedo, LargoErrorOrigenTorpedoVal
.global MensajeTorpedoColumna, LargoMensajeTorpedoColumnaVal
.global MensajeTorpedoFila, LargoMensajeTorpedoFilaVal

MenuDireccionTorpedo:
    .asciz "\n  Seleccione direccion del torpedo:\n    1. Norte (desde fila A hacia abajo)\n    2. Sur (desde fila J hacia arriba)\n    3. Este (desde columna 14 hacia izquierda)\n    4. Oeste (desde columna 1 hacia derecha)\n  Opcion: "
LargoMenuDireccionTorpedoVal: .quad 218

ErrorOrigenTorpedo:
    .asciz "\n ERROR: Coordenada invalida para torpedo\n"
LargoErrorOrigenTorpedoVal: .quad 42

MensajeTorpedoColumna:
    .asciz "\n  Ingrese columna (1-14): "
LargoMensajeTorpedoColumnaVal: .quad 27

MensajeTorpedoFila:
    .asciz "\n  Ingrese fila (A-J): "
LargoMensajeTorpedoFilaVal: .quad 23

// ============================================
// MENSAJES DE SOLICITUD DE ATAQUE
// ============================================
.global MensajeCoordenadaAtaque, LargoMensajeCoordenadaAtaqueVal
.global MensajeOpcionMisil, LargoMensajeOpcionMisilVal

MensajeCoordenadaAtaque:
    .asciz "\n  Ingrese coordenada de ataque (ej: D7): "
LargoMensajeCoordenadaAtaqueVal: .quad 42

MensajeOpcionMisil:
    .asciz "\n  Opcion: "
LargoMensajeOpcionMisilVal: .quad 11

.global ErrorMunicionAgotada, LargoErrorMunicionAgotadaVal
ErrorMunicionAgotada:
    .asciz "\n No quedan ataques de este tipo. Seleccione otra opcion.\n"
LargoErrorMunicionAgotadaVal: .quad 58

// ============================================
// MENSAJES DE DEBUG
// ============================================
.global DebugMsg1, LargoDebugMsg1Val
.global DebugMsg2, LargoDebugMsg2Val
.global DebugMsg3, LargoDebugMsg3Val
.global DebugMsg4, LargoDebugMsg4Val
.global DebugMsg5, LargoDebugMsg5Val
.global DebugMsg6, LargoDebugMsg6Val

DebugMsg1:
    .asciz "\n[DEBUG] Entrando a f08AplicarPatron\n"
LargoDebugMsg1Val: .quad 36

DebugMsg2:
    .asciz "\n[DEBUG] Inicio del loop de patron\n"
LargoDebugMsg2Val: .quad 34

DebugMsg3:
    .asciz "\n[DEBUG] Procesando celda\n"
LargoDebugMsg3Val: .quad 25

DebugMsg4:
    .asciz "\n[DEBUG] Llamando a ProcesarDisparoEnCelda\n"
LargoDebugMsg4Val: .quad 42

DebugMsg5:
    .asciz "\n[DEBUG] Despues de ProcesarDisparoEnCelda\n"
LargoDebugMsg5Val: .quad 42

DebugMsg6:
    .asciz "\n[DEBUG] Fin del patron, copiando coordenadas\n"
LargoDebugMsg6Val: .quad 45

// ============================================
// MENSAJES DE RESULTADO DE ATAQUE
// ============================================
.global MensajeAgua, LargoMensajeAguaVal
.global MensajeImpacto, LargoMensajeImpactoVal
.global MensajeHundido, LargoMensajeHundidoVal
.global MensajeDisparoRepetido, LargoMensajeDisparoRepetidoVal

MensajeAgua:
    .asciz "\n AGUA - No hay nada aqui\n"
LargoMensajeAguaVal: .quad 26

MensajeImpacto:
    .asciz "\n\033[33m IMPACTO!\033[0m Has golpeado un barco enemigo\n"
LargoMensajeImpactoVal: .quad 52

MensajeHundido:
    .asciz "\n\033[32m BARCO HUNDIDO!\033[0m Has destruido una embarcacion enemiga\n"
LargoMensajeHundidoVal: .quad 65

// Nombres de barcos para mensajes detallados
.global NombrePortaviones, NombreAcorazado, NombreDestructor
.global NombreSubmarino, NombrePatrullero

NombrePortaviones: .asciz "PORTAVIONES"
NombreAcorazado:   .asciz "ACORAZADO"
NombreDestructor:  .asciz "DESTRUCTOR"
NombreSubmarino:   .asciz "SUBMARINO"
NombrePatrullero:  .asciz "PATRULLERO"

MensajeDisparoRepetido:
    .asciz "\n Ya has disparado a esta coordenada anteriormente\n"
LargoMensajeDisparoRepetidoVal: .quad 51

// ============================================
// MENSAJES DE TURNO
// ============================================
.global MensajeTurnoJugador, LargoMensajeTurnoJugadorVal
.global MensajeTurnoEnemigo, LargoMensajeTurnoEnemigoVal

MensajeTurnoJugador:
    .asciz "\n========================================\n            TU TURNO                    \n========================================\n"
LargoMensajeTurnoJugadorVal: .quad 124

MensajeTurnoEnemigo:
    .asciz "\n========================================\n         TURNO DEL ENEMIGO              \n========================================\n"
LargoMensajeTurnoEnemigoVal: .quad 124

// ============================================
// MENSAJES DE ATAQUE ENEMIGO
// ============================================
.global MensajeEnemigoDispara, LargoMensajeEnemigoDisparaVal
.global MensajeEnemigoImpacto, LargoMensajeEnemigoImpactoVal
.global MensajeEnemigoHundio, LargoMensajeEnemigoHundioVal

MensajeEnemigoDispara:
    .asciz "\n  El enemigo está atacando...\n"
LargoMensajeEnemigoDisparaVal: .quad 31

MensajeEnemigoImpacto:
    .asciz "\n\033[31m El enemigo ha impactado\033[0m uno de tus barcos en "
LargoMensajeEnemigoImpactoVal: .quad 61

MensajeEnemigoHundio:
    .asciz "\n\033[31m El enemigo ha hundido uno de tus barcos!\033[0m\n"
LargoMensajeEnemigoHundioVal: .quad 57

// ============================================
// MENSAJES DE FIN DE JUEGO
// ============================================
.global MensajeVictoria, LargoMensajeVictoriaVal
.global MensajeDerrota, LargoMensajeDerrotaVal

MensajeVictoria:
    .asciz "\n========================================\n                                        \n\033[32m           VICTORIA!\033[0m                    \n                                        \n  Has hundido toda la flota enemiga     \n                                        \n========================================\n\n"
LargoMensajeVictoriaVal: .quad 303

MensajeDerrota:
    .asciz "\n========================================\n                                        \n\033[31m             DERROTA\033[0m                    \n                                        \n   Toda tu flota ha sido destruida      \n                                        \n========================================\n\n"
LargoMensajeDerrotaVal: .quad 303

// ============================================
// MENSAJES DE SALIDA
// ============================================
.global MensajeSalir, LargoMensajeSalirVal

MensajeSalir:
    .asciz "\n  Gracias por jugar Battleship: Advanced Mission\n  Saliendo del juego...\n\n"
LargoMensajeSalirVal: .quad 75

// ============================================
// MENSAJES DE TABLERO
// ============================================
.global TituloTableroPropio, LargoTituloTableroPropioVal
.global TituloTableroEnemigo, LargoTituloTableroEnemigoVal

TituloTableroPropio:
    .asciz "\n  ========== TU FLOTA ==========\n"
LargoTituloTableroPropioVal: .quad 34

TituloTableroEnemigo:
    .asciz "\n  ========= FLOTA ENEMIGA =========\n"
LargoTituloTableroEnemigoVal: .quad 37

// ============================================
// NÚMEROS PARA COLUMNAS (1-14)
// ============================================
.global Num1, Num2, Num3, Num4, Num5, Num6, Num7
.global Num8, Num9, Num10, Num11, Num12, Num13, Num14

Num1:  .asciz "1"
Num2:  .asciz "  2"
Num3:  .asciz "  3"
Num4:  .asciz "  4"
Num5:  .asciz "  5"
Num6:  .asciz "  6"
Num7:  .asciz "  7"
Num8:  .asciz "  8"
Num9:  .asciz "  9"
Num10: .asciz "  10"
Num11: .asciz " 11"
Num12: .asciz " 12"
Num13: .asciz " 13"
Num14: .asciz " 14"

// ============================================
// LETRAS PARA FILAS (A-J)
// ============================================
.global LetraA, LetraB, LetraC, LetraD, LetraE
.global LetraF, LetraG, LetraH, LetraI, LetraJ

LetraA: .asciz "A"
LetraB: .asciz "B"
LetraC: .asciz "C"
LetraD: .asciz "D"
LetraE: .asciz "E"
LetraF: .asciz "F"
LetraG: .asciz "G"
LetraH: .asciz "H"
LetraI: .asciz "I"
LetraJ: .asciz "J"

// ============================================
// MENSAJES DE ERROR GENERALES
// ============================================
.global ErrorGenerico, LargoErrorGenericoVal
.global ErrorOpcionInvalida, LargoErrorOpcionInvalidaVal
.global ErrorEntradaVacia, LargoErrorEntradaVaciaVal

ErrorGenerico:
    .asciz "\n ERROR: Ha ocurrido un error inesperado\n"
LargoErrorGenericoVal: .quad 41

ErrorOpcionInvalida:
    .asciz "\n ERROR: Opcion invalida. Intente de nuevo.\n"
LargoErrorOpcionInvalidaVal: .quad 44

ErrorEntradaVacia:
    .asciz "\n ERROR: La entrada no puede estar vacia\n"
LargoErrorEntradaVaciaVal: .quad 41

// ============================================
// MENSAJE DE PRESIONAR ENTER
// ============================================
.global MensajePresionarEnter, LargoMensajePresionarEnterVal

MensajePresionarEnter:
    .asciz "\n  Presione ENTER para continuar..."
LargoMensajePresionarEnterVal: .quad 35

// ============================================
// FIN DEL ARCHIVO
// ============================================
