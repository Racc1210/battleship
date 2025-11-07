// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_main.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Punto de entrada principal del juego Battleship.
// Sistema de menú completo con opciones de juego,
// tutorial, créditos y salir.
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// 02 | 2025-11-06 | Roymar Castillo - Sistema de menú mejorado
// ***************************************************

// Declaración global del punto de entrada
.global _start

// Dependencias externas
.extern f01ImprimirCadena
.extern f02LeerCadena
.extern f03LeerNumero
.extern f05LimpiarPantalla
.extern f13InicializarSemilla
.extern f01FasePreparacion
.extern f02BucleEnfrentamiento
.extern f05MostrarResultadoFinal
.extern BufferLectura
.extern MensajeBienvenida, LargoMensajeBienvenidaVal
.extern MenuPrincipal, LargoMenuPrincipalVal
.extern OpcionInvalida, LargoOpcionInvalidaVal
.extern TutorialPagina1, LargoTutorialPagina1Val
.extern TutorialPagina2, LargoTutorialPagina2Val
.extern TutorialPagina3, LargoTutorialPagina3Val
.extern TutorialPagina4, LargoTutorialPagina4Val
.extern MensajeCreditos, LargoMensajeCreditosVal
.extern MensajeDespedida, LargoMensajeDespedidaVal
.extern MensajePresionarEnter, LargoMensajePresionarEnterVal
.extern SaltoLinea
.extern JuegoTerminado

.section .bss
OpcionMenu: .skip 8         // Opción seleccionada del menú

.section .text

// ******  Nombre  ***********************************
// _start
// ******  Descripción  ******************************
// Punto de entrada principal. Muestra menú y maneja
// la navegación entre opciones.
// ******  Retorno  **********************************
// No retorna (termina el proceso)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Sale con código 0 en ejecución normal
// ***************************************************
_start:
        // Inicializar semilla aleatoria (una sola vez)
        BL f13InicializarSemilla
        
        // Loop principal del menú (mostrar directamente)
MenuLoop:
        BL f05LimpiarPantalla
        BL MostrarMenuPrincipal
        
        // Leer opción
        BL f03LeerNumero
        LDR x1, =OpcionMenu
        STR x0, [x1]
        
        // Procesar opción
        CMP x0, #1
        BEQ OpcionJugar
        CMP x0, #2
        BEQ OpcionTutorial
        CMP x0, #3
        BEQ OpcionCreditos
        CMP x0, #4
        BEQ OpcionSalir
        
        // Opción inválida
        LDR x1, =OpcionInvalida
        LDR x2, =LargoOpcionInvalidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL EsperarEnter
        
        B MenuLoop

// ============================================
// OPCIÓN 1: JUGAR
// ============================================
OpcionJugar:
        BL f05LimpiarPantalla
        
        // Resetear estado del juego
        LDR x0, =JuegoTerminado
        STR xzr, [x0]
        
        // Fase de preparación
        BL f01FasePreparacion
        
        // Limpiar pantalla antes del combate
        BL f05LimpiarPantalla
        
        // Bucle de enfrentamiento
        BL f02BucleEnfrentamiento
        
        // Mostrar resultado final
        BL f05MostrarResultadoFinal
        
        // Preguntar qué hacer después
        BL MostrarMenuFinJuego
        B MenuLoop

// ============================================
// OPCIÓN 2: TUTORIAL
// ============================================
OpcionTutorial:
        // Página 1: Introducción
        BL f05LimpiarPantalla
        
        LDR x1, =TutorialPagina1
        LDR x2, =LargoTutorialPagina1Val
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL EsperarEnter
        
        // Página 2: Símbolos
        BL f05LimpiarPantalla
        
        LDR x1, =TutorialPagina2
        LDR x2, =LargoTutorialPagina2Val
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL EsperarEnter
        
        // Página 3: Barcos
        BL f05LimpiarPantalla
        
        LDR x1, =TutorialPagina3
        LDR x2, =LargoTutorialPagina3Val
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL EsperarEnter
        
        // Página 4: Armamento
        BL f05LimpiarPantalla
        
        LDR x1, =TutorialPagina4
        LDR x2, =LargoTutorialPagina4Val
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL EsperarEnter
        
        // Volver al menú principal
        B MenuLoop

// ============================================
// OPCIÓN 3: CRÉDITOS
// ============================================
OpcionCreditos:
        BL f05LimpiarPantalla
        
        // Mostrar título
        LDR x1, =MensajeBienvenida
        LDR x2, =LargoMensajeBienvenidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Mostrar créditos
        LDR x1, =MensajeCreditos
        LDR x2, =LargoMensajeCreditosVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL EsperarEnter
        
        B MenuLoop

// ============================================
// OPCIÓN 4: SALIR
// ============================================
OpcionSalir:
        BL f05LimpiarPantalla
        
        LDR x1, =MensajeDespedida
        LDR x2, =LargoMensajeDespedidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Terminar programa
        MOV x8, #93             // Syscall exit
        MOV x0, #0              // Código de salida 0
        SVC #0

// ============================================
// FUNCIONES AUXILIARES
// ============================================

// Mostrar menú principal
MostrarMenuPrincipal:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x1, =MenuPrincipal
        LDR x2, =LargoMenuPrincipalVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        ldp x29, x30, [sp], 16
        RET

// Esperar ENTER
EsperarEnter:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x1, =BufferLectura
        MOV x2, #10
        BL f02LeerCadena
        
        ldp x29, x30, [sp], 16
        RET

// Menú de fin de juego
MostrarMenuFinJuego:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
MenuFinLoop:
        LDR x1, =MenuFinJuego
        LDR x2, =LargoMenuFinJuegoVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        BL f03LeerNumero
        
        CMP x0, #1
        BEQ FinJugar          // Jugar de nuevo
        CMP x0, #2
        BEQ FinMenu           // Volver al menú
        CMP x0, #3
        BEQ FinSalir          // Salir
        
        // Opción inválida
        LDR x1, =OpcionInvalida
        LDR x2, =LargoOpcionInvalidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B MenuFinLoop

FinJugar:
        // Volver a OpcionJugar
        ldp x29, x30, [sp], 16
        B OpcionJugar

FinMenu:
        // Volver al menú principal
        ldp x29, x30, [sp], 16
        RET

FinSalir:
        // Salir del juego
        ldp x29, x30, [sp], 16
        B OpcionSalir


// ============================================
// FIN DEL ARCHIVO
// ============================================
