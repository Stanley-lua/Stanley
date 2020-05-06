BUILD_DIR=build
ENTRY_FILE=executable.lua
OUTPUT=stanley

COMPILED=$(BUILD_DIR)/$(OUTPUT)
BUILD_OPTIONS=-b $(BUILD_DIR) -e $(ENTRY_FILE) -o $(OUTPUT)

default: all

DEPENDENCIES=CLI counter Debug File opairs oscapture spairs switch YAML
LIBS=$(addprefix Stanley-lua/, $(DEPENDENCIES))

$(LIBS):
	@if [ ! -d "lib/$@" ]; then \
		git clone https://github.com/$@.git lib/$@; \
	fi

lib: $(LIBS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(COMPILED).lua: lib $(BUILD_DIR)
	@lexe $(BUILD_OPTIONS) bundle

$(COMPILED).luac: $(COMPILED).lua
	@lexe $(BUILD_OPTIONS) build

all: $(COMPILED).luac
	@$(COMPILED) --version

clean:
	@lexe -b $(BUILD_DIR) clean

install: default
	cp -f $(BUILD_DIR)/$(OUTPUT) ~/.local/bin/$(OUTPUT)

uninstall: clean
	rm ~/.local/bin/$(OUTPUT)
