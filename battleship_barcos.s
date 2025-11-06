// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_barcos.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Módulo de gestión de barcos. Implementa:
// - Colocación manual de barcos (proa y popa)
// - Validación de posiciones y orientación
// - Validación de distancia según tamaño
// - Detección de solapamientos
// - Colocación automática de barcos de la IA
// - Gestión de estructuras de datos de barcos
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

// Declaraciones globales
.global f01ColocarTodosBarcosJugador
.global f02ColocarBarcoManual
.global f03ValidarPosicionBarco
.global f04ValidarDistancia
.global f05ValidarOrientacion
.global f06ValidarSolapamiento
.global f07ColocarBarcoEnTablero
.global f08ColocarTodosBarcosIA
.global f09ColocarBarcoAleatorio
.global f10InicializarMunicion
.global BarcosJugador
.global BarcosComputadora
.global MunicionJugador
.global MunicionComputadora

// Dependencias externas
.extern f01ImprimirCadena
.extern f02LeerCadena
.extern f05ValidarCoordenada
.extern f07ActualizarCelda
.extern f02ImprimirTableroPropio
.extern f10ParsearCoordenada
.extern f12LeerCoordenada
.extern f02NumeroAleatorio
.extern f05LimpiarPantalla
.extern TableroJugador, TableroComputadora
.extern FILAS, COLUMNAS
.extern ESTADO_BARCO
.extern TIPO_PORTAVIONES, TIPO_ACORAZADO, TIPO_DESTRUCTOR
.extern TIPO_SUBMARINO, TIPO_PATRULLERO
.extern TAMANO_PORTAVIONES, TAMANO_ACORAZADO, TAMANO_DESTRUCTOR
.extern TAMANO_SUBMARINO, TAMANO_PATRULLERO
.extern ORIENTACION_HORIZONTAL, ORIENTACION_VERTICAL
.extern BARCO_ACTIVO
.extern MUNICION_EXOCET, MUNICION_TOMAHAWK, MUNICION_APACHE, MUNICION_TORPEDO
.extern MensajeColocacion, LargoMensajeColocacionVal
.extern MensajePortaviones, LargoMensajePortavionesVal
.extern MensajeAcorazado, LargoMensajeAcorazadoVal
.extern MensajeDestructor, LargoMensajeDestructorVal
.extern MensajeSubmarino, LargoMensajeSubmarinoVal
.extern MensajePatrullero, LargoMensajePatrulleroVal
.extern MensajeProa, LargoMensajePraoVal
.extern MensajePopa, LargoMensajePopaVal
.extern ErrorFormatoCoord, LargoErrorFormatoCoorVal
.extern ErrorFueraRango, LargoErrorFueraRangoVal
.extern ErrorOrientacion, LargoErrorOrientacionVal
.extern ErrorDistancia, LargoErrorDistanciaVal
.extern ErrorSolapamiento, LargoErrorSolapamientoVal
.extern MensajePresionarEnter, LargoMensajePresionarEnterVal

// Sección de datos no inicializados
.section .bss

// Estructuras de barcos: 40 bytes × 5 barcos = 200 bytes
// Estructura individual (40 bytes):
//   +0:  Tipo (1 byte)
//   +1:  Tamaño (1 byte)
//   +2:  Fila inicio (1 byte)
//   +3:  Columna inicio (1 byte)
//   +4:  Fila fin (1 byte)
//   +5:  Columna fin (1 byte)
//   +6:  Orientación (1 byte)
//   +7:  Impactos recibidos (1 byte)
//   +8:  Estado (1 byte): 0=activo, 1=hundido
//   +9-39: Reservado

BarcosJugador:      .skip 200  // 5 barcos × 40 bytes
BarcosComputadora:  .skip 200

// Munición disponible: 5 tipos × 8 bytes
MunicionJugador:    .skip 40
MunicionComputadora: .skip 40

// Buffers temporales
BufferProa:         .skip 8
BufferPopa:         .skip 8


.section .text

