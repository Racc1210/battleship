// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_tablero.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Módulo de gestión de tableros. Implementa:
// - Inicialización de tableros 10×14
// - Impresión visual de tableros (propio y enemigo)
// - Validación de coordenadas
// - Acceso y actualización de celdas
// - Sistema de fog of war para tablero enemigo
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

// Declaraciones globales
.global f01InicializarTableros
.global f02ImprimirTableroPropio
.global f03ImprimirTableroEnemigo
.global f04ImprimirAmbosTableros
.global f05ValidarCoordenada
.global f06ObtenerEstadoCelda
.global f07ActualizarCelda
.global f08CalcularIndice
.global f09RegistrarUltimoAtaque
.global f10RegistrarAtaqueMultiple
.global f11EsCeldaUltimoAtaque
.global f12LimpiarUltimoAtaque
.global TableroJugador
.global TableroComputadora
.global TableroDisparosJugador
.global TableroDisparosComputadora

// Dependencias externas
.extern f01ImprimirCadena
.extern f07ConvertirFilaALetra
.extern f09ConvertirColumnaATexto
.extern FILAS, COLUMNAS, TOTAL_CELDAS
.extern ESTADO_VACIA, ESTADO_VACIA_IMPACTADA
.extern ESTADO_BARCO, ESTADO_BARCO_IMPACTADO
.extern ESTADO_DESCONOCIDA, ESTADO_ENEMIGO_AGUA, ESTADO_ENEMIGO_BARCO
.extern SimboloAgua, SimboloAguaImpactada
.extern SimboloBarco, SimboloBarcoImpactado
.extern SimboloDesconocida, SimboloEnemigoAgua, SimboloEnemigoBarco
.extern ColorRojo, ColorAmarillo, ColorReset
.extern Espacio, SaltoLinea, Separador
.extern TituloTableroPropio, LargoTituloTableroPropioVal
.extern TituloTableroEnemigo, LargoTituloTableroEnemigoVal
.extern LetraA, LetraB, LetraC, LetraD, LetraE
.extern LetraF, LetraG, LetraH, LetraI, LetraJ
.extern Num1, Num2, Num3, Num4, Num5, Num6, Num7
.extern Num8, Num9, Num10, Num11, Num12, Num13, Num14

// Declarar globales ANTES de las secciones
.global UltimoAtaqueFila, UltimoAtaqueColumna, UltimoAtaqueCantidad
.global UltimoAtaqueCeldas

// Sección de datos no inicializados
.section .bss

// Tableros principales: 10 filas × 14 columnas = 140 celdas × 8 bytes
TableroJugador:          .skip 1120  // Tablero propio con barcos
TableroComputadora:      .skip 1120  // Tablero enemigo (oculto)
TableroDisparosJugador:  .skip 1120  // Registro de disparos del jugador
TableroDisparosComputadora: .skip 1120 // Registro de disparos de la IA

// Buffer temporal para conversión de números
BufferTemp:              .skip 8

// Tracking del último ataque para highlighting
UltimoAtaqueFila:        .skip 8     // Fila del último ataque individual
UltimoAtaqueColumna:     .skip 8     // Columna del último ataque individual
UltimoAtaqueCantidad:    .skip 8     // Cantidad de celdas en último ataque
UltimoAtaqueCeldas:      .skip 360   // Max 45 pares de coordenadas (fila,columna) × 8 bytes

// Códigos de color ANSI (locales a este archivo)
.section .data
ColorAmarillo:  .asciz "\033[33m"   // Amarillo para última celda atacada
ColorReset:     .asciz "\033[0m"    // Reset color


.section .text

// ******  Nombre  ***********************************
// f01InicializarTableros
// ******  Descripción  ******************************
// Inicializa los 4 tableros del juego:
// - Tablero del jugador (todas celdas vacías)
// - Tablero de la computadora (todas celdas vacías)
// - Tablero de disparos del jugador (desconocidas)
// - Tablero de disparos de la computadora (vacías)
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01InicializarTableros:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Inicializar tablero del jugador (todas vacías)
        LDR x0, =TableroJugador
        LDR x1, =ESTADO_VACIA
        LDR x1, [x1]
        LDR x2, =TOTAL_CELDAS
        LDR x2, [x2]            // x2 = 140
        
