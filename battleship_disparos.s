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
.global f14ObtenerNombreBarco

// Dependencias externas
.extern f01ImprimirCadena
.extern f11ImprimirNumero
.extern f06ObtenerEstadoCelda
.extern f07ActualizarCelda
.extern f16ObtenerTipo
.extern f17ObtenerIdBarco
.extern f18ActualizarCeldaCompleta
.extern TableroJugador, TableroComputadora
.extern TableroDisparosJugador, TableroDisparosComputadora
.extern BarcosJugador, BarcosComputadora
.extern ContadorImpactosJugador, ContadorImpactosComputadora
.extern EstadoBarcosJugador, EstadoBarcosComputadora
.extern TamanosPorID
.extern ESTADO_VACIA, ESTADO_VACIA_IMPACTADA
.extern ESTADO_BARCO, ESTADO_BARCO_IMPACTADO
.extern ESTADO_DESCONOCIDA, ESTADO_ENEMIGO_AGUA, ESTADO_ENEMIGO_BARCO
.extern CELDA_DESCUBIERTO_SI
.extern CELDA_TIPO_AGUA, CELDA_TIPO_AGUA_IMPACT
.extern CELDA_TIPO_BARCO, CELDA_TIPO_BARCO_IMPACT
.extern CELDA_ID_NINGUNO
.extern BARCO_ACTIVO, BARCO_HUNDIDO
.extern NUM_BARCOS
.extern MensajeDebugTamano, MensajeDebugImpactos, SaltoLinea
.extern NombrePortaviones, NombreAcorazado, NombreDestructor
.extern NombreSubmarino, NombrePatrullero

.section .text

