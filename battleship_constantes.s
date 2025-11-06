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
.global ESTADO_VACIA, ESTADO_VACIA_IMPACTADA
.global ESTADO_BARCO, ESTADO_BARCO_IMPACTADO

ESTADO_VACIA:           .quad 0  // Agua sin impactar
ESTADO_VACIA_IMPACTADA: .quad 1  // Agua impactada por enemigo
ESTADO_BARCO:           .quad 2  // Barco sin impactar
ESTADO_BARCO_IMPACTADO: .quad 3  // Barco impactado

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
// TAMAÑOS DE EMBARCACIONES
// ============================================
.global TAMANO_PORTAVIONES, TAMANO_ACORAZADO, TAMANO_DESTRUCTOR
.global TAMANO_SUBMARINO, TAMANO_PATRULLERO

TAMANO_PORTAVIONES: .quad 5
TAMANO_ACORAZADO:   .quad 4
TAMANO_DESTRUCTOR:  .quad 3
TAMANO_SUBMARINO:   .quad 3
TAMANO_PATRULLERO:  .quad 2

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

DIR_NORTE: .quad 0  // Desde borde inferior hacia arriba
DIR_SUR:   .quad 1  // Desde borde superior hacia abajo
DIR_ESTE:  .quad 2  // Desde borde izquierdo hacia derecha
DIR_OESTE: .quad 3  // Desde borde derecho hacia izquierda

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

SimboloDesconocida:  .asciz "·"  // Celda no explorada
SimboloEnemigoAgua:  .asciz "O"  // Disparo fallido
SimboloEnemigoBarco: .asciz "X"  // Barco enemigo impactado
SimboloTorpedo:      .asciz "T"  // Trayectoria de torpedo

// ============================================
// SÍMBOLOS DE INTERFAZ
// ============================================
.global Espacio, SaltoLinea, Separador, DosPuntos

Espacio:     .asciz " "
SaltoLinea:  .asciz "\n"
Separador:   .asciz " | "
DosPuntos:   .asciz ": "

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
// MENSAJE DE BIENVENIDA
// ============================================
.global MensajeBienvenida, LargoMensajeBienvenidaVal

MensajeBienvenida:
    .asciz "\n╔════════════════════════════════════════════════════════════╗\n║                                                            ║\n║            BATTLESHIP: ADVANCED MISSION                    ║\n║                                                            ║\n║              Versión ARM64 Assembly                        ║\n║                                                            ║\n╚════════════════════════════════════════════════════════════╝\n\n"
LargoMensajeBienvenidaVal: .quad 452

// ============================================
// MENSAJE DE CRÉDITOS
// ============================================
.global MensajeCreditos, LargoMensajeCreditosVal

MensajeCreditos:
    .asciz "    Desarrollado por: Roymar Castillo\n    Institución: Instituto Tecnológico de Costa Rica\n    Proyecto: Programación en Bajo Nivel - ARM64\n    Año: 2025\n\n"
LargoMensajeCreditosVal: .quad 155

// ============================================
// MENSAJE DE INSTRUCCIONES GENERALES
// ============================================
.global MensajeInstrucciones, LargoMensajeInstruccionesVal

MensajeInstrucciones:
    .asciz "╔════════════════════════════════════════════════════════════╗\n║                    ¿CÓMO JUGAR?                            ║\n╚════════════════════════════════════════════════════════════╝\n\n  OBJETIVO:\n    Hundir toda la flota enemiga antes de que destruyan la tuya\n\n  TABLERO:\n    • Dimensiones: 10 filas (A-J) × 14 columnas (1-14)\n    • Coordenadas: Letra + Número (ejemplo: D7, A1, J14)\n\n  FASES DEL JUEGO:\n    1. PREPARACIÓN: Coloca tus 5 barcos en el tablero\n    2. COMBATE: Alterna turnos con el enemigo atacando\n\n  SÍMBOLOS:\n    ~  = Agua sin explorar\n    O  = Disparo al agua (fallo)\n    B  = Tu barco (sin daño)\n    X  = Impacto en barco\n    ·  = Zona enemiga sin explorar (niebla de guerra)\n\n"
