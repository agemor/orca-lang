package elsa.vm;
import elsa.vm.Beluga.Instruction;
import elsa.vm.Beluga.Memory;

/**
 * Beluga Advanced Orca Virtual Machine
 * 
 * @author 김 현준
 */
class Beluga {
	
	private static var opcode:Map <String, Int> = [ "PSH" => 0x1,
												   "PSR" => 0x2,
												   "PSM" => 0x3,
			  									   "POP" => 0x4,
	  											   "OPR" => 0x5,
		  										   "JMP" => 0x6,
												   "JMF" => 0x7,
												   "IVK" => 0x8,
												   "SAL" => 0x9,
												   "SAA" => 0xA,
												   "DAL" => 0xB,
												   "DAA" => 0xC,
												   "STO" => 0xD,
												   "STA" => 0xE,
												   "FRE" => 0xF,
												   "RDA" => 0x10,
												   "PSC" => 0x11,
												   "MOC" => 0x12,
												   "END" => 0x13];
												   
	private static var undefined:String = "undefined";
	
	/**
	 * VM 환경 변수
	 */
	public var maximumStackSize:Int = 1024 * 20;
	public var dynamicMemoryIndex:Int;
	
	/**
	 * 시스템 레지스터, 스택
	 */
	public var memory:Memory;
	public var register:Array<Dynamic>;
	public var mainStack:Array<Dynamic>;
	public var callStack:Array<Int>;
	
	/**
	 * 프로그램
	 */
	public var program:Array<Instruction>;
	public var pointer:Int;
	
	/**
	 * 벨루가 머신 초기화
	 */
	public function new(maximumStackSize:Int = 1024 * 20) {			
		this.maximumStackSize = maximumStackSize;
	}
	
	/**
	 * 벨루가 머신에 어셈블리를 로드한다.
	 */
	public function load(assembly:String):Void {
		
		// 어셈블리를 캐시한다.
		program = parseAssembly(assembly);
		
		// 시스템 초기화
		memory = new Memory(dynamicMemoryIndex);
		register = new Array<Dynamic>();		
		mainStack = new Array<Dynamic>();
		callStack = new Array<Int>();
		
		pointer = 0;
	}
	