f01loop_jugador:
        CMP x2, #0
        BLE f01init_computadora
        STR x1, [x0]
        ADD x0, x0, #8
        SUB x2, x2, #1
        B f01loop_jugador
        
f01init_computadora:
        // Inicializar tablero de la computadora (todas vacías)
        LDR x0, =TableroComputadora
        LDR x1, =ESTADO_VACIA
        LDR x1, [x1]
        LDR x2, =TOTAL_CELDAS
        LDR x2, [x2]
        
f01loop_computadora:
        CMP x2, #0
        BLE f01init_disparos_jugador
        STR x1, [x0]
        ADD x0, x0, #8
        SUB x2, x2, #1
        B f01loop_computadora
        
f01init_disparos_jugador:
        // Inicializar disparos del jugador (todas desconocidas)
        LDR x0, =TableroDisparosJugador
        LDR x1, =ESTADO_DESCONOCIDA
        LDR x1, [x1]
        LDR x2, =TOTAL_CELDAS
        LDR x2, [x2]
        
f01loop_disparos_j:
        CMP x2, #0
        BLE f01init_disparos_comp
        STR x1, [x0]
        ADD x0, x0, #8
        SUB x2, x2, #1
        B f01loop_disparos_j
        
f01init_disparos_comp:
        // Inicializar disparos de la computadora (todas vacías)
        LDR x0, =TableroDisparosComputadora
        LDR x1, =ESTADO_VACIA
        LDR x1, [x1]
        LDR x2, =TOTAL_CELDAS
        LDR x2, [x2]
        
f01loop_disparos_c:
        CMP x2, #0
        BLE f01fin
        STR x1, [x0]
        ADD x0, x0, #8
        SUB x2, x2, #1
        B f01loop_disparos_c
        
f01fin:
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f08CalcularIndice
// ******  Descripción  ******************************
// Calcula el índice lineal de una celda en el
// tablero a partir de coordenadas (fila, columna).
// Fórmula: índice = (fila × 14) + columna
// ******  Retorno  **********************************
// x0: Índice lineal (0-139)
// ******  Entradas  *********************************
// x0: Fila (0-9)
// x1: Columna (0-13)
// ******  Errores  **********************************
// No valida rangos (usar f05ValidarCoordenada antes)
// ***************************************************
f08CalcularIndice:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // índice = fila × 14 + columna
        MOV x2, #14
        MUL x0, x0, x2          // x0 = fila × 14
        ADD x0, x0, x1          // x0 = (fila × 14) + columna
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f05ValidarCoordenada
// ******  Descripción  ******************************
// Valida que una coordenada esté dentro de los
// límites del tablero (0-9, 0-13).
// ******  Retorno  **********************************
// x0: 1 si válida, 0 si inválida
// ******  Entradas  *********************************
// x0: Fila (debe ser 0-9)
// x1: Columna (debe ser 0-13)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05ValidarCoordenada:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Validar fila (0-9)
        CMP x0, #0
        BLT f05invalida
        CMP x0, #9
        BGT f05invalida
        
        // Validar columna (0-13)
        CMP x1, #0
        BLT f05invalida
        CMP x1, #13
        BGT f05invalida
        
        // Coordenada válida
        MOV x0, #1
        ldp x29, x30, [sp], 16
        RET

