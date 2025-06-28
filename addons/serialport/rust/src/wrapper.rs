use serialport::ClearBuffer;
    
use godot::prelude::*;
use serialport::{DataBits, FlowControl, Parity, StopBits};
use std::collections::HashMap;
use std::io::{Read, Write};
use std::time::Duration;

#[derive(GodotClass)]
#[class(base=Node)]
pub struct SerialPort {
    base: Base<Node>,
    ports: HashMap<String, Box<dyn serialport::SerialPort>>,
    last_error: Option<String>,
    // 可选：保存端口参数
    baud_rate: u32,
    data_bits: DataBits,
    parity: Parity,
    stop_bits: StopBits,
    flow_control: FlowControl,
    timeout: u64,
}
#[godot_api]
impl INode for SerialPort {
    fn init(base: Base<Self::Base>) -> Self {
        Self{
            base,
            ports: Default::default(),
            last_error: None,
            baud_rate: 0,
            data_bits: DataBits::Five,
            parity: Parity::None,
            stop_bits: StopBits::One,
            flow_control: FlowControl::None,
            timeout: 0,
        }
    }
}
#[godot_api]
impl SerialPort {
    #[func]
    fn list_ports(&self) -> PackedStringArray {
        let arr = match serialport::available_ports() {
            Ok(ports) =>
                ports.into_iter()
                    .map(|p| GString::from(p.port_name))
                    .collect(),
            Err(e) => {
                godot_print!("Error listing ports: {}", e);
                vec![]
            }
        };
        PackedStringArray::from(arr)
    }

    #[func]
    fn open_port(&mut self, port_name: String) -> bool {
        let builder = serialport::new(&port_name, self.baud_rate)
            .data_bits(self.data_bits)
            .parity(self.parity)
            .stop_bits(self.stop_bits)
            .flow_control(self.flow_control)
            .timeout(Duration::from_millis(self.timeout));
        match builder.open() {
            Ok(port) => {
                self.ports.insert(port_name, port);
                true
            }
            Err(e) => {
                self.last_error = Some(e.to_string());
                false
            }
        }
    }

    #[func]
    fn close_port(&mut self, port_name: String) {
        self.ports.remove(&port_name);
    }

    #[func]
    fn set_baud_rate(&mut self, baud: i64) {
        self.baud_rate = baud as u32;
    }
    #[func]
    fn set_data_bits(&mut self, bits: i64) {
        self.data_bits = match bits {
            5 => DataBits::Five,
            6 => DataBits::Six,
            7 => DataBits::Seven,
            _ => DataBits::Eight,
        };
    }
    #[func]
    fn set_parity(&mut self, parity: i64) {
        self.parity = match parity {
            1 => Parity::Odd,
            2 => Parity::Even,
            _ => Parity::None,
        };
    }
    #[func]
    fn set_stop_bits(&mut self, stop: i64) {
        self.stop_bits = match stop {
            2 => StopBits::Two,
            _ => StopBits::One,
        };
    }
    #[func]
    fn set_flow_control(&mut self, flow: i64) {
        self.flow_control = match flow {
            1 => FlowControl::Software,
            2 => FlowControl::Hardware,
            _ => FlowControl::None,
        };
    }
    #[func]
    fn set_timeout(&mut self, ms: i64) {
        self.timeout = ms as u64;
    }

    #[func]
    fn write_bytes(&mut self, port_name: String, data: PackedByteArray) -> i64 {
        if let Some(port) = self.ports.get_mut(&port_name) {
            let buf = data.to_vec();
            match port.write(&buf) {
                Ok(n) => n as i64,
                Err(e) => {
                    self.last_error = Some(e.to_string());
                    -1
                }
            }
        } else {
            -1
        }
    }

    #[func]
    fn write_string(&mut self, port_name: String, text: String) -> i64 {
        self.write_bytes(port_name, PackedByteArray::from(text.as_bytes()))
    }

