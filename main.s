// ******  Datos administrativos  *******************
// Nombre del archivo: main.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Buscaminas
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Punto de entrada del programa. Gestiona el menú
// principal, configuración de dificultades (Principiante,
// Intermedio, Experto, Personalizada) y el flujo
// principal de ejecución del juego.
// ******  Versión  **********************************
// 01 | 2025-10-13 | Roymar Castillo - Versión final
// ***************************************************


// Sección de datos no inicializados (.bss)
.section .bss
        
// Variables temporales de configuración
TmpFilas:       .skip 8    // Filas temporales para modo personalizado
TmpColumnas:    .skip 8    // Columnas temporales para modo personalizado
TmpMinas:       .skip 8    // Minas temporales para modo personalizado

// Variables globales de configuración del juego
.global FilasSel
.global ColumnasSel
.global MinasSel
        
FilasSel:       .skip 8    // Cantidad de filas seleccionadas
ColumnasSel:    .skip 8    // Cantidad de columnas seleccionadas
MinasSel:       .skip 8    // Cantidad de minas seleccionadas


// Sección de código (.text)
.section .text
.global _start


// Dependencias externas - Funciones de utilidades
.extern f01ImprimirCadena
.extern f03LeerNumero
.extern f04ValidarRango
.extern f05LimpiarPantalla


// Dependencias externas - Funciones de lógica

.extern f01ConfigurarYJugar


// Dependencias externas - Variables
.extern Semilla


// Dependencias externas - Mensajes y constantes
.extern Bienvenida, LargoBienvenidaVal
.extern Menu, LargoMenuVal
.extern MensajeSalir, LargoMensajeSalirVal
.extern MensajeErrorSeleccion, LargoMensajeErrorSeleccionVal
.extern MensajeFilas, LargoMensajeFilasVal
.extern MensajeColumnas, LargoMensajeColumnasVal
.extern MensajeMinas, LargoMensajeMinasVal
.extern MensajeErrorCantidadFilas, LargoMensajeErrorCantidadFilasVal
.extern MensajeErrorCantidadColumnas, LargoMensajeErrorCantidadColumnasVal
.extern MensajeErrorCantidadMinas, LargoMensajeErrorCantidadMinasVal


// ******  Nombre  ***********************************
// _start
// ******  Descripción  ******************************
// Punto de entrada del programa. Inicializa la
// semilla aleatoria usando syscall getrandom,
// limpia variables globales e inicia el flujo
// del programa.
// ******  Retorno  **********************************
// Termina con exit syscall (93)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
_start:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        BL f05LimpiarPantalla
        
        MOV x8, #172             // Syscall getrandom
        SVC #0
        LDR x3, =Semilla
        STR x0, [x3]             // Inicializar semilla aleatoria
        LDR x1, =TmpFilas
        MOV x0, #0
        STR x0, [x1]             // Limpiar TmpFilas
        LDR x1, =TmpColumnas
        MOV x0, #0
        STR x0, [x1]             // Limpiar TmpColumnas
        LDR x1, =TmpMinas
        MOV x0, #0
        STR x0, [x1]             // Limpiar TmpMinas
        LDR x1, =FilasSel
        MOV x0, #0
        STR x0, [x1]             // Limpiar FilasSel
        LDR x1, =ColumnasSel
        MOV x0, #0
        STR x0, [x1]             // Limpiar ColumnasSel
        LDR x1, =MinasSel
        MOV x0, #0
        STR x0, [x1]             // Limpiar MinasSel
        BL f01IniciarPrograma
        BL f02MenuPrincipal
        MOV x0, #0
        MOV x8, #93              // Syscall exit
        SVC #0

// ******  Nombre  ***********************************
// f01IniciarPrograma
// ******  Descripción  ******************************
// Muestra el mensaje de bienvenida al usuario.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01IniciarPrograma:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x1, =Bienvenida
        LDR x2, =LargoBienvenidaVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        ldp x29, x30, [sp], 16
        RET

