package elsa.vm;

import haxe.ds.GenericStack;
import haxe.ds.Vector;

import elsa.debug.Debug;

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
		var instructions: Array<Instruction> = [];
		var lines = code.split("\n");
		var instructionNumber = 0;
		for (line in lines.iterator()) {
			var id = line.substring(0, 3);
			var args = if (line.length < 4) []
				else line.substring(4).split(",").map(function (argument) {
				return StringTools.trim(argument);
			});
			instructions[instructionNumber++] = new Instruction(id, args);
		}
		return instructions;
	}
	public function run() {
		pointer = 0;
		while (true) {
			var instruction = program[pointer];
			switch (instruction.id) {
			case "POP": register[getAddress(instruction.args[0])] = stack.pop();
			case "PSH":
				if (instruction.args[0].charAt(0) == "&")
					stack.add(getData(instruction.args[0]).clone());
				else
					stack.add(new Data(instruction.args[0]));
			case "EXE": switch (getStringValue(instruction.args[0])) {
				case "print": Debug.print(getStringValue(instruction.args[1]));
				case "whoami": Debug.print("ELSA VM unstable");
				}
			case "END": return;
			}
			++pointer;
		}
	}
	public function getData(data: String): Data {
		if (data.charAt(0) == "&") {
			var candidate = register[Std.parseInt(data.substring(1))];
			return if (candidate.isRegistry)
				getData(candidate.string.substring(1)) else candidate;
		}
		else {
			return memory[getAddress(data)];
		}
	}
	public function getAddress(data: String): Int {
		return switch (data.charAt(0)) {
		case "&": getAddress(register[Std.parseInt(data.substring(1))].string);
		case "@": Std.parseInt(data.substring(1));
		default: Std.parseInt(data);
		}
	}
	public function getStringValue(data: String): String {
		return if (data.length < 1) "" else switch (data.charAt(0)) {
		case "&": getStringValue(register[Std.parseInt(data.substring(1))].string);
		case "@": getStringValue(memory[Std.parseInt(data.substring(1))].string);
		default: data;
		}
	}
}

class Data {
	public var isReference: Bool;
	public var isRegistry: Bool;
	public var data (default, set): Dynamic;
	public var string (get, never): String;
	public function new(data: Dynamic) {
		this.data = data;
	}
	public function clone() {
		return new Data(data);
	}
	function set_data(value: Dynamic) {
		data = value;
		isReference = Type.getClass(data) == Data;
		isRegistry = Type.getClass(data) == String &&
					data.length > 0 && data.charAt(0) == "@";
		return data;
	}
	function get_string(): String {
		return if (isReference) data.string else Std.string(data);
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
