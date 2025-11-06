// ******  Datos administrativos  *******************
// Nombre del archivo: utilidades.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Funciones auxiliares: conversión ASCII a número,
// generador de números aleatorios, lectura de entrada
// numérica del usuario, validación de rangos, y
// conversión de coordenadas (Letra↔Número) para
// el sistema de coordenadas del juego (A1-J14).
// ******  Versión  **********************************
// 01 | 2025-10-13 | Roymar Castillo - Versión inicial Buscaminas
// 02 | 2025-11-05 | Roymar Castillo - Extensión para Battleship
// ***************************************************

// Declaraciones globales - Funciones originales
.global f01AsciiANumero
.global f02NumeroAleatorio
.global f03LeerNumero
.global f04ValidarRango
.global f05LimpiarPantalla
.global Semilla

// Declaraciones globales - Funciones nuevas para Battleship
.global f06ConvertirLetraAFila
.global f07ConvertirFilaALetra
.global f08ConvertirTextoAColumna
.global f09ConvertirColumnaATexto
.global f10ParsearCoordenada
.global f11ImprimirNumero
.global f12LeerCoordenada
.global f13InicializarSemilla


// Dependencias externas
.extern f01ImprimirCadena
.extern f02LeerCadena


// Sección de datos inicializados
.section .data
Semilla: .quad 123456789   // Semilla para generador aleatorio


// Sección de datos no inicializados
.section .bss
BufferLectura: .skip 8     // Buffer temporal para lectura de entrada
BufferCoordenada: .skip 8  // Buffer para leer coordenadas (ej: "A1", "J14")
BufferNumero: .skip 8      // Buffer para convertir números a texto


.section .text

// ******  Nombre  ***********************************
// f01AsciiANumero
// ******  Descripción  ******************************
// Convierte una cadena ASCII a un número entero.
// Procesa dígitos hasta encontrar fin de cadena
// o salto de línea.
// ******  Retorno  **********************************
// x0: Número entero resultante
// ******  Entradas  *********************************
// x1: Dirección de la cadena ASCII
// x2: Longitud máxima a procesar
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f01AsciiANumero:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        MOV x3, x2              // x3 = Longitud máxima
        MOV x0, #0              // x0 = Resultado acumulado
        MOV x4, #0              // x4 = Índice actual

f01bucle_conversion:
        CMP x4, x3
        B.GE f01fin
        LDRB w5, [x1, x4]       // w5 = Caracter actual
        CMP w5, #10             // Verificar salto de línea
        BEQ f01fin
        SUB w5, w5, #'0'        // Convertir ASCII a dígito
        MOV x6, #10
        MUL x0, x0, x6          // Multiplicar resultado por 10
        ADD x0, x0, x5          // Sumar nuevo dígito
        ADD x4, x4, #1
        B f01bucle_conversion

f01fin:
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f02NumeroAleatorio
// ******  Descripción  ******************************
// Genera un número pseudo-aleatorio en el rango
// [0, max) usando un generador congruencial lineal.
// Actualiza la semilla global automáticamente.
// ******  Retorno  **********************************
// x0: Número aleatorio en rango [0, max)
// ******  Entradas  *********************************
// x0: Valor máximo (no inclusivo)
// ******  Errores  **********************************
// Si max <= 0, retorna 0
// ***************************************************
f02NumeroAleatorio:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        MOV x1, x0              // x1 = Valor máximo
        CMP x1, #0              // Validar rango
        BLE f02rango_invalido
        
        LDR x2, =Semilla
        LDR x3, [x2]            // x3 = Semilla actual
        LDR x4, =6364136223846793005  // Constante multiplicadora
        MUL x3, x3, x4
        EOR x3, x3, x4
        ADD x3, x3, #1
        STR x3, [x2]            // Guardar nueva semilla
        

        LSR x0, x3, #16         // Descartar bits bajos
        UDIV x5, x0, x1         // División para obtener residuo
        MSUB x0, x5, x1, x0     // x0 = x0 - (x5 * x1), módulo
        
        ldp x29, x30, [sp], 16
        RET

