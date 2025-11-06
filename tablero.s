// ******  Datos administrativos  *******************
// Nombre del archivo: tablero.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Buscaminas
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Módulo central del tablero de juego. Implementa:
// inicialización del tablero, colocación de minas,
// impresión visual, descubrimiento de celdas con
// cascada, colocación de banderas, conteo de minas
// cercanas, y verificación de victoria/derrota.
// ******  Versión  **********************************
// 01 | 2025-10-13 | Roymar Castillo - Versión final
// ***************************************************

// Declaraciones globales
.global f01InicializarTablero
.global f02ColocarMinasAleatorias
.global f03ImprimirTablero
.global f04DescubrirCelda
.global f05ColocarBandera
.global f06DescubrirCascada
.global f07ContarMinasCercanas
.global f08Victoria
.global f09Derrota
.global f10VerificarVictoria
.global f11RevelarTodasMinas
.global TableroPtr
.global BufferSimbolo
.global JuegoTerminado


// Dependencias externas
.extern FilasSel
.extern ColumnasSel
.extern MinasSel
.extern f01ImprimirCadena
.extern f02NumeroAleatorio
.extern f05LimpiarPantalla
.extern ESTADO_OCULTA
.extern ESTADO_DESCUBIERTA
.extern ESTADO_BANDERA
.extern MensajeVictoria
.extern LargoMensajeVictoriaVal
.extern MensajeDerrota
.extern LargoMensajeDerrotaVal
.extern SimboloVacio, SimboloMina, SimboloBandera, Espacio


.section .bss
TableroPtr:     .skip 8    // Puntero al tablero en heap
BufferSimbolo:  .skip 8    // Buffer temporal para símbolos
JuegoTerminado: .skip 8    // Flag: 0=en curso, 1=terminado
    


.section .text

// ******  Nombre  ***********************************
// f01InicializarTablero
// ******  Descripción  ******************************
// Crea el tablero de juego en memoria dinámica (heap).
// Calcula tamaño necesario (filas*columnas*2 bytes),
// reserva memoria con syscall brk, inicializa todas
// las celdas a estado oculto y sin mina, luego coloca
// minas aleatoriamente.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Cantidad de filas
// x1: Cantidad de columnas
// x2: Cantidad de minas
// ******  Errores  **********************************
// Error #07: Fallo al reservar memoria
// ***************************************************
f01InicializarTablero:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x10, =FilasSel
        LDR x10, [x10]           // x10 = Filas
        LDR x11, =ColumnasSel
        LDR x11, [x11]           // x11 = Columnas
        
        MUL x12, x10, x11        // x12 = Total celdas
        LSL x12, x12, #1         // x12 = Bytes necesarios (2 por celda)
        
        MOV x8, #214             // Syscall brk (obtener heap actual)
        MOV x0, #0
        SVC #0
        MOV x13, x0              // x13 = Dirección base heap
        ADD x0, x13, x12         // x0 = Nueva dirección heap
        MOV x8, #214             // Syscall brk (expandir heap)
        SVC #0
        
        CMP x0, x13              // Verificar si se expandió
        BLT f01error  
        
        LDR x14, =TableroPtr
        STR x13, [x14]           // Guardar puntero al tablero
        
        MOV x3, #0               // x3 = Índice fila
f01bucle_filas:
        CMP x3, x10
        B.GE f01inicializado
        MOV x4, #0               // x4 = Índice columna
