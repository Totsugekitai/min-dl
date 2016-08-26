CFLAGS = -std=gnu99 -Wall -Werror -g -D_GNU_SOURCE
CFLAGS += -DPROG_HEADER=prog_header

OUT = out

BIN = $(OUT) $(OUT)/test_lib.so $(OUT)/loader
all: $(BIN)

$(OUT):
	@mkdir -p $(OUT)

$(OUT)/test_lib.o: test_lib.c
	$(CC) $(CFLAGS) -fvisibility=hidden -shared -fPIC -c $< \
		-o $@ -MMD -MF $@.d

$(OUT)/test_lib.so: $(OUT)/test_lib.o
	$(CC) -shared -Wl,--entry=prog_header -Wl,-z,defs -nostdlib \
		$< -o $@

$(OUT)/%.o: %.c
	$(CC) $(CFLAGS) -o $@ -MMD -MF $@.d -c $<

LOADER_OBJS = $(OUT)/loader.o $(OUT)/test_loader.o
$(OUT)/loader: $(LOADER_OBJS)
	$(CC) -o $@ $(LOADER_OBJS)

check: $(BIN)
	@(cd $(OUT) && ./loader)

clean:
	rm -rf $(OUT)
