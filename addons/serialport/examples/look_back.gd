extends Node

# 配置参数
@export var port_name := "/dev/ttyUSB0"
@export var iterations := 100
@export var length := 8
@export var baudrate := 115200
var test_bytes : PackedByteArray = PackedByteArray() # 可选自定义数据

func _ready():
    var serial = SerialPort.new()
    serial.set_baud_rate(baudrate)
    serial.set_data_bits(8)
    serial.set_parity(0)
    serial.set_stop_bits(1)
    serial.set_flow_control(0)
    serial.set_timeout(10000) # 10秒

    if not serial.open_port(port_name):
        print("Failed to open %s: %s" % [port_name, serial.get_last_error()])
        return

    if test_bytes.size() == 0:
        test_bytes.resize(length)
        for i in range(length):
            test_bytes[i] = i

    var read_times = []
    var write_times = []
    var buf = PackedByteArray()
    var ok = true

    for i in range(iterations):
        # 写
        var t0 = Time.get_ticks_usec()
        var n = serial.write_bytes(port_name, test_bytes)
        var t1 = Time.get_ticks_usec()
        write_times.append((t1 - t0) / 1e6)
        if n != length:
            print("Write error at iter %d" % i)
            ok = false
            break

        # 读
        t0 = Time.get_ticks_usec()
        buf = serial.read_bytes(port_name, length)
        t1 = Time.get_ticks_usec()
        read_times.append((t1 - t0) / 1e6)
        if buf != test_bytes:
            print("Data mismatch at iter %d" % i)
            ok = false
            break

    serial.close_port(port_name)

    if ok:
        print("Loopback %s:" % port_name)
        print("  data-length: %d bytes" % length)
        print("  iterations: %d" % iterations)
        print("  read:")
        print("    total: %.6fs" % sum(read_times))
        print("    average: %.6fs" % (sum(read_times) / read_times.size()))
        print("    max: %.6fs" % (read_times.max() if read_times.size() > 0 else 0))
        print("  write:")
        print("    total: %.6fs" % sum(write_times))
        print("    average: %.6fs" % (sum(write_times) / write_times.size()))
        print("    max: %.6fs" % (write_times.max() if write_times.size() > 0 else 0))
        print("  total: %.6fs" % (sum(read_times) + sum(write_times)))
        var avg = (sum(read_times) / read_times.size()) + (sum(write_times) / write_times.size())
        print("  bytes/s: %.6f" % (float(length) / avg if avg > 0 else 0))
    else:
        print("Loopback test failed.")

func sum(arr: Array):
    var res = 0
    for i in arr:
        res += i;
    return res
