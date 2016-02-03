#sade

since i banged my head the whole day to setup that damn gdb/lldb/whatever environment for native android development,
i think this may help someone else facing the same hurdle.....

the included scripts tries to abstract the whole process.

#prerequisites
. android ndk
. android ndk
. lldb (to use lldb)

#usage
first of all, customize ./env.setup with your source files, flags, paths and init scripts for gdb/lldb

to compile and push on the device:

make push-gdb -> to build with gcc and setup remote debugging with gdbserver
make push-lldb -> to build with clang and setup remote debugging with lldb-server

to debug, run in another shell:

make debug-gdb -> to debug using gdb
echo 'make debug-lldb -> to debug using lldb