LargoMensajeInstruccionesVal: .quad 702

// ============================================
// DESCRIPCIÓN DE BARCOS
// ============================================
.global MensajeDescripcionBarcos, LargoMensajeDescripcionBarcosVal

MensajeDescripcionBarcos:
    .asciz "╔════════════════════════════════════════════════════════════╗\n║                    TUS EMBARCACIONES                       ║\n╚════════════════════════════════════════════════════════════╝\n\n  1. PORTAVIONES (5 celdas)\n     └─ Armamento: 2 Misiles Exocet (patrón especial)\n\n  2. ACORAZADO (4 celdas)\n     └─ Armamento: 1 Misil Tomahawk (área 3×3)\n\n  3. DESTRUCTOR (3 celdas)\n     └─ Armamento: 2 Misiles Apache (patrón especial)\n\n  4. SUBMARINO (3 celdas)\n     └─ Armamento: 2 Torpedos (línea completa)\n\n  5. PATRULLERO (2 celdas)\n     └─ Armamento: Misiles estándar únicamente\n\n"
LargoMensajeDescripcionBarcosVal: .quad 578

// ============================================
// DESCRIPCIÓN DE MISILES
// ============================================
.global MensajeDescripcionMisiles, LargoMensajeDescripcionMisilesVal

MensajeDescripcionMisiles:
    .asciz "╔════════════════════════════════════════════════════════════╗\n║                   TIPOS DE ARMAMENTO                       ║\n╚════════════════════════════════════════════════════════════╝\n\n   MISIL ESTÁNDAR\n      Alcance: 1 celda\n      Munición: ILIMITADA\n      Disponible en: Todos los barcos\n\n   MISIL EXOCET (del Portaviones)\n      Alcance: Patrón especial de 5 celdas\n      Munición: 2 disparos\n      Patrones: X (esquinas) o + (cruz)\n\n   MISIL TOMAHAWK (del Acorazado)\n      Alcance: Área 3×3 (9 celdas)\n      Munición: 1 disparo\n      Efecto: Bombardeo masivo\n\n   MISIL APACHE (del Destructor)\n      Alcance: Patrón especial de 3-4 celdas\n      Munición: 2 disparos\n      Patrones: Horizontal o Vertical\n\n   TORPEDO (del Submarino)\n      Alcance: Línea completa desde el borde\n      Munición: 2 disparos\n      Direcciones: Norte, Sur, Este, Oeste\n\n    NOTA: Los misiles especiales son limitados.\n            ¡Úsalos estratégicamente!\n\n"
LargoMensajeDescripcionMisilesVal: .quad 943

// ============================================
// MENSAJE DE DESPEDIDA
// ============================================
.global MensajeDespedida, LargoMensajeDespedidaVal

MensajeDespedida:
    .asciz "\n╔════════════════════════════════════════════════════════════╗\n║                                                            ║\n║          Gracias por jugar Battleship ARM64                ║\n║                                                            ║\n║              ¡Hasta la próxima batalla!                    ║\n║                                                            ║\n╚════════════════════════════════════════════════════════════╝\n\n"
LargoMensajeDespedidaVal: .quad 443

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
    .asciz "\n╔════════════════════════════════════════╗\n║      FASE DE COLOCACIÓN DE BARCOS      ║\n╚════════════════════════════════════════╝\n\n"
LargoMensajeColocacionVal: .quad 131

MensajePortaviones:
    .asciz "\n PORTAVIONES (5 celdas)\n  Misiles: 2 Exocet\n"
LargoMensajePortavionesVal: .quad 45

MensajeAcorazado:
    .asciz "\n ACORAZADO (4 celdas)\n  Misiles: 1 Tomahawk (área 3x3)\n"
LargoMensajeAcorazadoVal: .quad 56

MensajeDestructor:
    .asciz "\n DESTRUCTOR (3 celdas)\n  Misiles: 2 Apache\n"
LargoMensajeDestructorVal: .quad 44

MensajeSubmarino:
    .asciz "\n SUBMARINO (3 celdas)\n  Armas: 2 Torpedos\n"
