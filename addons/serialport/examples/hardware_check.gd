extends Node

const TEST_MESSAGE = "Test Message"

# 配置参数
var port1_name := "/dev/ttyUSB0"
var port2_name := "" # 可选，留空则单口测试
var loopback := false

func _ready():
    var serial1 = SerialPortWrapper.new()
    serial1.set_baud_rate(9600)
    serial1.set_data_bits(8)
    serial1.set_parity(0)
    serial1.set_stop_bits(1)
    serial1.set_flow_control(0)
    serial1.set_timeout(1000)
    if not serial1.open_port(port1_name):
        print("Failed to open %s: %s" % [port1_name, serial1.get_last_error()])
        return

    print("Testing '%s':" % port1_name)
    test_single_port(serial1, loopback)

    if port2_name != "":
        var serial2 = SerialPortWrapper.new()
        serial2.set_baud_rate(9600)
        serial2.set_data_bits(8)
        serial2.set_parity(0)
        serial2.set_stop_bits(1)
        serial2.set_flow_control(0)
        serial2.set_timeout(1000)
        if not serial2.open_port(port2_name):
            print("Failed to open %s: %s" % [port2_name, serial2.get_last_error()])
            return
        print("Testing '%s':" % port2_name)
        test_single_port(serial2, false)
        test_dual_ports(serial1, serial2)

func test_single_port(port, loopback):
    print("Testing baud rates...")
    for baud in [9600, 38400, 115200, 10000, 600000, 1800000]:
        port.set_baud_rate(baud)
        var r = port.get_baud_rate()
        if r != baud:
            print("  %d: FAILED (got %d)" % [baud, r])
        else:
            print("  %d: success" % baud)

    print("Testing data bits...")
    for bits in [5, 6, 7, 8]:
        port.set_data_bits(bits)
        var r = port.get_data_bits()
        if r != bits:
            print("  %d: FAILED (got %d)" % [bits, r])
        else:
            print("  %d: success" % bits)

    print("Testing flow control...")
    for flow in [1, 2, 0]: # 1:Software, 2:Hardware, 0:None
        port.set_flow_control(flow)
        var r = port.get_flow_control()
        if r != flow:
            print("  %d: FAILED (got %d)" % [flow, r])
        else:
            print("  %d: success" % flow)

    print("Testing parity...")
    for parity in [1, 2, 0]: # 1:Odd, 2:Even, 0:None
        port.set_parity(parity)
        var r = port.get_parity()
        if r != parity:
            print("  %d: FAILED (got %d)" % [parity, r])
        else:
            print("  %d: success" % parity)

    print("Testing stop bits...")
    for stop in [2, 1]:
        port.set_stop_bits(stop)
        var r = port.get_stop_bits()
        if r != stop:
            print("  %d: FAILED (got %d)" % [stop, r])
        else:
            print("  %d: success" % stop)

    print("Testing bytes to read and write...")
    print("  bytes_to_write: %s" % str(port.bytes_to_write(port1_name)))
    print("  bytes_to_read: %s" % str(port.bytes_to_read(port1_name)))

    print("Test clearing software buffers...")
    port.clear_input_buffer(port1_name)
    port.clear_output_buffer(port1_name)
    port.clear_all_buffer(port1_name)

    print("Testing data transmission...")
    port.write_string(port1_name, TEST_MESSAGE)
    print("success")

    if loopback:
        print("Testing data reception...")
        port.set_timeout(250)
        var buf = port.read_bytes(port1_name, TEST_MESSAGE.length())
        var msg_recvd = buf.get_string_from_utf8()
        if msg_recvd == TEST_MESSAGE:
            print("success")
        else:
            print("FAILED: %s" % msg_recvd)

func test_dual_ports(port1, port2):
    print("Testing paired ports '%s' and '%s':" % [port1_name, port2_name])
    set_defaults(port1)
    set_defaults(port2)
    for baud in [2000000, 115200, 57600, 10000, 9600]:
        port1.set_baud_rate(baud)
        port2.set_baud_rate(baud)
        check_test_message(port1, port2)
        check_test_message(port2, port1)
    for flow in [1, 2]: # 1:Software, 2:Hardware
        port1.set_flow_control(flow)
        port2.set_flow_control(flow)
        check_test_message(port1, port2)
        check_test_message(port2, port1)

func set_defaults(port):
    port.set_baud_rate(9600)
    port.set_data_bits(8)
    port.set_flow_control(1) # Software
    port.set_parity(0)
    port.set_stop_bits(1)
    port.set_timeout(1000)

func check_test_message(sender, receiver):
    sender.clear_all_buffer(port1_name)
    receiver.clear_all_buffer(port2_name)
    sender.write_string(port1_name, TEST_MESSAGE)
    sender.flush(port1_name)
    var buf = receiver.read_bytes(port2_name, TEST_MESSAGE.length())
    var msg_recvd = buf.get_string_from_utf8()
    if msg_recvd == TEST_MESSAGE:
        print("        success")
    else:
        print("FAILED: %s" % msg_recvd)
