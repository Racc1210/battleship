// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_disparos.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Módulo de procesamiento de disparos. Implementa:
// - Procesamiento de impactos individuales
// - Actualización de estados de celdas
// - Verificación de barcos hundidos
// - Conteo de barcos destruidos
// - Gestión de resultados de ataques
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

// Declaraciones globales
.global f01ProcesarDisparoEnCelda
.global f02ActualizarTableroDisparos
.global f03VerificarBarcoHundido
.global f04ContarBarcosHundidos
.global f05IncrementarImpactosBarco
.global f06ObtenerBarcoEnCelda

// Dependencias externas
.extern f01ImprimirCadena
.extern f11ImprimirNumero
.extern f06ObtenerEstadoCelda
.extern f07ActualizarCelda
.extern TableroJugador, TableroComputadora
.extern TableroDisparosJugador, TableroDisparosComputadora
.extern BarcosJugador, BarcosComputadora
.extern ESTADO_VACIA, ESTADO_VACIA_IMPACTADA
.extern ESTADO_BARCO, ESTADO_BARCO_IMPACTADO
.extern ESTADO_DESCONOCIDA, ESTADO_ENEMIGO_AGUA, ESTADO_ENEMIGO_BARCO
.extern BARCO_ACTIVO, BARCO_HUNDIDO
.extern NUM_BARCOS
.extern MensajeDebugTamano, MensajeDebugImpactos, SaltoLinea

.section .text