// ******  Nombre  ***********************************
// f01ProcesarDisparoEnCelda
// ******  Descripción  ******************************
// Procesa un disparo en una celda específica del
// tablero objetivo usando la nueva estructura
// [descubierto, tipo, id_barco]. Actualiza el tipo
// de celda, incrementa contadores y verifica hundimiento.
// ******  Retorno  **********************************
// x0: Resultado del disparo
//     0 = Agua (fallo)
//     1 = Impacto (barco golpeado)
//     2 = Hundido (barco destruido)
// x1: ID del barco impactado (1-5 si aplica), o 0
// ******  Entradas  *********************************
// x0: Dirección del tablero objetivo
// x1: Dirección del tablero de disparos
// x2: Dirección del array ContadorImpactos
// x3: Dirección del array EstadoBarcos
// x4: Fila del disparo
// x5: Columna del disparo
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01ProcesarDisparoEnCelda:
        stp x29, x30, [sp, -96]!
        mov x29, sp
        
        // Guardar parámetros
        STR x0, [sp, #16]       // Tablero objetivo
        STR x1, [sp, #24]       // Tablero disparos
        STR x2, [sp, #32]       // ContadorImpactos
        STR x3, [sp, #40]       // EstadoBarcos
        STR x4, [sp, #48]       // Fila
        STR x5, [sp, #56]       // Columna
        
        // Obtener tipo de celda usando f16ObtenerTipo
        MOV x1, x4              // Fila
        MOV x2, x5              // Columna
        BL f16ObtenerTipo       // Retorna tipo en x0
        STR x0, [sp, #64]       // Guardar tipo actual
        
        // Verificar si es agua (tipo 0) o barco (tipo 2)
        LDR x1, =CELDA_TIPO_AGUA
        LDR x1, [x1]
        CMP x0, x1
        BEQ f01nuevo_agua
        
        LDR x1, =CELDA_TIPO_BARCO
        LDR x1, [x1]
        CMP x0, x1
        BEQ f01nuevo_barco
        
        // Si es tipo 1 o 3 (ya impactado), ignorar
        MOV x0, #0              // Resultado: AGUA (repetido)
        MOV x1, #0              // Sin ID
        ldp x29, x30, [sp], 96
        RET

f01nuevo_agua:
        // Actualizar celda: tipo = CELDA_TIPO_AGUA_IMPACT (1)
        LDR x0, [sp, #16]       // Tablero objetivo
        LDR x1, [sp, #48]       // Fila
        LDR x2, [sp, #56]       // Columna
        LDR x3, =CELDA_DESCUBIERTO_SI
        LDR x3, [x3]            // descubierto = 1
        LDR x4, =CELDA_TIPO_AGUA_IMPACT
        LDR x4, [x4]            // tipo = 1
        LDR x5, =CELDA_ID_NINGUNO
        LDR x5, [x5]            // id = 0
        BL f18ActualizarCeldaCompleta
        
        // Actualizar tablero de disparos (mantener compatibilidad)
        LDR x0, [sp, #24]       // Tablero disparos
        LDR x1, [sp, #48]       // Fila
        LDR x2, [sp, #56]       // Columna
        LDR x3, =ESTADO_ENEMIGO_AGUA
        LDR x3, [x3]
        BL f07ActualizarCelda
        
        MOV x0, #0              // Resultado: AGUA
        MOV x1, #0              // Sin ID
        ldp x29, x30, [sp], 96
        RET

f01nuevo_barco:
        // Obtener ID del barco usando f17ObtenerIdBarco
        LDR x0, [sp, #16]       // Tablero objetivo
        LDR x1, [sp, #48]       // Fila
        LDR x2, [sp, #56]       // Columna
        BL f17ObtenerIdBarco    // Retorna ID en x0 (1-5)
        STR x0, [sp, #72]       // Guardar ID del barco
        
        // Actualizar celda: tipo = CELDA_TIPO_BARCO_IMPACT (3)
        LDR x0, [sp, #16]       // Tablero objetivo
        LDR x1, [sp, #48]       // Fila
        LDR x2, [sp, #56]       // Columna
        LDR x3, =CELDA_DESCUBIERTO_SI
        LDR x3, [x3]            // descubierto = 1
        LDR x4, =CELDA_TIPO_BARCO_IMPACT
        LDR x4, [x4]            // tipo = 3
        LDR x5, [sp, #72]       // id_barco (mantener)
        BL f18ActualizarCeldaCompleta
        
        // Actualizar tablero de disparos
        LDR x0, [sp, #24]       // Tablero disparos
        LDR x1, [sp, #48]       // Fila
        LDR x2, [sp, #56]       // Columna
        LDR x3, =ESTADO_ENEMIGO_BARCO
        LDR x3, [x3]
        BL f07ActualizarCelda
        
        // Incrementar ContadorImpactos[id]
        LDR x0, [sp, #32]       // ContadorImpactos
        LDR x1, [sp, #72]       // ID (1-5)
        LSL x2, x1, #3          // × 8 bytes
        ADD x0, x0, x2          // Dirección de ContadorImpactos[ID]
        LDR x3, [x0]            // Leer contador actual
        ADD x3, x3, #1          // Incrementar
        STR x3, [x0]            // Guardar
        STR x3, [sp, #80]       // Guardar impactos actuales
        
        // Obtener tamaño del barco desde TamanosPorID[id]
        LDR x0, =TamanosPorID
        LDR x1, [sp, #72]       // ID
        LSL x2, x1, #3          // × 8 bytes
        ADD x0, x0, x2
        LDR x4, [x0]            // Tamaño del barco
        
        // Comparar impactos con tamaño
        LDR x3, [sp, #80]       // Impactos
        CMP x3, x4
        BLT f01barco_impactado  // No hundido aún
        
        // Barco hundido: actualizar EstadoBarcos[id] = 1
        LDR x0, [sp, #40]       // EstadoBarcos
        LDR x1, [sp, #72]       // ID
        LSL x2, x1, #3          // × 8 bytes
        ADD x0, x0, x2
        MOV x3, #1
        STR x3, [x0]            // Marcar como hundido
        
        MOV x0, #2              // Resultado: HUNDIDO
        LDR x1, [sp, #72]       // ID del barco
        ldp x29, x30, [sp], 96
        RET

f01barco_impactado:
        MOV x0, #1              // Resultado: IMPACTO
        LDR x1, [sp, #72]       // ID del barco
        ldp x29, x30, [sp], 96
        RET


// ******  Nombre  ***********************************
// f06ObtenerBarcoEnCelda
// ******  Descripción  ******************************
// OBSOLETA - Ya no se usa con la nueva estructura.
// Ahora usamos f17ObtenerIdBarco directamente.
// Se mantiene por compatibilidad de exportación.
// ******  Retorno  **********************************
// x0: Siempre -1 (no implementado)
// ******  Entradas  *********************************
// x0: Dirección del array de barcos (ignorado)
// x1: Fila de la celda (ignorado)
// x2: Columna de la celda (ignorado)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f06ObtenerBarcoEnCelda:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        MOV x0, #-1             // No implementado
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f05IncrementarImpactosBarco
// ******  Descripción  ******************************
// OBSOLETA - Ya no se usa con la nueva estructura.
// Ahora se incrementa ContadorImpactos directamente
// en f01ProcesarDisparoEnCelda.
// Se mantiene por compatibilidad de exportación.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Dirección del array de barcos (ignorado)
// x1: Índice del barco (ignorado)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05IncrementarImpactosBarco:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // No hacer nada
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f03VerificarBarcoHundido
// ******  Descripción  ******************************
// Verifica si un barco ha sido hundido comparando
// ContadorImpactos[id] con TamanosPorID[id].
// SIMPLIFICADO: Ya no usa array BarcosJugador.
// ******  Retorno  **********************************
// x0: 1 si hundido, 0 si aún activo
// ******  Entradas  *********************************
// x0: Dirección del array ContadorImpactos
// x1: ID del barco (1-5)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f03VerificarBarcoHundido:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        STR x0, [sp, #16]       // ContadorImpactos
        STR x1, [sp, #24]       // ID del barco
        
        // Obtener impactos: ContadorImpactos[id]
        LSL x2, x1, #3          // × 8 bytes
        ADD x0, x0, x2
        LDR x3, [x0]            // Impactos
        
        // Obtener tamaño: TamanosPorID[id]
        LDR x0, =TamanosPorID
        LDR x1, [sp, #24]       // ID
        LSL x2, x1, #3          // × 8 bytes
        ADD x0, x0, x2
        LDR x4, [x0]            // Tamaño
        
        // Comparar
        CMP x3, x4
        BLT f03aun_activo
        
        // Hundido
        MOV x0, #1
        ldp x29, x30, [sp], 32
        RET

f03aun_activo:
        MOV x0, #0
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f04ContarBarcosHundidos
// ******  Descripción  ******************************
// Cuenta cuántos barcos han sido hundidos usando
// el array EstadoBarcos. SIMPLIFICADO.
// ******  Retorno  **********************************
// x0: Cantidad de barcos hundidos (0-5)
// ******  Entradas  *********************************
// x0: Dirección del array EstadoBarcos
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04ContarBarcosHundidos:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        MOV x10, x0             // Array EstadoBarcos
        MOV x11, #0             // Contador
        MOV x19, #1             // Índice (empezar en 1, saltar [0])
        
f04loop_contar:
        CMP x19, #6             // 1-5 = 5 barcos
        BGE f04fin_contar
        
        // Leer EstadoBarcos[índice]
        LSL x1, x19, #3         // × 8 bytes
        ADD x1, x10, x1
        LDR x2, [x1]            // Estado (0 = activo, 1 = hundido)
        
        // Si hundido, incrementar
        CMP x2, #1
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


// ******  Nombre  ***********************************
// f14ObtenerNombreBarco
// ******  Descripción  ******************************
// Devuelve la dirección del nombre del barco basado
// en su ID.
// ******  Retorno  **********************************
// x0: Dirección del string con el nombre
// x1: Longitud del nombre
// ******  Entradas  *********************************
// x0: ID del barco (1-5)
// ******  Errores  **********************************
// Si ID inválido, retorna nombre "DESCONOCIDO"
// ***************************************************
f14ObtenerNombreBarco:
        CMP x0, #1
        BEQ f14portaviones
        CMP x0, #2
        BEQ f14acorazado
        CMP x0, #3
        BEQ f14destructor
        CMP x0, #4
        BEQ f14submarino
        CMP x0, #5
        BEQ f14patrullero
        
        // ID inválido - retornar algo por defecto
        LDR x0, =NombrePortaviones
        MOV x1, #11
        RET

f14portaviones:
        LDR x0, =NombrePortaviones
        MOV x1, #11  // "PORTAVIONES" = 11 chars
        RET

f14acorazado:
        LDR x0, =NombreAcorazado
        MOV x1, #9   // "ACORAZADO" = 9 chars
        RET

f14destructor:
        LDR x0, =NombreDestructor
        MOV x1, #10  // "DESTRUCTOR" = 10 chars
        RET

f14submarino:
        LDR x0, =NombreSubmarino
        MOV x1, #9   // "SUBMARINO" = 9 chars
        RET

f14patrullero:
        LDR x0, =NombrePatrullero
        MOV x1, #10  // "PATRULLERO" = 10 chars
        RET


// ============================================
// FIN DEL ARCHIVO
// ============================================
