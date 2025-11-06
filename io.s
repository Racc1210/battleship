// ******  Datos administrativos  *******************
// Nombre del archivo: io.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Buscaminas 
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Módulo de entrada/salida. Proporciona funciones
// para imprimir cadenas en pantalla y leer entrada
// del usuario mediante syscalls de Linux ARM64.
// ******  Versión  **********************************
// 01 | 2025-10-13 | Roymar Castillo - Versión final
// ***************************************************

.section .text

.global f01ImprimirCadena
.global f02LeerCadena

// ******  Nombre  ***********************************
// f01ImprimirCadena
// ******  Descripción  ******************************
// Imprime una cadena de texto en stdout usando
// la syscall write (64) de Linux ARM64.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x1: Dirección de la cadena a imprimir
// x2: Longitud de la cadena en bytes
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01ImprimirCadena:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        mov x8, #64              // Syscall write
        mov x0, #1               // File descriptor stdout
        svc #0
        ldp x29, x30, [sp], 16
        ret


// ******  Nombre  ***********************************
// f02LeerCadena
// ******  Descripción  ******************************
// Lee una cadena de texto desde stdin usando
// la syscall read (63) de Linux ARM64.
// ******  Retorno  **********************************
// x0: Número de bytes leídos
// ******  Entradas  *********************************
// x1: Buffer donde almacenar la entrada
// x2: Tamaño máximo a leer
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f02LeerCadena:
        stp x29, x30, [sp, -16]! 
        mov x29, sp
        MOV x8, #63              // Syscall read
        MOV x0, #0               // File descriptor stdin
        SVC #0
        ldp x29, x30, [sp], 16
        RET
