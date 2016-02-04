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

define android_setup_debug
	@echo [.] setup debugging...
	$(_ADB) forward tcp:5039 tcp:5039
	$(_ADB) push ./runserver.sh $(DEVICE_DIR)
	$(_ADB) shell chmod 755 $(DEVICE_DIR)/runserver.sh
endef

define android_push_binaries
	@echo [.] uploading binaries...
	$(_ADB) push ./$(OUT_BIN) $(DEVICE_DIR)
	$(_ADB) shell chmod 755 $(DEVICE_DIR)/$(OUT_BIN)
endef

define compile_gcc
	@echo [.] build using gcc...
	$(_GCC) $(CFLAGS) $(SOURCES) -o $(OUT_DIR)/$(OUT_BIN)
endef

define compile_clang
	@echo [.] build using clang...
	$(_CLANG) $(CFLAGS) $(SOURCES) -o $(OUT_DIR)/$(OUT_BIN)
endef

define android_start_gdbserver
	@echo [.] uploading gdbserver...
	$(_ADB) push $(_GDBSERVER) $(DEVICE_DIR)
	$(_ADB) shell chmod 755 $(DEVICE_DIR)/$(notdir $(_GDBSERVER))
	@echo [.] starting gdbserver...
	$(_ADB) shell $(DEVICE_DIR)/runserver.sh $(notdir $(_GDBSERVER)) $(DEVICE_DIR) $(OUT_BIN)
endef

define android_start_lldbserver
	@echo [.] uploading lldb-server...
	$(_ADB) push $(_LLDBSERVER) $(DEVICE_DIR)
	$(_ADB) shell chmod 755 $(DEVICE_DIR)/$(notdir $(_LLDBSERVER))
	@echo [.] starting lldb-server...
	$(_ADB) shell $(DEVICE_DIR)/runserver.sh $(notdir $(_LLDBSERVER)) $(DEVICE_DIR) $(OUT_BIN)
endef

define start_gdb
	$(call create_gdb_setup)
	@echo [.] starting gdb...
	$(_GDB) -x $(OUT_DIR)/gdb.setup
endef

define start_lldb
	$(call android_create_lldb_setup)
	@echo [.] starting lldb...
	lldb -s $(OUT_DIR)/lldb.setup
endef

all:
	@echo "$$BANNER"

build:
	$(call compile_$(COMPILER))

push:
	$(call android_push_binaries)

build-push: build
	$(call android_push_binaries)

build-push-startserver: build-push
	$(call android_setup_debug)
ifeq ($(DEBUGGER),gdb)
	$(call android_start_gdbserver)
else
	$(call android_start_lldbserver)
endif

debug-startserver:
	$(call android_setup_debug)
ifeq ($(DEBUGGER),gdb)
	$(call android_start_gdbserver)
else
	$(call android_start_lldbserver)
endif

debug-startclient:
ifeq ($(DEBUGGER), gdb)
	$(call start_gdb)
else
	$(call start_lldb)
endif

clean:
	@echo [.] cleanup...
	rm -f $(OUT_DIR)/$(OUT_BIN) *.o $(OUT_DIR)/gdb.setup $(OUT_DIR)/lldb.setup
