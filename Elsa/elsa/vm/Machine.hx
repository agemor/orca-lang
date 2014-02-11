package elsa.vm;

class Machine {
	// TODO
}

class Data {
	public var isReference: Bool;
	public var isRegistry: Bool;
	public var data (default, set): Dynamic;
	public function new(data: Dynamic) {
		this.data = data;
	}
	public function set_data(value: Dynamic) {
		data = value;
		isReference = Type.getClass(data) == Data;
		isRegistry = Type.getClass(data) == String &&
					data.length > 0 && data.charAt(0) == "@";
		return data;
	}
}

class Instruction {
	public var id: String;
	public var args: Array<String>;
	public function new(id: String, args: Array<String>) {
		this.id = id;
		this.args = args;
	}
}
