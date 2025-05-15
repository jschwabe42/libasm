NAME = libasm.a
SRC = strlen strcmp strcpy write read strdup
B_SRC = atoi_base linked_list
ASM = $(foreach src,$(SRC),$(src)/ft_$(src).s)
OBJ = $(foreach src,$(SRC),$(src)/ft_$(src).o)
M_OBJ = $(foreach src,$(SRC),$(src)/main.o)

all: $(NAME)
# @remind (relinking) bonus rule for part - nothing is forbidden in main part, naming conventions do not apply for .s
# @audit-ok malloc only in list functions & strdup implementation
# @audit-ok testing main has to be able to "compile" with the "library to show that it’s functional": not needed in makefile - link from anywhere
# @audit precondition: currently relinking (because of dirmake breaking tracking)
# @audit Your code must set the variable errno properly.
bonus:
	$(MAKE) SRC="$(SRC) $(B_SRC)" all
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

test_bonus_mains:
	$(MAKE) SRC="$(B_SRC)" test_mains

dirmake:
	for src in $(SRC); do \
		mkdir -p build/$$src; \
	done

# Clean up compiled files
clean:
	rm -rf build
	for obj in $(OBJ) $(M_OBJ); do \
		rm -f $$obj; \
	done
	for src in $(SRC); do \
		rm -f $$src/test_$$src.out; \
	done

# Clean up compiled files and the library
fclean: clean
	rm -f $(NAME)

# Rebuild everything
re: fclean all

.PHONY: all clean fclean re dirmake bonus