	public function run():Void {		
		while (true) {
			var inst:Instruction = program[pointer];			
			
			switch(inst.opcode) {				
				// PSH
				case 1: mainStack.push(inst.arg);					
				// PSR	
				case 2: mainStack.push(register[inst.intArg]);					
				// PSM	
				case 3:	mainStack.push(memory.read(inst.intArg));					
				// POP	
				case 4: register[inst.intArg] = mainStack.pop();					
				// OPR	
				case 5: mainStack.push(operate(inst.intArg));					
				// JMP	
				case 6: pointer = cast(mainStack.pop(), Int);					
				// JMF	
				case 7: if (mainStack.pop() < 0) pointer = cast(mainStack.pop(), Int);
						else mainStack.pop();	
				// IVK	
				case 8: invoke(inst.intArg);					
				// SAL	
				case 9:	memory.allocate(undefined, inst.intArg);
				// SAA	
				case 10: memory.allocate(new Array<Dynamic>(), inst.intArg);
				// DAL
				case 11: mainStack.push(memory.allocate(undefined));			
				// DAA	
				case 12: mainStack.push(memory.read(memory.allocate(new Array<Dynamic>())));
				// STO	
				case 13: memory.write(cast(mainStack.pop(), Int), mainStack.pop());
				// STA	
				case 14: memory.writeArray(cast(mainStack.pop(), Int), cast(mainStack.pop(), Int), mainStack.pop());
				// FRE
				case 15: memory.free(inst.intArg);
				// RDA	
				case 16: mainStack.push(memory.readArray(cast(mainStack.pop(), Int), cast(mainStack.pop(), Int)));
				// PSC	
				case 17: callStack.push(pointer + 2);
				// MOC	
				case 18: mainStack.push(callStack.pop());				
				// END	
				case 19: break;					
				// 정의되지 않은 명령	
				default: trace("Undefined opcode error."); break;					
			}
			pointer ++;
		}		
	}	
	
	
	private function operate(oprcode:Int):Dynamic {
		
		var n1:Dynamic;
		var n2:Dynamic;
		var n3:Dynamic;	
		var n1Int:Int;
		var n2Int:Int;
		var n1Array:Array<Dynamic>;
		
		switch(oprcode) {
			case 1:
				n1 = mainStack.pop();
			case 1:
				n2 = mainStack.pop(); n1 = mainStack.pop();
			case 1:
				n2 = mainStack.pop(); n1Int = cast(mainStack.pop(), Int);
			case 1:
				n3 = mainStack.pop(); n2Int = cast(mainStack.pop(), Int); n1Array = cast(mainStack.pop(), Array<Dynamic>);
		}
		
		switch(oprcode) {
			case 1: return n1 + n2;
			case 1:	return n1 - n2;
			case 1:	return n1 / n2;	
			case 1:	return n1 * n2;
			case 1:	return n1 % n2;
			case 1: return n1 & n2;
			case 1: return n1 | n2;
			case 1: return n1 ^ n2;
			case 1: return ~ n1;
			case 1: return n1 << n2;
			case 1: return n1 >> n2;
			case 1: return Std.string(n1) + Std.string(n2);
			case 1: return memory.write(n1Int, n2);
			case 1: return memory.write(n1Int, memory.read(n1Int) + n2);
			case 1: return memory.write(n1Int, memory.read(n1Int) - n2);
			case 1: return memory.write(n1Int, memory.read(n1Int) / n2);
			case 1:	return memory.write(n1Int, memory.read(n1Int) * n2);
			case 1: return memory.write(n1Int, memory.read(n1Int) % n2);
			case 1: return memory.write(n1Int, memory.read(n1Int) & n2);
			case 1: return memory.write(n1Int, memory.read(n1Int) | n2);
			case 1: return memory.write(n1Int, memory.read(n1Int) ^ n2);
			case 1: return memory.write(n1Int, ~ memory.read(n1Int));
			case 1: return memory.write(n1Int, memory.read(n1Int) << n2);
			case 1: return memory.write(n1Int, memory.read(n1Int) >> n2);
			case 1: return memory.write(n1Int, Std.string(memory.read(n1Int)) + Std.string(n2));
			case 1: return n1Array[n2Int] = n3;			
			case 1: return n1Array[n2Int] = n1Array[n2Int] + n3;
			case 1: return n1Array[n2Int] = n1Array[n2Int] - n3;
			case 1: return n1Array[n2Int] = n1Array[n2Int] / n3;
			case 1:	return n1Array[n2Int] = n1Array[n2Int] * n3;
			case 1: return n1Array[n2Int] = n1Array[n2Int] % n3;
			case 1: return n1Array[n2Int] = n1Array[n2Int] & n3;
			case 1:	return n1Array[n2Int] = n1Array[n2Int] | n3;
			case 1:	return n1Array[n2Int] = n1Array[n2Int] ^ n3;
			case 1:	return n1Array[n2Int] = ~ n1Array[n2Int];
			case 1:	return n1Array[n2Int] = n1Array[n2Int] << n3;
			case 1:	return n1Array[n2Int] = n1Array[n2Int] >> n3;
			case 1:	return n1Array[n2Int] = Std.string(n1Array[n2Int]) + Std.string(n3);
			case 1: return (n1 == n2 ? 1 : 0);
			case 1: return (n1 != n2 ? 1 : 0);
			case 1: return (n1 > n2 ? 1 : 0);
			case 1: return (n1 >= n2 ? 1 : 0);
			case 1: return (n1 < n2 ? 1 : 0);
			case 1: return (n1 <= n2 ? 1 : 0);
			case 1: return (n1 + n2 > 1 ? 1 : 0);
			case 1: return (n1 + n2 > 0 ? 1 : 0);
			case 1: return (n1 < 1 ? 1 : 0);			
			case 1: return Std.parseFloat(n1);
			case 1: return Std.string(n1);
			case 1: return getRuntimeValue(n1, parseInt(n2));
			case 1: return -n1;
			case 1: return Std.string(n1).charAt(parseInt(n2));	
			case 1: return memory.read(parseInt(n1));
		}
		
		trace("Undefined oprcode error.");
		return null;
	}
	
	private function invoke(inkcode:Int):Void {
		switch(inkcode) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
			case 12:
			case 13:
			case 14:
			case 15:
			case 16:
			case 27:
				var array:Array<Dynamic> = memory.storage[cast(mainStack.pop(), Int)];
				array[array.length - 1] ++;
		}
		
