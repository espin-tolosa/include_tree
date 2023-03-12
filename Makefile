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


# ------------------------------------------------------------------------------
# RULES
# ------------------------------------------------------------------------------

all: $(BUILD_TARGET)/$(BIN)

$(BUILD_TARGET)/$(BIN): $(POSTPRO)
	$(CC) $(CFLAGS) $(OBJECTS) -o $@

$(BUILD_TARGET)/$(E_TARGET)/%.c: $(SRCDIR)/%.c $(OBJECTS)
	$(CC) $(CFLAGS) -E $< -o $@

$(BUILD_TARGET)/$(O_TARGET)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(RM) -r $(BINDIR)/$(SRC_HASH) $(BIN)