LargoMensajeSubmarinoVal: .quad 43

MensajePatrullero:
    .asciz "\n PATRULLERO (2 celdas)\n  Misiles: Solo estándar\n"
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
    .asciz "\n ERROR: Formato inválido. Use letra (A-J) + número (1-14)\n"
LargoErrorFormatoCoorVal: .quad 59

ErrorFueraRango:
    .asciz "\n ERROR: Coordenada fuera del tablero (A-J, 1-14)\n"
LargoErrorFueraRangoVal: .quad 50

ErrorOrientacion:
    .asciz "\n ERROR: El barco debe estar horizontal o vertical (no diagonal)\n"
LargoErrorOrientacionVal: .quad 65

ErrorDistancia:
    .asciz "\n ERROR: La distancia no corresponde al tamaño del barco\n"
LargoErrorDistanciaVal: .quad 57

ErrorSolapamiento:
    .asciz "\n ERROR: El barco se solapa con otra embarcación existente\n"
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
    .asciz "\n╔════════════════════════════════════════╗\n║        SELECCIONE TIPO DE MISIL        ║\n╚════════════════════════════════════════╝\n\n"
LargoMenuMisilesVal: .quad 131

OpcionEstandar:
    .asciz "  1. Misil Estándar (1 celda) [ILIMITADO]\n"
LargoOpcionEstandarVal: .quad 42

OpcionExocet:
    .asciz "  2. Misil Exocet (patrón especial) [Disponibles: "
LargoOpcionExocetVal: .quad 50

OpcionTomahawk:
    .asciz "  3. Misil Tomahawk (área 3x3) [Disponibles: "
LargoOpcionTomahawkVal: .quad 45

OpcionApache:
    .asciz "  4. Misil Apache (patrón especial) [Disponibles: "
LargoOpcionApacheVal: .quad 50

OpcionTorpedo:
    .asciz "  5. Torpedo (línea recta) [Disponibles: "
LargoOpcionTorpedoVal: .quad 41

// ============================================
// MENSAJES DE SELECCIÓN DE PATRÓN
// ============================================
.global MenuPatronExocet, LargoMenuPatronExocetVal
.global MenuPatronApache, LargoMenuPatronApacheVal

MenuPatronExocet:
    .asciz "\n  Seleccione patrón de Exocet:\n    1. Patrón X (esquinas)\n    2. Patrón + (cruz)\n  Opción: "
LargoMenuPatronExocetVal: .quad 92

MenuPatronApache:
    .asciz "\n  Seleccione patrón de Apache:\n    1. Patrón horizontal\n    2. Patrón vertical\n  Opción: "
LargoMenuPatronApacheVal: .quad 90

// ============================================
// MENSAJES DE TORPEDO
// ============================================
.global MenuDireccionTorpedo, LargoMenuDireccionTorpedoVal
.global ErrorOrigenTorpedo, LargoErrorOrigenTorpedoVal

MenuDireccionTorpedo:
    .asciz "\n  Seleccione dirección del torpedo:\n    1. Norte \n    2. Sur \n    3. Este\n    4. Oeste \n  Opción: "
LargoMenuDireccionTorpedoVal: .quad 99

ErrorOrigenTorpedo:
    .asciz "\n ERROR: El torpedo debe lanzarse desde el borde del tablero\n         en la dirección especificada\n"
LargoErrorOrigenTorpedoVal: .quad 99

// ============================================
// MENSAJES DE SOLICITUD DE ATAQUE
// ============================================
.global MensajeCoordenadaAtaque, LargoMensajeCoordenadaAtaqueVal
.global MensajeOpcionMisil, LargoMensajeOpcionMisilVal

MensajeCoordenadaAtaque:
    .asciz "\n  Ingrese coordenada de ataque (ej: D7): "
LargoMensajeCoordenadaAtaqueVal: .quad 42

MensajeOpcionMisil:
    .asciz "\n  Opción: "
LargoMensajeOpcionMisilVal: .quad 11