		trace("Undefined inkcode error.");
	}
	
	private function getRuntimeValue(target:Dynamic, valueType:Int = 0):Dynamic {
		switch(valueType) {
			// 배열 길이
			case 0:
				return cast(target, Array<Dynamic>).length;
			// 문자열 길이	
			case 1:
				return cast(target, String).length;
			case 2:
				return cast(target, String).charCodeAt(0);
			case 3:
				var index:Int = parseInt(target);	
				return String.fromCharCode(index);
		}
		return null;
	}

	
	/**
	 * 어셈블리를 인스트럭션 배열로 파싱한다.
	 * 
	 * @param	assembly
	 * @return
	 */
	private function parseAssembly(assembly:String):Array<Instruction> {
		
		// 줄바꿈 문자로 어셈블리 코드를 구분한다.
		var lines:Array<String> = assembly.split("\n");

		var instructions:Array<Instruction> = new Array<Instruction>();

		// 메타데이터를 읽는다.
		dynamicMemoryIndex = Std.parseInt(lines[0]);
		
		for ( i in 1...lines.length) { 

			var line:String = lines[i];
			
			// 명령 식별자를 읽어 온다.
			var mnemonic:String = line.substring(0, 3);

			// 단문형 명령이라면 추가 바이트를 파싱하지 않는다.
			if (line.length < 4) {
				instructions.push(new Instruction(opcode.get(mnemonic)));
				continue;
			}
			
			var arg:Dynamic = null;
			
			// 명령의 종결 문자로 데이터 타입을 판단한다.
			switch(line.charAt(line.length - 1)) {				
				case "s":
					arg = line.substring(4, line.length - 1);
				default:
					arg = Std.parseFloat(StringTools.trim(line.substring(4)));
			}
			
			// 명령 객체를 생성한다.
			instructions.push(new Instruction(opcode.get(mnemonic), arg));
		}

		return instructions;
	}
}

/**
 * 어셈블리 인스트럭션
 */
class Instruction {
	
	public var opcode:Int;
	
	// 빠른 실행을 위해 미리 캐스팅
	public var intArg:Int;
	public var arg:Dynamic;
	
	public function new(opcode:Int, arg:Dynamic = null) {
		this.opcode = opcode;
		this.arg = arg;
		
		if (Std.is(arg, Int)) {
			intArg = cast(arg, Int);
		}
	}
}

/**
 * 가상 메모리 스토리지
 */
class Memory {
	
	public var dynamicMemoryIndex:Int;
	public var storage:Array<Array<Dynamic>>;
	
	public function new(dynamicMemoryIndex:Int) {
		storage = new Array<Array<Dynamic>>();	
		
		this.dynamicMemoryIndex = dynamicMemoryIndex;
		storage[dynamicMemoryIndex] = 0;
	}
	
	/**
	 * 메모리에 새 데이터를 할당한다.
	 * 
	 * @param	initValue
	 * @param	address
	 * @return
	 */
	public function allocate(initValue:Dynamic, address:Int = -1):Int {
		
		// 동적 할당이라면 스토리지의 끝에 메모리를 할당한다.
		if (address < 0) {
			storage.push(initValue);
			return storage.length - 1;
		}
		
		var memory:Array<Dynamic> = storage[address];
		
		// 스토리지가 없다면 생성해 준다.
		if (memory == null)
			storage[address] = new Array<Dynamic>();
			
		memory.push(initValue);
		
		return address;		
	}
	
	/**
	 * 데이터를 할당 해제한다.
	 * 
	 * @param	address
	 */
	public function free(address:Int):Void {
		var memory:Array<Dynamic> = storage[address];
		
		if (memory != null && memory.length > 0) {
			memory.pop();
		}
	}
	
	/**
	 * 메모리에 데이터를 쓴다.
	 * 
	 * @param	address
	 * @param	data
	 */
	public function write(address:Int, data:Dynamic):Dynamic {
		var memory:Array<Dynamic> = storage[address];
		
		memory[memory.length - 1] = data;
		return data;
	}
	
	/**
	 * 메모리에 배열 데이터를 쓴다.
	 * 
	 * @param	address
	 * @param	index
	 * @param	value
	 */
	public function writeArray(address:Int, index:Int, data:Dynamic):Dynamic {
		var array:Array<Dynamic> = cast(read(address), Array<Dynamic>);
		array[index] = data;	
		return data;
	}
	
	/**
	 * 메모리로부터 데이터를 읽어 온다.
	 * 
	 * @param	address
	 * @return
	 */
	public function read(address:Int):Dynamic {
		var memory:Array<Dynamic> = storage[address];
		
		return memory[memory.length - 1];
	}
	
	/**
	 * 메모리로부터 배열 데이터를 읽어 온다.
	 * 
	 * @param	address
	 * @param	index
	 * @return
	 */
	public function readArray(address:Int, index:Int):Dynamic {
		var array:Array<Dynamic> = cast(read(address), Array<Dynamic>);
		return array[index];
	}

}