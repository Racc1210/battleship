// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_misiles.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Módulo de sistema de misiles. Implementa:
// - Menú de selección de misiles disponibles
// - Lanzamiento de misiles estándar (1 celda)
// - Lanzamiento de Exocet (2 patrones)
// - Lanzamiento de Tomahawk (área 3×3)
// - Lanzamiento de Apache (2 patrones)
// - Lanzamiento de torpedos (direccional desde bordes)
// - Aplicación de patrones de ataque
// - Gestión de munición
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

// Declaraciones globales
.global f01MostrarMenuMisiles
.global f02SeleccionarYLanzarMisil
.global f03LanzarMisilEstandar
.global f04LanzarMisilExocet
.global f05LanzarMisilTomahawk
.global f06LanzarMisilApache
.global f07LanzarTorpedo
.global f08AplicarPatron
.global f09SeleccionarPatronExocet
.global f10SeleccionarPatronApache
.global f11SeleccionarDireccionTorpedo
.global f12ValidarOrigenTorpedo
.global f13DecrementarMunicion
.global f14VerificarMunicionDisponible

// Dependencias externas
.extern f01ImprimirCadena
.extern f02LeerCadena
.extern f03LeerNumero
.extern f12LeerCoordenada
.extern f05ValidarCoordenada
.extern f01ProcesarDisparoEnCelda
.extern f11ImprimirNumero
.extern f09RegistrarUltimoAtaque
.extern f12LimpiarUltimoAtaque
.extern BufferLectura
.extern UltimoAtaqueCeldas, UltimoAtaqueCantidad
.extern MunicionJugador, MunicionComputadora
.extern TableroComputadora, TableroJugador
.extern TableroDisparosJugador, TableroDisparosComputadora
.extern BarcosComputadora, BarcosJugador
.extern PatronExocet1, PatronExocet2
.extern PatronApache1, PatronApache2
.extern PatronTomahawk
.extern MenuMisiles, LargoMenuMisilesVal
.extern OpcionEstandar, LargoOpcionEstandarVal
.extern OpcionExocet, LargoOpcionExocetVal
.extern OpcionTomahawk, LargoOpcionTomahawkVal
.extern OpcionApache, LargoOpcionApacheVal
.extern OpcionTorpedo, LargoOpcionTorpedoVal
.extern MenuPatronExocet, LargoMenuPatronExocetVal
.extern MenuPatronApache, LargoMenuPatronApacheVal
.extern MenuDireccionTorpedo, LargoMenuDireccionTorpedoVal
.extern ErrorOrigenTorpedo, LargoErrorOrigenTorpedoVal
.extern MensajeCoordenadaAtaque, LargoMensajeCoordenadaAtaqueVal
.extern MensajeOpcionMisil, LargoMensajeOpcionMisilVal
.extern MensajeAgua, LargoMensajeAguaVal
.extern MensajeImpacto, LargoMensajeImpactoVal
.extern MensajeHundido, LargoMensajeHundidoVal
.extern ErrorOpcionInvalida, LargoErrorOpcionInvalidaVal
.extern ErrorMunicionAgotada, LargoErrorMunicionAgotadaVal
// .extern DebugMsg1, LargoDebugMsg1Val
// .extern DebugMsg2, LargoDebugMsg2Val
// .extern DebugMsg3, LargoDebugMsg3Val
// .extern DebugMsg4, LargoDebugMsg4Val
// .extern DebugMsg5, LargoDebugMsg5Val
// .extern DebugMsg6, LargoDebugMsg6Val
.extern DebugMsgStack1, LargoDebugMsgStack1Val
.extern DebugMsgStack2, LargoDebugMsgStack2Val
.extern DebugMsgStack3, LargoDebugMsgStack3Val
.extern DebugMsgStack4, LargoDebugMsgStack4Val
.extern DebugMsgEntry1, LargoDebugMsgEntry1Val
.extern DebugMsgEntry2, LargoDebugMsgEntry2Val
.extern SaltoLinea

.section .bss
BufferMunicion: .skip 8

