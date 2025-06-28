extends Node

# 配置参数
var port_name := "/dev/ttyUSB0"
var baud_rate := 115200
var stop_bits := 1      # 1 或 2
var data_bits := 8      # 5/6/7/8
var rate := 1           # 发送频率Hz，0为只发一次
var send_string := "."

var _timer := 0.0

func _ready():
    var serial = SerialPort.new()
    serial.set_baud_rate(baud_rate)
    serial.set_data_bits(data_bits)
    serial.set_stop_bits(stop_bits)
    serial.set_parity(0)
    serial.set_flow_control(0)
    serial.set_timeout(1000)
    if not serial.open_port(port_name):
        print("Failed to open %s: %s" % [port_name, serial.get_last_error()])
        return

    print("Writing '%s' to %s at %d baud at %dHz" % [send_string, port_name, baud_rate, rate])
    _send_once(serial)
    if rate > 0:
        set_process(true)
    else:
        serial.close_port(port_name)

func _process(delta):
    _timer += delta
    if _timer >= 1.0 / rate:
        _timer = 0.0
        var serial = SerialPort.new()
        _send_once(serial)

func _send_once(serial):
    var n = serial.write_string(port_name, send_string)
    if n > 0:
        print(send_string)
    else:
        print("Write error: %s" % serial.get_last_error())
