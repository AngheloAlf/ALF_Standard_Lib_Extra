LIB_NAME		= ALF_std_extra
STC_LIB_PRE		= lib
STC_LIB_EXT		= a
DYN_LIB_PRE		= lib
DYN_LIB_EXT		= so

LIB_STATIC		= $(STC_LIB_PRE)$(LIB_NAME).$(STC_LIB_EXT)
LIB_DYNAMIC		= $(DYN_LIB_PRE)$(LIB_NAME).$(DYN_LIB_EXT)


# Directories
PATH_SEPARATOR	= /
ifeq ($(OS),Windows_NT)
	PATH_SEPARATOR	= \\
endif
SRC_DIR		= src
OBJ_DIR		= obj
INCLUDE_DIR	= include
OUT_DIR		= out
DOCS		= docs
TESTS		= tests

TESTS_OUT	= $(OUT_DIR)$(PATH_SEPARATOR)$(TESTS)

FOLDERS		= $(OBJ_DIR) $(OUT_DIR) $(TESTS_OUT)
RM_FOLDERS	= $(OBJ_DIR) $(OUT_DIR)

# Compiler
CC			= gcc
LANG_EXT	= c
HEADER_EXT	= h
OBJ_EXT		= o
FLAGS		= -Wall -fPIC -I$(INCLUDE_DIR)
SHARED_FLAG	= -shared
DEBUG_FLAG	= -g
LIBS		= -ldl

# 
AR			= @ar
AR_FLAGS	= cvq

# Doxygen, documentation generator
DOXYGEN		= doxygen 

# Commands
ECHO		= @echo
COPY		= @cp
MOVE		= @mv
MAKEDIR		= @mkdir
MKDIR_FLAGS	= -p
REMOVE		= @rm
RM_FLAGS	= -rf

ifeq ($(OS),Windows_NT)
	MKDIR_FLAGS	= 
	REMOVE		= @rd
	RM_FLAGS	= /s /q
	MOVE		= move
endif

TEST_SRC	= $(wildcard $(TESTS)/*.$(LANG_EXT))
TEST_EXE	= $(patsubst $(TESTS)/%.$(LANG_EXT), $(TESTS_OUT)/%, $(TEST_SRC))

SRC_FILES	= $(wildcard $(SRC_DIR)/*.$(LANG_EXT))
OBJ_O		= $(patsubst $(SRC_DIR)/%.$(LANG_EXT), $(OBJ_DIR)/%.$(OBJ_EXT), $(SRC_FILES))

all: static_lib dynamic_lib
	$(ECHO) "Done\n"

debug: make_debug_objects ar_static_lib compile_dynamic_lib
	$(ECHO) "Debug ready\n"

install: #static_lib dynamic_lib
	$(ECHO) "Not supported yet"

clean:
	$(REMOVE) $(RM_FLAGS) $(RM_FOLDERS)

docs: make_docs_folder doxygen_make_docs
	$(ECHO) "done"

tests: makefolders $(TEST_EXE)
	$(ECHO) "Done."


$(TESTS_OUT)/%: $(TESTS)/%.$(LANG_EXT)
	$(ECHO) $(CC) $<
	$(CC) $< -o $@ $(FLAGS) -L$(OUT_DIR) -l$(LIB_NAME)

make_docs_folder:
	$(MAKEDIR) $(MKDIR_FLAGS) $(DOCS)

doxygen_make_docs: make_docs_folder
	$(DOXYGEN) docs.conf

clean_docs:
	$(REMOVE) $(RM_FLAGS) $(DOCS)


static_lib: make_objects ar_static_lib
	$(ECHO) "\tStatic library done\n"

dynamic_lib: make_objects compile_dynamic_lib
	$(ECHO) "\tDynamic library done\n"


makefolders:
	$(ECHO) "Making folders"
	$(MAKEDIR) $(MKDIR_FLAGS) $(FOLDERS)
	$(ECHO) "\tFolders done\n"

$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.$(LANG_EXT)
	$(ECHO) $(CC) -c $< 
	$(CC) -c $< -o $@ $(FLAGS) $(LIBS)

make_objects: makefolders $(OBJ_O)
	$(ECHO) "\tObjects done\n"

make_debug_objects: makefolders
	$(ECHO) "Making objects"
	$(CC) -c $(SRC_DIR)$(PATH_SEPARATOR)*.$(LANG_EXT) $(FLAGS) $(DEBUG_FLAG)
	$(ECHO) "->Moving files"
	$(MOVE) *.$(OBJ_EXT) $(OBJ_DIR)$(PATH_SEPARATOR)
	$(ECHO) "\tObjects done\n"

ar_static_lib: make_objects
	$(ECHO) "Making static lib"
	$(ECHO) $(AR) $(OUT_DIR)$(PATH_SEPARATOR)$(LIB_STATIC)
	$(AR) $(AR_FLAGS) $(OUT_DIR)$(PATH_SEPARATOR)$(LIB_STATIC) $(OBJ_DIR)$(PATH_SEPARATOR)*.$(OBJ_EXT)
	$(ECHO) "->Static lib done"

compile_dynamic_lib: make_objects
	$(ECHO) "Making dynamic lib"
	$(ECHO) $(CC) $(OUT_DIR)$(PATH_SEPARATOR)$(LIB_DYNAMIC) $(SHARED_FLAG)
	$(CC) $(OBJ_DIR)$(PATH_SEPARATOR)*.$(OBJ_EXT) $(SHARED_FLAG) -o $(OUT_DIR)$(PATH_SEPARATOR)$(LIB_DYNAMIC) $(LIBS)
	$(ECHO) "->Dynamic lib done"
