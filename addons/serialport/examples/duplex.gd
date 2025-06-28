extends Node

var port_name := ""
var baud_rate := 9600
var serial: SerialPortWrapper = null
var serial_clone: SerialPortWrapper = null
var send_timer: Timer = null

func _ready():
    var ports = SerialPortWrapper.new().list_ports()
    if ports.size() == 0:
        print("No serial port")
        return
    port_name = ports[0]
    serial = SerialPortWrapper.new()
    serial.set_baud_rate(baud_rate)
    serial.set_data_bits(8)
    serial.set_parity(0)
    serial.set_stop_bits(1)
    serial.set_flow_control(0)
    serial.set_timeout(100)
    if not serial.open_port(port_name):
        print("Failed to open serial port: %s" % serial.get_last_error())
        return

    # 克隆端口（假设 Rust 封装支持 try_clone_port 返回新 SerialPortWrapper 实例）
    serial_clone = serial.try_clone_port(port_name)
    if serial_clone == null:
        print("Failed to clone serial port")
        return

    # 定时发送
    send_timer = Timer.new()
    send_timer.wait_time = 1.0
    send_timer.autostart = true
    send_timer.one_shot = false
    add_child(send_timer)
    send_timer.timeout.connect(_on_send_timer_timeout)

    set_process(true)

func _on_send_timer_timeout():
    var data = PackedByteArray([5, 6, 7, 8])
    var n = serial_clone.write_bytes(port_name, data)
    if n != data.size():
        print("Failed to write to serial port")

func _process(_delta):
    var buf = serial.read_bytes(port_name, 1)
    if buf.size() == 1:
        print("Received: %s" % str(buf))