f01bucle_columnas:
        CMP x4, x11
        B.GE f01siguiente_fila
        MUL x15, x3, x11         // Calcular offset
        ADD x15, x15, x4
        LSL x15, x15, #1         // Multiplicar por 2 (2 bytes/celda)
        LDR x16, =TableroPtr
        LDR x16, [x16]
        ADD x17, x16, x15        // x17 = Dirección de celda
        MOV w18, #0              // Byte 0: Sin mina
        STRB w18, [x17]
        MOV w18, #0              // Byte 1: Estado oculto        
        STRB w18, [x17, #1]
        ADD x4, x4, #1
        B f01bucle_columnas
f01siguiente_fila:
        ADD x3, x3, #1
        B f01bucle_filas
f01inicializado:
        
        BL f02ColocarMinasAleatorias
        ldp x29, x30, [sp], 16
        RET
f01error:

        MOV x0, #1               // Código de error
        MOV x8, #93              // Syscall exit
        SVC #0


// ****** Nombre ***********************************
// f02ColocarMinasAleatorias
 // ****** Descripción ******************************
// Coloca minas en posiciones aleatorias del tablero.
// Genera coordenadas aleatorias y verifica que la
// celda no tenga ya una mina antes de colocarla.
// Incluye protección contra bucles infinitos.
 // ****** Retorno **********************************
// Ninguno
 // ****** Entradas *********************************
// Ninguna (usa variables globales FilasSel,
// ColumnasSel, MinasSel)
 // ****** Errores **********************************
// Error #08 Demasiados intentos sin colocar minas
// ***************************************************
f02ColocarMinasAleatorias:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x10, =FilasSel
        LDR x10, [x10]           // x10 = Filas
        LDR x11, =ColumnasSel
        LDR x11, [x11]           // x11 = Columnas
        LDR x12, =MinasSel
        LDR x12, [x12]           // x12 = Minas a colocar
        LDR x13, =TableroPtr
        LDR x13, [x13]           // x13 = Puntero al tablero
        MOV x14, #0              // x14 = Contador de minas colocadas
        MOV x20, #0              // x20 = Contador de intentos
        MOV x21, #10000          // x21 = Máximo de intentos     
f02bucle_minas:
        CMP x14, x12
        B.GE f02fin
        CMP x20, x21
        B.GE f02fin      
        
        MOV x0, x10
        BL f02NumeroAleatorio
        UDIV x15, x0, x10
        MSUB x15, x15, x10, x0
        
        MOV x0, x11
        BL f02NumeroAleatorio
        UDIV x16, x0, x11
        MSUB x16, x16, x11, x0
        
        MUL x17, x15, x11
        ADD x17, x17, x16
        LSL x17, x17, #1
        ADD x18, x13, x17
        
        LDRB w19, [x18]
        CMP w19, #1
        ADD x20, x20, #1  
        BEQ f02bucle_minas 
        
        MOV w19, #1
        STRB w19, [x18]
        ADD x14, x14, #1
        ADD x20, x20, #1   
        B f02bucle_minas
f02fin:
        ldp x29, x30, [sp], 16
        RET


// ****** Nombre ***********************************
// f03ImprimirTablero
 // ****** Descripción ******************************
// Imprime el estado actual del tablero en pantalla.
// Muestra símbolos según el estado de cada celda
// # (oculta), ! (bandera), // (mina), _ (vacía),
// o números (1-8) indicando minas cercanas.
 // ****** Retorno **********************************
// Ninguno
 // ****** Entradas *********************************
// Ninguna (usa TableroPtr y variables globales)
 // ****** Errores **********************************
// Ninguno
// ***************************************************
f03ImprimirTablero:
        stp x29, x30, [sp, -64]!  
        mov x29, sp
        
        BL f05LimpiarPantalla
        
        LDR x10, =FilasSel
        LDR x20, [x10]           // x20 = Filas
        LDR x11, =ColumnasSel  
        LDR x21, [x11]           // x21 = Columnas
        
        
        LDR x12, =TableroPtr
        LDR x12, [x12]           // x12 = Puntero al tablero
        CMP x12, #0
        BEQ f03fin
        
        
        MOV x4, #0               // x4 = Índice fila
        
f03bucle_filas:
        CMP x4, x20
        B.GE f03fin
        
        
        MOV x6, #0               // x6 = Índice columna
        
f03bucle_columnas:
        CMP x6, x21
        B.GE f03fin_fila
        

        MUL x13, x4, x21
        ADD x13, x13, x6
        LSL x13, x13, #1
        ADD x14, x12, x13
        
        
        LDRB w16, [x14, #1]  
        
        MOV w22, #'#'       
        
        CMP w16, #2          
        BEQ f03bandera
        
        CMP w16, #1         
        BEQ f03descubierta
        B f03imprimir_caracter
        
f03bandera:
        MOV w22, #'!'
        B f03imprimir_caracter
        
f03descubierta:
        LDRB w15, [x14]      
        CMP w15, #1
        BEQ f03mina
        
        
        stp x4, x6, [sp, #16]
        stp x12, x20, [sp, #32]
        str x21, [sp, #48]
        
        MOV x0, x4    
        MOV x1, x6    
        BL f07ContarMinasCercanas
        
        
        ldp x4, x6, [sp, #16]
        ldp x12, x20, [sp, #32]
        ldr x21, [sp, #48]
        
        
        CMP x0, #0
        BEQ f03vacia
        
        
        ADD w22, w0, #'0'
        B f03imprimir_caracter
        
f03mina:
        MOV w22, #'@'
        B f03imprimir_caracter

f03vacia:
        MOV w22, #'_'
        
f03imprimir_caracter:
        
        stp x4, x6, [sp, #16]
        stp x12, x20, [sp, #32]
        str x21, [sp, #48]
        
        
        STRB w22, [sp, #56]
        MOV x8, #64          
        MOV x0, #1           
        ADD x1, sp, #56      
        MOV x2, #1           
        SVC #0
        
        
        MOV w23, #' '
        STRB w23, [sp, #56]
        MOV x8, #64
        MOV x0, #1
        ADD x1, sp, #56
        MOV x2, #1
        SVC #0
        

        ldp x4, x6, [sp, #16]
        ldp x12, x20, [sp, #32]
        ldr x21, [sp, #48]
        
        
        ADD x6, x6, #1
        B f03bucle_columnas
        
f03fin_fila:
        
        MOV w24, #10  
        STRB w24, [sp, #56]
        MOV x8, #64
        MOV x0, #1
        ADD x1, sp, #56
        MOV x2, #1
        SVC #0
        
       
        ADD x4, x4, #1
        B f03bucle_filas

f03fin:
        ldp x29, x30, [sp], 64
        RET


// ****** Nombre ***********************************
// f04DescubrirCelda
 // ****** Descripción ******************************
// Descubre una celda del tablero. Si la celda tiene
// una mina, activa derrota. Si no tiene minas cercanas,
// inicia descubrimiento en cascada. Verifica victoria
// después de descubrir.
 // ****** Retorno **********************************
// Ninguno
 // ****** Entradas *********************************
// x0 Fila de la celda (0-based)
// x1 Columna de la celda (0-based)
 // ****** Errores **********************************
// Ninguno
// ***************************************************
f04DescubrirCelda:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        
        LDR x12, =TableroPtr
        LDR x12, [x12]           // x12 = Puntero al tablero
        CMP x12, #0
        BEQ f04fin
        
        LDR x10, =FilasSel
        LDR x10, [x10]           // x10 = Filas
        LDR x11, =ColumnasSel
        LDR x11, [x11]           // x11 = Columnas
        
        
        CMP x0, #0
        BLT f04fin
        CMP x0, x10
        BGE f04fin
        CMP x1, #0
        BLT f04fin
        CMP x1, x11
        BGE f04fin
        
        
        MUL x13, x0, x11
        ADD x13, x13, x1
        LSL x13, x13, #1
        ADD x14, x12, x13
        
        
        LDRB w15, [x14, #1]
        LDR x16, =ESTADO_BANDERA
        LDR w16, [x16]
        CMP w15, w16
        BEQ f04fin 
        
        LDR x17, =ESTADO_DESCUBIERTA
        LDR w17, [x17]
        CMP w15, w17
        BEQ f04fin 
        
        MOV x20, x0  
        MOV x21, x1  
        
 
        BL f07ContarMinasCercanas
        MOV x22, x0  
        
        STRB w17, [x14, #1]
        
        LDRB w23, [x14]      
        CMP w23, #1
        BNE f04sin_mina
        BL f11RevelarTodasMinas
        BL f03ImprimirTablero
        BL f09Derrota
        B f04fin
f04sin_mina:
        
        CMP x22, #0
        BNE f04verificar_victoria
        
        
        MOV x0, x20  
        MOV x1, x21  
        BL f06DescubrirCascada
        
f04verificar_victoria:
        
        BL f10VerificarVictoria
        CMP x0, #1
        BNE f04fin
        
        BL f03ImprimirTablero
        BL f08Victoria
        
f04fin:
        ldp x29, x30, [sp], 16
        RET


// ****** Nombre ***********************************
// f05ColocarBandera
 // ****** Descripción ******************************
// Coloca o quita una bandera en una celda. Si la
// celda ya tiene bandera, la quita. Si está oculta,
// coloca la bandera. No afecta celdas descubiertas.
 // ****** Retorno **********************************
// Ninguno
 // ****** Entradas *********************************
// x0 Fila de la celda (0-based)
// x1 Columna de la celda (0-based)
 // ****** Errores **********************************
// Ninguno
// ***************************************************
f05ColocarBandera:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x10, =FilasSel
        LDR x10, [x10]           // x10 = Filas
        LDR x11, =ColumnasSel
        LDR x11, [x11]           // x11 = Columnas
        LDR x12, =TableroPtr
        LDR x12, [x12]           // x12 = Puntero al tablero
        MUL x13, x0, x11         // Calcular offset
        ADD x13, x13, x1
        LSL x13, x13, #1
        ADD x14, x12, x13        // x14 = Dirección de celda
        LDRB w15, [x14, #1]      // w15 = Estado actual
        LDR x16, =ESTADO_BANDERA
        LDR w16, [x16]
        CMP w15, w16
        BEQ f05quitar_bandera
        
        LDR x17, =ESTADO_OCULTA
        LDR w17, [x17]
        CMP w15, w17
        BEQ f05poner_bandera
        B f05fin
f05poner_bandera:
        STRB w16, [x14, #1]
        B f05fin
f05quitar_bandera:
        LDR x18, =ESTADO_OCULTA
        LDR w18, [x18]
        STRB w18, [x14, #1]
f05fin:
        ldp x29, x30, [sp], 16
        RET

// ****** Nombre ***********************************
// f06DescubrirCascada
 // ****** Descripción ******************************
// Descubre automáticamente celdas vacías adyacentes.
// Cuando una celda no tiene minas cercanas, revela
// las 8 celdas vecinas recursivamente. Implementa
// el efecto cascada característico del Buscaminas.
 // ****** Retorno **********************************
// Ninguno
 // ****** Entradas *********************************
// x0 Fila de la celda inicial (0-based)
// x1 Columna de la celda inicial (0-based)
 // ****** Errores **********************************
// Ninguno
// ***************************************************
f06DescubrirCascada:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        
        LDR x12, =TableroPtr
        LDR x12, [x12]           // x12 = Puntero al tablero
        CMP x12, #0
        BEQ f06fin
        
        
        LDR x10, =FilasSel
        LDR x10, [x10]      
        LDR x11, =ColumnasSel
        LDR x11, [x11]      
        
        
        MOV x20, x0  
        MOV x21, x1  
        
        
        CMP x20, #0
        BLT f06fin
        CMP x20, x10
        BGE f06fin
        CMP x21, #0
        BLT f06fin
        CMP x21, x11
        BGE f06fin
        
        
        SUB x0, x20, #1
        SUB x1, x21, #1
        BL f06revelar_celda
        
        SUB x0, x20, #1
        MOV x1, x21
        BL f06revelar_celda
        

        SUB x0, x20, #1
        ADD x1, x21, #1
        BL f06revelar_celda
        
  
        MOV x0, x20
        SUB x1, x21, #1
        BL f06revelar_celda
        
        MOV x0, x20
        ADD x1, x21, #1
        BL f06revelar_celda
        
        ADD x0, x20, #1
        SUB x1, x21, #1
        BL f06revelar_celda
        
        
        ADD x0, x20, #1
        MOV x1, x21
        BL f06revelar_celda
        
        ADD x0, x20, #1
        ADD x1, x21, #1
        BL f06revelar_celda
        
f06fin:
        ldp x29, x30, [sp], 16
        RET


f06revelar_celda:
        stp x29, x30, [sp, -96]!  
        mov x29, sp
        

        stp x0, x1, [sp, #16]      
        
        
        LDR x10, =FilasSel
        LDR x10, [x10]
        LDR x11, =ColumnasSel
        LDR x11, [x11]
        LDR x12, =TableroPtr
        LDR x12, [x12]
        
        
        stp x10, x11, [sp, #32]
        str x12, [sp, #48]
        
        
        ldp x0, x1, [sp, #16]
        
        
        CMP x0, #0
        BLT f06revelar_fin
        CMP x0, x10
        BGE f06revelar_fin
        CMP x1, #0
        BLT f06revelar_fin
        CMP x1, x11
        BGE f06revelar_fin
        
       
        MUL x2, x0, x11
        ADD x2, x2, x1
        LSL x2, x2, #1
        ADD x3, x12, x2
        
        
        LDRB w4, [x3, #1]
        
        
        CMP w4, #0              
        BNE f06revelar_fin
        
        
        LDRB w5, [x3]
        CMP w5, #1              
        BEQ f06revelar_fin  
        
        
        MOV w6, #1              
        STRB w6, [x3, #1]
        
        
        ldp x0, x1, [sp, #16]
        
        BL f07ContarMinasCercanas
        MOV x7, x0              
        
        ldp x0, x1, [sp, #16]
        
        
        CMP x7, #0
        BNE f06revelar_fin
        
        str x0, [sp, #56] 
        str x1, [sp, #64]  
        
        
        ldr x0, [sp, #56]
        ldr x1, [sp, #64]
        SUB x0, x0, #1
        SUB x1, x1, #1
        BL f06revelar_celda
        
        
        ldr x0, [sp, #56]
        ldr x1, [sp, #64]
        SUB x0, x0, #1
        BL f06revelar_celda
        
        
        ldr x0, [sp, #56]
        ldr x1, [sp, #64]
        SUB x0, x0, #1
        ADD x1, x1, #1
        BL f06revelar_celda
        
       
        ldr x0, [sp, #56]
        ldr x1, [sp, #64]
        SUB x1, x1, #1
        BL f06revelar_celda
        
        
        ldr x0, [sp, #56]
        ldr x1, [sp, #64]
        ADD x1, x1, #1
        BL f06revelar_celda
        
        ldr x0, [sp, #56]
        ldr x1, [sp, #64]
        ADD x0, x0, #1
        SUB x1, x1, #1
        BL f06revelar_celda
        
        ldr x0, [sp, #56]
        ldr x1, [sp, #64]
        ADD x0, x0, #1
        BL f06revelar_celda
        
        ldr x0, [sp, #56]
        ldr x1, [sp, #64]
        ADD x0, x0, #1
        ADD x1, x1, #1
        BL f06revelar_celda
        
f06revelar_fin:
        ldp x29, x30, [sp], 96
        RET


// ****** Nombre ***********************************
// f07ContarMinasCercanas
 // ****** Descripción ******************************
// Cuenta el número de minas en las 8 celdas
// adyacentes a una posición dada. Valida que
// cada vecino esté dentro de los límites antes
// de verificar si contiene mina.
 // ****** Retorno **********************************
// x0 Cantidad de minas cercanas (0-8)
 // ****** Entradas *********************************
// x0 Fila de la celda a analizar
// x1 Columna de la celda a analizar
 // ****** Errores **********************************
// Ninguno (retorna 0 si coordenadas inválidas)
// ***************************************************
f07ContarMinasCercanas:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x12, =TableroPtr              // x12 = Puntero al tablero
        LDR x12, [x12]
        CMP x12, #0
        BEQ f07error
        
        MOV x20, x0                       // x20 = Fila a analizar
        MOV x21, x1                       // x21 = Columna a analizar
        
        LDR x10, =FilasSel                // x10 = Total filas
        LDR x10, [x10]
        LDR x11, =ColumnasSel             // x11 = Total columnas
        LDR x11, [x11]
        
        // Validar que coordenadas estén en rango
        CMP x20, #0
        BLT f07error
        CMP x20, x10
        BGE f07error
        CMP x21, #0
        BLT f07error
        CMP x21, x11
        BGE f07error
        
        MOV x22, #0                       // x22 = Contador de minas
        
        // Revisar 8 vecinos y acumular minas
        // Arriba-izquierda
        SUB x0, x20, #1
        SUB x1, x21, #1
        BL f07checksingle
        ADD x22, x22, x0
        
        // Arriba
        SUB x0, x20, #1
        MOV x1, x21
        BL f07checksingle
        ADD x22, x22, x0
        
        // Arriba-derecha
        SUB x0, x20, #1
        ADD x1, x21, #1
        BL f07checksingle
        ADD x22, x22, x0
        
        // Izquierda
        MOV x0, x20
        SUB x1, x21, #1
        BL f07checksingle
        ADD x22, x22, x0
        
        // Derecha
        MOV x0, x20
        ADD x1, x21, #1
        BL f07checksingle
        ADD x22, x22, x0
        
        // Abajo-izquierda
        ADD x0, x20, #1
        SUB x1, x21, #1
        BL f07checksingle
        ADD x22, x22, x0
        
        // Abajo
        ADD x0, x20, #1
        MOV x1, x21
        BL f07checksingle
        ADD x22, x22, x0
        
        // Abajo-derecha
        ADD x0, x20, #1
        ADD x1, x21, #1
        BL f07checksingle
        ADD x22, x22, x0
        
        MOV x0, x22                       // x0 = Total minas contadas
        ldp x29, x30, [sp], 16
        RET

f07error:
        MOV x0, #0                        // x0 = 0 (error)
        ldp x29, x30, [sp], 16
        RET


f07checksingle:
        // Verificar límites del vecino
        CMP x0, #0
        BLT f07sin_mina
        CMP x0, x10
        BGE f07sin_mina
        CMP x1, #0
        BLT f07sin_mina
        CMP x1, x11
        BGE f07sin_mina
        
        // Calcular offset y leer byte de mina
        MUL x2, x0, x11
        ADD x2, x2, x1
        LSL x2, x2, #1
        ADD x3, x12, x2
        LDRB w4, [x3]                     // w4 = Byte de mina (0 o 1)
        
        CMP w4, #1
        BEQ f07tiene_mina
        
f07sin_mina:
        MOV x0, #0                        // x0 = 0 (no hay mina)
        RET
        
f07tiene_mina:
        MOV x0, #1                        // x0 = 1 (hay mina)
        RET


// ****** Nombre ***********************************
// f08Victoria
 // ****** Descripción ******************************
// Establece la bandera JuegoTerminado e imprime
// el mensaje de victoria al usuario.
 // ****** Retorno **********************************
// Ninguno
 // ****** Entradas *********************************
// Ninguna
 // ****** Errores **********************************
// Ninguno
// ***************************************************
f08Victoria:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x0, =JuegoTerminado           // x0 = Dirección de JuegoTerminado
        MOV x1, #1                        // x1 = 1 (juego terminado)
        STR x1, [x0]                      // Establecer bandera
        LDR x1, =MensajeVictoria          // x1 = Mensaje de victoria
        LDR x2, =LargoMensajeVictoriaVal  // x2 = Largo del mensaje
        LDR x2, [x2]
        BL f01ImprimirCadena              // Imprimir mensaje
        ldp x29, x30, [sp], 16
        RET


// ****** Nombre ***********************************
// f09Derrota
 // ****** Descripción ******************************
// Establece la bandera JuegoTerminado e imprime
// el mensaje de derrota al usuario.
 // ****** Retorno **********************************
// Ninguno
 // ****** Entradas *********************************
// Ninguna
 // ****** Errores **********************************
// Ninguno
// ***************************************************
f09Derrota:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x0, =JuegoTerminado           // x0 = Dirección de JuegoTerminado
        MOV x1, #1                        // x1 = 1 (juego terminado)
        STR x1, [x0]                      // Establecer bandera
        LDR x1, =MensajeDerrota           // x1 = Mensaje de derrota
        LDR x2, =LargoMensajeDerrotaVal   // x2 = Largo del mensaje
        LDR x2, [x2]
        BL f01ImprimirCadena              // Imprimir mensaje
        ldp x29, x30, [sp], 16
        RET


// ****** Nombre ***********************************
// f10VerificarVictoria
 // ****** Descripción ******************************
// Verifica si el jugador ha ganado revisando que
// todas las celdas sin mina estén descubiertas.
// Retorna 1 si se cumple la condición de victoria,
// 0 en caso contrario.
 // ****** Retorno **********************************
// x0 1 si hay victoria, 0 si no
 // ****** Entradas *********************************
// Ninguna
 // ****** Errores **********************************
// Ninguno (retorna 0 si error)
// ***************************************************
f10VerificarVictoria:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        LDR x12, =TableroPtr              // x12 = Puntero al tablero
        LDR x12, [x12]
        CMP x12, #0
        BEQ f10error
        
        LDR x10, =FilasSel                // x10 = Total filas
        LDR x10, [x10]
        LDR x11, =ColumnasSel             // x11 = Total columnas
        LDR x11, [x11]
        
        MOV x4, #0                        // x4 = Índice fila
f10bucle_filas:
        CMP x4, x10
        B.GE f10victoria
        MOV x6, #0                        // x6 = Índice columna
f10bucle_columnas:
        CMP x6, x11
        B.GE f10siguiente_fila
        
        // Calcular offset de celda actual
        MUL x13, x4, x11
        ADD x13, x13, x6
        LSL x13, x13, #1
        ADD x14, x12, x13
        
        LDRB w15, [x14]                   // w15 = Byte de mina (0 o 1)
        LDRB w16, [x14, #1]               // w16 = Byte de estado
        
        // Si tiene mina, ignorar esta celda
        CMP w15, #1
        BEQ f10siguiente_columna  
        
        // Si no tiene mina, debe estar descubierta (estado=1)
        CMP w16, #1
        BNE f10sin_victoria               // Si no está descubierta, no hay victoria
        
f10siguiente_columna:
        ADD x6, x6, #1
        B f10bucle_columnas
        
f10siguiente_fila:
        ADD x4, x4, #1
        B f10bucle_filas
        
f10victoria:
        MOV x0, #1                        // x0 = 1 (hay victoria)
        ldp x29, x30, [sp], 16
        RET
        
f10sin_victoria:
        MOV x0, #0                        // x0 = 0 (no hay victoria)
        ldp x29, x30, [sp], 16
        RET
        
f10error:
        MOV x0, #0                        // x0 = 0 (error)
        ldp x29, x30, [sp], 16
        RET


// ****** Nombre ***********************************
// f11RevelarTodasMinas
 // ****** Descripción ******************************
// Revela todas las minas del tablero estableciendo
// su estado como descubierta. Se usa al final del
// juego para mostrar la ubicación de todas las minas.
 // ****** Retorno **********************************
// Ninguno
 // ****** Entradas *********************************
// Ninguna
 // ****** Errores **********************************
// Ninguno
// ***************************************************
f11RevelarTodasMinas:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        LDR x12, =TableroPtr              // x12 = Puntero al tablero
        LDR x12, [x12]
        CMP x12, #0
        BEQ f11fin
        LDR x10, =FilasSel                // x10 = Total filas
        LDR x10, [x10]
        LDR x11, =ColumnasSel             // x11 = Total columnas
        LDR x11, [x11]
        MOV x4, #0                        // x4 = Índice fila
f11bucle_filas:
        CMP x4, x10
        B.GE f11fin
        MOV x6, #0                        // x6 = Índice columna
f11bucle_columnas:
        CMP x6, x11
        B.GE f11siguiente_fila
        // Calcular offset de celda actual
        MUL x13, x4, x11
        ADD x13, x13, x6
        LSL x13, x13, #1
        ADD x14, x12, x13
        LDRB w15, [x14]                   // w15 = Byte de mina (0 o 1)
        // Si hay mina, revelarla
        CMP w15, #1
        BNE f11siguiente_columna
        LDR x17, =ESTADO_DESCUBIERTA      // x17 = Estado descubierta (1)
        LDR w17, [x17]
        STRB w17, [x14, #1]               // Establecer estado = descubierta
f11siguiente_columna:
        ADD x6, x6, #1
        B f11bucle_columnas
f11siguiente_fila:
        ADD x4, x4, #1
        B f11bucle_filas
f11fin:
        ldp x29, x30, [sp], 16
        RET
