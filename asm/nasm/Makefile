NAME = libasm.a

SRC = strlen

ASM = $(SRC)/ft_$(SRC).s
OBJ = $(SRC)/ft_$(SRC).o
M_OBJ = $(SRC)/main.o
SCRIPTS = cd $(SRC) && bash ./build_$(SRC).sh && ./test_$(SRC).out
MOVE_CMD = mv -f $(OBJ) ./build/$(SRC)

all: $(NAME)

# build the library
$(NAME): $(OBJ)
	ar rcs $(NAME) $(OBJ)
	$(MOVE_CMD)

# build object file for library
$(OBJ): $(ASM) dirmake
	nasm -f macho64 -o $@ $<

# run each c testing main file using their scripts
test_mains: dirmake
	$(SCRIPTS)
	$(MOVE_CMD)

dirmake:
	mkdir -p build/$(SRC)

# Clean up compiled files
clean:
	rm -rf build

# Clean up compiled files and the library
fclean: clean
	rm -f $(NAME)

# Rebuild everything
re: fclean all

.PHONY: all clean fclean re dirmake
