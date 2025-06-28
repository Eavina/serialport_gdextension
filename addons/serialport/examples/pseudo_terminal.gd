extends Node

func _ready():
    # 假设 Rust 封装有 create_pseudo_terminal_pair()，返回 [master_name, slave_name]
    var serial: SerialPortWrapper = SerialPortWrapper.new()
    var pair = serial.create_pseudo_terminal_pair()
    if pair.size() != 2:
        print("Unable to create pseudo-terminal pair")
        return

    var master = pair[0]
    var slave = pair[1]

    print("Master ptty: %s" % master)
    print("Slave  ptty: %s" % slave)

    if not serial.open_port(master) or not serial.open_port(slave):
        print("Failed to open pseudo terminals")
        return

    print("Sending 5 messages from master to slave.")
    for x in range(1, 6):
        var msg = "Message #%d" % x
        var n = serial.write_string(master, msg)
        if n != msg.length():
            print("Write error")
            break

        var buf = serial.read_bytes(slave, msg.length())
        var msg_recvd = buf.get_string_from_utf8()
        if msg_recvd != msg:
            print("Data mismatch: %s != %s" % [msg_recvd, msg])
            break

        print("Slave Rx: %s" % msg_recvd)
        await get_tree().create_timer(1.0).timeout

    serial.close_port(master)
    serial.close_port(slave)
