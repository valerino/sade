# sade

since i banged my head the whole day to setup that damn gdb/lldb/whatever environment for native android development,
i think this may help someone else facing the same hurdles.....

the included standard Makefile tries to abstract the whole process.

# prerequisites
android ndk

lldb (to use lldb/lldb-server)

# how to use it
env.setup contains the customizations you need to adapt to your environment (paths, etc...)

you can extend it as you will, providing your compiler flags and all.

then, just issuing 'make' will print a nice help

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
	the current shell will hangs until debug has ended and/or error

	make debug-startclient
	starts the debugger client on the host, according to DEBUGGER defined in env.setup (gdb or lldb)
	must be run in another shell to connect with the server started with 'make debug-startserver'

# NOTE
i made this for android development, but really you can customize this for almost every environment supporting gdb/lldb remote debugging: just play with the provided env.setup!
