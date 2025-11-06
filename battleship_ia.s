// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_ia.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Módulo de Inteligencia Artificial del oponente.
// Implementa:
// - Colocación automática de barcos de la IA
// - Estrategia de ataque (búsqueda y destrucción)
// - Selección inteligente de coordenadas
// - Uso de misiles especiales por la IA
// - Modo caza tras impacto
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

// Declaraciones globales
.global f01InicializarIA
.global f02TurnoIA
.global f03SeleccionarCoordenadaIA
.global f04EstrategiaBusqueda
.global f05EstrategiaDestruccion
.global f06RegistrarImpactoIA
.global f07ObtenerCeldasAdyacentes
.global f08ValidarSolapamientoIA
.global f09ColocarBarcosIACompleto
.global ModoIA
.global UltimoImpactoFilaIA
.global UltimoImpactoColumnaIA

// Dependencias externas
.extern f02NumeroAleatorio
.extern f05ValidarCoordenada
.extern f06ObtenerEstadoCelda
.extern f07ActualizarCelda
.extern f01ProcesarDisparoEnCelda
.extern f01ImprimirCadena
.extern f02ImprimirTableroPropio
.extern TableroJugador, TableroComputadora
.extern TableroDisparosComputadora, TableroDisparosJugador
.extern BarcosJugador, BarcosComputadora
.extern MunicionComputadora
.extern PatronExocet1, PatronExocet2
.extern PatronApache1, PatronApache2
.extern PatronTomahawk
.extern ESTADO_VACIA, ESTADO_BARCO, ESTADO_DESCONOCIDA
.extern ESTADO_ENEMIGO_AGUA, ESTADO_ENEMIGO_BARCO
.extern ORIENTACION_HORIZONTAL, ORIENTACION_VERTICAL
.extern BARCO_ACTIVO
.extern MensajeEnemigoDispara, LargoMensajeEnemigoDisparaVal
.extern MensajeEnemigoImpacto, LargoMensajeEnemigoImpactoVal
.extern MensajeEnemigoHundio, LargoMensajeEnemigoHundioVal
.extern MensajeAgua, LargoMensajeAguaVal
.extern SaltoLinea

.section .bss

// Variables de estado de la IA
ModoIA:                  .skip 8    // 0=búsqueda, 1=destrucción
UltimoImpactoFilaIA:     .skip 8    // Última fila con impacto
UltimoImpactoColumnaIA:  .skip 8    // Última columna con impacto
DireccionActualIA:       .skip 8    // Dirección actual de búsqueda
IntentosBusquedaIA:      .skip 8    // Contador de intentos

.section .text

