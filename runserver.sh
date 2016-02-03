#!/system/bin/sh
#$1 = gdbserver to debug with gdb, lldb-server to debug with lldb
#$2 = the device dir with the debug server and the binary, i.e. /data/local/tmp
#$3 = binary to be debugged (gdb only)
if [ "$1" = "gdbserver" ]; then
    # use gdb
    cd $2
    $2/$1 :5039 ./$3
fi
if [ "$1" = "lldb-server" ]; then
    # use lldb
    rm -f $2/$3 # must be deleted first if exists, or lldb bails out ....
    cd $2
    $2/$1 platform --listen *:5039
fi
