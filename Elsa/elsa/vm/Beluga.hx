package elsa.vm;
import elsa.vm.Beluga;

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
			case 6: pointer = cast(mainStack.pop(), Int); continue;					
			// JMF	
			case 7:
				var condition:Dynamic = mainStack.pop();
				if (mainStack.pop() <= 0) {
					pointer = cast(condition, Int);
					continue;
				}
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
			case 14:			
				var targetArray:Array<Dynamic> = cast(mainStack.pop(), Array<Dynamic>);
				var targetIndex:Int = cast(mainStack.pop(), Int);				
				targetArray[targetIndex] = mainStack.pop();
			// FRE
			case 15: memory.free(inst.intArg);
			// RDA	
			case 16:
				var targetArray:Array<Dynamic> = cast(mainStack.pop(), Array<Dynamic>);
				var targetIndex:Int = cast(mainStack.pop(), Int);	
				mainStack.push(targetArray[targetIndex]);
			// PSC	
			case 17: callStack.push(pointer + 3);
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
		
		var n1:Dynamic = null;
		var n2:Dynamic = null;
		var n3:Dynamic = null;	
		var n1Int:Int = 0;
		var n2Array:Array<Dynamic> = null;
		
		switch(oprcode) {
			case 9, 10, 46, 47, 48:
				n1 = mainStack.pop();
			case 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 38, 39, 40, 41, 42, 43, 44, 45, 49, 50:
				n2 = mainStack.pop(); n1 = mainStack.pop();
			case 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25:
				n2 = mainStack.pop(); n1Int = cast(mainStack.pop(), Int);
			case 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37:
				n3 = mainStack.pop(); n2Array = cast(mainStack.pop(), Array<Dynamic>); n1Int = cast(mainStack.pop(), Int);
		}
		
		switch(oprcode) {
			case 1: return n1 + n2;
			case 2:	return n1 - n2;
			case 3:	return n1 / n2;
			case 4:	return n1 * n2;
			case 5:	return n1 % n2;
			case 6: return n1 & n2;
			case 7: return n1 | n2;
			case 8: return n1 ^ n2;
			case 9: return ~ n1;
			case 10: return - n1;
			case 11: return n1 << n2;
			case 12: return n1 >> n2;
			case 13: return Std.string(n1) + Std.string(n2);
			case 14: return memory.write(n1Int, n2);
			case 15: return memory.write(n1Int, memory.read(n1Int) + n2);
			case 16: return memory.write(n1Int, memory.read(n1Int) - n2);
			case 17: return memory.write(n1Int, memory.read(n1Int) / n2);
			case 18: return memory.write(n1Int, memory.read(n1Int) * n2);
			case 19: return memory.write(n1Int, memory.read(n1Int) % n2);
			case 20: return memory.write(n1Int, memory.read(n1Int) & n2);
			case 21: return memory.write(n1Int, memory.read(n1Int) | n2);
			case 22: return memory.write(n1Int, memory.read(n1Int) ^ n2);
			case 23: return memory.write(n1Int, memory.read(n1Int) << n2);
			case 24: return memory.write(n1Int, memory.read(n1Int) >> n2);
			case 25: return memory.write(n1Int, Std.string(memory.read(n1Int)) + Std.string(n2));
			case 26: return n2Array[n1Int] = n3;
			case 27: return n2Array[n1Int] = n2Array[n1Int] + n3;
			case 28: return n2Array[n1Int] = n2Array[n1Int] - n3;
			case 29: return n2Array[n1Int] = n2Array[n1Int] / n3;
			case 30: return n2Array[n1Int] = n2Array[n1Int] * n3;
			case 31: return n2Array[n1Int] = n2Array[n1Int] % n3;
			case 32: return n2Array[n1Int] = n2Array[n1Int] & n3;
			case 33: return n2Array[n1Int] = n2Array[n1Int] | n3;
			case 34: return n2Array[n1Int] = n2Array[n1Int] ^ n3;
			case 35: return n2Array[n1Int] = n2Array[n1Int] << n3;
			case 36: return n2Array[n1Int] = n2Array[n1Int] >> n3;
			case 37: return n2Array[n1Int] = Std.string(n2Array[n1Int]) + Std.string(n3);
			case 38: return (n1 == n2 ? 1 : 0);
			case 39: return (n1 != n2 ? 1 : 0);
			case 40: return (n1 > n2 ? 1 : 0);
			case 41: return (n1 >= n2 ? 1 : 0);
			case 42: return (n1 < n2 ? 1 : 0);
			case 43: return (n1 <= n2 ? 1 : 0);
			case 44: return (n1 + n2 > 1 ? 1 : 0);
			case 45: return (n1 + n2 > 0 ? 1 : 0);
			case 46: return (n1 < 1 ? 1 : 0);
			case 47: return Std.parseFloat(n1);
			case 48: return Std.string(n1);
			case 49: return Std.string(n1).charAt(cast(n2, Int));
			case 50: return getRuntimeValue(n1, cast(n2, Int));
		}
		
		trace("Undefined oprcode error.");
		return null;
	}
	
	private function invoke(inkcode:Int):Void {
		switch(inkcode) {
			case 1: trace(mainStack.pop());
			case 2: mainStack.push(Sys.stdin().readLine());
			case 3: trace("ORCA VM(BELUGA) UNSTABLE");
			case 4: mainStack.push(OrcinusAPI.abs(cast(mainStack.pop(), Float)));
			case 5: mainStack.push(OrcinusAPI.acos(cast(mainStack.pop(), Float)));
			case 6: mainStack.push(OrcinusAPI.asin(cast(mainStack.pop(), Float)));
			case 7: mainStack.push(OrcinusAPI.atan(cast(mainStack.pop(), Float)));
			case 8: mainStack.push(OrcinusAPI.atan2(cast(mainStack.pop(), Float), cast(mainStack.pop(), Float)));
			case 9: mainStack.push(OrcinusAPI.ceil(cast(mainStack.pop(), Float)));
			case 10: mainStack.push(OrcinusAPI.floor(cast(mainStack.pop(), Float)));
			case 11: mainStack.push(OrcinusAPI.round(cast(mainStack.pop(), Float)));
			case 12: mainStack.push(OrcinusAPI.cos(cast(mainStack.pop(), Float)));
			case 13: mainStack.push(OrcinusAPI.sin(cast(mainStack.pop(), Float)));
			case 14: mainStack.push(OrcinusAPI.tan(cast(mainStack.pop(), Float)));
			case 15: mainStack.push(OrcinusAPI.log(cast(mainStack.pop(), Float)));
			case 16: mainStack.push(OrcinusAPI.sqrt(cast(mainStack.pop(), Float)));
			case 17: mainStack.push(OrcinusAPI.pow(cast(mainStack.pop(), Float), cast(mainStack.pop(), Float)));
			case 18: mainStack.push(OrcinusAPI.random());
			case 27: 
				var counterAddr:Int = cast(mainStack.pop(), Int);
				var counterMem:Array<Dynamic> = memory.storage[counterAddr];
				counterMem[counterMem.length - 1] ++;
			default: trace("Undefined inkcode error.");
		}
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
				var index:Int = cast(target, Int);	
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
					var rawnum:String = StringTools.trim(line.substring(4));					
					if (rawnum.indexOf(".") > 0)
						arg = Std.parseFloat(rawnum);
					else					
						arg = Std.parseInt(rawnum);
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
	public var intArg:Int = 0;
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
		storage[dynamicMemoryIndex] = new Array<Dynamic>();
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
			storage.push([initValue]);
			return storage.length - 1;
		}
		// 스토리지가 없다면 생성해 준다.
		if (storage[address] == null)
			storage[address] = new Array<Dynamic>();
		
		var memory:Array<Dynamic> = storage[address];	
			
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
		return array[Std.int(index)];
	}

}