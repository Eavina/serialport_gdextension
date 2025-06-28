extends Node

# 配置参数
@export var port_name := "/dev/ttyUSB0"
@export var baud_rate := 115200

func _ready():
    var serial = SerialPort.new()
    serial.set_baud_rate(baud_rate)
    serial.set_data_bits(8)
    serial.set_parity(0)
    serial.set_stop_bits(1)
    serial.set_flow_control(0)
    serial.set_timeout(10) # 10ms

    if not serial.open_port(port_name):
        print("Failed to open %s: %s" % [port_name, serial.get_last_error()])
        return

    print("Receiving data on %s at %d baud:" % [port_name, baud_rate])
    set_process(true)

func _process(_delta):
    var serial = SerialPort.new()
    var buf = serial.read_bytes(port_name, 1000)
    if buf.size() > 0:
        var s = ""
        for b in buf:
            s += char(b)
        print(s) # 或 print_raw(s) 以避免自动换行