f02rango_invalido:
        MOV x0, #0              // Retornar 0 si rango inválido
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f03LeerNumero
// ******  Descripción  ******************************
// Lee un número desde la entrada estándar.
// Utiliza buffer temporal para almacenar entrada
// y luego la convierte a entero.
// ******  Retorno  **********************************
// x0: Número entero leído
// ******  Entradas  *********************************
// Ninguna (lee desde stdin)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f03LeerNumero:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        

        LDR x1, =BufferLectura  // x1 = Dirección del buffer
        MOV x2, #4              // x2 = Tamaño máximo
        BL f02LeerCadena
        
        LDR x1, =BufferLectura  // x1 = Dirección del buffer
        MOV x2, #4              // x2 = Longitud a convertir
        BL f01AsciiANumero
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f04ValidarRango
// ******  Descripción  ******************************
// Valida si un valor se encuentra dentro de un
// rango inclusivo [min, max].
// ******  Retorno  **********************************
// x0: 1 si está en rango, 0 si está fuera
// ******  Entradas  *********************************
// x0: Valor a validar
// x1: Valor mínimo (inclusivo)
// x2: Valor máximo (inclusivo)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f04ValidarRango:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
       
        CMP x0, x1              // Comparar con mínimo
        BLT f04fuera_de_rango
        
        
        CMP x0, x2              // Comparar con máximo
        BGT f04fuera_de_rango
        
        
        MOV x0, #1              // Retornar 1 (en rango)
        ldp x29, x30, [sp], 16
        RET

