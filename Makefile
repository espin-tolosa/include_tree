include .env
export $(shell sed 's/=.*//' .env)

O_TARGET := obj
E_TARGET := pst

SRC_HASH := $(shell find src -type f -exec cat {} \; | sha1sum | head -c 8)
BUILD_TARGET := $(BINDIR)/$(SRC_HASH)/$(TARGET)

$(shell mkdir -p $(BUILD_TARGET)/$(O_TARGET))
$(shell mkdir -p $(BUILD_TARGET)/$(E_TARGET))

CFLAGS := $(addprefix -, std=$(STD) $(TARGET) $(WBASE) $(WCOMP))

SOURCES = $(wildcard $(SRCDIR)/*.c)
OBJECTS = $(patsubst $(SRCDIR)/%.c,$(BUILD_TARGET)/$(O_TARGET)/%.o,$(SOURCES))
POSTPRO = $(patsubst $(SRCDIR)/%.c,$(BUILD_TARGET)/$(E_TARGET)/%.c,$(SOURCES))

.SECONDARY: $(OBJECTS)

INCLUDE = $(addprefix -I, $(INCS))
LIBRARY = $(addprefix -l, $(LIBS))

DEPS = $(shell find $(BUILD_TARGET)/$(E_TARGET) -iname "*.c" -exec cat {} \; | grep "\.h" | grep -oP '(?<=").*(?=")' | awk '!seen[$0]++' > $(BUILD_TARGET)/deps)


# ------------------------------------------------------------------------------
# RULES
# ------------------------------------------------------------------------------

all: $(BUILD_TARGET)/$(BIN)

$(BUILD_TARGET)/$(BIN): $(POSTPRO)
	$(CC) $(CFLAGS) $(OBJECTS) -Wl,-rpath ./include $(LIBRARY) -o $@

$(BUILD_TARGET)/$(E_TARGET)/%.c: $(SRCDIR)/%.c $(OBJECTS)
	$(CC) $(CFLAGS) $(INCLUDE) -E $< -o $@

$(BUILD_TARGET)/$(O_TARGET)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

clean:
	$(RM) -r $(BINDIR)/$(SRC_HASH) $(BIN)

current:
	@echo "$(BUILD_TARGET)"

current_e:
	@echo "$(BUILD_TARGET)/$(E_TARGET)"

current_bin:
	@echo "$(BIN)"

push:
	git push all master

fetch:
	git fetch --all
#LD=./include

#gcc main.c -o dynamic.out -L ./include -Wl,-rpath $LD -pthread
#gcc main.c -o static.out -static -L ./include -Wl,-rpath $LD -pthread
