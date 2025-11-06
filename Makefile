# Makefile para el juego Battleship Advanced Mission en ARM64
# Autor: Roymar Castillo
# Fecha: 2025-11-05

# Herramientas
AS=as
LD=ld
ASFLAGS=-g
LDFLAGS=

# Archivos fuente del juego Battleship
SRC=battleship_main.s \
    battleship_logica.s \
    battleship_constantes.s \
    battleship_patrones.s \
    battleship_tablero.s \
    battleship_barcos.s \
    battleship_disparos.s \
    battleship_misiles.s \
    battleship_ia.s \
    utilidades.s \
    io.s

# Archivos objeto
OBJ=$(SRC:.s=.o)

# Nombre del ejecutable
BIN=battleship

# Regla principal
all: $(BIN)

# Construir el ejecutable
$(BIN): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $(OBJ)

# Regla para archivos objeto
%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

# Limpiar archivos generados
clean:
	rm -f $(OBJ) $(BIN)

# Reconstruir desde cero
rebuild: clean all

# Ejecutar el juego
run: $(BIN)
	./$(BIN)

# Construir y jugar
play: rebuild run

# Test rápido (solo compila)
test: all
	@echo "Compilación exitosa del proyecto Battleship"

.PHONY: all clean rebuild run play test
