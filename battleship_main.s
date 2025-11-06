// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_main.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Punto de entrada principal del juego Battleship.
// Inicializa el sistema, muestra el menú principal,
// ejecuta las fases del juego y termina limpiamente.
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

// Declaración global del punto de entrada
.global _start

// Dependencias externas
.extern f01ImprimirCadena
.extern f05LimpiarPantalla
.extern f06InicializarSemilla
.extern f01FasePreparacion
.extern f02BucleEnfrentamiento
.extern MensajeBienvenida, LargoMensajeBienvenidaVal
.extern MensajeCreditos, LargoMensajeCreditosVal
.extern MensajeInstrucciones, LargoMensajeInstruccionesVal
.extern MensajeDescripcionBarcos, LargoMensajeDescripcionBarcosVal
.extern MensajeDescripcionMisiles, LargoMensajeDescripcionMisilesVal
.extern MensajePresionarEnter, LargoMensajePresionarEnterVal
.extern MensajeDespedida, LargoMensajeDespedidaVal
.extern SaltoLinea

.section .text

// ******  Nombre  ***********************************
// _start
// ******  Descripción  ******************************
// Punto de entrada principal del programa. Secuencia:
// 1. Inicializa el generador aleatorio
// 2. Muestra pantalla de bienvenida
// 3. Muestra instrucciones
// 4. Ejecuta fase de preparación (colocación de barcos)
// 5. Ejecuta bucle de enfrentamiento
// 6. Muestra mensaje de despedida
// 7. Termina el programa con exit syscall
// ******  Retorno  **********************************
// No retorna (termina el proceso)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Sale con código 0 en ejecución normal
// ***************************************************
_start:
        // Inicializar semilla aleatoria
        BL f06InicializarSemilla
        
        // ============================================
        // PANTALLA 1: BIENVENIDA Y CRÉDITOS
        // ============================================
        BL f05LimpiarPantalla
        
        // Mostrar mensaje de bienvenida
        LDR x1, =MensajeBienvenida
        LDR x2, =LargoMensajeBienvenidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Mostrar créditos
        LDR x1, =MensajeCreditos
        LDR x2, =LargoMensajeCreditosVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Esperar Enter
        LDR x1, =MensajePresionarEnter
        LDR x2, =LargoMensajePresionarEnterVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        MOV x8, #63             // Syscall read
        MOV x0, #0              // stdin
        SUB sp, sp, #16
        MOV x1, sp
        MOV x2, #2
        SVC #0
        ADD sp, sp, #16
        
        // ============================================
        // PANTALLA 2: INSTRUCCIONES
        // ============================================
        BL f05LimpiarPantalla
        
        // Mostrar instrucciones
        LDR x1, =MensajeInstrucciones
        LDR x2, =LargoMensajeInstruccionesVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Esperar Enter
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
        
        // ============================================
        // PANTALLA 3: DESCRIPCIÓN DE BARCOS
        // ============================================
        BL f05LimpiarPantalla
        
        // Mostrar descripción de barcos
        LDR x1, =MensajeDescripcionBarcos
        LDR x2, =LargoMensajeDescripcionBarcosVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Esperar Enter
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
        
        // ============================================
        // PANTALLA 4: DESCRIPCIÓN DE MISILES
        // ============================================
        BL f05LimpiarPantalla
        
        // Mostrar descripción de misiles
        LDR x1, =MensajeDescripcionMisiles
        LDR x2, =LargoMensajeDescripcionMisilesVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Esperar Enter
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
        
        // ============================================
        // INICIO DEL JUEGO
        // ============================================
        
        // Fase 1: Preparación (colocación de barcos)
        BL f01FasePreparacion
        
        // Fase 2: Enfrentamiento (bucle principal)
        BL f02BucleEnfrentamiento
        
        // ============================================
        // PANTALLA FINAL: DESPEDIDA
        // ============================================
        BL f05LimpiarPantalla
        
        LDR x1, =MensajeDespedida
        LDR x2, =LargoMensajeDespedidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        
        // Pequeña pausa antes de salir
        LDR x1, =SaltoLinea
        MOV x2, #1
        BL f01ImprimirCadena
        
        // Terminar programa (exit syscall)
        MOV x8, #93             // Syscall exit
        MOV x0, #0              // Código de salida 0
        SVC #0


// ============================================
// FIN DEL ARCHIVO
// ============================================
