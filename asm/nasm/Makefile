NAME = libasm.a
SRC = strlen strcmp strcpy write
ASM = $(foreach src,$(SRC),$(src)/ft_$(src).s)
OBJ = $(foreach src,$(SRC),$(src)/ft_$(src).o)
M_OBJ = $(foreach src,$(SRC),$(src)/main.o)

all: $(NAME)

# build the library
$(NAME): $(OBJ)
	ar rcs $(NAME) $(OBJ)
	for src in $(SRC); do \
		mkdir -p build/$$src; \
		mv -f $$src/ft_$$src.o ./build/$$src; \
	done

# build object file for library
%.o: %.s dirmake
	nasm -f macho64 -o $@ $<

# run each c testing main file using their scripts
test_mains: $(OBJ) dirmake
	@set -e; for src in $(SRC); do \
		echo "Testing $$src"; \
		(cd $$src && bash ./build_$$src.sh && ./test_$$src.out); \
	done

dirmake:
	for src in $(SRC); do \
		mkdir -p build/$$src; \
	done

# Clean up compiled files
clean:
	rm -rf build

# Clean up compiled files and the library
fclean: clean
	rm -f $(NAME)

# Rebuild everything
re: fclean all

.PHONY: all clean fclean re dirmake