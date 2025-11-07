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
.extern f18ActualizarCeldaCompleta
.extern f02ImprimirTableroPropio
.extern f10ParsearCoordenada
.extern f11ImprimirNumero
.extern f12LeerCoordenada
.extern f02NumeroAleatorio
.extern f05LimpiarPantalla
.extern f16ObtenerTipo
.extern TableroJugador, TableroComputadora
.extern ContadorImpactosJugador, ContadorImpactosComputadora
.extern EstadoBarcosJugador, EstadoBarcosComputadora
.extern FILAS, COLUMNAS
.extern ESTADO_BARCO
.extern CELDA_DESCUBIERTO_NO, CELDA_DESCUBIERTO_SI
.extern CELDA_TIPO_AGUA, CELDA_TIPO_BARCO, CELDA_ID_NINGUNO
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
.extern MensajeDebugRetorno, MensajeDebugTamano, MensajeDebugImpactos
.extern Espacio, SaltoLinea

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
//   +9:  ID del barco (1 byte): 1=Portaviones, 2=Acorazado, 3=Destructor, 4=Submarino, 5=Patrullero
//   +10-39: Reservado

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
        STR x1, [sp, #24]       // Columna popa (reutilizamos slot que tenía tipo)
        
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
        // Parámetros para f07ColocarBarcoEnTablero:
        // x0=índice, x1=fila_proa, x2=col_proa, x3=fila_popa, x4=col_popa, x5=tamaño
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
        
        // Obtener tipo de celda usando f16ObtenerTipo
        LDR x3, =TableroJugador
        // x0 = fila, x1 = columna (ya cargadas)
        BL f16ObtenerTipo       // Retorna tipo en x0
        
        // Verificar si es tipo BARCO (2)
        LDR x7, =CELDA_TIPO_BARCO
        LDR x7, [x7]
        CMP x0, x7
        BEQ f06hay_solapamiento
        
        LDR x0, [sp, #48]
        LDR x1, [sp, #56]
        ADD x0, x0, #1          // Siguiente fila
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
        
        // Obtener tipo de celda usando f16ObtenerTipo
        LDR x4, =TableroJugador
        // x0 = fila, x1 = columna (ya cargadas)
        BL f16ObtenerTipo       // Retorna tipo en x0
        
        // Verificar si es tipo BARCO (2)
        LDR x8, =CELDA_TIPO_BARCO
        LDR x8, [x8]
        CMP x0, x8
        BEQ f06hay_solapamiento
        
        LDR x0, [sp, #48]
        LDR x1, [sp, #56]
        ADD x1, x1, #1          // Siguiente columna
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
// Coloca un barco en el tablero del jugador usando
// la nueva estructura [descubierto, tipo, id_barco].
// Inicializa contadores de impactos y estado.
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
        stp x29, x30, [sp, -96]!
        mov x29, sp
        stp x19, x20, [sp, #16]
        stp x21, x22, [sp, #32]
        
        // DEBUG: Imprimir mensaje de entrada
        SUB sp, sp, #32
        LDR x1, =MensajeDebugRetorno
        MOV x2, #41
        BL f01ImprimirCadena
        ADD sp, sp, #32
        
        // Guardar parámetros
        STR x0, [sp, #48]       // Índice del barco
        STR x1, [sp, #56]       // Fila proa
        STR x2, [sp, #64]       // Columna proa
        STR x3, [sp, #72]       // Fila popa
        STR x4, [sp, #80]       // Columna popa
        STR x5, [sp, #88]       // Tamaño
        
        // DEBUG: Imprimir coordenadas recibidas
        SUB sp, sp, #32
        MOV x0, x1              // Fila proa
        BL f11ImprimirNumero
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        LDR x0, [sp, #64+32]    // Columna proa (ajustar por sub sp)
        BL f11ImprimirNumero
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        ADD sp, sp, #32
        
        // Calcular ID del barco (índice + 1)
        LDR x0, [sp, #48]       // Índice
        ADD x0, x0, #1          // ID = índice + 1
        MOV x22, x0             // Guardar ID en x22 para uso posterior
        
        // DEBUG: Imprimir ID calculado
        SUB sp, sp, #32
        LDR x1, =MensajeDebugTamano
        MOV x2, #9
        BL f01ImprimirCadena
        MOV x0, x22
        BL f11ImprimirNumero
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        ADD sp, sp, #32
        
        // Inicializar contadores para este barco
        LDR x10, =ContadorImpactosJugador
        LSL x11, x0, #3         // ID × 8
        ADD x10, x10, x11
        MOV x12, #0
        STR x12, [x10]          // ContadorImpactos[ID] = 0
        
        LDR x10, =EstadoBarcosJugador
        ADD x10, x10, x11
        STR x12, [x10]          // EstadoBarcos[ID] = 0 (activo)
        
        // Determinar orientación y marcar celdas
        LDR x1, [sp, #56]       // Fila proa
        LDR x3, [sp, #72]       // Fila popa
        CMP x1, x3
        BEQ f07marcar_horizontal
        
f07marcar_vertical:
        // Asegurar orden correcto
        LDR x1, [sp, #56]
        LDR x3, [sp, #72]
        CMP x1, x3
        BLE f07vertical_ok
        STR x3, [sp, #56]
        STR x1, [sp, #72]
        
f07vertical_ok:
        LDR x19, [sp, #56]      // x19 = fila inicio
        LDR x20, [sp, #72]      // x20 = fila fin
        LDR x21, [sp, #64]      // x21 = columna (fija)
        // x22 ya tiene id_barco
        
        // DEBUG: Entrar en loop vertical
        SUB sp, sp, #32
        LDR x1, =MensajeDebugImpactos
        MOV x2, #11
        BL f01ImprimirCadena
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        ADD sp, sp, #32
        
f07loop_marcar_vertical:
        CMP x19, x20
        BGT f07fin_colocacion
        
        // DEBUG: Imprimir celda actual
        SUB sp, sp, #32
        MOV x0, x19
        BL f11ImprimirNumero
        LDR x1, =Espacio
        MOV x2, #1
        BL f01ImprimirCadena
        MOV x0, x21
        BL f11ImprimirNumero
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        ADD sp, sp, #32
        
        // Preparar parámetros para f18ActualizarCeldaCompleta
        LDR x0, =TableroJugador
        MOV x1, x19             // fila
        MOV x2, x21             // columna
        LDR x3, =CELDA_DESCUBIERTO_SI
        LDR x3, [x3]            // descubierto = 1
        LDR x4, =CELDA_TIPO_BARCO
        LDR x4, [x4]            // tipo = 2
        MOV x5, x22             // id_barco
        
        BL f18ActualizarCeldaCompleta
        
        ADD x19, x19, #1        // Siguiente fila
        B f07loop_marcar_vertical

f07marcar_horizontal:
        LDR x1, [sp, #56]       // Fila (fija)
        LDR x2, [sp, #64]       // Columna proa
        LDR x4, [sp, #80]       // Columna popa
        CMP x2, x4
        BLE f07horizontal_ok
        STR x4, [sp, #64]
        STR x2, [sp, #80]
        
f07horizontal_ok:
        LDR x19, [sp, #56]      // x19 = fila (fija)
        LDR x20, [sp, #64]      // x20 = columna inicio
        LDR x21, [sp, #80]      // x21 = columna fin
        // x22 ya tiene id_barco
        
f07loop_marcar_horizontal:
        CMP x20, x21
        BGT f07fin_colocacion
        
        // Preparar parámetros para f18ActualizarCeldaCompleta
        LDR x0, =TableroJugador
        MOV x1, x19             // fila
        MOV x2, x20             // columna
        LDR x3, =CELDA_DESCUBIERTO_SI
        LDR x3, [x3]            // descubierto = 1
        LDR x4, =CELDA_TIPO_BARCO
        LDR x4, [x4]            // tipo = 2
        MOV x5, x22             // id_barco
        
        BL f18ActualizarCeldaCompleta
        
        ADD x20, x20, #1        // Siguiente columna
        B f07loop_marcar_horizontal

f07fin_colocacion:
        ldp x21, x22, [sp, #32]
        ldp x19, x20, [sp, #16]
        ldp x29, x30, [sp], 96
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
        // Necesitamos verificar si las celdas están libres
        LDR x0, [sp, #40]       // Fila proa
        LDR x1, [sp, #48]       // Columna proa
        LDR x2, [sp, #32]       // Orientación
        CMP x2, #0
        BEQ f09validar_horizontal
        
f09validar_vertical:
        // Vertical: recorrer filas
        LDR x2, [sp, #40]       // Fila inicio
        LDR x3, [sp, #24]       // Tamaño
        ADD x3, x2, x3          // Fila fin + 1
        SUB x3, x3, #1          // Fila fin
        LDR x1, [sp, #48]       // Columna (constante)
        
f09loop_validar_vert:
        CMP x2, x3
        BGT f09colocar_ia       // Todas libres
        
        // Verificar celda [x2, x1]
        MOV x0, x2
        LDR x4, =TableroComputadora
        BL f16ObtenerTipo
        
        LDR x5, =CELDA_TIPO_BARCO
        LDR x5, [x5]
        CMP x0, x5
        BEQ f09intentar_colocacion  // Solapamiento, reintentar
        
        ADD x2, x2, #1
        B f09loop_validar_vert
        
f09validar_horizontal:
        // Horizontal: recorrer columnas
        LDR x0, [sp, #40]       // Fila (constante)
        LDR x1, [sp, #48]       // Columna inicio
        LDR x3, [sp, #24]       // Tamaño
        ADD x3, x1, x3          // Columna fin + 1
        SUB x3, x3, #1          // Columna fin
        
f09loop_validar_horiz:
        CMP x1, x3
        BGT f09colocar_ia       // Todas libres
        
        // Verificar celda [x0, x1]
        LDR x4, =TableroComputadora
        BL f16ObtenerTipo
        
        LDR x5, =CELDA_TIPO_BARCO
        LDR x5, [x5]
        CMP x0, x5
        BEQ f09intentar_colocacion  // Solapamiento, reintentar
        
        ADD x1, x1, #1
        LDR x0, [sp, #40]       // Restaurar fila
        B f09loop_validar_horiz

f09colocar_ia:
        // Colocar barco en TableroComputadora
        LDR x0, [sp, #16]       // Índice del barco
        LDR x5, [sp, #24]       // Tamaño
        
        // Inicializar ContadorImpactosComputadora[id] = 0
        ADD x1, x0, #1          // id_barco = índice + 1
        LDR x2, =ContadorImpactosComputadora
        LSL x3, x1, #3          // × 8 bytes
        ADD x2, x2, x3
        STR xzr, [x2]
        
        // Inicializar EstadoBarcosComputadora[id] = 0
        LDR x2, =EstadoBarcosComputadora
        ADD x2, x2, x3
        STR xzr, [x2]
        
        // Marcar celdas según orientación
        LDR x2, [sp, #32]       // Orientación
        CMP x2, #0
        BEQ f09marcar_horizontal
        
f09marcar_vertical:
        LDR x2, [sp, #40]       // Fila inicio
        LDR x3, [sp, #24]       // Tamaño
        ADD x3, x2, x3          // Fila fin + 1
        SUB x3, x3, #1          // Fila fin
        LDR x4, [sp, #48]       // Columna (constante)
        ADD x6, x0, #1          // id_barco = índice + 1
        
f09loop_marcar_vert:
        CMP x2, x3
        BGT f09fin_colocacion
        
        // Actualizar celda [x2, x4] con [descubierto=0, tipo=2, id_barco=x6]
        LDR x0, =TableroComputadora
        MOV x1, x2              // Fila
        MOV x7, x4              // Columna (guardar)
        STR x2, [sp, #48]       // Guardar fila
        STR x3, [sp, #56]       // Guardar fin
        
        MOV x2, x7              // x2 = columna
        LDR x3, =CELDA_DESCUBIERTO_NO
        LDR x3, [x3]            // descubierto = 0 (oculto)
        LDR x4, =CELDA_TIPO_BARCO
        LDR x4, [x4]            // tipo = 2
        MOV x5, x6              // id_barco
        BL f18ActualizarCeldaCompleta
        
        LDR x2, [sp, #48]       // Recuperar fila
        LDR x3, [sp, #56]       // Recuperar fin
        LDR x4, [sp, #48]       // Columna (recuperar del stack correcto)
        MOV x4, x7              // Restaurar columna original
        ADD x2, x2, #1
        B f09loop_marcar_vert
        
f09marcar_horizontal:
        LDR x2, [sp, #40]       // Fila (constante)
        LDR x3, [sp, #48]       // Columna inicio
        LDR x4, [sp, #24]       // Tamaño
        ADD x4, x3, x4          // Columna fin + 1
        SUB x4, x4, #1          // Columna fin
        ADD x6, x0, #1          // id_barco = índice + 1
        
f09loop_marcar_horiz:
        CMP x3, x4
        BGT f09fin_colocacion
        
        // Actualizar celda [x2, x3] con [descubierto=0, tipo=2, id_barco=x6]
        LDR x0, =TableroComputadora
        MOV x1, x2              // Fila
        STR x2, [sp, #48]       // Guardar fila
        STR x3, [sp, #56]       // Guardar columna
        STR x4, [sp, #32]       // Guardar fin
        
        MOV x2, x3              // x2 = columna
        LDR x3, =CELDA_DESCUBIERTO_NO
        LDR x3, [x3]            // descubierto = 0 (oculto)
        LDR x4, =CELDA_TIPO_BARCO
        LDR x4, [x4]            // tipo = 2
        MOV x5, x6              // id_barco
        BL f18ActualizarCeldaCompleta
        
        LDR x2, [sp, #48]       // Recuperar fila
        LDR x3, [sp, #56]       // Recuperar columna
        LDR x4, [sp, #32]       // Recuperar fin
        ADD x3, x3, #1
        B f09loop_marcar_horiz

f09fin_colocacion:
        
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