    #[func]
    fn read_bytes(&mut self, port_name: String, size: i64) -> PackedByteArray {
        let mut arr = PackedByteArray::new();
        if let Some(port) = self.ports.get_mut(&port_name) {
            let mut buf = vec![0u8; size as usize];
            match port.read(&mut buf) {
                Ok(n) => arr.extend_array(&PackedByteArray::from(&buf[..n])),
                Err(e) => self.last_error = Some(e.to_string()),
            }
        }
        arr
    }

    #[func]
    fn read_string(&mut self, port_name: String, size: i64) -> String {
        let arr = self.read_bytes(port_name, size);
        String::from_utf8_lossy(&arr.to_vec()).to_string()
    }

    #[func]
    fn get_last_error(&self) -> String {
        self.last_error.clone().unwrap_or_default()
    }

    #[func]
    fn bytes_to_read(&mut self, port_name: String) -> i64 {
        if let Some(port) = self.ports.get_mut(&port_name) {
            match port.bytes_to_read() {
                Ok(n) => n as i64,
                Err(e) => {
                    self.last_error = Some(e.to_string());
                    -1
                }
            }
        } else {
            -1
        }
    }

    #[func]
    fn bytes_to_write(&mut self, port_name: String) -> i64 {
        if let Some(port) = self.ports.get_mut(&port_name) {
            match port.bytes_to_write() {
                Ok(n) => n as i64,
                Err(e) => {
                    self.last_error = Some(e.to_string());
                    -1
                }
            }
        } else {
            -1
        }
    }

    #[func]
    fn clear_input_buffer(&mut self, port_name: String) -> bool {
        if let Some(port) = self.ports.get_mut(&port_name) {
            match port.clear(ClearBuffer::Input) {
                Ok(_) => true,
                Err(e) => {
                    self.last_error = Some(e.to_string());
                    false
                }
            }
        } else {
            false
        }
    }

    #[func]
    fn clear_output_buffer(&mut self, port_name: String) -> bool {
        if let Some(port) = self.ports.get_mut(&port_name) {
            match port.clear(ClearBuffer::Output) {
                Ok(_) => true,
                Err(e) => {
                    self.last_error = Some(e.to_string());
                    false
                }
            }
        } else {
            false
        }
    }

    #[func]
    fn clear_all_buffer(&mut self, port_name: String) -> bool {
        if let Some(port) = self.ports.get_mut(&port_name) {
            match port.clear(ClearBuffer::All) {
                Ok(_) => true,
                Err(e) => {
                    self.last_error = Some(e.to_string());
                    false
                }
            }
        } else {
            false
        }
    }

    #[func]
    fn flush(&mut self, port_name: String) -> bool {
        if let Some(port) = self.ports.get_mut(&port_name) {
            match port.flush() {
                Ok(_) => true,
                Err(e) => {
                    self.last_error = Some(e.to_string());
                    false
                }
            }
        } else {
            false
        }
    }

    #[func]
    fn get_baud_rate(&self) -> i64 {
        self.baud_rate as i64
    }

    #[func]
    fn get_data_bits(&self) -> i64 {
        match self.data_bits {
            DataBits::Five => 5,
            DataBits::Six => 6,
            DataBits::Seven => 7,
            DataBits::Eight => 8,
        }
    }

    #[func]
    fn get_parity(&self) -> i64 {
        match self.parity {
            Parity::Odd => 1,
            Parity::Even => 2,
            Parity::None => 0,
        }
    }

    #[func]
    fn get_stop_bits(&self) -> i64 {
        match self.stop_bits {
            StopBits::Two => 2,
            StopBits::One => 1,
        }
    }

    #[func]
    fn get_flow_control(&self) -> i64 {
        match self.flow_control {
            FlowControl::Software => 1,
            FlowControl::Hardware => 2,
            FlowControl::None => 0,
        }
    }

    #[func]
    fn get_timeout(&self) -> i64 {
        self.timeout as i64
    }
}