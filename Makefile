PROJECT := $(notdir $(CURDIR))
VERSION := 0.1

# Directories
SRC_DIR	:= source
INC_DIR := include
OBJ_DIR := obj
BIN_DIR	:= bin

ASM     := rgbasm
LD      := rgblink
FIX     := rgbfix
ASFLAGS := -i $(INC_DIR)
LDFLAGS :=

SRC_EXT := asm
INC_EXT := inc
OBJ_EXT := obj
TGT_EXT := gb

TARGET  := $(PROJECT)
OUTPUT  := $(BIN_DIR)/$(TARGET).$(TGT_EXT)

EMU     := wine ~/win/BGB/bgb.exe

#--------------------------------------------------------------------------------#
# Collect list of required files
SOURCE_FILES  := $(shell find $(SRC_DIR) -type f -name *.$(SRC_EXT))
INCLUDE_FILES := $(shell find $(INC_DIR) -type f -name *$(INC_EXT))
OBJECT_FILES  := $(patsubst $(SRC_DIR)/%, $(OBJ_DIR)/%, $(SOURCE_FILES:.$(SRC_EXT)=.$(OBJ_EXT)))

# Targets
.PHONY: all test clean directories

all: directories $(TARGET)

test: all
	$(EMU) $(OUTPUT)

clean:
	rm -rf $(OBJ_DIR)

directories: $(OBJ_DIR) $(BIN_DIR)

$(OBJ_DIR):
	mkdir -p $@
$(BIN_DIR):
	mkdir -p $@

$(TARGET): $(OBJECT_FILES)
	$(LD) -o $(OUTPUT) $^
	$(FIX) -v -p0 $(OUTPUT)

$(OBJ_DIR)/%.$(OBJ_EXT): $(SRC_DIR)/%.$(SRC_EXT)
	$(ASM) $(ASFLAGS) -o $@ $<
