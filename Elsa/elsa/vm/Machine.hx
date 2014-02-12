package elsa.vm;

import haxe.ds.GenericStack;
import haxe.ds.Vector;

class Machine {
	public var stack: GenericStack<Data>;
	public var register: Vector<Data>;
	public var memory: Vector<Data>;
	public var program: Array<Instruction>;
	public var pointer: Int;
	public var registerSize: Int;
	public var memorySize: Int;
	public function new(memorySize: Int, registerSize: Int) {
		this.memorySize = memorySize;
		this.registerSize = registerSize;
	}
	public function load(code: String) {
		stack = new GenericStack<Data>();
		register = new Vector<Data>(registerSize);
		memory = new Vector<Data>(memorySize);
		program = parse(code);
	}
	public function parse(code: String): Array<Instruction> {
		return []; // TODO
	}
	public function run() {
		// TODO
	}
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
