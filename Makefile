# sade - simple (native) android debug environment
# (c)opyleft, valerino, 2016

include env.setup

define BANNER
sade - simple (native) android debug environment
(c)opyleft, valerino, 2016

usage:
	make build
	build with COMPILER defined in env.setup (gcc or clang)

	make push
	push the built files on the connected device

	make build-push
	'make build' & 'make push' in one shot

	make debug-startserver
	push the debugger server on device and start it, according to DEBUGGER defined in env.setup (gdb or lldb)
	will stop the current shell until debug has ended and/or error

	make debug-startclient
	starts the debugger client on the host, according to DEBUGGER defined in env.setup (gdb or lldb)
	must be run in another shell to connect with the server started with 'make debug-startserver'
endef
export BANNER

# push the needed stuff on android device
define android-push-common
	adb forward tcp:5039 tcp:5039
	adb push ./runserver.sh $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/runserver.sh
	adb push ./$(OUT_BIN) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(OUT_BIN)
endef

# compile using gcc
define compile-gcc
	$(GCC_SRC) $(CFLAGS) $(SOURCES) -o $(OUT_DIR)/$(OUT_BIN)
endef

# compile using clang
define compile-clang
	$(CLANG_SRC) $(CFLAGS) $(SOURCES) -o $(OUT_DIR)/$(OUT_BIN)
endef

all:
	@echo "$$BANNER"

build:
	$(call compile-$(COMPILER))

push:
	$(call android-push-common)

build-push: build
	$(call android-push-common)

debug-startserver:
ifeq ($(DEBUGGER),gdb)
	adb push $(GDBSERVER_SRC) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(GDBSERVER_BIN)

	adb shell $(DEVICE_DIR)/runserver.sh $(GDBSERVER_BIN) $(DEVICE_DIR) $(OUT_BIN)
else
	adb push $(LLDBSERVER_SRC) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(LLDBSERVER_BIN)
	adb shell $(DEVICE_DIR)/runserver.sh $(LLDBSERVER_BIN) $(DEVICE_DIR) $(OUT_BIN)
endif

debug-startclient:
ifeq ($(DEBUGGER), gdb)
	$(call create_gdb_setup)
	$(GDB_SRC) -x $(OUT_DIR)/gdb.setup
else
	$(call create_lldb_setup)
	$(LLDB_SRC) -s $(OUT_DIR)/lldb.setup
endif

clean:
	rm -f $(OUT_DIR)/$(OUT_BIN) *.o $(OUT_DIR)/gdb.setup $(OUT_DIR)/lldb.setup