// ******  Nombre  ***********************************
// f01ProcesarDisparoEnCelda
// ******  Descripción  ******************************
// Procesa un disparo en una celda específica del
// tablero objetivo. Determina si es agua o barco,
// actualiza los estados correspondientes y verifica
// si el barco fue hundido.
// ******  Retorno  **********************************
// x0: Resultado del disparo
//     0 = Agua (fallo)
//     1 = Impacto (barco golpeado)
//     2 = Hundido (barco destruido)
// x1: Índice del barco impactado (si aplica), o -1
// ******  Entradas  *********************************
// x0: Dirección del tablero objetivo
// x1: Dirección del tablero de disparos
// x2: Dirección del array de barcos
// x3: Fila del disparo
// x4: Columna del disparo
// x5: 1 si es ataque del jugador, 0 si es de IA
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01ProcesarDisparoEnCelda:
        stp x29, x30, [sp, -80]!
        mov x29, sp
        
        // Guardar parámetros
        STR x0, [sp, #16]       // Tablero objetivo
        STR x1, [sp, #24]       // Tablero disparos
        STR x2, [sp, #32]       // Array de barcos
        STR x3, [sp, #40]       // Fila
        STR x4, [sp, #48]       // Columna
        STR x5, [sp, #56]       // Es jugador
        
        // Obtener estado de la celda en tablero objetivo
        MOV x1, x3              // Fila
        MOV x2, x4              // Columna
        BL f06ObtenerEstadoCelda
        STR x0, [sp, #64]       // Guardar estado
        
        // Verificar si es agua o barco
        LDR x1, =ESTADO_VACIA
        LDR x1, [x1]
        CMP x0, x1
        BEQ f01es_agua
        
        LDR x1, =ESTADO_BARCO
        LDR x1, [x1]
        CMP x0, x1
        BEQ f01es_barco
        
        LDR x1, =ESTADO_BARCO_IMPACTADO
        LDR x1, [x1]
        CMP x0, x1
        BEQ f01ya_impactado
        
        // Por defecto, tratar como agua
        B f01es_agua

f01es_agua:
        // Actualizar tablero objetivo: marcar como agua impactada
        LDR x0, [sp, #16]       // Tablero objetivo
        LDR x1, [sp, #40]       // Fila
        LDR x2, [sp, #48]       // Columna
        LDR x3, =ESTADO_VACIA_IMPACTADA
        LDR x3, [x3]
        BL f07ActualizarCelda
        
        // Actualizar tablero de disparos
        LDR x0, [sp, #24]       // Tablero disparos
        LDR x1, [sp, #40]       // Fila
        LDR x2, [sp, #48]       // Columna
        LDR x3, =ESTADO_ENEMIGO_AGUA
        LDR x3, [x3]
        BL f07ActualizarCelda
        
        MOV x0, #0              // Resultado: AGUA
        MOV x1, #-1             // Sin barco
        ldp x29, x30, [sp], 80
        RET

f01ya_impactado:
        // Ya fue impactado antes (disparo repetido)
        MOV x0, #0              // Resultado: AGUA (no hacer nada)
        MOV x1, #-1
        ldp x29, x30, [sp], 80
        RET

f01es_barco:
        // Actualizar tablero objetivo: marcar como barco impactado
        LDR x0, [sp, #16]       // Tablero objetivo
        LDR x1, [sp, #40]       // Fila
        LDR x2, [sp, #48]       // Columna
        LDR x3, =ESTADO_BARCO_IMPACTADO
        LDR x3, [x3]
        BL f07ActualizarCelda
        
        // Actualizar tablero de disparos
        LDR x0, [sp, #24]       // Tablero disparos
        LDR x1, [sp, #40]       // Fila
        LDR x2, [sp, #48]       // Columna
        LDR x3, =ESTADO_ENEMIGO_BARCO
        LDR x3, [x3]
        BL f07ActualizarCelda
        
        // Obtener índice del barco impactado
        LDR x0, [sp, #32]       // Array de barcos
        LDR x1, [sp, #40]       // Fila
        LDR x2, [sp, #48]       // Columna
        BL f06ObtenerBarcoEnCelda
        STR x0, [sp, #72]       // Guardar índice del barco
        
        // Incrementar contador de impactos del barco
        LDR x0, [sp, #32]       // Array de barcos
        LDR x1, [sp, #72]       // Índice del barco
        BL f05IncrementarImpactosBarco
        
        // Verificar si el barco fue hundido
        LDR x0, [sp, #32]       // Array de barcos
        LDR x1, [sp, #72]       // Índice del barco
        BL f03VerificarBarcoHundido
        
        CMP x0, #1
        BEQ f01barco_hundido
        
        // Impacto pero no hundido
        MOV x0, #1              // Resultado: IMPACTO
        LDR x1, [sp, #72]       // Índice del barco
        ldp x29, x30, [sp], 80
        RET

f01barco_hundido:
        MOV x0, #2              // Resultado: HUNDIDO
        LDR x1, [sp, #72]       // Índice del barco
        ldp x29, x30, [sp], 80
        RET


// ******  Nombre  ***********************************
// f06ObtenerBarcoEnCelda
// ******  Descripción  ******************************
// Busca qué barco ocupa una celda específica
// recorriendo el array de barcos y verificando
// sus coordenadas.
// ******  Retorno  **********************************
// x0: Índice del barco (0-4), o -1 si no hay barco
// ******  Entradas  *********************************
// x0: Dirección del array de barcos
// x1: Fila de la celda
// x2: Columna de la celda
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f06ObtenerBarcoEnCelda:
        stp x29, x30, [sp, -48]!
        mov x29, sp
        
        STR x0, [sp, #16]       // Array de barcos
        STR x1, [sp, #24]       // Fila buscada
        STR x2, [sp, #32]       // Columna buscada
        
        MOV x19, #0             // Contador de barcos
        
f06loop_barcos:
        CMP x19, #5
        BGE f06no_encontrado
        
        // Calcular dirección del barco actual
        LDR x0, [sp, #16]
        MOV x1, #40             // Tamaño de estructura
        MUL x2, x19, x1
        ADD x0, x0, x2          // Dirección del barco
        
        // Leer coordenadas del barco
        LDRB w3, [x0, #2]       // Fila inicio
        LDRB w4, [x0, #3]       // Columna inicio
        LDRB w5, [x0, #4]       // Fila fin
        LDRB w6, [x0, #5]       // Columna fin
        LDRB w7, [x0, #6]       // Orientación
        
        LDR x8, [sp, #24]       // Fila buscada
        LDR x9, [sp, #32]       // Columna buscada
        
        // Verificar si la celda está en este barco
        CMP w7, #0              // Horizontal
        BEQ f06verificar_horizontal
        
f06verificar_vertical:
        // Columna debe coincidir
        CMP w4, w9
        BNE f06siguiente_barco
        
        // Fila debe estar en rango [inicio, fin]
        CMP x8, x3
        BLT f06siguiente_barco
        CMP x8, x5
        BGT f06siguiente_barco
        
        // Encontrado
        MOV x0, x19
        ldp x29, x30, [sp], 48
        RET

f06verificar_horizontal:
        // Fila debe coincidir
        CMP w3, w8
        BNE f06siguiente_barco
        
        // Columna debe estar en rango [inicio, fin]
        CMP x9, x4
        BLT f06siguiente_barco
        CMP x9, x6
        BGT f06siguiente_barco
        
        // Encontrado
        MOV x0, x19
        ldp x29, x30, [sp], 48
        RET

f06siguiente_barco:
        ADD x19, x19, #1
        B f06loop_barcos

f06no_encontrado:
        MOV x0, #-1
        ldp x29, x30, [sp], 48
        RET


// ******  Nombre  ***********************************
// f05IncrementarImpactosBarco
// ******  Descripción  ******************************
// Incrementa el contador de impactos recibidos
// por un barco específico.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Dirección del array de barcos
// x1: Índice del barco (0-4)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05IncrementarImpactosBarco:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Calcular dirección del barco
        MOV x2, #40
        MUL x1, x1, x2
        ADD x0, x0, x1
        
        // Leer impactos actuales
        LDRB w1, [x0, #7]
        
        // Incrementar
        ADD w1, w1, #1
        
        // Guardar
        STRB w1, [x0, #7]
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f03VerificarBarcoHundido
// ******  Descripción  ******************************
// Verifica si un barco ha sido hundido comparando
// la cantidad de impactos recibidos con su tamaño.
// Si está hundido, actualiza su estado.
// ******  Retorno  **********************************
// x0: 1 si hundido, 0 si aún activo
// ******  Entradas  *********************************
// x0: Dirección del array de barcos
// x1: Índice del barco (0-4)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f03VerificarBarcoHundido:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        // Guardar parámetros para debug
        STR x0, [sp, #16]
        STR x1, [sp, #24]
        
        // Calcular dirección del barco
        MOV x2, #40
        MUL x1, x1, x2
        ADD x0, x0, x1
        
        // Leer tamaño e impactos
        LDRB w1, [x0, #1]       // Tamaño
        LDRB w2, [x0, #7]       // Impactos
        
        // === DEBUG: Imprimir valores ===
        STR x0, [sp, #16]       // Guardar dirección
        
        // Extender valores de byte a 64 bits antes de guardar
        UXTB w1, w1             // Limpiar bits altos de w1
        UXTB w2, w2             // Limpiar bits altos de w2
        MOV x3, x1              // Copiar a registro de 64 bits
        MOV x4, x2
        STR x3, [sp, #24]       // Guardar tamaño (64 bits)
        STR x4, [sp, #28]       // Guardar impactos (64 bits)
        
        // Imprimir tamaño
        LDR x1, =MensajeDebugTamano
        MOV x2, #9
        BL f01ImprimirCadena
        
        LDR x0, [sp, #24]       // Tamaño
        BL f11ImprimirNumero
        
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        // Imprimir impactos
        LDR x1, =MensajeDebugImpactos
        MOV x2, #11
        BL f01ImprimirCadena
        
        LDR x0, [sp, #28]       // Impactos
        BL f11ImprimirNumero
        
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        // Recuperar valores originales para comparación
        LDR x0, [sp, #16]       // Dirección
        LDRB w1, [x0, #1]       // Re-leer tamaño desde estructura
        LDRB w2, [x0, #7]       // Re-leer impactos desde estructura
        // === FIN DEBUG ===
        
        // Comparar impactos con tamaño
        CMP w2, w1
        BLT f03aun_activo
        
        // Hundido: actualizar estado
        MOV w3, #1
        STRB w3, [x0, #8]
        
        MOV x0, #1              // Hundido
        ldp x29, x30, [sp], 32
        RET

f03aun_activo:
        MOV x0, #0              // Aún activo
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f04ContarBarcosHundidos
// ******  Descripción  ******************************
// Cuenta cuántos barcos han sido hundidos en
// un array de barcos.
// ******  Retorno  **********************************
// x0: Cantidad de barcos hundidos (0-5)
// ******  Entradas  *********************************
// x0: Dirección del array de barcos
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04ContarBarcosHundidos:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        MOV x10, x0             // Array de barcos
        MOV x11, #0             // Contador
        MOV x19, #0             // Índice
        
f04loop_contar:
        CMP x19, #5
        BGE f04fin_contar
        
        // Calcular dirección del barco
        MOV x1, #40
        MUL x2, x19, x1
        ADD x1, x10, x2
        
        // Leer estado
        LDRB w2, [x1, #8]
        
        // Verificar si está hundido
        CMP w2, #1
        BNE f04siguiente
        
        ADD x11, x11, #1

f04siguiente:
        ADD x19, x19, #1
        B f04loop_contar

f04fin_contar:
        MOV x0, x11
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f02ActualizarTableroDisparos
// ******  Descripción  ******************************
// Actualiza el tablero de disparos después de un
// ataque. Marca la celda como explorada.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Dirección del tablero de disparos
// x1: Fila
// x2: Columna
// x3: Nuevo estado (AGUA o BARCO)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f02ActualizarTableroDisparos:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        BL f07ActualizarCelda
        
        ldp x29, x30, [sp], 16
        RET


// ============================================
// FIN DEL ARCHIVO
// ============================================
