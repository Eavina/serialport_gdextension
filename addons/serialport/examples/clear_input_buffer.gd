extends Node

var port_name := "/dev/ttyUSB0"
var baud_rate := 9600
var serial: SerialPortWrapper = null

func _ready():
    serial = SerialPortWrapper.new()
    serial.set_baud_rate(baud_rate)
    serial.set_data_bits(8)
    serial.set_parity(0)
    serial.set_stop_bits(1)
    serial.set_flow_control(0)
    serial.set_timeout(10)
    if not serial.open_port(port_name):
        print("Failed to open %s: %s" % [port_name, serial.get_last_error()])
        return

    print("Connected to %s at %d baud" % [port_name, baud_rate])
    print("Press Enter in Godot Output to clear the buffer. Stop the scene to quit.")
    set_process(true)

func _process(_delta):
    var available = serial.bytes_to_read(port_name)
    print("Bytes available to read: %d" % available)
    # 检查输入
    if Input.is_action_just_pressed("ui_accept"):
        print("------------------------- Discarding buffer -------------------------")
        serial.clear_input_buffer(port_name)
    # 100ms 间隔
    await get_tree().create_timer(0.1).timeout

# 你需要在 Rust 封装中实现 bytes_to_read(port_name) 和 clear_input_buffer(port_name) 方法
# bytes_to_read 返回可读字节数
# clear_input_buffer 清空输入缓冲区
