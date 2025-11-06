// ******  Datos administrativos  *******************
// Nombre del archivo: battleship_patrones.s
// Tipo de archivo: Código fuente ensamblador ARM64
// Proyecto: Battleship Advanced Mission
// Autor: Roymar Castillo
// Empresa: ITCR
// ******  Descripción  ******************************
// Define los patrones de ataque de los misiles
// especiales (Exocet y Apache). Cada patrón se
// representa como una lista de offsets relativos
// (fila, columna) desde la coordenada central de
// impacto. Se usa 0xFF como terminador.
// ******  Versión  **********************************
// 01 | 2025-11-05 | Roymar Castillo - Versión inicial
// ***************************************************

.section .data

// ============================================
// PATRÓN EXOCET 1 - Forma de X (esquinas)
// ============================================
// Patrón visual:
//   X . X
//   . X .
//   X . X
// Impacta 5 celdas: las 4 esquinas y el centro
// ============================================
.global PatronExocet1

PatronExocet1:
    .byte -1, -1    // Arriba-izquierda
    .byte -1,  1    // Arriba-derecha
    .byte  0,  0    // Centro (coordenada de disparo)
    .byte  1, -1    // Abajo-izquierda
    .byte  1,  1    // Abajo-derecha
    .byte 0xFF, 0xFF // Terminador

// ============================================
// PATRÓN EXOCET 2 - Forma de + (cruz)
// ============================================
// Patrón visual:
//   . X .
//   X X X
//   . X .
// Impacta 5 celdas: arriba, abajo, izquierda, derecha y centro
// ============================================
.global PatronExocet2

PatronExocet2:
    .byte -1,  0    // Arriba
    .byte  0, -1    // Izquierda
    .byte  0,  0    // Centro (coordenada de disparo)
    .byte  0,  1    // Derecha
    .byte  1,  0    // Abajo
    .byte 0xFF, 0xFF // Terminador

// ============================================
// PATRÓN APACHE 1 - Horizontal
// ============================================
// Patrón visual:
//   . X .
//   X X X
//   . . .
// Impacta 4 celdas: fila central (3 celdas) + celda arriba
// ============================================
.global PatronApache1

PatronApache1:
    .byte -1,  0    // Arriba-centro
    .byte  0, -1    // Centro-izquierda
    .byte  0,  0    // Centro (coordenada de disparo)
    .byte  0,  1    // Centro-derecha
    .byte 0xFF, 0xFF // Terminador

// ============================================
// PATRÓN APACHE 2 - Vertical
// ============================================
// Patrón visual:
//   . X .
//   . X .
//   . X .
// Impacta 3 celdas: línea vertical desde arriba
// ============================================
.global PatronApache2

PatronApache2:
    .byte -1,  0    // Arriba
    .byte  0,  0    // Centro (coordenada de disparo)
    .byte  1,  0    // Abajo
    .byte 0xFF, 0xFF // Terminador

// ============================================
// PATRÓN TOMAHAWK - Área 3x3
// ============================================
// Patrón visual:
//   X X X
//   X X X
//   X X X
// Impacta 9 celdas: toda el área 3×3 alrededor del centro
// ============================================
.global PatronTomahawk

PatronTomahawk:
    .byte -1, -1    // Arriba-izquierda
    .byte -1,  0    // Arriba-centro
    .byte -1,  1    // Arriba-derecha
    .byte  0, -1    // Centro-izquierda
    .byte  0,  0    // Centro (coordenada de disparo)
    .byte  0,  1    // Centro-derecha
    .byte  1, -1    // Abajo-izquierda
    .byte  1,  0    // Abajo-centro
    .byte  1,  1    // Abajo-derecha
    .byte 0xFF, 0xFF // Terminador

// ============================================
// TABLA DE PUNTEROS A PATRONES
// ============================================
// Facilita el acceso a los patrones mediante índice
// ============================================
.global TablaPunterosPatro nes

TablaPatrones:
    .quad PatronExocet1     // Índice 0
    .quad PatronExocet2     // Índice 1
    .quad PatronApache1     // Índice 2
    .quad PatronApache2     // Índice 3
    .quad PatronTomahawk    // Índice 4

// ============================================
// TAMAÑOS DE PATRONES (número de celdas impactadas)
// ============================================
.global TamanoPatronExocet1, TamanoPatronExocet2
.global TamanoPatronApache1, TamanoPatronApache2
.global TamanoPatronTomahawk

TamanoPatronExocet1:  .quad 5  // 5 celdas (esquinas + centro)
TamanoPatronExocet2:  .quad 5  // 5 celdas (cruz)
TamanoPatronApache1:  .quad 4  // 4 celdas (horizontal)
TamanoPatronApache2:  .quad 3  // 3 celdas (vertical)
TamanoPatronTomahawk: .quad 9  // 9 celdas (3×3)

// ============================================
// NOTAS SOBRE USO DE PATRONES
// ============================================
// Para aplicar un patrón:
// 1. Obtener coordenada central de impacto (fila, columna)
// 2. Cargar dirección del patrón correspondiente
// 3. Iterar sobre pares de bytes hasta encontrar terminador (0xFF, 0xFF)
// 4. Para cada par (offset_fila, offset_columna):
//    - Calcular: fila_objetivo = fila_central + offset_fila
//    - Calcular: columna_objetivo = columna_central + offset_columna
//    - Validar que la coordenada esté dentro del tablero (0-9, 0-13)
//    - Procesar impacto en esa celda
//
// Los offsets son números con signo (-1, 0, 1)
// ============================================

// ============================================
// FIN DEL ARCHIVO
// ============================================