// ******  Nombre  ***********************************
// f01InicializarIA
// ******  Descripción  ******************************
// Inicializa el estado de la IA al comenzar el juego.
// Establece modo de búsqueda y resetea variables.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01InicializarIA:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Modo inicial: búsqueda
        LDR x0, =ModoIA
        MOV x1, #0
        STR x1, [x0]
        
        // Resetear últimas coordenadas
        LDR x0, =UltimoImpactoFilaIA
        MOV x1, #-1
        STR x1, [x0]
        
        LDR x0, =UltimoImpactoColumnaIA
        MOV x1, #-1
        STR x1, [x0]
        
        // Inicializar munición de la IA
        LDR x0, =MunicionComputadora
        MOV x1, #2              // Exocet
        STR x1, [x0]
        MOV x1, #1              // Tomahawk
        STR x1, [x0, #8]
        MOV x1, #2              // Apache
        STR x1, [x0, #16]
        MOV x1, #2              // Torpedo
        STR x1, [x0, #24]
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f02TurnoIA
// ******  Descripción  ******************************
// Ejecuta el turno completo de la IA: selecciona
// coordenada, realiza ataque y actualiza estrategia.
// ******  Retorno  **********************************
// x0: Resultado del ataque (0=agua, 1=impacto, 2=hundido)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f02TurnoIA:
        stp x29, x30, [sp, -48]!
        mov x29, sp
        
        // Mensaje de ataque enemigo
        LDR x1, =MensajeEnemigoDispara
        LDR x2, =LargoMensajeEnemigoDisparaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Decidir qué tipo de misil usar (estratégico)
        BL f10SeleccionarMisilIA
        STR x0, [sp, #40]       // Tipo de misil (0=estándar, 1=Exocet, 2=Tomahawk, 3=Apache)
        
        CMP x0, #0
        BNE f02ataque_especial
        
        // Ataque estándar
        BL f03SeleccionarCoordenadaIA
        STR x0, [sp, #16]       // Fila
        STR x1, [sp, #24]       // Columna
        
        LDR x0, =TableroJugador
        LDR x1, =TableroDisparosComputadora
        LDR x2, =BarcosJugador
        LDR x3, [sp, #16]       // Fila
        LDR x4, [sp, #24]       // Columna
        MOV x5, #0              // Es IA
        BL f01ProcesarDisparoEnCelda
        B f02procesar_resultado

f02ataque_especial:
        // Usar misil especial de la IA
        LDR x0, [sp, #40]
        BL f11LanzarMisilEspecialIA
        // x0 ahora contiene el resultado real (0=agua, 1=impacto, 2=hundido)

f02procesar_resultado:
        STR x0, [sp, #32]       // Guardar resultado
        
        // Actualizar estrategia según resultado
        CMP x0, #0
        BEQ f02resultado_agua_ia
        
        // Fue impacto o hundido
        // Solo registrar si fue un disparo estándar (tiene coordenadas válidas)
        LDR x3, [sp, #40]       // Tipo de misil
        CMP x3, #0              // 0 = estándar
        BNE f02no_registrar_especial
        
        LDR x0, [sp, #16]       // Fila
        LDR x1, [sp, #24]       // Columna
        LDR x2, [sp, #32]       // Resultado
        BL f06RegistrarImpactoIA
        
f02no_registrar_especial:
        // Mostrar mensaje
        LDR x0, [sp, #32]
        CMP x0, #2
        BEQ f02hundido_ia
        
        // Impacto
        LDR x1, =MensajeEnemigoImpacto
        LDR x2, =LargoMensajeEnemigoImpactoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f02fin_turno

f02hundido_ia:
        LDR x1, =MensajeEnemigoHundio
        LDR x2, =LargoMensajeEnemigoHundioVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Volver a modo búsqueda
        LDR x0, =ModoIA
        MOV x1, #0
        STR x1, [x0]
        B f02fin_turno

f02resultado_agua_ia:
        LDR x1, =MensajeAgua
        LDR x2, =LargoMensajeAguaVal
        LDR x2, [x2]
        BL f01ImprimirCadena

f02fin_turno:
        // Imprimir tablero del jugador
        BL f02ImprimirTableroPropio
        
        LDR x0, [sp, #32]       // Retornar resultado
        ldp x29, x30, [sp], 48
        RET


// ******  Nombre  ***********************************
// f03SeleccionarCoordenadaIA
// ******  Descripción  ******************************
// Selecciona coordenada de ataque según el modo
// actual de la IA (búsqueda o destrucción).
// ******  Retorno  **********************************
// x0: Fila seleccionada
// x1: Columna seleccionada
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f03SeleccionarCoordenadaIA:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x0, =ModoIA
        LDR x0, [x0]
        
        CMP x0, #0
        BEQ f03modo_busqueda
        
        // Modo destrucción
        BL f05EstrategiaDestruccion
        ldp x29, x30, [sp], 16
        RET

f03modo_busqueda:
        BL f04EstrategiaBusqueda
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f04EstrategiaBusqueda
// ******  Descripción  ******************************
// Estrategia de búsqueda aleatoria. Genera coordenadas
// aleatorias hasta encontrar una celda no explorada.
// Implementa patrón de tablero de ajedrez para
// mayor eficiencia (opcional).
// ******  Retorno  **********************************
// x0: Fila
// x1: Columna
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04EstrategiaBusqueda:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
f04generar_coordenada:
        // Generar fila aleatoria (0-9)
        MOV x0, #10
        BL f02NumeroAleatorio
        STR x0, [sp, #16]       // Guardar fila
        
        // Generar columna aleatoria (0-13)
        MOV x0, #14
        BL f02NumeroAleatorio
        STR x1, [sp, #24]       // Guardar columna
        MOV x1, x0              // x1 = columna
        LDR x0, [sp, #16]       // x0 = fila
        
        // Verificar si ya fue disparada
        STR x0, [sp, #16]
        STR x1, [sp, #24]
        
        LDR x0, =TableroDisparosComputadora
        LDR x1, [sp, #16]       // Fila
        LDR x2, [sp, #24]       // Columna
        BL f06ObtenerEstadoCelda
        
        // Si es desconocida (0), es válida
        LDR x1, =ESTADO_DESCONOCIDA
        LDR x1, [x1]
        CMP x0, x1
        BNE f04generar_coordenada
        
        // Coordenada válida encontrada
        LDR x0, [sp, #16]       // Fila
        LDR x1, [sp, #24]       // Columna
        
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f05EstrategiaDestruccion
// ******  Descripción  ******************************
// Estrategia de destrucción tras impacto. Ataca
// celdas adyacentes al último impacto para encontrar
// la orientación del barco y hundirlo.
// ******  Retorno  **********************************
// x0: Fila
// x1: Columna
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05EstrategiaDestruccion:
        stp x29, x30, [sp, -64]!
        mov x29, sp
        
        // Obtener último impacto
        LDR x0, =UltimoImpactoFilaIA
        LDR x19, [x0]           // Fila del último impacto
        LDR x0, =UltimoImpactoColumnaIA
        LDR x20, [x0]           // Columna del último impacto
        
        // Intentar celdas adyacentes en orden: arriba, abajo, izquierda, derecha
        MOV x21, #0             // Contador de dirección
        
f05probar_direccion:
        CMP x21, #4
        BGE f05sin_adyacentes
        
        // Calcular coordenada según dirección
        MOV x22, x19            // Fila candidata
        MOV x23, x20            // Columna candidata
        
        CMP x21, #0             // Arriba
        BEQ f05direccion_arriba
        CMP x21, #1             // Abajo
        BEQ f05direccion_abajo
        CMP x21, #2             // Izquierda
        BEQ f05direccion_izquierda
        CMP x21, #3             // Derecha
        BEQ f05direccion_derecha
        
f05direccion_arriba:
        SUB x22, x22, #1
        B f05validar_candidata

f05direccion_abajo:
        ADD x22, x22, #1
        B f05validar_candidata

f05direccion_izquierda:
        SUB x23, x23, #1
        B f05validar_candidata

f05direccion_derecha:
        ADD x23, x23, #1

f05validar_candidata:
        // Validar límites
        CMP x22, #0
        BLT f05siguiente_direccion
        CMP x22, #9
        BGT f05siguiente_direccion
        CMP x23, #0
        BLT f05siguiente_direccion
        CMP x23, #13
        BGT f05siguiente_direccion
        
        // Verificar si ya fue disparada
        STR x21, [sp, #16]
        STR x22, [sp, #24]
        STR x23, [sp, #32]
        
        LDR x0, =TableroDisparosComputadora
        MOV x1, x22
        MOV x2, x23
        BL f06ObtenerEstadoCelda
        
        LDR x21, [sp, #16]
        LDR x22, [sp, #24]
        LDR x23, [sp, #32]
        
        // Si es desconocida, usar esta coordenada
        LDR x1, =ESTADO_DESCONOCIDA
        LDR x1, [x1]
        CMP x0, x1
        BEQ f05coordenada_encontrada

f05siguiente_direccion:
        ADD x21, x21, #1
        B f05probar_direccion

f05sin_adyacentes:
        // No hay adyacentes válidas, volver a búsqueda
        LDR x0, =ModoIA
        MOV x1, #0
        STR x1, [x0]
        BL f04EstrategiaBusqueda
        ldp x29, x30, [sp], 64
        RET

f05coordenada_encontrada:
        MOV x0, x22             // Fila
        MOV x1, x23             // Columna
        ldp x29, x30, [sp], 64
        RET


// ******  Nombre  ***********************************
// f06RegistrarImpactoIA
// ******  Descripción  ******************************
// Registra un impacto exitoso de la IA y actualiza
// el modo de estrategia según el resultado.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Fila del impacto
// x1: Columna del impacto
// x2: Resultado (1=impacto, 2=hundido)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f06RegistrarImpactoIA:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Guardar coordenadas del impacto
        LDR x3, =UltimoImpactoFilaIA
        STR x0, [x3]
        LDR x3, =UltimoImpactoColumnaIA
        STR x1, [x3]
        
        // Si fue hundido, volver a modo búsqueda
        CMP x2, #2
        BEQ f06modo_busqueda
        
        // Si fue impacto, cambiar a modo destrucción
        LDR x0, =ModoIA
        MOV x1, #1
        STR x1, [x0]
        
        ldp x29, x30, [sp], 16
        RET

f06modo_busqueda:
        LDR x0, =ModoIA
        MOV x1, #0
        STR x1, [x0]
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f07ObtenerCeldasAdyacentes
// ******  Descripción  ******************************
// Obtiene las coordenadas de las 4 celdas adyacentes
// a una posición dada (arriba, abajo, izquierda, derecha).
// ******  Retorno  **********************************
// x0-x7: Coordenadas de las 4 celdas adyacentes
//        (fila1, col1, fila2, col2, fila3, col3, fila4, col4)
//        Valor -1 indica celda fuera de límites
// ******  Entradas  *********************************
// x0: Fila central
// x1: Columna central
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f07ObtenerCeldasAdyacentes:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Arriba (fila-1, columna)
        SUB x2, x0, #1
        MOV x3, x1
        CMP x2, #0
        CSEL x2, x2, xzr, GE
        CSINV x2, x2, xzr, GE
        
        // Abajo (fila+1, columna)
        ADD x4, x0, #1
        MOV x5, x1
        CMP x4, #9
        MOV x10, #-1
        CSEL x4, x4, x10, LE
        
        // Izquierda (fila, columna-1)
        MOV x6, x0
        SUB x7, x1, #1
        CMP x7, #0
        CSEL x7, x7, x10, GE
        
        // Derecha (fila, columna+1)
        MOV x8, x0
        ADD x9, x1, #1
        CMP x9, #13
        CSEL x9, x9, x10, LE
        
        // Retornar en registros x0-x7
        MOV x0, x2
        MOV x1, x3
        MOV x2, x4
        MOV x3, x5
        MOV x4, x6
        MOV x5, x7
        MOV x6, x8
        MOV x7, x9
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f08ValidarSolapamientoIA
// ******  Descripción  ******************************
// Valida que un barco de la IA no se solape con
// otros barcos ya colocados en TableroComputadora.
// ******  Retorno  **********************************
// x0: 1 si no hay solapamiento, 0 si hay
// ******  Entradas  *********************************
// x0: Fila inicio
// x1: Columna inicio
// x2: Fila fin
// x3: Columna fin
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f08ValidarSolapamientoIA:
        stp x29, x30, [sp, -64]!
        mov x29, sp
        
        STR x0, [sp, #16]       // Fila inicio
        STR x1, [sp, #24]       // Columna inicio
        STR x2, [sp, #32]       // Fila fin
        STR x3, [sp, #40]       // Columna fin
        
        // Determinar orientación
        CMP x0, x2
        BEQ f08recorrer_horizontal_ia
        
f08recorrer_vertical_ia:
        // Asegurar orden
        LDR x0, [sp, #16]
        LDR x2, [sp, #32]
        CMP x0, x2
        BLE f08vertical_ok_ia
        STR x2, [sp, #16]
        STR x0, [sp, #32]
        
f08vertical_ok_ia:
        LDR x0, [sp, #16]       // Fila inicio
        LDR x2, [sp, #32]       // Fila fin
        LDR x1, [sp, #24]       // Columna
        
f08loop_vertical_ia:
        CMP x0, x2
        BGT f08sin_solapamiento_ia
        
        STR x0, [sp, #48]
        STR x1, [sp, #56]
        
        // Verificar celda en TableroComputadora
        LDR x3, =TableroComputadora
        MOV x4, #14
        MUL x5, x0, x4
        ADD x5, x5, x1
        LSL x5, x5, #3
        ADD x3, x3, x5
        LDR x6, [x3]
        
        LDR x7, =ESTADO_BARCO
        LDR x7, [x7]
        CMP x6, x7
        BEQ f08hay_solapamiento_ia
        
        LDR x0, [sp, #48]
        ADD x0, x0, #1
        B f08loop_vertical_ia

f08recorrer_horizontal_ia:
        LDR x1, [sp, #24]
        LDR x3, [sp, #40]
        CMP x1, x3
        BLE f08horizontal_ok_ia
        STR x3, [sp, #24]
        STR x1, [sp, #40]
        
f08horizontal_ok_ia:
        LDR x0, [sp, #16]       // Fila
        LDR x1, [sp, #24]       // Columna inicio
        LDR x3, [sp, #40]       // Columna fin
        
f08loop_horizontal_ia:
        CMP x1, x3
        BGT f08sin_solapamiento_ia
        
        STR x0, [sp, #48]
        STR x1, [sp, #56]
        
        LDR x4, =TableroComputadora
        MOV x5, #14
        MUL x6, x0, x5
        ADD x6, x6, x1
        LSL x6, x6, #3
        ADD x4, x4, x6
        LDR x7, [x4]
        
        LDR x8, =ESTADO_BARCO
        LDR x8, [x8]
        CMP x7, x8
        BEQ f08hay_solapamiento_ia
        
        LDR x1, [sp, #56]
        ADD x1, x1, #1
        B f08loop_horizontal_ia

f08sin_solapamiento_ia:
        MOV x0, #1
        ldp x29, x30, [sp], 64
        RET

f08hay_solapamiento_ia:
        MOV x0, #0
        ldp x29, x30, [sp], 64
        RET


// ******  Nombre  ***********************************
// f09ColocarBarcosIACompleto
// ******  Descripción  ******************************
// Completa la colocación de todos los barcos de la
// IA con validación de solapamiento y límites.
// Mejora de f09ColocarBarcoAleatorio de battleship_barcos.s
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f09ColocarBarcosIACompleto:
        stp x29, x30, [sp, -80]!
        mov x29, sp
        
        // Colocar 5 barcos con tamaños: 5, 4, 3, 3, 2
        MOV x19, #0             // Índice de barco
        
f09loop_barcos:
        CMP x19, #5
        BGE f09fin_colocacion
        
        // Determinar tamaño según índice
        CMP x19, #0
        BEQ f09tamano_5
        CMP x19, #1
        BEQ f09tamano_4
        CMP x19, #2
        BEQ f09tamano_3a
        CMP x19, #3
        BEQ f09tamano_3b
        MOV x20, #2             // Patrullero
        B f09intentar

f09tamano_5:
        MOV x20, #5             // Portaviones
        B f09intentar
        
f09tamano_4:
        MOV x20, #4             // Acorazado
        B f09intentar
        
f09tamano_3a:
        MOV x20, #3             // Destructor
        B f09intentar
        
f09tamano_3b:
        MOV x20, #3             // Submarino

f09intentar:
        STR x19, [sp, #16]
        STR x20, [sp, #24]
        
        // Generar orientación
        MOV x0, #2
        BL f02NumeroAleatorio
        STR x0, [sp, #32]       // Orientación
        
        CMP x0, #0
        BEQ f09gen_horizontal_ia
        
f09gen_vertical_ia:
        // Fila aleatoria
        LDR x1, [sp, #24]       // Tamaño
        MOV x0, #10
        SUB x0, x0, x1
        ADD x0, x0, #1
        BL f02NumeroAleatorio
        STR x0, [sp, #40]       // Fila inicio
        
        // Columna aleatoria
        MOV x0, #14
        BL f02NumeroAleatorio
        STR x0, [sp, #48]       // Columna
        
        // Calcular fila fin
        LDR x0, [sp, #40]
        LDR x1, [sp, #24]
        ADD x0, x0, x1
        SUB x0, x0, #1
        STR x0, [sp, #56]       // Fila fin
        
        // Validar solapamiento
        LDR x0, [sp, #40]       // Fila inicio
        LDR x1, [sp, #48]       // Columna
        LDR x2, [sp, #56]       // Fila fin
        LDR x3, [sp, #48]       // Columna
        BL f08ValidarSolapamientoIA
        CMP x0, #0
        BEQ f09intentar
        
        // Colocar barco
        B f09marcar_barco_ia

f09gen_horizontal_ia:
        // Fila aleatoria
        MOV x0, #10
        BL f02NumeroAleatorio
        STR x0, [sp, #40]       // Fila
        
        // Columna aleatoria
        LDR x1, [sp, #24]       // Tamaño
        MOV x0, #14
        SUB x0, x0, x1
        ADD x0, x0, #1
        BL f02NumeroAleatorio
        STR x0, [sp, #48]       // Columna inicio
        
        // Calcular columna fin
        LDR x0, [sp, #48]
        LDR x1, [sp, #24]
        ADD x0, x0, x1
        SUB x0, x0, #1
        STR x0, [sp, #56]       // Columna fin
        
        // Validar solapamiento
        LDR x0, [sp, #40]       // Fila
        LDR x1, [sp, #48]       // Columna inicio
        LDR x2, [sp, #40]       // Fila
        LDR x3, [sp, #56]       // Columna fin
        BL f08ValidarSolapamientoIA
        CMP x0, #0
        BEQ f09intentar

f09marcar_barco_ia:
        // Primero registrar el barco en BarcosComputadora
        LDR x0, =BarcosComputadora
        LDR x19, [sp, #16]      // Índice del barco
        MOV x4, #40             // Tamaño de cada estructura Barco
        MUL x5, x19, x4
        ADD x0, x0, x5          // x0 apunta al barco actual
        
        // Guardar tipo
        STR x19, [x0]           // Offset 0: tipo
        
        // Guardar tamaño
        LDR x6, [sp, #24]
        STR x6, [x0, #8]        // Offset 8: tamaño
        
        // Guardar fila_inicio, columna_inicio, fila_fin, columna_fin, orientación
        LDR x7, [sp, #32]       // Orientación
        STR x7, [x0, #16]       // Offset 16: orientación
        
        CMP x7, #0
        BEQ f09registrar_h_ia
        
f09registrar_v_ia:
        LDR x8, [sp, #40]       // Fila inicio
        LDR x9, [sp, #48]       // Columna
        LDR x10, [sp, #56]      // Fila fin
        
        STR x8, [x0, #24]       // Offset 24: fila_inicio
        STR x9, [x0, #32]       // Offset 32: columna_inicio (igual a columna_fin)
        B f09marcar_celdas_ia
        
f09registrar_h_ia:
        LDR x8, [sp, #40]       // Fila
        LDR x9, [sp, #48]       // Columna inicio
        LDR x10, [sp, #56]      // Columna fin
        
        STR x8, [x0, #24]       // Offset 24: fila_inicio (igual a fila_fin)
        STR x9, [x0, #32]       // Offset 32: columna_inicio

f09marcar_celdas_ia:
        // Ahora marcar celdas en TableroComputadora
        LDR x21, [sp, #32]      // Orientación
        CMP x21, #0
        BEQ f09marcar_h_ia
        
        // Marcar vertical
        LDR x1, [sp, #40]       // Fila inicio
        LDR x2, [sp, #56]       // Fila fin
        LDR x3, [sp, #48]       // Columna
        
f09loop_marcar_v_ia:
        CMP x1, x2
        BGT f09siguiente_barco
        
        LDR x0, =TableroComputadora
        LDR x4, =ESTADO_BARCO
        LDR x4, [x4]
        MOV x5, #14
        MUL x6, x1, x5
        ADD x6, x6, x3
        LSL x6, x6, #3
        ADD x0, x0, x6
        STR x4, [x0]
        
        ADD x1, x1, #1
        B f09loop_marcar_v_ia

f09marcar_h_ia:
        LDR x1, [sp, #40]       // Fila
        LDR x2, [sp, #48]       // Columna inicio
        LDR x3, [sp, #56]       // Columna fin
        
f09loop_marcar_h_ia:
        CMP x2, x3
        BGT f09siguiente_barco
        
        LDR x0, =TableroComputadora
        LDR x4, =ESTADO_BARCO
        LDR x4, [x4]
        MOV x5, #14
        MUL x6, x1, x5
        ADD x6, x6, x2
        LSL x6, x6, #3
        ADD x0, x0, x6
        STR x4, [x0]
        
        ADD x2, x2, #1
        B f09loop_marcar_h_ia

f09siguiente_barco:
        LDR x19, [sp, #16]
        ADD x19, x19, #1
        B f09loop_barcos

f09fin_colocacion:
        ldp x29, x30, [sp], 80
        RET


// ******  Nombre  ***********************************
// f10SeleccionarMisilIA
// ******  Descripción  ******************************
// Decide estratégicamente qué tipo de misil usar.
// Usa misiles especiales cuando hay munición y
// la situación es favorable.
// ******  Retorno  **********************************
// x0: Tipo de misil (0=estándar, 1=Exocet, 2=Tomahawk, 3=Apache)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f10SeleccionarMisilIA:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        // Generar número aleatorio para decidir (20% usar especial)
        MOV x0, #100
        BL f02NumeroAleatorio
        STR x0, [sp, #16]
        
        CMP x0, #80             // 80% usar estándar
        BGE f10usar_estandar
        
        // Verificar munición de Tomahawk (más potente)
        LDR x0, =MunicionComputadora
        LDR x1, [x0, #8]        // Tomahawk
        CMP x1, #0
        BGT f10usar_tomahawk
        
        // Verificar Apache
        LDR x1, [x0, #16]
        CMP x1, #0
        BGT f10usar_apache
        
        // Verificar Exocet
        LDR x1, [x0]
        CMP x1, #0
        BGT f10usar_exocet
        
f10usar_estandar:
        MOV x0, #0
        ldp x29, x30, [sp], 32
        RET

f10usar_exocet:
        MOV x0, #1
        ldp x29, x30, [sp], 32
        RET

f10usar_tomahawk:
        MOV x0, #2
        ldp x29, x30, [sp], 32
        RET

f10usar_apache:
        MOV x0, #3
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f11LanzarMisilEspecialIA
// ******  Descripción  ******************************
// Ejecuta un ataque con misil especial de la IA.
// ******  Retorno  **********************************
// x0: Resultado del ataque
// ******  Entradas  *********************************
// x0: Tipo de misil (1=Exocet, 2=Tomahawk, 3=Apache)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f11LanzarMisilEspecialIA:
        stp x29, x30, [sp, -64]!
        mov x29, sp
        
        STR x0, [sp, #16]       // Tipo de misil (guardar para munición)
        
        // Generar coordenada aleatoria
        BL f04EstrategiaBusqueda
        STR x0, [sp, #24]       // Fila
        STR x1, [sp, #32]       // Columna
        
        LDR x0, [sp, #16]
        CMP x0, #1
        BEQ f11usar_exocet_ia
        CMP x0, #2
        BEQ f11usar_tomahawk_ia
        CMP x0, #3
        BEQ f11usar_apache_ia
        B f11fin_especial

f11usar_exocet_ia:
        // Seleccionar patrón aleatorio (0 o 1)
        MOV x0, #2
        BL f02NumeroAleatorio
        CMP x0, #0
        BEQ f11exocet_patron1
        LDR x0, =PatronExocet2
        B f11aplicar_patron_ia

f11exocet_patron1:
        LDR x0, =PatronExocet1
        B f11aplicar_patron_ia

f11usar_tomahawk_ia:
        LDR x0, =PatronTomahawk
        B f11aplicar_patron_ia

f11usar_apache_ia:
        MOV x0, #2
        BL f02NumeroAleatorio
        CMP x0, #0
        BEQ f11apache_patron1
        LDR x0, =PatronApache2
        B f11aplicar_patron_ia

f11apache_patron1:
        LDR x0, =PatronApache1

f11aplicar_patron_ia:
        // x0 ya tiene el patrón
        LDR x1, [sp, #24]       // Fila
        LDR x2, [sp, #32]       // Columna
        
        // Aplicar patrón (ahora retorna el mejor resultado)
        BL f12AplicarPatronIA
        STR x0, [sp, #48]       // Guardar resultado del ataque en [sp,#48]
        
        // Decrementar munición usando el tipo original
        LDR x0, [sp, #16]       // Tipo de misil original (1, 2 o 3)
        SUB x0, x0, #1          // Convertir a índice munición (0, 1 o 2)
        BL f13DecrementarMunicionIA
        
        // Recuperar resultado del ataque
        LDR x0, [sp, #48]
        B f11fin_especial

f11fin_especial:
        // x0 ya contiene el resultado del ataque (0=agua, 1=impacto, 2=hundido)
        ldp x29, x30, [sp], 64
        RET
        RET


// ******  Nombre  ***********************************
// f12AplicarPatronIA
// ******  Descripción  ******************************
// Aplica un patrón de ataque de la IA.
// ******  Retorno  **********************************
// x0: Mejor resultado del patrón (0=agua, 1=impacto, 2=hundido)
// ******  Entradas  *********************************
// x0: Dirección del patrón
// x1: Fila central
// x2: Columna central
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f12AplicarPatronIA:
        stp x29, x30, [sp, -80]!
        mov x29, sp
        
        STR x0, [sp, #16]       // Patrón
        STR x1, [sp, #24]       // Fila central
        STR x2, [sp, #32]       // Columna central
        MOV x20, x0             // Puntero al patrón
        MOV x21, #0             // Mejor resultado acumulado (0=agua)
        STR x21, [sp, #56]      // Guardar mejor resultado

f12loop_patron_ia:
        LDRSB w22, [x20]
        LDRSB w23, [x20, #1]
        
        // Verificar terminador
        CMP w22, #-1
        BNE f12procesar_celda_ia
        CMP w23, #-1
        BNE f12procesar_celda_ia
        LDR x5, [sp, #16]
        CMP x20, x5
        BEQ f12procesar_celda_ia
        B f12fin_patron_ia

f12procesar_celda_ia:
        LDR x1, [sp, #24]       // Fila central
        LDR x2, [sp, #32]       // Columna central
        SXTW x3, w22
        SXTW x4, w23
        ADD x1, x1, x3
        ADD x2, x2, x4
        
        // Validar coordenada
        CMP x1, #0
        BLT f12siguiente_offset_ia
        CMP x1, #9
        BGT f12siguiente_offset_ia
        CMP x2, #0
        BLT f12siguiente_offset_ia
        CMP x2, #13
        BGT f12siguiente_offset_ia
        
        // Procesar disparo
        LDR x0, =TableroJugador
        STR x1, [sp, #40]
        STR x2, [sp, #48]
        MOV x3, x1
        MOV x4, x2
        LDR x1, =TableroDisparosComputadora
        LDR x2, =BarcosJugador
        MOV x5, #0              // Es IA
        BL f01ProcesarDisparoEnCelda
        
        // Actualizar mejor resultado
        // Si resultado actual > mejor resultado, actualizar
        LDR x1, [sp, #56]       // Mejor resultado actual
        CMP x0, x1
        BLE f12siguiente_offset_ia
        STR x0, [sp, #56]       // Actualizar mejor resultado

f12siguiente_offset_ia:
        ADD x20, x20, #2
        B f12loop_patron_ia

f12fin_patron_ia:
        LDR x0, [sp, #56]       // Retornar mejor resultado
        ldp x29, x30, [sp], 80
        RET


// ******  Nombre  ***********************************
// f13DecrementarMunicionIA
// ******  Descripción  ******************************
// Decrementa la munición de la IA.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Índice del tipo de misil
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f13DecrementarMunicionIA:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x1, =MunicionComputadora
        LSL x2, x0, #3
        ADD x1, x1, x2
        LDR x3, [x1]
        CMP x3, #0
        BLE f13fin_dec
        SUB x3, x3, #1
        STR x3, [x1]

f13fin_dec:
        ldp x29, x30, [sp], 16
        RET


// ============================================
// FIN DEL ARCHIVO
// ============================================