// ******  Nombre  ***********************************
// f02MenuPrincipal
// ******  Descripción  ******************************
// Muestra el menú principal y gestiona la selección
// del usuario. Valida la opción y redirige a la
// función correspondiente según la dificultad elegida.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Error #06: Opción inválida en menú principal
// ***************************************************
f02MenuPrincipal:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x1, =Menu
        LDR x2, =LargoMenuVal
        LDR x2, [x2]
        BL f01ImprimirCadena

f02leer_opcion:
        BL f03LeerNumero
        MOV x9, x0               // x9 = Opción seleccionada

        MOV x0, x9
        MOV x1, #1               // x1 = Mínimo (1)
        MOV x2, #5               // x2 = Máximo (5)
        BL f04ValidarRango
        CMP x0, #0
        BEQ f02opcion_invalida

        CMP x9, #5
        BEQ f03SalirPrograma

        CMP x9, #1
        BEQ f04Principiante
        CMP x9, #2
        BEQ f05Intermedio
        CMP x9, #3
        BEQ f06Experto
        CMP x9, #4
        BEQ f07Personalizada

        B f02MenuPrincipal

f02opcion_invalida:
        LDR x1, =MensajeErrorSeleccion
        LDR x2, =LargoMensajeErrorSeleccionVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f02leer_opcion

// ******  Nombre  ***********************************
// f03SalirPrograma
// ******  Descripción  ******************************
// Muestra mensaje de despedida y termina el programa
// con exit code 0.
// ******  Retorno  **********************************
// Termina programa con exit(0)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f03SalirPrograma:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x1, =MensajeSalir
        LDR x2, =LargoMensajeSalirVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        MOV x0, #0
        MOV x8, #93              // Syscall exit
        ldp x29, x30, [sp], 16
        SVC #0

// ******  Nombre  ***********************************
// f04Principiante
// ******  Descripción  ******************************
// Configura el juego en modo Principiante:
// tablero 8x8 con 10 minas. Guarda configuración
// e inicia partida.
// ******  Retorno  **********************************
// Ninguno (retorna al menú después de jugar)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04Principiante:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        MOV x0, #8               // x0 = Filas
        MOV x1, #8               // x1 = Columnas
        MOV x2, #10              // x2 = Minas
        BL f08GuardarConfig
        
        ldp x29, x30, [sp], 16
        B f02MenuPrincipal

// ******  Nombre  ***********************************
// f05Intermedio
// ******  Descripción  ******************************
// Configura el juego en modo Intermedio:
// tablero 16x16 con 40 minas. Guarda configuración
// e inicia partida.
// ******  Retorno  **********************************
// Ninguno (retorna al menú después de jugar)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05Intermedio:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        MOV x0, #16              // x0 = Filas
        MOV x1, #16              // x1 = Columnas
        MOV x2, #40              // x2 = Minas
        BL f08GuardarConfig
        
        ldp x29, x30, [sp], 16
        B f02MenuPrincipal

// ******  Nombre  ***********************************
// f06Experto
// ******  Descripción  ******************************
// Configura el juego en modo Experto:
// tablero 30x16 con 99 minas. Guarda configuración
// e inicia partida.
// ******  Retorno  **********************************
// Ninguno (retorna al menú después de jugar)
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f06Experto:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        MOV x0, #30              // x0 = Filas
        MOV x1, #16              // x1 = Columnas
        MOV x2, #99              // x2 = Minas
        BL f08GuardarConfig
        
        ldp x29, x30, [sp], 16
        B f02MenuPrincipal

