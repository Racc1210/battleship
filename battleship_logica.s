// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_logica.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Módulo de lógica principal del juego. Implementa:
// - Fase de preparación (colocación de barcos)
// - Bucle principal de enfrentamiento
// - Alternancia de turnos jugador/IA
// - Verificación de condiciones de victoria/derrota
// - Gestión de fin de juego
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

// Declaraciones globales
.global f01FasePreparacion
.global f02BucleEnfrentamiento
.global f03TurnoJugador
.global f04VerificarFinDeJuego
.global f05MostrarResultadoFinal
.global JuegoTerminado

// Dependencias externas
.extern f01ImprimirCadena
.extern f02LeerCadena
.extern f05LimpiarPantalla
.extern f01InicializarTableros
.extern f01ColocarTodosBarcosJugador
.extern f08ColocarTodosBarcosIA
.extern f01InicializarIA
.extern f02SeleccionarYLanzarMisil
.extern f02TurnoIA
.extern f04ContarBarcosHundidos
.extern DEBUG_ImprimirTableroEnemigo
.extern f03ImprimirTableroEnemigo
.extern f04ImprimirAmbosTableros
.extern BarcosJugador, BarcosComputadora
.extern EstadoBarcosJugador, EstadoBarcosComputadora
.extern BufferLectura
.extern MensajePresionarEnter, LargoMensajePresionarEnterVal
.extern MensajeTurnoJugador, LargoMensajeTurnoJugadorVal
.extern MensajeTurnoEnemigo, LargoMensajeTurnoEnemigoVal
.extern MensajeVictoria, LargoMensajeVictoriaVal
.extern MensajeDerrota, LargoMensajeDerrotaVal
.extern MensajeVictoriaFinal, LargoMensajeVictoriaFinalVal
.extern MensajeDerrotaFinal, LargoMensajeDerrotaFinalVal
.extern SaltoLinea

.section .bss
JuegoTerminado: .skip 8    // 0=en curso, 1=jugador ganó, 2=IA ganó

.section .text

// ******  Nombre  ***********************************
// f01FasePreparacion
// ******  Descripción  ******************************
// Ejecuta la fase de preparación del juego:
// 1. Inicializa tableros
// 2. Jugador coloca sus barcos manualmente
// 3. IA coloca sus barcos automáticamente
// 4. Inicializa estado de la IA
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01FasePreparacion:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Limpiar pantalla
        BL f05LimpiarPantalla
        
        // Inicializar tableros (ambos vacíos)
        BL f01InicializarTableros
        
        // Fase de colocación del jugador
        BL f01ColocarTodosBarcosJugador
        
        // Mensaje de transición
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        BL f01ImprimirCadena
        
        // Colocar barcos de la IA (usando sistema nuevo)
        BL f08ColocarTodosBarcosIA
        
        // [DEBUG TEMPORAL] Mostrar tablero enemigo con barcos revelados
        BL DEBUG_ImprimirTableroEnemigo
        
        // Esperar ENTER para continuar
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        LDR x1, =BufferLectura
        MOV x2, #10
        BL f02LeerCadena
        
        // Inicializar estado de la IA
        BL f01InicializarIA
        
        // Resetear flag de juego terminado
        LDR x0, =JuegoTerminado
        MOV x1, #0
        STR x1, [x0]
        
        // Mensaje para comenzar
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Esperar Enter (leer y descartar)
        MOV x8, #63             // Syscall read
        MOV x0, #0              // stdin
        SUB sp, sp, #16
        MOV x1, sp
        MOV x2, #2
        SVC #0
        ADD sp, sp, #16
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f02BucleEnfrentamiento
// ******  Descripción  ******************************
// Bucle principal del juego. Alterna entre turno
// del jugador y turno de la IA hasta que uno de
// los dos pierda todos sus barcos.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f02BucleEnfrentamiento:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
f02loop_juego:
        // Verificar si el juego terminó
        LDR x0, =JuegoTerminado
        LDR x0, [x0]
        CMP x0, #0
        BNE f02fin_juego
        
        // Limpiar pantalla antes del turno del jugador
        BL f05LimpiarPantalla
        
        // Turno del jugador
        BL f03TurnoJugador
        
        // Verificar victoria del jugador
        BL f04VerificarFinDeJuego
        LDR x0, =JuegoTerminado
        LDR x0, [x0]
        CMP x0, #0
        BNE f02fin_juego
        
        // Pequeña pausa
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        MOV x8, #63
        MOV x0, #0
        SUB sp, sp, #16
        MOV x1, sp
        MOV x2, #2
        SVC #0
        ADD sp, sp, #16
        
        // Limpiar antes del turno enemigo
        BL f05LimpiarPantalla
        
        // Turno de la IA
        LDR x1, =MensajeTurnoEnemigo
        LDR x2, =LargoMensajeTurnoEnemigoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f02TurnoIA
        
        // Verificar victoria de la IA
        BL f04VerificarFinDeJuego
        LDR x0, =JuegoTerminado
        LDR x0, [x0]
        CMP x0, #0
        BNE f02fin_juego
        
        // Pequeña pausa
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        MOV x8, #63
        MOV x0, #0
        SUB sp, sp, #16
        MOV x1, sp
        MOV x2, #2
        SVC #0
        ADD sp, sp, #16
        
        B f02loop_juego

