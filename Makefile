# sade - simple (native) android debug environment
# (c)opyleft, valerino, 2016

include env.setup

all:
	@echo 'usage:'
	@echo 'customize ./env.setup with your source files, flags, paths and init scripts for gdb/ldb'
	@echo ''
	@echo 'to compile and push on the device:'
	@echo 'make push-gdb -> to build with gcc and setup remote debugging with gdbserver'
	@echo 'make push-lldb -> to build with clang and setup remote debugging with lldb-server'
	@echo ''
	@echo 'to debug, run in another shell:'
	@echo 'make debug-gdb -> to debug using gdb'
	@echo 'make debug-lldb -> to debug using lldb'

define push-post
	adb push ./$(OUT_BIN) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(OUT_BIN)
endef

push-common:
	adb forward tcp:5039 tcp:5039
	adb push ./runserver.sh $(DEVICE_DIR)
	adb push ./env.setup $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/runserver.sh
	adb shell chmod 755 $(DEVICE_DIR)/env.setup

compile-gcc: push-common
	$(GCC) $(CFLAGS) $(SOURCES) -o ./$(OUT_BIN)
	$(call push-post)

compile-clang: push-common
	$(CLANG) $(CFLAGS) $(SOURCES) -o ./$(OUT_BIN)
	$(call push-post)

push-gdb: compile-gcc
	adb push $(GDBSERVER_SRC) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(GDBSERVER_BIN)
	@echo '**** NOW RUN make debug-gdb IN ANOTHER SHELL ****'
	adb shell $(DEVICE_DIR)/runserver.sh $(GDBSERVER_BIN) $(DEVICE_DIR) $(OUT_BIN)

push-lldb: compile-clang
	adb push $(LLDBSERVER_SRC) $(DEVICE_DIR)
	adb shell chmod 755 $(DEVICE_DIR)/$(LLDBSERVER_BIN)
	@echo '**** NOW RUN make debug-lldb IN ANOTHER SHELL ****'
	adb shell $(DEVICE_DIR)/runserver.sh $(LLDBSERVER_BIN) $(DEVICE_DIR) $(OUT_BIN)

debug-gdb:
	$(call create_gdb_setup)
	$(GDB) -x ./gdb.setup

debug-lldb:
	$(call create_lldb_setup)
	$(LLDB) -s ./lldb.setup

clean:
	rm -f $(OUT_BIN) *.o