f05invalida:
        MOV x0, #0
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f06ObtenerEstadoCelda
// ******  Descripción  ******************************
// Obtiene el estado de una celda específica de
// un tablero.
// ******  Retorno  **********************************
// x0: Estado de la celda
// ******  Entradas  *********************************
// x0: Dirección base del tablero
// x1: Fila (0-9)
// x2: Columna (0-13)
// ******  Errores  **********************************
// No valida coordenadas (hacer antes con f05)
// ***************************************************
f06ObtenerEstadoCelda:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        // Guardar dirección del tablero
        STR x0, [sp, #16]
        
        // Calcular índice
        MOV x0, x1              // x0 = fila
        MOV x1, x2              // x1 = columna
        BL f08CalcularIndice
        
        // Acceder a la celda: dirección + (índice × 8)
        LDR x1, [sp, #16]       // Recuperar dirección base
        LSL x0, x0, #3          // Multiplicar índice × 8
        ADD x1, x1, x0          // Dirección final
        LDR x0, [x1]            // Cargar estado
        
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f07ActualizarCelda
// ******  Descripción  ******************************
// Actualiza el estado de una celda específica
// en un tablero.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Dirección base del tablero
// x1: Fila (0-9)
// x2: Columna (0-13)
// x3: Nuevo estado de la celda
// ******  Errores  **********************************
// No valida coordenadas (hacer antes con f05)
// ***************************************************
f07ActualizarCelda:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        // Guardar parámetros
        STR x0, [sp, #16]       // Dirección del tablero
        STR x3, [sp, #24]       // Nuevo estado
        
        // Calcular índice
        MOV x0, x1              // x0 = fila
        MOV x1, x2              // x1 = columna
        BL f08CalcularIndice
        
        // Actualizar celda: dirección + (índice × 8)
        LDR x1, [sp, #16]       // Recuperar dirección base
        LSL x0, x0, #3          // Multiplicar índice × 8
        ADD x1, x1, x0          // Dirección final
        LDR x3, [sp, #24]       // Recuperar nuevo estado
        STR x3, [x1]            // Almacenar nuevo estado
        
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f02ImprimirTableroPropio
// ******  Descripción  ******************************
// Imprime el tablero del jugador con todos sus
// barcos visibles y los impactos enemigos.
// Muestra 4 estados: agua, agua impactada, barco,
// barco impactado.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna (usa TableroJugador global)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f02ImprimirTableroPropio:
        stp x29, x30, [sp, -48]!
        mov x29, sp
        
        // Imprimir título
        LDR x1, =TituloTableroPropio
        LDR x2, =LargoTituloTableroPropioVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Imprimir encabezado de columnas: "   1  2  3  4  5..."
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        
        // Imprimir números de columnas
        LDR x1, =Num1
        MOV x2, #1
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num2
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num3
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num4
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num5
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num6
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num7
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num8
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num9
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num10
        MOV x2, #4
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num11
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num12
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num13
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num14
        MOV x2, #3
        BL f01ImprimirCadena
        
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        // Imprimir filas (A-J)
        MOV x19, #0             // x19 = contador de fila
        
f02loop_filas:
        CMP x19, #10
        BGE f02fin
        
        // Imprimir letra de fila
        STR x19, [sp, #16]      // Guardar contador
        
        // Convertir número de fila a letra
        MOV x0, x19
        BL f07ConvertirFilaALetra
        
        // Imprimir letra
        STRB w0, [sp, #24]
        MOV w1, #0
        STRB w1, [sp, #25]
        ADD x1, sp, #24
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        
        // Imprimir celdas de la fila
        MOV x20, #0             // x20 = contador de columna
        
f02loop_columnas:
        CMP x20, #14
        BGE f02fin_fila
        
        STR x20, [sp, #32]      // Guardar contador columna
        
        // Obtener estado de la celda
        LDR x0, =TableroJugador
        LDR x1, [sp, #16]       // fila
        MOV x2, x20             // columna
        BL f06ObtenerEstadoCelda
        
        // Determinar símbolo según estado
        LDR x1, =ESTADO_VACIA
        LDR x1, [x1]
        CMP x0, x1
        BEQ f02imprimir_agua
        
        LDR x1, =ESTADO_VACIA_IMPACTADA
        LDR x1, [x1]
        CMP x0, x1
        BEQ f02imprimir_agua_impactada
        
        LDR x1, =ESTADO_BARCO
        LDR x1, [x1]
        CMP x0, x1
        BEQ f02imprimir_barco
        
        LDR x1, =ESTADO_BARCO_IMPACTADO
        LDR x1, [x1]
        CMP x0, x1
        BEQ f02imprimir_barco_impactado
        
        // Por defecto, agua
        B f02imprimir_agua
        
f02imprimir_agua:
        LDR x1, =SimboloAgua
        MOV x2, #1
        BL f01ImprimirCadena
        B f02siguiente_columna
        
f02imprimir_agua_impactada:
        // Verificar si es último ataque (amarillo)
        LDR x0, [sp, #16]       // Fila
        LDR x1, [sp, #32]       // Columna
        BL f11EsCeldaUltimoAtaque
        CMP x0, #1
        BEQ f02agua_impactada_amarillo
        
        // Agua impactada normal (sin color especial)
        LDR x1, =SimboloAguaImpactada
        MOV x2, #1
        BL f01ImprimirCadena
        B f02siguiente_columna
        
f02agua_impactada_amarillo:
        // Amarillo para último ataque
        LDR x1, =ColorAmarillo
        MOV x2, #5              // \033[33m = 5 bytes
        BL f01ImprimirCadena
        LDR x1, =SimboloAguaImpactada
        MOV x2, #1
        BL f01ImprimirCadena
        LDR x1, =ColorReset
        MOV x2, #4              // \033[0m = 4 bytes
        BL f01ImprimirCadena
        B f02siguiente_columna
        
f02imprimir_barco:
        LDR x1, =SimboloBarco
        MOV x2, #1
        BL f01ImprimirCadena
        B f02siguiente_columna
        
f02imprimir_barco_impactado:
        // Verificar si es último ataque (amarillo)
        LDR x0, [sp, #16]       // Fila
        LDR x1, [sp, #32]       // Columna
        BL f11EsCeldaUltimoAtaque
        CMP x0, #1
        BEQ f02barco_impactado_amarillo
        
        // Rojo para barco impactado (ataque enemigo anterior)
        LDR x1, =ColorRojo
        MOV x2, #5              // \033[31m = 5 bytes
        BL f01ImprimirCadena
        LDR x1, =SimboloBarcoImpactado
        MOV x2, #1
        BL f01ImprimirCadena
        LDR x1, =ColorReset
        MOV x2, #4              // \033[0m = 4 bytes
        BL f01ImprimirCadena
        B f02siguiente_columna
        
f02barco_impactado_amarillo:
        // Amarillo para último ataque
        LDR x1, =ColorAmarillo
        MOV x2, #5              // \033[33m = 5 bytes
        BL f01ImprimirCadena
        LDR x1, =SimboloBarcoImpactado
        MOV x2, #1
        BL f01ImprimirCadena
        LDR x1, =ColorReset
        MOV x2, #4              // \033[0m = 4 bytes
        BL f01ImprimirCadena
        
f02siguiente_columna:
        // Espacio entre celdas (3 espacios)
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        
        LDR x20, [sp, #32]      // Recuperar contador
        ADD x20, x20, #1
        B f02loop_columnas
        
f02fin_fila:
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x19, [sp, #16]      // Recuperar contador fila
        ADD x19, x19, #1
        B f02loop_filas
        
f02fin:
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        ldp x29, x30, [sp], 48
        RET


// ******  Nombre  ***********************************
// f03ImprimirTableroEnemigo
// ******  Descripción  ******************************
// Imprime el tablero enemigo con fog of war.
// Solo muestra celdas exploradas (disparos realizados).
// Muestra 3 estados: desconocida, agua impactada,
// barco impactado.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna (usa TableroDisparosJugador global)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f03ImprimirTableroEnemigo:
        stp x29, x30, [sp, -48]!
        mov x29, sp
        
        // Imprimir título
        LDR x1, =TituloTableroEnemigo
        LDR x2, =LargoTituloTableroEnemigoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Imprimir encabezado de columnas
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        
        LDR x1, =Num1
        MOV x2, #1
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num2
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num3
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num4
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num5
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num6
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num7
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num8
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num9
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num10
        MOV x2, #4
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num11
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num12
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num13
        MOV x2, #3
        BL f01ImprimirCadena
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Num14
        MOV x2, #3
        BL f01ImprimirCadena
        
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        // Imprimir filas (A-J)
        MOV x19, #0             // x19 = contador de fila
        
f03loop_filas:
        CMP x19, #10
        BGE f03fin
        
        // Imprimir letra de fila
        STR x19, [sp, #16]
        
        MOV x0, x19
        BL f07ConvertirFilaALetra
        
        STRB w0, [sp, #24]
        MOV w1, #0
        STRB w1, [sp, #25]
        ADD x1, sp, #24
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        
        // Imprimir celdas de la fila
        MOV x20, #0             // x20 = contador de columna
        
f03loop_columnas:
        CMP x20, #14
        BGE f03fin_fila
        
        STR x20, [sp, #32]
        
        // Obtener estado del tablero de disparos
        LDR x0, =TableroDisparosJugador
        LDR x1, [sp, #16]       // fila
        MOV x2, x20             // columna
        BL f06ObtenerEstadoCelda
        
        // Determinar símbolo según estado
        LDR x1, =ESTADO_DESCONOCIDA
        LDR x1, [x1]
        CMP x0, x1
        BEQ f03imprimir_desconocida
        
        LDR x1, =ESTADO_ENEMIGO_AGUA
        LDR x1, [x1]
        CMP x0, x1
        BEQ f03imprimir_enemigo_agua
        
        LDR x1, =ESTADO_ENEMIGO_BARCO
        LDR x1, [x1]
        CMP x0, x1
        BEQ f03imprimir_enemigo_barco
        
        // Por defecto, desconocida
        B f03imprimir_desconocida
        
f03imprimir_desconocida:
        // Verificar si es parte del último ataque
        LDR x0, [sp, #16]       // fila
        LDR x1, [sp, #32]       // columna
        BL f11EsCeldaUltimoAtaque
        CMP x0, #1
        BNE f03desc_sin_color
        
        // Imprimir con color amarillo
        LDR x1, =ColorAmarillo
        MOV x2, #5              // Longitud "\033[33m"
        BL f01ImprimirCadena
        
f03desc_sin_color:
        LDR x1, =SimboloDesconocida
        MOV x2, #1
        BL f01ImprimirCadena
        
        // Reset color si fue coloreado
        LDR x0, [sp, #16]
        LDR x1, [sp, #32]
        BL f11EsCeldaUltimoAtaque
        CMP x0, #1
        BNE f03siguiente_columna
        LDR x1, =ColorReset
        MOV x2, #4
        BL f01ImprimirCadena
        
        B f03siguiente_columna
        
f03imprimir_enemigo_agua:
        // Verificar si es parte del último ataque
        LDR x0, [sp, #16]
        LDR x1, [sp, #32]
        BL f11EsCeldaUltimoAtaque
        CMP x0, #1
        BNE f03agua_sin_color
        
        LDR x1, =ColorAmarillo
        MOV x2, #5
        BL f01ImprimirCadena
        
f03agua_sin_color:
        LDR x1, =SimboloEnemigoAgua
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x0, [sp, #16]
        LDR x1, [sp, #32]
        BL f11EsCeldaUltimoAtaque
        CMP x0, #1
        BNE f03siguiente_columna
        LDR x1, =ColorReset
        MOV x2, #4
        BL f01ImprimirCadena
        
        B f03siguiente_columna
        
f03imprimir_enemigo_barco:
        // Verificar si es parte del último ataque
        LDR x0, [sp, #16]
        LDR x1, [sp, #32]
        BL f11EsCeldaUltimoAtaque
        CMP x0, #1
        BNE f03barco_sin_color
        
        LDR x1, =ColorAmarillo
        MOV x2, #5
        BL f01ImprimirCadena
        
f03barco_sin_color:
        LDR x1, =SimboloEnemigoBarco
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x0, [sp, #16]
        LDR x1, [sp, #32]
        BL f11EsCeldaUltimoAtaque
        CMP x0, #1
        BNE f03siguiente_columna
        LDR x1, =ColorReset
        MOV x2, #4
        BL f01ImprimirCadena
        
f03siguiente_columna:
        // Espacio entre celdas (3 espacios)
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        
        LDR x20, [sp, #32]
        ADD x20, x20, #1
        B f03loop_columnas
        
f03fin_fila:
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        LDR x19, [sp, #16]
        ADD x19, x19, #1
        B f03loop_filas
        
f03fin:
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        ldp x29, x30, [sp], 48
        RET


// ******  Nombre  ***********************************
// f04ImprimirAmbosTableros
// ******  Descripción  ******************************
// Imprime ambos tableros uno después del otro:
// primero el tablero enemigo y luego el propio.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04ImprimirAmbosTableros:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        BL f03ImprimirTableroEnemigo
        BL f02ImprimirTableroPropio
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f09RegistrarUltimoAtaque
// ******  Descripción  ******************************
// Registra las coordenadas del último ataque para
// poder resaltarlas con color en la próxima impresión.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Fila
// x1: Columna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
.global f09RegistrarUltimoAtaque
f09RegistrarUltimoAtaque:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Guardar coordenada simple (para ataques de 1 celda)
        LDR x2, =UltimoAtaqueFila
        STR x0, [x2]
        LDR x2, =UltimoAtaqueColumna
        STR x1, [x2]
        
        // Registrar en array de celdas
        LDR x2, =UltimoAtaqueCeldas
        STR x0, [x2]            // Fila
        STR x1, [x2, #8]        // Columna
        
        // Establecer cantidad = 1
        LDR x2, =UltimoAtaqueCantidad
        MOV x3, #1
        STR x3, [x2]
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f10RegistrarAtaqueMultiple
// ******  Descripción  ******************************
// Registra múltiples coordenadas de un ataque de
// patrón para resaltarlas con color.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Dirección del array de coordenadas [(fila,columna),...]
// x1: Cantidad de pares
// ******  Errores  **********************************
// Ninguno
// ***************************************************
.global f10RegistrarAtaqueMultiple
f10RegistrarAtaqueMultiple:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        STR x0, [sp, #16]       // Array fuente
        STR x1, [sp, #24]       // Cantidad
        
        // Guardar cantidad
        LDR x2, =UltimoAtaqueCantidad
        STR x1, [x2]
        
        // Copiar coordenadas al array global
        LDR x3, =UltimoAtaqueCeldas
        MOV x4, #0              // Índice
        
f10loop_copiar:
        LDR x5, [sp, #24]
        CMP x4, x5
        BGE f10fin
        
        LDR x0, [sp, #16]       // Array fuente
        LSL x6, x4, #4          // × 16 (2 coords × 8 bytes)
        ADD x0, x0, x6
        
        LDR x7, [x0]            // Fila
        LDR x8, [x0, #8]        // Columna
        
        LSL x6, x4, #4
        ADD x9, x3, x6
        STR x7, [x9]
        STR x8, [x9, #8]
        
        ADD x4, x4, #1
        B f10loop_copiar
        
f10fin:
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f11EsCeldaUltimoAtaque
// ******  Descripción  ******************************
// Verifica si una coordenada fue parte del último ataque.
// ******  Retorno  **********************************
// x0: 1 si fue parte del último ataque, 0 si no
// ******  Entradas  *********************************
// x0: Fila a verificar
// x1: Columna a verificar
// ******  Errores  **********************************
// Ninguno
// ***************************************************
.global f11EsCeldaUltimoAtaque
f11EsCeldaUltimoAtaque:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        STR x0, [sp, #16]       // Fila buscada
        STR x1, [sp, #24]       // Columna buscada
        
        // Obtener cantidad de celdas en último ataque
        LDR x2, =UltimoAtaqueCantidad
        LDR x2, [x2]
        
        CMP x2, #0
        BLE f11no_encontrada
        
        // Buscar en array
        LDR x3, =UltimoAtaqueCeldas
        MOV x4, #0              // Índice
        
f11loop_buscar:
        CMP x4, x2
        BGE f11no_encontrada
        
        LSL x5, x4, #4          // × 16
        ADD x6, x3, x5
        
        LDR x7, [x6]            // Fila del ataque
        LDR x8, [x6, #8]        // Columna del ataque
        
        LDR x9, [sp, #16]       // Fila buscada
        LDR x10, [sp, #24]      // Columna buscada
        
        CMP x7, x9
        BNE f11siguiente
        CMP x8, x10
        BEQ f11encontrada
        
f11siguiente:
        ADD x4, x4, #1
        B f11loop_buscar
        
f11encontrada:
        MOV x0, #1
        ldp x29, x30, [sp], 32
        RET
        
f11no_encontrada:
        MOV x0, #0
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f12LimpiarUltimoAtaque
// ******  Descripción  ******************************
// Limpia el registro del último ataque.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
.global f12LimpiarUltimoAtaque
f12LimpiarUltimoAtaque:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x0, =UltimoAtaqueCantidad
        MOV x1, #0
        STR x1, [x0]
        
        ldp x29, x30, [sp], 16
        RET


// ============================================
// FIN DEL ARCHIVO
// ============================================