f02fin_juego:
        // Mostrar resultado final
        BL f05MostrarResultadoFinal
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f03TurnoJugador
// ******  Descripción  ******************************
// Ejecuta el turno completo del jugador:
// 1. Limpia pantalla
// 2. Muestra tableros
// 3. Muestra menú de misiles
// 4. Jugador selecciona y lanza misil
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f03TurnoJugador:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Limpiar pantalla
        BL f05LimpiarPantalla
        
        // Mostrar mensaje de turno
        LDR x1, =MensajeTurnoJugador
        LDR x2, =LargoMensajeTurnoJugadorVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Mostrar tableros
        BL f04ImprimirAmbosTableros
        
        // Seleccionar y lanzar misil
        BL f02SeleccionarYLanzarMisil
        
        // Mostrar tablero enemigo actualizado
        BL f03ImprimirTableroEnemigo
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f04VerificarFinDeJuego
// ******  Descripción  ******************************
// Verifica si el juego ha terminado contando los
// barcos hundidos de cada jugador. Si alguno perdió
// todos sus barcos, actualiza JuegoTerminado.
// ******  Retorno  **********************************
// Ninguno (actualiza variable global JuegoTerminado)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04VerificarFinDeJuego:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        // Contar barcos hundidos del jugador
        LDR x0, =EstadoBarcosJugador
        BL f04ContarBarcosHundidos
        STR x0, [sp, #16]       // Guardar barcos hundidos del jugador
        
        // Contar barcos hundidos de la computadora
        LDR x0, =EstadoBarcosComputadora
        BL f04ContarBarcosHundidos
        STR x0, [sp, #24]       // Guardar barcos hundidos de la IA
        
        // Verificar si el jugador perdió (5 barcos hundidos)
        LDR x0, [sp, #16]
        CMP x0, #5
        BEQ f04jugador_perdio
        
        // Verificar si la IA perdió (5 barcos hundidos)
        LDR x0, [sp, #24]
        CMP x0, #5
        BEQ f04jugador_gano
        
        // El juego continúa
        ldp x29, x30, [sp], 32
        RET

f04jugador_gano:
        LDR x0, =JuegoTerminado
        MOV x1, #1              // Victoria del jugador
        STR x1, [x0]
        ldp x29, x30, [sp], 32
        RET

f04jugador_perdio:
        LDR x0, =JuegoTerminado
        MOV x1, #2              // Victoria de la IA
        STR x1, [x0]
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f05MostrarResultadoFinal
// ******  Descripción  ******************************
// Muestra el mensaje final de victoria o derrota
// según el resultado del juego.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna (usa JuegoTerminado global)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05MostrarResultadoFinal:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Limpiar pantalla
        BL f05LimpiarPantalla
        
        // Verificar resultado
        LDR x0, =JuegoTerminado
        LDR x0, [x0]
        
        CMP x0, #1
        BEQ f05mostrar_victoria
        
        CMP x0, #2
        BEQ f05mostrar_derrota
        
        // No debería llegar aquí
        ldp x29, x30, [sp], 16
        RET

f05mostrar_victoria:
        // Usar mensaje de victoria final (más grande y bonito)
        LDR x1, =MensajeVictoriaFinal
        LDR x2, =LargoMensajeVictoriaFinalVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Esperar ENTER
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x1, =BufferLectura
        MOV x2, #10
        BL f02LeerCadena
        
        ldp x29, x30, [sp], 16
        RET

f05mostrar_derrota:
        // Usar mensaje de derrota final (más grande y bonito)
        LDR x1, =MensajeDerrotaFinal
        LDR x2, =LargoMensajeDerrotaFinalVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Esperar ENTER
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x1, =BufferLectura
        MOV x2, #10
        BL f02LeerCadena
        
        ldp x29, x30, [sp], 16
        RET


// ============================================
// FIN DEL ARCHIVO
// ============================================
