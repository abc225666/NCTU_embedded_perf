CC ?= gcc
CFLAGS_common ?= -Wall -std=gnu99 -g3 -DDEBUG -O0

EXEC = pi matrix branch
GIT_HOOKS := .git/hooks/applied
.PHONY: all
all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

SRCS_common = main.c

pi: %:$(SRCS_common) %.c
	$(CC) $(CFLAGS_common) \
		-o $@ -DPI -DHEADER="\"$@.h\"" \
		$(SRCS_common) $@.c

matrix: %:$(SRCS_common) %.c
	$(CC) $(CFLAGS_common) \
		-o $@ -DMATRIX -DHEADER="\"$@.h\"" \
		$(SRCS_common) $@.c

branch: %:$(SRCS_common) %.c
	$(CC) $(CFLAGS_common) \
		-o $@ -DBRANCH -DHEADER="\"$@.h\"" \
		$(SRCS_common) $@.c

cache-test: $(EXEC)
	perf stat --repeat 5 \
		-e cache-misses,cache-references,instructions,cycles \
		./matrix

branch-test: branch
	perf stat --repeat 5 \
		-e branch-misses,branches \
		./branch

plot: output.txt
	gnuplot scripts/runtime.gp

.PHONY: clean
clean:
	$(RM) $(EXEC) *.o perf.*
