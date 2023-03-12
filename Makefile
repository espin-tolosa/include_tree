BIN=include-tree

OBJS=main.o

OBJDIR=obj
SRCDIR=src
INCDIR=include
BINDIR=build
PSTDIR=post

CC=gcc

CLEVEL=-g

STD=-std=c99

# Base warnings common for all projects
WBASE= -Wall -Wextra

# Warnings able to detect Non MISRA-C 2012 Compliant
WCOMP= -Wmissing-braces

#
CFLAGS = $(CLEVEL) $(WBASE) $(WCOMP)

all: $(BIN)

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) $(OBJS) -o $@

$(OBJDIR)/%.o: $(PSTDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(PSTDIR)/%.c:
	$(CC) -E $< > $@

clean:
	$(RM) -r $(BUILDDIR) $(OBJDIR) $(PSTDIR)