f04fuera_de_rango:
        MOV x0, #0              // Retornar 0 (fuera de rango)
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f05LimpiarPantalla
// ******  Descripción  ******************************
// Limpia la pantalla usando secuencias de escape
// ANSI. Envía ESC[2J (limpiar) y ESC[H (cursor
// a inicio).
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f05LimpiarPantalla:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        MOV w0, #27             // ESC
        STRB w0, [sp, #16]
        MOV w0, #'['
        STRB w0, [sp, #17]
        MOV w0, #'2'
        STRB w0, [sp, #18]
        MOV w0, #'J'
        STRB w0, [sp, #19]
        MOV w0, #27             // ESC
        STRB w0, [sp, #20]
        MOV w0, #'['
        STRB w0, [sp, #21]
        MOV w0, #'H'
        STRB w0, [sp, #22]
        
        MOV x8, #64             // Syscall write
        MOV x0, #1              // File descriptor stdout
        ADD x1, sp, #16         // x1 = Dirección secuencia ANSI
        MOV x2, #7              // x2 = Longitud secuencia
        SVC #0
        
        ldp x29, x30, [sp], 32
        RET


// ============================================
// NUEVAS FUNCIONES PARA BATTLESHIP
// ============================================

// ******  Nombre  ***********************************
// f06ConvertirLetraAFila
// ******  Descripción  ******************************
// Convierte una letra (A-J) a un índice de fila (0-9).
// Acepta tanto mayúsculas como minúsculas.
// ******  Retorno  **********************************
// x0: Índice de fila (0-9), o -1 si inválido
// ******  Entradas  *********************************
// w0: Carácter ASCII de la letra (A-J o a-j)
// ******  Errores  **********************************
// Retorna -1 si el carácter no está en el rango
// ***************************************************
f06ConvertirLetraAFila:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Convertir a mayúscula si es minúscula
        CMP w0, #'a'
        BLT f06verificar_mayuscula
        CMP w0, #'z'
        BGT f06invalido
        SUB w0, w0, #32         // Convertir a mayúscula
        
f06verificar_mayuscula:
        // Verificar rango A-J (65-74)
        CMP w0, #'A'
        BLT f06invalido
        CMP w0, #'J'
        BGT f06invalido
        
        // Convertir: A=0, B=1, ..., J=9
        SUB w0, w0, #'A'
        
        ldp x29, x30, [sp], 16
        RET

f06invalido:
        MOV x0, #-1             // Retornar -1 si inválido
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f07ConvertirFilaALetra
// ******  Descripción  ******************************
// Convierte un índice de fila (0-9) a letra (A-J).
// ******  Retorno  **********************************
// w0: Carácter ASCII de la letra (A-J), o 0 si inválido
// ******  Entradas  *********************************
// x0: Índice de fila (0-9)
// ******  Errores  **********************************
// Retorna 0 si el índice no está en el rango
// ***************************************************
f07ConvertirFilaALetra:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Verificar rango 0-9
        CMP x0, #0
        BLT f07invalido
        CMP x0, #9
        BGT f07invalido
        
        // Convertir: 0=A, 1=B, ..., 9=J
        ADD w0, w0, #'A'
        
        ldp x29, x30, [sp], 16
        RET

f07invalido:
        MOV w0, #0              // Retornar 0 si inválido
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f08ConvertirTextoAColumna
// ******  Descripción  ******************************
// Convierte un texto "1"-"14" a índice de columna (0-13).
// Maneja 1 o 2 dígitos.
// ******  Retorno  **********************************
// x0: Índice de columna (0-13), o -1 si inválido
// ******  Entradas  *********************************
// x1: Dirección del buffer con el texto
// x2: Longitud del buffer
// ******  Errores  **********************************
// Retorna -1 si el texto no representa 1-14
// ***************************************************
f08ConvertirTextoAColumna:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Convertir texto a número usando f01AsciiANumero
        BL f01AsciiANumero
        
        // Verificar rango 1-14
        CMP x0, #1
        BLT f08invalido
        CMP x0, #14
        BGT f08invalido
        
        // Convertir a índice: 1→0, 2→1, ..., 14→13
        SUB x0, x0, #1
        
        ldp x29, x30, [sp], 16
        RET

f08invalido:
        MOV x0, #-1             // Retornar -1 si inválido
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f09ConvertirColumnaATexto
// ******  Descripción  ******************************
// Convierte un índice de columna (0-13) a texto ("1"-"14").
// Almacena el resultado en un buffer.
// ******  Retorno  **********************************
// x0: Longitud del texto generado (1 o 2), o -1 si error
// ******  Entradas  *********************************
// x0: Índice de columna (0-13)
// x1: Dirección del buffer de salida (mínimo 3 bytes)
// ******  Errores  **********************************
// Retorna -1 si el índice no está en el rango
// ***************************************************
f09ConvertirColumnaATexto:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Guardar buffer destino
        MOV x9, x1
        
        // Verificar rango 0-13
        CMP x0, #0
        BLT f09invalido
        CMP x0, #13
        BGT f09invalido
        
        // Convertir a número de columna: 0→1, 1→2, ..., 13→14
        ADD x0, x0, #1
        
        // Determinar si es 1 o 2 dígitos
        CMP x0, #10
        BLT f09un_digito
        
f09dos_digitos:
        // Número de 2 dígitos (10-14)
        MOV x2, #10
        UDIV x3, x0, x2         // x3 = primer dígito
        MSUB x4, x3, x2, x0     // x4 = segundo dígito
        
        ADD w3, w3, #'0'        // Convertir a ASCII
        ADD w4, w4, #'0'
        
        STRB w3, [x9]           // Almacenar primer dígito
        STRB w4, [x9, #1]       // Almacenar segundo dígito
        MOV w5, #0
        STRB w5, [x9, #2]       // Terminador nulo
        
        MOV x0, #2              // Longitud = 2
        ldp x29, x30, [sp], 16
        RET

f09un_digito:
        // Número de 1 dígito (1-9)
        ADD w0, w0, #'0'        // Convertir a ASCII
        STRB w0, [x9]           // Almacenar dígito
        MOV w1, #0
        STRB w1, [x9, #1]       // Terminador nulo
        
        MOV x0, #1              // Longitud = 1
        ldp x29, x30, [sp], 16
        RET

f09invalido:
        MOV x0, #-1             // Retornar -1 si inválido
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f10ParsearCoordenada
// ******  Descripción  ******************************
// Parsea una coordenada completa (ej: "A1", "J14")
// y la convierte a índices (fila, columna).
// Formato esperado: Letra + Número (sin espacios)
// ******  Retorno  **********************************
// x0: Índice de fila (0-9), o -1 si error
// x1: Índice de columna (0-13), o -1 si error
// ******  Entradas  *********************************
// x1: Dirección del buffer con la coordenada
// x2: Longitud del buffer (2-3 bytes)
// ******  Errores  **********************************
// Retorna (-1, -1) si el formato es inválido
// ***************************************************
f10ParsearCoordenada:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        // Guardar parámetros
        STR x1, [sp, #16]       // Buffer
        STR x2, [sp, #24]       // Longitud
        
        // Validar longitud (debe ser 2 o 3)
        CMP x2, #2
        BLT f10invalido
        CMP x2, #4
        BGE f10invalido
        
        // Extraer letra (primer carácter)
        LDRB w0, [x1]
        BL f06ConvertirLetraAFila
        CMP x0, #-1
        BEQ f10invalido
        
        // Guardar fila
        MOV x10, x0
        
        // Extraer número (resto de caracteres)
        LDR x1, [sp, #16]       // Recuperar buffer
        LDR x2, [sp, #24]       // Recuperar longitud
        ADD x1, x1, #1          // Saltar la letra
        SUB x2, x2, #1          // Reducir longitud
        
        BL f08ConvertirTextoAColumna
        CMP x0, #-1
        BEQ f10invalido
        
        // Retornar (fila, columna)
        MOV x1, x0              // x1 = columna
        MOV x0, x10             // x0 = fila
        
        ldp x29, x30, [sp], 32
        RET

f10invalido:
        MOV x0, #-1             // Fila inválida
        MOV x1, #-1             // Columna inválida
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f11ImprimirNumero
// ******  Descripción  ******************************
// Convierte un número a ASCII e imprime en pantalla.
// Útil para debugging y mostrar información numérica.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// x0: Número a imprimir (0-99)
// ******  Errores  **********************************
// Ninguno
// ***************************************************
f11ImprimirNumero:
        stp x29, x30, [sp, -32]!
        mov x29, sp
        
        // Si es 0, caso especial
        CMP x0, #0
        BEQ f11cero
        
        // Determinar cantidad de dígitos
        CMP x0, #10
        BLT f11un_digito
        
f11dos_digitos:
        // Extraer dígitos
        MOV x2, #10
        UDIV x3, x0, x2         // x3 = primer dígito
        MSUB x4, x3, x2, x0     // x4 = segundo dígito
        
        ADD w3, w3, #'0'
        ADD w4, w4, #'0'
        
        STRB w3, [sp, #16]
        STRB w4, [sp, #17]
        MOV w5, #10             // Salto de línea
        STRB w5, [sp, #18]
        
        MOV x8, #64             // Syscall write
        MOV x0, #1              // stdout
        ADD x1, sp, #16
        MOV x2, #3
        SVC #0
        
        ldp x29, x30, [sp], 32
        RET

f11un_digito:
        ADD w0, w0, #'0'
        STRB w0, [sp, #16]
        MOV w1, #10             // Salto de línea
        STRB w1, [sp, #17]
        
        MOV x8, #64             // Syscall write
        MOV x0, #1              // stdout
        ADD x1, sp, #16
        MOV x2, #2
        SVC #0
        
        ldp x29, x30, [sp], 32
        RET

f11cero:
        MOV w0, #'0'
        STRB w0, [sp, #16]
        MOV w1, #10             // Salto de línea
        STRB w1, [sp, #17]
        
        MOV x8, #64             // Syscall write
        MOV x0, #1              // stdout
        ADD x1, sp, #16
        MOV x2, #2
        SVC #0
        
        ldp x29, x30, [sp], 32
        RET


// ******  Nombre  ***********************************
// f12LeerCoordenada
// ******  Descripción  ******************************
// Lee una coordenada desde entrada estándar y la
// parsea automáticamente a índices (fila, columna).
// ******  Retorno  **********************************
// x0: Índice de fila (0-9), o -1 si error
// x1: Índice de columna (0-13), o -1 si error
// ******  Entradas  *********************************
// Ninguna (lee desde stdin)
// ******  Errores  **********************************
// Retorna (-1, -1) si el formato es inválido
// ***************************************************
f12LeerCoordenada:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Leer desde entrada estándar
        LDR x1, =BufferCoordenada
        MOV x2, #6              // Máximo: "J14\n\0"
        BL f02LeerCadena
        
        // Parsear coordenada
        LDR x1, =BufferCoordenada
        MOV x2, #5
        BL f10ParsearCoordenada
        
        ldp x29, x30, [sp], 16
        RET


// ******  Nombre  ***********************************
// f13InicializarSemilla
// ******  Descripción  ******************************
// Inicializa la semilla del generador aleatorio
// usando el syscall getrandom de Linux para obtener
// un valor verdaderamente aleatorio del sistema.
// ******  Retorno  **********************************
// Ninguno
// ******  Entradas  *********************************
// Ninguna
// ******  Errores  **********************************
// Si getrandom falla, usa una semilla por defecto
// basada en el tiempo del sistema
// ***************************************************
f13InicializarSemilla:
        stp x29, x30, [sp, -16]!
        mov x29, sp
        
        // Intentar obtener bytes aleatorios con getrandom
        // syscall 278 en ARM64 Linux
        MOV x8, #278            // Syscall getrandom
        LDR x0, =Semilla        // Buffer donde guardar
        MOV x1, #8              // 8 bytes (64 bits)
        MOV x2, #0              // Flags = 0 (bloqueante si es necesario)
        SVC #0
        
        // Verificar si tuvo éxito (retorna bytes leídos)
        CMP x0, #8
        BEQ f13fin              // Si leyó 8 bytes, ya está
        
        // Si falló getrandom, usar timestamp como semilla alternativa
        // syscall 169 = gettimeofday (o usar clock_gettime)
        MOV x8, #169            // Syscall gettimeofday
        SUB sp, sp, #16         // Espacio para timeval struct
        MOV x0, sp              // Puntero a timeval
        MOV x1, #0              // timezone = NULL
        SVC #0
        
        LDR x1, [sp]            // Cargar tv_sec
        LDR x2, [sp, #8]        // Cargar tv_usec
        ADD sp, sp, #16         // Restaurar stack
        
        // Combinar segundos y microsegundos para crear semilla
        LSL x1, x1, #20         // Desplazar segundos
        EOR x1, x1, x2          // XOR con microsegundos
        
        // Guardar en Semilla global
        LDR x0, =Semilla
        STR x1, [x0]

f13fin:
        ldp x29, x30, [sp], 16
        RET


// ============================================
// FIN DE FUNCIONES PARA BATTLESHIP
// ============================================
