BUILD_DIR=./build
ENTRY_FILE=./executable.lua
OUTPUT=stanley

all:
	stanley install
	mkdir -p $(BUILD_DIR)
	lexe -b $(BUILD_DIR) -o $(OUTPUT) -e $(ENTRY_FILE) build
	@$(BUILD_DIR)/$(OUTPUT) --version

clean:
	lexe -b $(BUILD_DIR) clean

install: all
	cp $(BUILD_DIR)/$(OUTPUT) ~/.local/bin/$(OUTPUT)

uninstall: clean
	rm ~/.local/bin/$(OUTPUT)