.section .text

// ******  Nombre  ***********************************
// f01MostrarMenuMisiles
// ******  Descripción  ******************************
// Muestra el menú de misiles disponibles, ocultando
// aquellos cuya munición se ha agotado. Los misiles
// estándar siempre se muestran (ilimitados).
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna (usa MunicionJugador global)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01MostrarMenuMisiles:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Mostrar encabezado del menú
        LDR x1, =MenuMisiles
        LDR x2, =LargoMenuMisilesVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Opción 1: Misil Estándar (siempre disponible)
        LDR x1, =OpcionEstandar
        LDR x2, =LargoOpcionEstandarVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Opción 2: Misil Exocet
        LDR x1, =OpcionExocet
        LDR x2, =LargoOpcionExocetVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Imprimir cantidad
        LDR x0, =MunicionJugador
        LDR x0, [x0]
        BL f11ImprimirNumero
        
        // Opción 3: Misil Tomahawk
        LDR x1, =OpcionTomahawk
        LDR x2, =LargoOpcionTomahawkVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x0, =MunicionJugador
        LDR x0, [x0, #8]
        BL f11ImprimirNumero
        
        // Opción 4: Misil Apache
        LDR x1, =OpcionApache
        LDR x2, =LargoOpcionApacheVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x0, =MunicionJugador
        LDR x0, [x0, #16]
        BL f11ImprimirNumero
        
        // Opción 5: Torpedo
        LDR x1, =OpcionTorpedo
        LDR x2, =LargoOpcionTorpedoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x0, =MunicionJugador
        LDR x0, [x0, #24]
        BL f11ImprimirNumero
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f02SeleccionarYLanzarMisil
// ******  Descripción  ******************************
// Muestra el menú, solicita selección del usuario,
// valida la opción y llama a la función de
// lanzamiento correspondiente.
// ******  Retorno  **********************************
// x0: Cantidad de impactos realizados
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Reintenta hasta obtener opción válida
// ***************************************************
f02SeleccionarYLanzarMisil:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
f02solicitar_opcion:
        // Mostrar menú
        BL f01MostrarMenuMisiles
        
        // Solicitar opción
        LDR x1, =MensajeOpcionMisil
        LDR x2, =LargoMensajeOpcionMisilVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Leer opción
        BL f03LeerNumero
        
        // Validar opción (1-5)
        CMP x0, #1
        BLT f02opcion_invalida
        CMP x0, #5
        BGT f02opcion_invalida
        
        // Verificar munición disponible
        SUB x1, x0, #1          // Convertir a índice (0-4)
        STR x0, [sp, #16]       // Guardar opción original (NO en #8 porque sobrescribe x30!)
        BL f14VerificarMunicionDisponible
        CMP x0, #0
        BEQ f02sin_municion
        
        // Ejecutar acción según opción
        LDR x1, [sp, #16]       // Recuperar opción
        SUB x1, x1, #1          // Convertir a índice
        CMP x1, #0
        BEQ f02lanzar_estandar
        CMP x1, #1
        BEQ f02lanzar_exocet
        CMP x1, #2
        BEQ f02lanzar_tomahawk
        CMP x1, #3
        BEQ f02lanzar_apache
        CMP x1, #4
        BEQ f02lanzar_torpedo
        
        B f02opcion_invalida

f02sin_municion:
        LDR x1, =ErrorMunicionAgotada
        LDR x2, =LargoErrorMunicionAgotadaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f02solicitar_opcion

f02lanzar_estandar:
        BL f03LanzarMisilEstandar
        ldp x29, x30, [sp], 32
        RET

f02lanzar_exocet:
        BL f04LanzarMisilExocet
        ldp x29, x30, [sp], 32
        RET

f02lanzar_tomahawk:
        BL f05LanzarMisilTomahawk
        ldp x29, x30, [sp], 32
        RET

f02lanzar_apache:
        BL f06LanzarMisilApache
        ldp x29, x30, [sp], 32
        RET

f02lanzar_torpedo:
        BL f07LanzarTorpedo
        ldp x29, x30, [sp], 32
        RET

f02opcion_invalida:
        LDR x1, =ErrorOpcionInvalida
        LDR x2, =LargoErrorOpcionInvalidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f02solicitar_opcion


// ******  Nombre  ***********************************
// f14VerificarMunicionDisponible
// ******  Descripción  ******************************
// Verifica si hay munición disponible para un
// tipo de misil específico.
// ******  Retorno  **********************************
// x0: 1 si hay munición, 0 si no hay
// ******  Entradas  *********************************
// x1: Índice del tipo de misil (0-4)
//     0=Estándar, 1=Exocet, 2=Tomahawk, 3=Apache, 4=Torpedo
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f14VerificarMunicionDisponible:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Misil estándar siempre disponible
        CMP x1, #0
        BEQ f14disponible
        
        // Cargar munición del tipo correspondiente
        // x1 contiene índice: 1=Exocet, 2=Tomahawk, 3=Apache, 4=Torpedo
        // Pero MunicionJugador tiene índices: 0=Exocet, 1=Tomahawk, 2=Apache, 3=Torpedo
        LDR x0, =MunicionJugador
        SUB x2, x1, #1          // Convertir índice: 1→0, 2→1, 3→2, 4→3
        LSL x2, x2, #3          // × 8 bytes
        ADD x0, x0, x2
        LDR x3, [x0]
        
        CMP x3, #0
        BLE f14no_disponible
        
f14disponible:
        MOV x0, #1
        ldp x29, x30, [sp], 16
        RET

f14no_disponible:
        MOV x0, #0
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f03LanzarMisilEstandar
// ******  Descripción  ******************************
// Lanza un misil estándar que impacta una única
// celda. Solicita coordenadas al usuario.
// ******  Retorno  **********************************
// x0: Resultado del disparo (0=agua, 1=impacto, 2=hundido)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Reintenta si coordenada inválida
// ***************************************************
f03LanzarMisilEstandar:
        stp x29, x30, [sp, -80]!
        mov x29, sp
        
f03solicitar_coord:
        // Solicitar coordenada
        LDR x1, =MensajeCoordenadaAtaque
        LDR x2, =LargoMensajeCoordenadaAtaqueVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Leer coordenada
        BL f12LeerCoordenada
        
        // Guardar coordenadas ANTES de validar
        STR x0, [sp, #16]       // Fila
        STR x1, [sp, #24]       // Columna
        
        // Validar (x0 y x1 ya tienen fila y columna)
        BL f05ValidarCoordenada
        CMP x0, #0
        BEQ f03solicitar_coord
        
        // Procesar disparo
        LDR x0, =TableroComputadora
        LDR x1, =TableroDisparosJugador
        LDR x2, =BarcosComputadora
        LDR x3, [sp, #16]       // Fila
        LDR x4, [sp, #24]       // Columna
        MOV x5, #1              // Es jugador
        BL f01ProcesarDisparoEnCelda
        
        // x0 tiene el resultado - guardarlo
        STR x0, [sp, #32]       // Resultado
        
        // Registrar último ataque para highlighting
        LDR x0, [sp, #16]       // Fila
        LDR x1, [sp, #24]       // Columna
        BL f09RegistrarUltimoAtaque
        
        // Recuperar resultado
        LDR x0, [sp, #32]
        
        // Mostrar resultado
        CMP x0, #0
        BEQ f03resultado_agua
        CMP x0, #1
        BEQ f03resultado_impacto
        CMP x0, #2
        BEQ f03resultado_hundido
        
f03resultado_agua:
        LDR x1, =MensajeAgua
        LDR x2, =LargoMensajeAguaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        MOV x0, #0
        ldp x29, x30, [sp], 80
        RET

f03resultado_impacto:
        LDR x1, =MensajeImpacto
        LDR x2, =LargoMensajeImpactoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        MOV x0, #1
        ldp x29, x30, [sp], 80
        RET

f03resultado_hundido:
        LDR x1, =MensajeHundido
        LDR x2, =LargoMensajeHundidoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        MOV x0, #2
        ldp x29, x30, [sp], 80
        RET


// ******  Nombre  ***********************************
// f04LanzarMisilExocet
// ******  Descripción  ******************************
// Lanza un misil Exocet con patrón seleccionable.
// Solicita patrón, coordenadas y aplica el patrón.
// ******  Retorno  **********************************
// x0: Cantidad de impactos
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04LanzarMisilExocet:
        stp x29, x30, [sp, -48]!
        mov x29, sp
        
        // Seleccionar patrón
        BL f09SeleccionarPatronExocet
        STR x0, [sp, #16]       // Guardar dirección del patrón
        
        // Solicitar coordenada central
        LDR x1, =MensajeCoordenadaAtaque
        LDR x2, =LargoMensajeCoordenadaAtaqueVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f12LeerCoordenada
        STR x0, [sp, #24]       // Fila central
        STR x1, [sp, #32]       // Columna central
        
        // Aplicar patrón
        LDR x0, [sp, #16]       // Patrón
        LDR x1, [sp, #24]       // Fila
        LDR x2, [sp, #32]       // Columna
        BL f08AplicarPatron
        
        // Decrementar munición Exocet
        MOV x0, #0              // Índice Exocet
        BL f13DecrementarMunicion
        
        ldp x29, x30, [sp], 48
        RET


// ******  Nombre  ***********************************
// f05LanzarMisilTomahawk
// ******  Descripción  ******************************
// Lanza un misil Tomahawk que impacta área 3×3.
// ******  Retorno  **********************************
// x0: Cantidad de impactos
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05LanzarMisilTomahawk:
        stp x29, x30, [sp, -48]!
        mov x29, sp
        
        // Solicitar coordenada central
        LDR x1, =MensajeCoordenadaAtaque
        LDR x2, =LargoMensajeCoordenadaAtaqueVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f12LeerCoordenada
        STR x0, [sp, #16]       // Fila central
        STR x1, [sp, #24]       // Columna central
        
        // Aplicar patrón Tomahawk
        LDR x0, =PatronTomahawk
        LDR x1, [sp, #16]
        LDR x2, [sp, #24]
        BL f08AplicarPatron
        
        // Decrementar munición
        MOV x0, #1              // Índice Tomahawk
        BL f13DecrementarMunicion
        
        ldp x29, x30, [sp], 48
        RET


// ******  Nombre  ***********************************
// f06LanzarMisilApache
// ******  Descripción  ******************************
// Lanza un misil Apache con patrón seleccionable.
// ******  Retorno  **********************************
// x0: Cantidad de impactos
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f06LanzarMisilApache:
        stp x29, x30, [sp, -48]!
        mov x29, sp
        
        // Seleccionar patrón
        BL f10SeleccionarPatronApache
        STR x0, [sp, #16]
        
        // Solicitar coordenada
        LDR x1, =MensajeCoordenadaAtaque
        LDR x2, =LargoMensajeCoordenadaAtaqueVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f12LeerCoordenada
        STR x0, [sp, #24]
        STR x1, [sp, #32]
        
        // Aplicar patrón
        LDR x0, [sp, #16]
        LDR x1, [sp, #24]
        LDR x2, [sp, #32]
        BL f08AplicarPatron
        
        // Decrementar munición
        MOV x0, #2              // Índice Apache
        BL f13DecrementarMunicion
        
        ldp x29, x30, [sp], 48
        RET


// ******  Nombre  ***********************************
// f07LanzarTorpedo
// ******  Descripción  ******************************
// Lanza un torpedo desde el borde del tablero en
// una dirección específica. Viaja hasta impactar
// el primer barco o salir del tablero.
// ******  Retorno  **********************************
// x0: Resultado (0=no impacto, 1=impacto, 2=hundido)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Reintenta si origen/dirección inválidos
// ***************************************************
f07LanzarTorpedo:
        stp x29, x30, [sp, -64]!
        mov x29, sp
        
f07solicitar_direccion:
        // Seleccionar dirección
        BL f11SeleccionarDireccionTorpedo
        STR x0, [sp, #16]       // Dirección (0=N, 1=S, 2=E, 3=O)
        
        // Solicitar fila o columna según dirección
        LDR x2, [sp, #16]
        CMP x2, #0              // Norte
        BEQ f07solicitar_columna_norte_sur
        CMP x2, #1              // Sur
        BEQ f07solicitar_columna_norte_sur
        // Si no es Norte ni Sur, es Este u Oeste
        B f07solicitar_fila_este_oeste

f07solicitar_columna_norte_sur:
        // Norte/Sur: solicitar solo columna (1-14)
        LDR x1, =MensajeColumnaAtaque
        LDR x2, =LargoMensajeColumnaAtaqueVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f03LeerNumero         // Lee número de columna (1-14)
        SUB x0, x0, #1           // Convertir a índice 0-13
        CMP x0, #0
        BLT f07origen_invalido
        CMP x0, #13
        BGT f07origen_invalido
        
        STR x0, [sp, #32]        // Guardar columna
        
        // Establecer fila según dirección
        LDR x2, [sp, #16]
        CMP x2, #0               // Norte: fila A (0)
        BEQ f07set_fila_norte
        MOV x0, #9               // Sur: fila J (9)
        STR x0, [sp, #24]
        B f07iniciar_torpedo

f07set_fila_norte:
        MOV x0, #0
        STR x0, [sp, #24]
        B f07iniciar_torpedo

f07solicitar_fila_este_oeste:
        // Este/Oeste: solicitar solo fila (A-J)
        LDR x1, =MensajeFilaAtaque
        LDR x2, =LargoMensajeFilaAtaqueVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f02LeerCadena          // Lee una cadena
        
        // Convertir letra a índice (A=0, J=9)
        LDR x1, =BufferLectura
        LDRB w0, [x1]             // Primer carácter
        
        // Convertir a mayúscula si es necesario
        CMP w0, #'a'
        BLT f07check_uppercase
        CMP w0, #'z'
        BGT f07origen_invalido
        SUB w0, w0, #32           // Convertir a mayúscula

f07check_uppercase:
        CMP w0, #'A'
        BLT f07origen_invalido
        CMP w0, #'J'
        BGT f07origen_invalido
        SUB w0, w0, #'A'          // Convertir a índice 0-9
        
        STR x0, [sp, #24]         // Guardar fila
        
        // Establecer columna según dirección
        LDR x2, [sp, #16]
        CMP x2, #2                // Este: columna 14 (13)
        BEQ f07set_col_este
        MOV x0, #0                // Oeste: columna 1 (0)
        STR x0, [sp, #32]
        B f07iniciar_torpedo

f07set_col_este:
        MOV x0, #13
        STR x0, [sp, #32]

f07iniciar_torpedo:
        // Recorrer en la dirección especificada
        LDR x19, [sp, #24]      // Fila actual
        LDR x20, [sp, #32]      // Columna actual
        LDR x21, [sp, #16]      // Dirección
        MOV x22, #0             // Resultado inicial (AGUA)
        STR x22, [sp, #40]      // Guardar resultado inicial
        
f07recorrer_torpedo:
        // Avanzar según dirección
        CMP x21, #0             // Norte (viene desde arriba → avanza hacia abajo)
        BEQ f07avanzar_norte
        CMP x21, #1             // Sur (viene desde abajo → avanza hacia arriba)
        BEQ f07avanzar_sur
        CMP x21, #2             // Este (viene desde derecha → avanza hacia izquierda)
        BEQ f07avanzar_este
        CMP x21, #3             // Oeste (viene desde izquierda → avanza hacia derecha)
        BEQ f07avanzar_oeste
        
f07avanzar_norte:
        ADD x19, x19, #1        // Norte: incrementar fila (A→B→C...)
        B f07verificar_celda

f07avanzar_sur:
        SUB x19, x19, #1        // Sur: decrementar fila (J→I→H...)
        B f07verificar_celda

f07avanzar_este:
        SUB x20, x20, #1        // Este: decrementar columna (14→13→12...)
        B f07verificar_celda

f07avanzar_oeste:
        ADD x20, x20, #1        // Oeste: incrementar columna (1→2→3...)

f07verificar_celda:
        // Verificar límites del tablero 10x14 (filas 0-9, columnas 0-13)
        CMP x19, #0
        BLT f07fin_torpedo
        CMP x19, #9
        BGT f07fin_torpedo
        CMP x20, #0
        BLT f07fin_torpedo
        CMP x20, #13
        BGT f07fin_torpedo
        
        // Procesar celda actual
        LDR x0, =TableroComputadora
        LDR x1, =TableroDisparosJugador
        LDR x2, =BarcosComputadora
        MOV x3, x19
        MOV x4, x20
        MOV x5, #1
        BL f01ProcesarDisparoEnCelda
        
        // Si impactó barco, terminar
        CMP x0, #0
        BGT f07impacto_torpedo
        
        // Continuar recorrido
        B f07recorrer_torpedo

f07impacto_torpedo:
        STR x0, [sp, #40]
        B f07fin_torpedo

f07origen_invalido:
        LDR x1, =ErrorOrigenTorpedo
        LDR x2, =LargoErrorOrigenTorpedoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f07solicitar_direccion

f07fin_torpedo:
        // Decrementar munición
        MOV x0, #3              // Índice Torpedo
        BL f13DecrementarMunicion
        
        LDR x0, [sp, #40]
        ldp x29, x30, [sp], 64
        RET


// ******  Nombre  ***********************************
// f08AplicarPatron
// ******  Descripción  ******************************
// Aplica un patrón de ataque desde una coordenada
// central. Lee offsets del patrón y procesa cada
// celda afectada.
// ******  Retorno  **********************************
// x0: Cantidad de impactos realizados
// ******  Entradas  *********************************
// x0: Dirección del patrón
// x1: Fila central
// x2: Columna central
// ******  Errores  **********************************
// Ninguno (salta celdas fuera del tablero)
// ***************************************************
f08AplicarPatron:
        stp x29, x30, [sp, -240]!    // 240 bytes: 80 para vars + 160 para buffer (10 celdas × 16)
        mov x29, sp
        
        // Guardar registros callee-saved
        STP x19, x20, [sp, #16]
        STP x21, x22, [sp, #32]
        STR x23, [sp, #48]
        
        STR x0, [sp, #56]       // Patrón
        STR x1, [sp, #64]       // Fila central
        STR x2, [sp, #72]       // Columna central
        MOV x19, #0             // Contador impactos
        MOV x20, x0             // Puntero al patrón inicial
        MOV x21, #0             // Contador de celdas atacadas
        
        // Buffer local para coordenadas (en stack)
        // Desde [sp, #80] tenemos espacio para coordenadas
        
f08loop_patron:
        
        // Leer siguiente offset
        LDRSB w22, [x20]        // Offset fila (signed byte)
        LDRSB w23, [x20, #1]    // Offset columna (signed byte)
        
        // Verificar terminador (0xFF, 0xFF) que se lee como (-1, -1)
        // Pero (-1, -1) también es un offset válido (diagonal arriba-izquierda)
        // Solución: verificar AMBOS a la vez primero
        CMP w22, #-1
        BNE f08procesar_celda   // Si fila no es -1, procesar
        CMP w23, #-1
        BNE f08procesar_celda   // Si fila es -1 pero columna no, procesar
        // Si llegamos aquí, ambos son -1, podría ser terminador O primera celda diagonal
        // Verificar si es el primer offset o no
        LDR x5, [sp, #56]       // Patrón inicial
        CMP x20, x5             // ¿Estamos en el primer offset?
        BEQ f08procesar_celda   // Si es el primero, es una celda válida
        B f08fin_patron         // Si no, es el terminador
        
f08procesar_celda:
        // Calcular coordenada objetivo
        LDR x1, [sp, #64]       // Fila central
        LDR x2, [sp, #72]       // Columna central
        SXTW x3, w22            // Extender signo de offset fila a 64 bits
        SXTW x4, w23            // Extender signo de offset columna a 64 bits
        ADD x1, x1, x3          // Fila objetivo
        ADD x2, x2, x4          // Columna objetivo
        
        // Validar coordenada
        CMP x1, #0
        BLT f08siguiente_offset
        CMP x1, #9
        BGT f08siguiente_offset
        CMP x2, #0
        BLT f08siguiente_offset
        CMP x2, #13             // Tablero 10x14: columnas 0-13
        BGT f08siguiente_offset
        
        // Guardar coordenadas en buffer local del stack
        MOV x5, #80             // Offset base para buffer  
        LSL x6, x21, #4         // × 16 bytes por par
        ADD x5, x5, x6
        ADD x5, sp, x5          // Dirección en stack
        STR x1, [x5]            // Guardar fila
        STR x2, [x5, #8]        // Guardar columna
        
        // Procesar disparo
        LDR x0, =TableroComputadora
        MOV x3, x1
        MOV x4, x2
        LDR x1, =TableroDisparosJugador
        LDR x2, =BarcosComputadora
        MOV x5, #1
        BL f01ProcesarDisparoEnCelda
        
        // Incrementar contador de celdas
        ADD x21, x21, #1
        
        // Incrementar contador si fue impacto
        CMP x0, #0
        BLE f08siguiente_offset
        ADD x19, x19, #1
        
f08siguiente_offset:
        ADD x20, x20, #2        // Avanzar al siguiente par
        B f08loop_patron

f08fin_patron:
        // Copiar coordenadas del stack al array global
        LDR x5, =UltimoAtaqueCeldas
        MOV x6, #0              // Índice
        
f08copiar_coords:
        CMP x6, x21             // ¿Copiamos todas?
        BGE f08terminar
        
        // Calcular offset en stack
        MOV x7, #80
        LSL x8, x6, #4
        ADD x7, x7, x8
        ADD x7, sp, x7
        
        // Leer del stack
        LDR x8, [x7]            // Fila
        LDR x9, [x7, #8]        // Columna
        
        // Escribir al array global
        LSL x10, x6, #4
        ADD x10, x5, x10
        STR x8, [x10]
        STR x9, [x10, #8]
        
        ADD x6, x6, #1
        B f08copiar_coords
        
f08terminar:
        // Guardar cantidad de celdas en variable global
        LDR x0, =UltimoAtaqueCantidad
        STR x21, [x0]
        
        // Retornar cantidad de impactos
        MOV x0, x19
        
        // Restaurar registros callee-saved
        LDP x19, x20, [sp, #16]
        LDP x21, x22, [sp, #32]
        LDR x23, [sp, #48]
        
        ldp x29, x30, [sp], 240
        RET


// ******  Nombre  ***********************************
// f09SeleccionarPatronExocet
// ******  Descripción  ******************************
// Solicita al usuario seleccionar uno de los dos
// patrones disponibles del misil Exocet.
// ******  Retorno  **********************************
// x0: Dirección del patrón seleccionado
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Reintenta hasta opción válida
// ***************************************************
f09SeleccionarPatronExocet:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
f09solicitar:
        LDR x1, =MenuPatronExocet
        LDR x2, =LargoMenuPatronExocetVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f03LeerNumero
        
        CMP x0, #1
        BEQ f09patron1
        CMP x0, #2
        BEQ f09patron2
        
        LDR x1, =ErrorOpcionInvalida
        LDR x2, =LargoErrorOpcionInvalidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f09solicitar

f09patron1:
        LDR x0, =PatronExocet1
        ldp x29, x30, [sp], 16
        RET

f09patron2:
        LDR x0, =PatronExocet2
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f10SeleccionarPatronApache
// ******  Descripción  ******************************
// Solicita al usuario seleccionar uno de los dos
// patrones disponibles del misil Apache.
// ******  Retorno  **********************************
// x0: Dirección del patrón seleccionado
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Reintenta hasta opción válida
// ***************************************************
f10SeleccionarPatronApache:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
f10solicitar:
        LDR x1, =MenuPatronApache
        LDR x2, =LargoMenuPatronApacheVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f03LeerNumero
        
        CMP x0, #1
        BEQ f10patron1
        CMP x0, #2
        BEQ f10patron2
        
        LDR x1, =ErrorOpcionInvalida
        LDR x2, =LargoErrorOpcionInvalidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f10solicitar

f10patron1:
        LDR x0, =PatronApache1
        ldp x29, x30, [sp], 16
        RET

f10patron2:
        LDR x0, =PatronApache2
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f11SeleccionarDireccionTorpedo
// ******  Descripción  ******************************
// Solicita al usuario seleccionar dirección del
// torpedo (Norte, Sur, Este, Oeste).
// ******  Retorno  **********************************
// x0: Dirección (0=N, 1=S, 2=E, 3=O)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Reintenta hasta opción válida
// ***************************************************
f11SeleccionarDireccionTorpedo:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
f11solicitar:
        LDR x1, =MenuDireccionTorpedo
        LDR x2, =LargoMenuDireccionTorpedoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f03LeerNumero
        
        CMP x0, #1
        BLT f11invalida
        CMP x0, #4
        BGT f11invalida
        
        SUB x0, x0, #1          // Convertir 1-4 a 0-3
        ldp x29, x30, [sp], 16
        RET

f11invalida:
        LDR x1, =ErrorOpcionInvalida
        LDR x2, =LargoErrorOpcionInvalidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f11solicitar


// ******  Nombre  ***********************************
// f12ValidarOrigenTorpedo
// ******  Descripción  ******************************
// Valida que el torpedo se lance desde el borde
// del tablero en la dirección correcta.
// ******  Retorno  **********************************
// x0: 1 si válido, 0 si inválido
// ******  Entradas  *********************************
// x0: Fila de origen
// x1: Columna de origen
// x2: Dirección (0=N, 1=S, 2=E, 3=O)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f12ValidarOrigenTorpedo:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        CMP x2, #0              // Norte (desde fila 9)
        BEQ f12validar_norte
        CMP x2, #1              // Sur (desde fila 0)
        BEQ f12validar_sur
        CMP x2, #2              // Este (desde columna 0)
        BEQ f12validar_este
        CMP x2, #3              // Oeste (desde columna 13)
        BEQ f12validar_oeste
        
f12validar_norte:
        CMP x0, #0              // Norte: desde fila A (0) viaja hacia abajo (SUR)
        BNE f12invalido
        MOV x0, #1
        ldp x29, x30, [sp], 16
        RET

f12validar_sur:
        CMP x0, #9              // Sur: desde fila J (9) viaja hacia arriba (NORTE)
        BNE f12invalido
        MOV x0, #1
        ldp x29, x30, [sp], 16
        RET

f12validar_este:
        CMP x1, #13             // Este: desde columna 14 (13) viaja hacia izquierda (OESTE)
        BNE f12invalido
        MOV x0, #1
        ldp x29, x30, [sp], 16
        RET

f12validar_oeste:
        CMP x1, #0              // Oeste: desde columna 1 (0) viaja hacia derecha (ESTE)
        BNE f12invalido
        MOV x0, #1
        ldp x29, x30, [sp], 16
        RET

f12invalido:
        MOV x0, #0
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f13DecrementarMunicion
// ******  Descripción  ******************************
// Decrementa el contador de munición de un tipo
// de misil específico.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Índice del tipo de misil (0-3)
//     0=Exocet, 1=Tomahawk, 2=Apache, 3=Torpedo
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f13DecrementarMunicion:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x1, =MunicionJugador
        LSL x2, x0, #3          // × 8 bytes
        ADD x1, x1, x2
        
        LDR x3, [x1]
        CMP x3, #0
        BLE f13fin
        
        SUB x3, x3, #1
        STR x3, [x1]

f13fin:
        ldp x29, x30, [sp], 16
        RET


// ============================================
// FIN DEL ARCHIVO
// ============================================
