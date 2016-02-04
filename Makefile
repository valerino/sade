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

	make build-push-startserver
	'make build' & 'make push' & 'make debug-startserver' in one shot

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
	@echo [.] uploading binaries...
	adb forward tcp:5039 tcp:5039
	adb push ./runserver.sh $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/runserver.sh
	adb push ./$(OUT_BIN) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(OUT_BIN)
endef

# compile using gcc
define compile-gcc
	@echo [.] build using gcc...
	$(_GCC) $(CFLAGS) $(SOURCES) -o $(OUT_DIR)/$(OUT_BIN)
endef

# compile using clang
define compile-clang
	@echo [.] build using clang...
	$(_CLANG) $(CFLAGS) $(SOURCES) -o $(OUT_DIR)/$(OUT_BIN)
endef

define start-gdbserver
	@echo [.] uploading gdbserver...
	adb push $(_GDBSERVER) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(notdir $(_GDBSERVER))
	@echo [.] starting gdbserver...
	adb shell $(DEVICE_DIR)/runserver.sh $(notdir $(_GDBSERVER)) $(DEVICE_DIR) $(OUT_BIN)
endef

define start-lldbserver
	@echo [.] uploading lldbserver...
	adb push $(_LLDBSERVER) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(notdir $(_LLDBSERVER))
	@echo [.] starting lldb-server...
	adb shell $(DEVICE_DIR)/runserver.sh $(notdir $(_LLDBSERVER)) $(DEVICE_DIR) $(OUT_BIN)
endef

define start-gdb
	$(call create_gdb_setup)
	@echo [.] starting gdb...
	$(_GDB) -x $(OUT_DIR)/gdb.setup
endef

define start-lldb
	$(call create_lldb_setup)
	@echo [.] starting lldb...
	lldb -s $(OUT_DIR)/lldb.setup
endef

all:
	@echo "$$BANNER"

build:
	$(call compile-$(COMPILER))

push:
	$(call android-push-common)

build-push: build
	$(call android-push-common)

build-push-startserver: build-push
ifeq ($(DEBUGGER),gdb)
	$(call start-gdbserver)
else
	$(call start-lldbserver)
endif

debug-startserver:
ifeq ($(DEBUGGER),gdb)
	$(call start-gdbserver)
else
	$(call start-lldbserver)
endif

debug-startclient:
ifeq ($(DEBUGGER), gdb)
	$(call start-gdb)
else
	$(call start-lldb)
endif

clean:
	@echo [.] cleanup...
	rm -f $(OUT_DIR)/$(OUT_BIN) *.o $(OUT_DIR)/gdb.setup $(OUT_DIR)/lldb.setup