// ******  Nombre  ***********************************
// f01ColocarTodosBarcosJugador
// ******  Descripción  ******************************
// Gestiona la colocación de los 5 barcos del jugador
// en orden fijo: Portaviones, Acorazado, Destructor,
// Submarino, Patrullero. Solicita coordenadas,
// valida y coloca cada barco, mostrando el tablero
// después de cada colocación exitosa.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno (reintenta hasta colocación válida)
// ***************************************************
f01ColocarTodosBarcosJugador:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Mostrar mensaje de fase de colocación
        BL f05LimpiarPantalla
        LDR x1, =MensajeColocacion
        LDR x2, =LargoMensajeColocacionVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Colocar Portaviones (índice 0, tamaño 5)
        LDR x1, =MensajePortaviones
        LDR x2, =LargoMensajePortavionesVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        MOV x0, #0              // Índice de barco
        LDR x1, =TIPO_PORTAVIONES
        LDR x1, [x1]
        LDR x2, =TAMANO_PORTAVIONES
        LDR x2, [x2]
        BL f02ColocarBarcoManual
        
        // Colocar Acorazado (índice 1, tamaño 4)
        LDR x1, =MensajeAcorazado
        LDR x2, =LargoMensajeAcorazadoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        MOV x0, #1
        LDR x1, =TIPO_ACORAZADO
        LDR x1, [x1]
        LDR x2, =TAMANO_ACORAZADO
        LDR x2, [x2]
        BL f02ColocarBarcoManual
        
        // Colocar Destructor (índice 2, tamaño 3)
        LDR x1, =MensajeDestructor
        LDR x2, =LargoMensajeDestructorVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        MOV x0, #2
        LDR x1, =TIPO_DESTRUCTOR
        LDR x1, [x1]
        LDR x2, =TAMANO_DESTRUCTOR
        LDR x2, [x2]
        BL f02ColocarBarcoManual
        
        // Colocar Submarino (índice 3, tamaño 3)
        LDR x1, =MensajeSubmarino
        LDR x2, =LargoMensajeSubmarinoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        MOV x0, #3
        LDR x1, =TIPO_SUBMARINO
        LDR x1, [x1]
        LDR x2, =TAMANO_SUBMARINO
        LDR x2, [x2]
        BL f02ColocarBarcoManual
        
        // Colocar Patrullero (índice 4, tamaño 2)
        LDR x1, =MensajePatrullero
        LDR x2, =LargoMensajePatrulleroVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        MOV x0, #4
        LDR x1, =TIPO_PATRULLERO
        LDR x1, [x1]
        LDR x2, =TAMANO_PATRULLERO
        LDR x2, [x2]
        BL f02ColocarBarcoManual
        
        // Inicializar munición del jugador
        BL f10InicializarMunicion
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f02ColocarBarcoManual
// ******  Descripción  ******************************
// Solicita al usuario las coordenadas de proa y popa
// de un barco, valida la posición y lo coloca en el
// tablero. Repite hasta obtener una colocación válida.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Índice del barco (0-4)
// x1: Tipo de barco
// x2: Tamaño del barco
// ******  Errores  **********************************
// Ninguno (reintenta hasta éxito)
// ***************************************************
f02ColocarBarcoManual:
        stp x29, x30, [sp, -64]!
        mov x29, sp
        
        // Guardar parámetros
        STR x0, [sp, #16]       // Índice
        STR x1, [sp, #24]       // Tipo
        STR x2, [sp, #32]       // Tamaño
        
f02solicitar_coordenadas:
        // Solicitar coordenada de proa
        LDR x1, =MensajeProa
        LDR x2, =LargoMensajePraoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Leer coordenada de proa
        BL f12LeerCoordenada
        
        // Validar formato
        CMP x0, #-1
        BEQ f02error_formato
        CMP x1, #-1
        BEQ f02error_formato
        
        // Guardar proa
        STR x0, [sp, #40]       // Fila proa
        STR x1, [sp, #48]       // Columna proa
        
        // Solicitar coordenada de popa
        LDR x1, =MensajePopa
        LDR x2, =LargoMensajePopaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Leer coordenada de popa
        BL f12LeerCoordenada
        
        // Validar formato
        CMP x0, #-1
        BEQ f02error_formato
        CMP x1, #-1
        BEQ f02error_formato
        
        // Guardar popa
        STR x0, [sp, #56]       // Fila popa
        STR x1, [sp, #24]       // Columna popa (reutilizamos slot)
        
        // Validar orientación (horizontal o vertical, no diagonal)
        LDR x0, [sp, #40]       // Fila proa
        LDR x1, [sp, #48]       // Columna proa
        LDR x2, [sp, #56]       // Fila popa
        LDR x3, [sp, #24]       // Columna popa
        BL f05ValidarOrientacion
        CMP x0, #0
        BEQ f02error_orientacion
        
        // Validar distancia según tamaño del barco
        LDR x0, [sp, #40]       // Fila proa
        LDR x1, [sp, #48]       // Columna proa
        LDR x2, [sp, #56]       // Fila popa
        LDR x3, [sp, #24]       // Columna popa
        LDR x4, [sp, #32]       // Tamaño esperado
        BL f04ValidarDistancia
        CMP x0, #0
        BEQ f02error_distancia
        
        // Validar solapamiento con otros barcos
        LDR x0, [sp, #40]       // Fila proa
        LDR x1, [sp, #48]       // Columna proa
        LDR x2, [sp, #56]       // Fila popa
        LDR x3, [sp, #24]       // Columna popa
        BL f06ValidarSolapamiento
        CMP x0, #0
        BEQ f02error_solapamiento
        
        // Todas las validaciones pasaron, colocar barco
        LDR x0, [sp, #16]       // Índice
        LDR x1, [sp, #24]       // Tipo (recuperar original)
        LDR x1, [sp, #24]       // Columna popa (corregir)
        LDR x2, [sp, #32]       // Tamaño
        LDR x3, [sp, #40]       // Fila proa
        LDR x4, [sp, #48]       // Columna proa
        LDR x5, [sp, #56]       // Fila popa
        LDR x6, [sp, #24]       // Columna popa
        
        // Recargar parámetros correctamente
        LDR x0, [sp, #16]       // Índice
        LDR x1, [sp, #24]       // Tipo (del stack original)
        LDR x2, [sp, #32]       // Tamaño
        LDR x3, [sp, #40]       // Fila proa
        LDR x4, [sp, #48]       // Columna proa
        LDR x5, [sp, #56]       // Fila popa
        LDR x6, [sp, #24]       // Columna popa
        
        // Corrección: recuperar tipo original
        LDR x1, [sp, #24]
        STR x1, [sp, #24]       // Guardar columna popa
        
        // Reorganizar para f07ColocarBarcoEnTablero
        LDR x0, [sp, #16]       // Índice
        LDR x1, [sp, #24]       // Necesitamos recargar tipo
        
        // Llamar a función de colocación
        LDR x0, [sp, #16]       // Índice del barco
        LDR x1, [sp, #40]       // Fila proa
        LDR x2, [sp, #48]       // Columna proa
        LDR x3, [sp, #56]       // Fila popa
        LDR x4, [sp, #24]       // Columna popa
        LDR x5, [sp, #32]       // Tamaño
        BL f07ColocarBarcoEnTablero
        
        // Mostrar tablero actualizado
        BL f02ImprimirTableroPropio
        
        ldp x29, x30, [sp], 64
        RET

f02error_formato:
        LDR x1, =ErrorFormatoCoord
        LDR x2, =LargoErrorFormatoCoorVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f02solicitar_coordenadas

f02error_orientacion:
        LDR x1, =ErrorOrientacion
        LDR x2, =LargoErrorOrientacionVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f02solicitar_coordenadas

f02error_distancia:
        LDR x1, =ErrorDistancia
        LDR x2, =LargoErrorDistanciaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f02solicitar_coordenadas

f02error_solapamiento:
        LDR x1, =ErrorSolapamiento
        LDR x2, =LargoErrorSolapamientoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f02solicitar_coordenadas


// ******  Nombre  ***********************************
// f05ValidarOrientacion
// ******  Descripción  ******************************
// Valida que un barco esté orientado horizontal o
// verticalmente (no en diagonal).
// ******  Retorno  **********************************
// x0: 1 si válida, 0 si inválida (diagonal)
// ******  Entradas  *********************************
// x0: Fila proa
// x1: Columna proa
// x2: Fila popa
// x3: Columna popa
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05ValidarOrientacion:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Comparar filas
        CMP x0, x2
        BEQ f05horizontal
        
        // Comparar columnas
        CMP x1, x3
        BEQ f05vertical
        
        // Si ni filas ni columnas coinciden, es diagonal
        MOV x0, #0              // Inválida
        ldp x29, x30, [sp], 16
        RET

f05horizontal:
        // Verificar que columnas sean diferentes
        CMP x1, x3
        BEQ f05invalida         // Misma celda
        MOV x0, #1              // Válida
        ldp x29, x30, [sp], 16
        RET

f05vertical:
        // Verificar que filas sean diferentes
        CMP x0, x2
        BEQ f05invalida         // Misma celda
        MOV x0, #1              // Válida
        ldp x29, x30, [sp], 16
        RET

f05invalida:
        MOV x0, #0
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f04ValidarDistancia
// ******  Descripción  ******************************
// Valida que la distancia entre proa y popa
// corresponda al tamaño del barco.
// Distancia = |proa - popa| + 1
// ******  Retorno  **********************************
// x0: 1 si válida, 0 si inválida
// ******  Entradas  *********************************
// x0: Fila proa
// x1: Columna proa
// x2: Fila popa
// x3: Columna popa
// x4: Tamaño esperado del barco
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04ValidarDistancia:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Determinar si es horizontal o vertical
        CMP x0, x2
        BEQ f04calcular_horizontal
        
f04calcular_vertical:
        // Vertical: calcular |fila_proa - fila_popa| + 1
        SUBS x5, x2, x0         // x5 = fila_popa - fila_proa
        CNEG x5, x5, MI         // Si negativo, negar (valor absoluto)
        ADD x5, x5, #1          // +1 para incluir ambos extremos
        B f04comparar

f04calcular_horizontal:
        // Horizontal: calcular |col_proa - col_popa| + 1
        SUBS x5, x3, x1         // x5 = col_popa - col_proa
        CNEG x5, x5, MI         // Valor absoluto
        ADD x5, x5, #1

f04comparar:
        // Comparar distancia calculada con tamaño esperado
        CMP x5, x4
        BEQ f04valida
        
        MOV x0, #0              // Inválida
        ldp x29, x30, [sp], 16
        RET

f04valida:
        MOV x0, #1              // Válida
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f06ValidarSolapamiento
// ******  Descripción  ******************************
// Valida que las celdas del nuevo barco no se
// solapen con barcos ya colocados en el tablero.
// ******  Retorno  **********************************
// x0: 1 si no hay solapamiento, 0 si hay solapamiento
// ******  Entradas  *********************************
// x0: Fila proa
// x1: Columna proa
// x2: Fila popa
// x3: Columna popa
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f06ValidarSolapamiento:
        stp x29, x30, [sp, -64]!
        mov x29, sp
        
        // Guardar coordenadas
        STR x0, [sp, #16]       // Fila proa
        STR x1, [sp, #24]       // Columna proa
        STR x2, [sp, #32]       // Fila popa
        STR x3, [sp, #40]       // Columna popa
        
        // Determinar orientación y recorrer celdas
        CMP x0, x2
        BEQ f06recorrer_horizontal
        
f06recorrer_vertical:
        // Asegurar que proa < popa
        LDR x0, [sp, #16]       // Fila proa
        LDR x2, [sp, #32]       // Fila popa
        CMP x0, x2
        BLE f06vertical_orden_ok
        
        // Intercambiar
        STR x2, [sp, #16]
        STR x0, [sp, #32]
        
f06vertical_orden_ok:
        LDR x0, [sp, #16]       // Fila inicio
        LDR x2, [sp, #32]       // Fila fin
        LDR x1, [sp, #24]       // Columna (constante)
        
f06loop_vertical:
        CMP x0, x2
        BGT f06sin_solapamiento
        
        // Verificar celda actual
        STR x0, [sp, #48]
        STR x1, [sp, #56]
        
        // Obtener estado de celda en TableroJugador
        LDR x3, =TableroJugador
        MOV x4, #14
        MUL x5, x0, x4          // x5 = fila × 14
        ADD x5, x5, x1          // x5 = índice
        LSL x5, x5, #3          // × 8 bytes
        ADD x3, x3, x5
        LDR x6, [x3]            // Cargar estado
        
        // Verificar si hay barco
        LDR x7, =ESTADO_BARCO
        LDR x7, [x7]
        CMP x6, x7
        BEQ f06hay_solapamiento
        
        LDR x0, [sp, #48]
        ADD x0, x0, #1
        B f06loop_vertical

f06recorrer_horizontal:
        // Asegurar que proa < popa
        LDR x1, [sp, #24]       // Columna proa
        LDR x3, [sp, #40]       // Columna popa
        CMP x1, x3
        BLE f06horizontal_orden_ok
        
        // Intercambiar
        STR x3, [sp, #24]
        STR x1, [sp, #40]
        
f06horizontal_orden_ok:
        LDR x0, [sp, #16]       // Fila (constante)
        LDR x1, [sp, #24]       // Columna inicio
        LDR x3, [sp, #40]       // Columna fin
        
f06loop_horizontal:
        CMP x1, x3
        BGT f06sin_solapamiento
        
        // Verificar celda actual
        STR x0, [sp, #48]
        STR x1, [sp, #56]
        
        // Obtener estado de celda en TableroJugador
        LDR x4, =TableroJugador
        MOV x5, #14
        MUL x6, x0, x5          // x6 = fila × 14
        ADD x6, x6, x1          // x6 = índice
        LSL x6, x6, #3          // × 8 bytes
        ADD x4, x4, x6
        LDR x7, [x4]            // Cargar estado
        
        // Verificar si hay barco
        LDR x8, =ESTADO_BARCO
        LDR x8, [x8]
        CMP x7, x8
        BEQ f06hay_solapamiento
        
        LDR x1, [sp, #56]
        ADD x1, x1, #1
        B f06loop_horizontal

f06sin_solapamiento:
        MOV x0, #1              // No hay solapamiento
        ldp x29, x30, [sp], 64
        RET

f06hay_solapamiento:
        MOV x0, #0              // Hay solapamiento
        ldp x29, x30, [sp], 64
        RET


// ******  Nombre  ***********************************
// f07ColocarBarcoEnTablero
// ******  Descripción  ******************************
// Coloca un barco en el tablero del jugador,
// marcando todas sus celdas como BARCO y
// almacenando su información en la estructura
// de datos de barcos.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Índice del barco (0-4)
// x1: Fila proa
// x2: Columna proa
// x3: Fila popa
// x4: Columna popa
// x5: Tamaño del barco
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f07ColocarBarcoEnTablero:
        stp x29, x30, [sp, -80]!
        mov x29, sp
        
        // Guardar todos los parámetros
        STR x0, [sp, #16]       // Índice
        STR x1, [sp, #24]       // Fila proa
        STR x2, [sp, #32]       // Columna proa
        STR x3, [sp, #40]       // Fila popa
        STR x4, [sp, #48]       // Columna popa
        STR x5, [sp, #56]       // Tamaño
        
        // Determinar orientación
        CMP x1, x3
        BEQ f07marcar_horizontal
        
f07marcar_vertical:
        // Asegurar orden correcto
        LDR x1, [sp, #24]       // Fila proa
        LDR x3, [sp, #40]       // Fila popa
        CMP x1, x3
        BLE f07vertical_ok
        STR x3, [sp, #24]
        STR x1, [sp, #40]
        
f07vertical_ok:
        LDR x1, [sp, #24]       // Fila inicio
        LDR x3, [sp, #40]       // Fila fin
        LDR x2, [sp, #32]       // Columna
        LDR x10, =ORIENTACION_VERTICAL
        LDR x10, [x10]
        STR x10, [sp, #64]      // Guardar orientación
        
f07loop_marcar_vertical:
        CMP x1, x3
        BGT f07guardar_estructura
        
        // Marcar celda como BARCO
        LDR x0, =TableroJugador
        LDR x5, =ESTADO_BARCO
        LDR x5, [x5]
        
        // Calcular índice
        MOV x6, #14
        MUL x7, x1, x6
        ADD x7, x7, x2
        LSL x7, x7, #3
        ADD x0, x0, x7
        STR x5, [x0]
        
        ADD x1, x1, #1
        B f07loop_marcar_vertical

f07marcar_horizontal:
        LDR x1, [sp, #24]       // Fila
        LDR x2, [sp, #32]       // Columna proa
        LDR x4, [sp, #48]       // Columna popa
        CMP x2, x4
        BLE f07horizontal_ok
        STR x4, [sp, #32]
        STR x2, [sp, #48]
        
f07horizontal_ok:
        LDR x1, [sp, #24]       // Fila
        LDR x2, [sp, #32]       // Columna inicio
        LDR x4, [sp, #48]       // Columna fin
        LDR x10, =ORIENTACION_HORIZONTAL
        LDR x10, [x10]
        STR x10, [sp, #64]      // Guardar orientación
        
f07loop_marcar_horizontal:
        CMP x2, x4
        BGT f07guardar_estructura
        
        // Marcar celda como BARCO
        LDR x0, =TableroJugador
        LDR x5, =ESTADO_BARCO
        LDR x5, [x5]
        
        // Calcular índice
        MOV x6, #14
        MUL x7, x1, x6
        ADD x7, x7, x2
        LSL x7, x7, #3
        ADD x0, x0, x7
        STR x5, [x0]
        
        ADD x2, x2, #1
        B f07loop_marcar_horizontal

f07guardar_estructura:
        // Guardar información del barco en estructura
        LDR x0, [sp, #16]       // Índice del barco
        LDR x10, =BarcosJugador
        MOV x11, #40            // Tamaño de estructura
        MUL x0, x0, x11
        ADD x10, x10, x0        // Dirección de estructura
        
        // Guardar datos (simplificado por ahora)
        LDR x1, [sp, #24]       // Fila proa
        STRB w1, [x10, #2]
        LDR x1, [sp, #32]       // Columna proa
        STRB w1, [x10, #3]
        LDR x1, [sp, #40]       // Fila popa
        STRB w1, [x10, #4]
        LDR x1, [sp, #48]       // Columna popa
        STRB w1, [x10, #5]
        LDR x1, [sp, #56]       // Tamaño
        STRB w1, [x10, #1]
        LDR x1, [sp, #64]       // Orientación
        STRB w1, [x10, #6]
        
        // Estado inicial: activo, sin impactos
        MOV w1, #0
        STRB w1, [x10, #7]      // Impactos = 0
        STRB w1, [x10, #8]      // Estado = activo
        
        ldp x29, x30, [sp], 80
        RET


// ******  Nombre  ***********************************
// f08ColocarTodosBarcosIA
// ******  Descripción  ******************************
// Coloca los 5 barcos de la IA de forma aleatoria
// en el tablero de la computadora.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f08ColocarTodosBarcosIA:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Colocar Portaviones (tamaño 5)
        MOV x0, #0              // Índice
        MOV x1, #5              // Tamaño
        BL f09ColocarBarcoAleatorio
        
        // Colocar Acorazado (tamaño 4)
        MOV x0, #1
        MOV x1, #4
        BL f09ColocarBarcoAleatorio
        
        // Colocar Destructor (tamaño 3)
        MOV x0, #2
        MOV x1, #3
        BL f09ColocarBarcoAleatorio
        
        // Colocar Submarino (tamaño 3)
        MOV x0, #3
        MOV x1, #3
        BL f09ColocarBarcoAleatorio
        
        // Colocar Patrullero (tamaño 2)
        MOV x0, #4
        MOV x1, #2
        BL f09ColocarBarcoAleatorio
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f09ColocarBarcoAleatorio
// ******  Descripción  ******************************
// Coloca un barco en posición aleatoria válida
// en el tablero de la computadora.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Índice del barco
// x1: Tamaño del barco
// ******  Errores  **********************************
// Ninguno (reintenta hasta encontrar posición válida)
// ***************************************************
f09ColocarBarcoAleatorio:
        stp x29, x30, [sp, -48]!
        mov x29, sp
        
        STR x0, [sp, #16]       // Índice
        STR x1, [sp, #24]       // Tamaño
        
f09intentar_colocacion:
        // Generar orientación aleatoria (0 o 1)
        MOV x0, #2
        BL f02NumeroAleatorio
        STR x0, [sp, #32]       // Orientación
        
        CMP x0, #0
        BEQ f09generar_horizontal
        
f09generar_vertical:
        // Vertical: fila aleatoria (0 a 10-tamaño), columna cualquiera
        LDR x1, [sp, #24]       // Tamaño
        MOV x0, #10
        SUB x0, x0, x1
        ADD x0, x0, #1
        BL f02NumeroAleatorio   // Fila inicio
        STR x0, [sp, #40]       // Fila proa
        
        MOV x0, #14
        BL f02NumeroAleatorio   // Columna
        STR x0, [sp, #48]       // Columna (constante)
        
        // Calcular fila popa
        LDR x0, [sp, #40]
        LDR x1, [sp, #24]
        ADD x0, x0, x1
        SUB x0, x0, #1
        STR x0, [sp, #56]       // Fila popa
        
        B f09validar_ia

f09generar_horizontal:
        // Horizontal: fila cualquiera, columna aleatoria (0 a 14-tamaño)
        MOV x0, #10
        BL f02NumeroAleatorio
        STR x0, [sp, #40]       // Fila (constante)
        
        LDR x1, [sp, #24]
        MOV x0, #14
        SUB x0, x0, x1
        ADD x0, x0, #1
        BL f02NumeroAleatorio
        STR x0, [sp, #48]       // Columna proa
        
        // Calcular columna popa
        LDR x0, [sp, #48]
        LDR x1, [sp, #24]
        ADD x0, x0, x1
        SUB x0, x0, #1
        STR x0, [sp, #56]       // Columna popa
        
f09validar_ia:
        // Validar solapamiento en TableroComputadora
        // (implementación simplificada - marcar directamente)
        
        // Por ahora, marcar directamente sin validación exhaustiva
        // TODO: Implementar validación completa de solapamiento para IA
        
        LDR x0, [sp, #16]       // Índice
        LDR x1, [sp, #40]       // Fila inicio
        LDR x2, [sp, #48]       // Columna inicio
        LDR x3, [sp, #56]       // Fila/columna fin
        LDR x4, [sp, #32]       // Orientación
        
        // Marcar en TableroComputadora (implementación pendiente)
        
        ldp x29, x30, [sp], 48
        RET


// ******  Nombre  ***********************************
// f10InicializarMunicion
// ******  Descripción  ******************************
// Inicializa la munición disponible del jugador
// según los barcos colocados.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f10InicializarMunicion:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x0, =MunicionJugador
        
        // Exocet (Portaviones): 2
        LDR x1, =MUNICION_EXOCET
        LDR x1, [x1]
        STR x1, [x0]
        
        // Tomahawk (Acorazado): 1
        LDR x1, =MUNICION_TOMAHAWK
        LDR x1, [x1]
        STR x1, [x0, #8]
        
        // Apache (Destructor): 2
        LDR x1, =MUNICION_APACHE
        LDR x1, [x1]
        STR x1, [x0, #16]
        
        // Torpedo (Submarino): 2
        LDR x1, =MUNICION_TORPEDO
        LDR x1, [x1]
        STR x1, [x0, #24]
        
        ldp x29, x30, [sp], 16
        RET


// ============================================
// FIN DEL ARCHIVO
// ============================================
