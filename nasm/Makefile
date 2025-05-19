NAME = libasm.a

ifeq ($(shell uname -s),Darwin)
FORMAT		= macho64
ARCH		= -arch x86_64
ifeq ($(shell arch),i386)
ARCH		= 
endif
else
FORMAT		= elf64
ARCH		= 
endif

SRC			= strlen strcmp strcpy write read strdup
B_SRC		= atoi_base linked_list

BUILD_DIR	= build
OBJ_DIR		= $(BUILD_DIR)/obj

# separate for bonus rule only
SRC_FILES	= $(foreach src,$(SRC),$(src)/ft_$(src).s)
B_SRC_FILES	= $(foreach src,$(B_SRC),$(src)/ft_$(src).s)

OBJ_FILES	= $(patsubst %.s,$(OBJ_DIR)/%.o,$(SRC_FILES))
B_OBJ_FILES	= $(patsubst %.s,$(OBJ_DIR)/%.o,$(B_SRC_FILES))

CC = clang

# link to libasm.a
all: $(NAME)
bin:
	$(MAKE) bonus
	$(CC) -Wall -Wextra -Werror -g -fsanitize=address,undefined -fno-omit-frame-pointer $(ARCH) linkable_binary.c -L. -lasm -o linkable_binary.out
$(OBJ_DIR)/%.o: %.s | $(OBJ_DIR)
	@mkdir -p $(dir $@)
	nasm -g -Wall -f $(FORMAT) -o $@ $<

# Create all necessary directories
$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(addprefix $(OBJ_DIR)/,$(SRC) $(B_SRC))

# @remind bonus rule same name: will always run ar, for part - nothing is forbidden in main part, naming conventions do not apply for .s
# @audit-ok malloc only in list functions & strdup implementation
# @audit-ok testing main has to be able to "compile" with the "library to show that it’s functional": not needed in makefile - link from anywhere
# @audit-ok errno gets set in all functions doing syscalls + malloc
$(NAME): $(OBJ_FILES)
	ar rcs $(NAME) $^
bonus: $(B_OBJ_FILES) $(OBJ_FILES) 
	ar rcs $(NAME) $^

# run each c testing main file using their scripts
test_mains: $(OBJ_FILES) $(B_OBJ_FILES)
	for src in $(SRC) $(B_SRC); do \
		echo "Testing $$src"; \
		(cd $$src && bash ./build_$$src.sh && ./test_$$src.out); \
	done

# Clean up compiled files
clean:
	rm -rf $(BUILD_DIR)
	@set -e; for src in $(SRC) $(B_SRC); do \
		rm -f $$src/*.o; \
	done

# Clean up compiled files and the library
fclean: clean
	rm -f $(NAME) *.out
	@set -e; for src in $(SRC) $(B_SRC); do \
		rm -f $$src/test_$$src.out; \
	done

# Rebuild everything
re: fclean all

.PHONY: all clean fclean re bonus