// ******  Nombre  ***********************************
// f07Personalizada
// ******  Descripción  ******************************
// Permite al usuario configurar dimensiones del
// tablero y cantidad de minas personalizadas.
// Valida rangos (filas 8-30, columnas 8-24) y
// cantidad de minas válida.
// ******  Retorno  **********************************
// Ninguno (retorna al menú después de jugar)
// ******  Entradas  *********************************
// Ninguna (lee desde stdin)
// ******  Errores  **********************************
// Error #01: Filas fuera de rango
// Error #02: Columnas fuera de rango
// Error #03: Demasiadas minas
// ***************************************************
f07Personalizada:
        stp x29, x30, [sp, -16]!
        mov x29, sp

f07leer_filas:
        LDR x1, =MensajeFilas
        LDR x2, =LargoMensajeFilasVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL f03LeerNumero
        MOV x10, x0              // x10 = Filas ingresadas
        MOV x0, x10
        MOV x1, #8               // x1 = Mínimo filas
        MOV x2, #30              // x2 = Máximo filas
        BL f04ValidarRango
        CMP x0, #0
        BEQ f07error_filas
        LDR x13, =TmpFilas
        STR x10, [x13]           // Guardar filas temporales
        B f07leer_columnas

f07error_filas:
        LDR x1, =MensajeErrorCantidadFilas
        LDR x2, =LargoMensajeErrorCantidadFilasVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f07leer_filas

f07leer_columnas:
        LDR x1, =MensajeColumnas
        LDR x2, =LargoMensajeColumnasVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL f03LeerNumero
        MOV x11, x0              // x11 = Columnas ingresadas
        MOV x0, x11
        MOV x1, #8               // x1 = Mínimo columnas
        MOV x2, #24              // x2 = Máximo columnas
        BL f04ValidarRango
        CMP x0, #0
        BEQ f07error_columnas
        LDR x13, =TmpColumnas
        STR x11, [x13]           // Guardar columnas temporales
        B f07leer_minas

f07error_columnas:
        LDR x1, =MensajeErrorCantidadColumnas
        LDR x2, =LargoMensajeErrorCantidadColumnasVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f07leer_columnas

f07leer_minas:

        LDR x1, =MensajeMinas
        LDR x2, =LargoMensajeMinasVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        BL f03LeerNumero
        MOV x12, x0              // x12 = Minas ingresadas
        MOV x0, x12
        MOV x1, #1               // x1 = Mínimo minas
        MUL x2, x10, x11         // x2 = Filas * Columnas
        SUB x2, x2, #1           // x2 = Máximo minas (celdas - 1)
        BL f04ValidarRango
        CMP x0, #0
        BEQ f07error_minas
        B f07guardar_minas

f07guardar_minas:
        LDR x13, =TmpMinas
        STR x12, [x13]           // Guardar minas temporales
        B f07configuracion_completa

f07error_minas:
        LDR x1, =MensajeErrorCantidadMinas
        LDR x2, =LargoMensajeErrorCantidadMinasVal
        LDR x2, [x2]
        BL f01ImprimirCadena
        B f07leer_minas

f07configuracion_completa:
        LDR x13, =TmpFilas
        LDR x0, [x13]            // x0 = Filas
        LDR x14, =TmpColumnas
        LDR x1, [x14]            // x1 = Columnas
        LDR x15, =TmpMinas
        LDR x2, [x15]            // x2 = Minas
        BL f08GuardarConfig

        ldp x29, x30, [sp], 16
        B f02MenuPrincipal

// ******  Nombre  ***********************************
// f08GuardarConfig
// ******  Descripción  ******************************
// Guarda la configuración del tablero en variables
// globales (FilasSel, ColumnasSel, MinasSel) e
// inicia una nueva partida con esos parámetros.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Cantidad de filas
// x1: Cantidad de columnas
// x2: Cantidad de minas
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f08GuardarConfig:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x13, =FilasSel
        STR x0, [x13]            // Guardar filas seleccionadas
        LDR x14, =ColumnasSel
        STR x1, [x14]            // Guardar columnas seleccionadas
        LDR x15, =MinasSel
        STR x2, [x15]            // Guardar minas seleccionadas

        BL f01ConfigurarYJugar

        ldp x29, x30, [sp], 16
        RET
