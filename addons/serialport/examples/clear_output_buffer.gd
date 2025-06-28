extends Node

var port_name := "/dev/ttyUSB0"
var baud_rate := 9600
var block_size := 128
var serial: SerialPortWrapper = null
var block := PackedByteArray()
var running := true

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
        running = false
        return

    print("Connected to %s at %d baud" % [port_name, baud_rate])
    print("Press Enter in Godot Output to clear the buffer. Stop the scene to quit.")
    block.resize(block_size)
    for i in range(block_size):
        block[i] = 0
    set_process(true)

func _process(_delta):
    if not running:
        return
    # 持续写数据以填满输出缓冲区
    serial.write_bytes(port_name, block)
    # 检查输入
    if Input.is_action_just_pressed("ui_accept"):
        print("------------------------- Discarding buffer -------------------------")
        serial.clear_output_buffer(port_name)
    # 查询缓冲区剩余
    var queued = serial.bytes_to_write(port_name)
    print("Bytes queued to send: %d" % queued)
    # 100ms 间隔
    await get_tree().create_timer(0.1).timeout

# 你需要在 Rust 封装中实现 bytes_to_write(port_name) 和 clear_output_buffer(port_name) 方法
# bytes_to_write 返回待发送字节数
# clear_output_buffer 清空输出缓冲区
