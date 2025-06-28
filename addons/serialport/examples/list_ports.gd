extends  Node

func _ready():
    var serial: SerialPortWrapper = SerialPortWrapper.new()
    var ports = serial.list_ports()
    ports.sort() # 保持输出顺序一致

    match ports.size():
        0:
            print("No ports found.")
        1:
            print("Found 1 port:")
        _:
            print("Found %d ports:" % ports.size())

    for port_name in ports:
        print("    %s" % port_name)
        # 如果需要详细信息，可在 Rust 端扩展接口返回更多字段