// ============================================
// MENSAJES DE RESULTADO DE ATAQUE
// ============================================
.global MensajeAgua, LargoMensajeAguaVal
.global MensajeImpacto, LargoMensajeImpactoVal
.global MensajeHundido, LargoMensajeHundidoVal
.global MensajeDisparoRepetido, LargoMensajeDisparoRepetidoVal

MensajeAgua:
    .asciz "\n AGUA - No hay nada aquí\n"
LargoMensajeAguaVal: .quad 26

MensajeImpacto:
    .asciz "\n ¡IMPACTO! Has golpeado un barco enemigo\n"
LargoMensajeImpactoVal: .quad 42

MensajeHundido:
    .asciz "\n ¡BARCO HUNDIDO! Has destruido una embarcación enemiga\n"
LargoMensajeHundidoVal: .quad 56

MensajeDisparoRepetido:
    .asciz "\n Ya has disparado a esta coordenada anteriormente\n"
LargoMensajeDisparoRepetidoVal: .quad 51

// ============================================
// MENSAJES DE TURNO
// ============================================
.global MensajeTurnoJugador, LargoMensajeTurnoJugadorVal
.global MensajeTurnoEnemigo, LargoMensajeTurnoEnemigoVal

MensajeTurnoJugador:
    .asciz "\n╔════════════════════════════════════════╗\n║            TU TURNO                    ║\n╚════════════════════════════════════════╝\n"
LargoMensajeTurnoJugadorVal: .quad 130

MensajeTurnoEnemigo:
    .asciz "\n╔════════════════════════════════════════╗\n║         TURNO DEL ENEMIGO              ║\n╚════════════════════════════════════════╝\n"
LargoMensajeTurnoEnemigoVal: .quad 130

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
    .asciz "\n El enemigo ha impactado uno de tus barcos en "
LargoMensajeEnemigoImpactoVal: .quad 47

MensajeEnemigoHundio:
    .asciz "\n ¡El enemigo ha hundido uno de tus barcos!\n"
LargoMensajeEnemigoHundioVal: .quad 44

// ============================================
// MENSAJES DE FIN DE JUEGO
// ============================================
.global MensajeVictoria, LargoMensajeVictoriaVal
.global MensajeDerrota, LargoMensajeDerrotaVal

MensajeVictoria:
    .asciz "\n╔════════════════════════════════════════╗\n║                                        ║\n║           ¡VICTORIA!               ║\n║                                        ║\n║  Has hundido toda la flota enemiga     ║\n║                                        ║\n╚════════════════════════════════════════╝\n\n"
LargoMensajeVictoriaVal: .quad 299

MensajeDerrota:
    .asciz "\n╔════════════════════════════════════════╗\n║                                        ║\n║             DERROTA                ║\n║                                        ║\n║   Toda tu flota ha sido destruida      ║\n║                                        ║\n╚════════════════════════════════════════╝\n\n"
LargoMensajeDerrotaVal: .quad 299

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
    .asciz "\n  ══════════ TU FLOTA ══════════\n"
LargoTituloTableroPropioVal: .quad 34

TituloTableroEnemigo:
    .asciz "\n  ═════════ FLOTA ENEMIGA ═════════\n"
LargoTituloTableroEnemigoVal: .quad 37

// ============================================
// NÚMEROS PARA COLUMNAS (1-14)
// ============================================
.global Num1, Num2, Num3, Num4, Num5, Num6, Num7
.global Num8, Num9, Num10, Num11, Num12, Num13, Num14

Num1:  .asciz " 1"
Num2:  .asciz " 2"
Num3:  .asciz " 3"
Num4:  .asciz " 4"
Num5:  .asciz " 5"
Num6:  .asciz " 6"
Num7:  .asciz " 7"
Num8:  .asciz " 8"
Num9:  .asciz " 9"
Num10: .asciz "10"
Num11: .asciz "11"
Num12: .asciz "12"
Num13: .asciz "13"
Num14: .asciz "14"

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
    .asciz "\n ERROR: Opción inválida. Intente de nuevo.\n"
LargoErrorOpcionInvalidaVal: .quad 44

ErrorEntradaVacia:
    .asciz "\n ERROR: La entrada no puede estar vacía\n"
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
