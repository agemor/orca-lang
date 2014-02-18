package elsa.vm;
import elsa.syntax.ArrayReferenceSyntax;
import elsa.vm.Orcinus.Instruction;

/**
 * Orcinus Advanced Orca Virtual Machine
 * 
 * @author 김 현준
 */
class Orcinus {
	
	/**
	 * VM 환경 변수
	 */
	public var maximumStackSize:Int = 1024 * 20;
	
	/**
	 * 시스템 메모리와 레지스터
	 */
	public var memory:Array<Dynamic>;
	public var register:Array<Dynamic>;
	private var freeMemoryIndex:Int;
	
	/**
	 * 시스템 스택
	 */
	public var systemStack:Array<Dynamic>;
	public var callStack:Array<Int>;
	
	/**
	 * 프로그램
	 */
	public var program:Array<Instruction>;
	public var pointer:Int;
	
	/**
	 * VM 상태
	 */
	public var status:Status;
	
	/**
	 * 올시너스 머신 초기화
	 */
	public function new(maximumStackSize:Int = 1024 * 20) {		
		status = Status.IDLE;		
		this.maximumStackSize = maximumStackSize;
	}
	
	/**
	 * 올시너스 머신에 어셈블리를 로드한다.
	 */
	public function load(assembly:String):Void {
		
		// 시스템 초기화
		memory = new Array<Dynamic>();
		register = new Array<Dynamic>();		
		systemStack = new Array<Dynamic>();
		callStack = new Array<Int>();
		
		// 어셈블리를 캐시한다.
		program = parseAssembly(assembly);
		memory[freeMemoryIndex] = 0;
		
		pointer = 0;
		
		status = Status.LOADED;
	}
	
	public function run():Void {
		
		if (status != Status.LOADED) return;		
		status = Status.RUNNING;
		
		while (true) {
			var opcode:Instruction = program[pointer];			
			
			switch(opcode.id) {
				
				// 스택에서 값을 꺼내 레지스터에 저장한다.
				case "POP":					
					if (opcode.args.length > 1)
						register[parseIndicator(opcode.args[0])] = callStack.pop();	
					else
						register[parseIndicator(opcode.args[0])] = systemStack.pop();	
					
				// 값을 스택으로 밀어 넣는다.	
				case "PSH":
					if (opcode.args.length > 1)
						callStack.push(parseValue(opcode.args[0]));
					else
						systemStack.push(parseValue(opcode.args[0]));
					
				// 연산 처리	
				case "OPR":
					// 변수명 할당을 위한 인위적 스코프
					if (true) {
						var output:Int = parseIndicator(opcode.args[0]);
						var operator:Int = parseInt(parseValue(opcode.args[1]));
						
						// 양 항을 취득
						var left:Dynamic = parseValue(opcode.args[2]);
						var right:Dynamic = opcode.args.length > 3 ? parseValue(opcode.args[3]) : null;
						
						// 연산 처리할 수 없는 값이라면
						/*if (!((Std.is(left, Float) || Std.is(left, String)) && (Std.is(right, Float) || Std.is(right, String)))) {
							trace("Cannot calculate null.");
							pointer++;
							continue;
						}*/
						
						switch(operator) {
							case 1: register[output] = left + right;
							case 2:	register[output] = left - right;
							case 3:	register[output] = left / right;	
							case 4:	register[output] = left * right;
							case 5:	register[output] = left % right;
							case 6: register[output] = left & right;
							case 7: register[output] = left | right;
							case 8: register[output] = left ^ right;
							case 9: register[output] = ~ left;
							case 10: register[output] = left << right;
							case 11: register[output] = left >> right;
							case 12: register[output] = (left == right ? 1 : 0);
							case 13: register[output] = (left != right ? 1 : 0);
							case 14: register[output] = (left > right ? 1 : 0);
							case 15: register[output] = (left >= right ? 1 : 0);
							case 16: register[output] = (left < right ? 1 : 0);
							case 17: register[output] = (left <= right ? 1 : 0);
							case 18: register[output] = (left + right > 1 ? 1 : 0);
							case 19: register[output] = (left + right > 0 ? 1 : 0);
							case 20: register[output] = (left < 1 ? 1 : 0);
							case 21: register[output] = Std.string(left) + Std.string(right);
							case 22: register[output] = Std.parseFloat(left);
							case 23: register[output] = Std.string(left);
							case 24: register[output] = getRuntimeValue(left, parseInt(right));
							case 25: register[output] = -left;
							case 26: register[output] = Std.string(left).charAt(parseInt(right));
						}						
					}				
					
				// 배열 읽기	
				case "ESI":
					if (true) {						
						var output:Int = parseIndicator(opcode.args[0]);
						var array:Array<Dynamic> = cast(parseValue(opcode.args[1]), Array<Dynamic>);  						
						var arrayIndex:Int = parseInt(parseValue(opcode.args[2]));
						
						// 레지스터에 할당
						register[output] = array[arrayIndex];
					}
				
				// 배열 쓰기	
				case "EAD":
					if (true) {
						var array:Array<Dynamic> = cast(parseValue(opcode.args[0]), Array<Dynamic>);  
						var arrayIndex:Int = parseInt(parseValue(opcode.args[1]));
						var element:Dynamic = parseValue(opcode.args[2]);
						
						// 배열 인덱스에 할당
						array[arrayIndex] = element;
					}
				
				// 실수형 데이터 직접 대입	
				case "NDW":
					if (true) {
						var targetAddress:Int = parseInt(parseValue(opcode.args[0]));
						var data:Float = Std.parseFloat(Std.string(parseValue(opcode.args[1])));
						
						memory[targetAddress] = data;
					}
				
				// 문자형 데이터 직접 대입	
				case "SDW":
					if (true) {
						var targetAddress:Int = parseInt(parseValue(opcode.args[0]));
						var data:String = Std.string(parseValue(opcode.args[1]));
						
						memory[targetAddress] = data;
					}
				
				// 참조 데이터 직접 대입	
				case "RDW":
					if (true) {
						var targetAddress:Int = parseInt(parseValue(opcode.args[0]));
						var data:Dynamic = parseValue(opcode.args[1]);
						
						memory[targetAddress] = data;
					}
				
				// 포인터 점프	
				case "JMP":
					if (true) {

						// 판단 플래그 취득
						var judgement:Int = parseInt(parseValue(opcode.args[0]));
						var destination:Int = parseInt(parseValue(opcode.args[1]));

						// 포인터 수정
						if (judgement == 0) {
							pointer = destination;
							continue;
						}
					}
				
				// 동적 문자열 할당	
				case "DSA":
					if (true) {
						var output:Int = parseIndicator(opcode.args[0]);

						memory.push("");
						register[output] = memory.length - 1;
					}
				
				// 동적 실수형 할당	
				case "DNA":
					if (true) {
						var output:Int = parseIndicator(opcode.args[0]);

						memory.push(0);
						register[output] = memory.length - 1;
					}
					
				// 동적 배열 할당	
				case "DAA":
					if (true) {
						var output:Int = parseIndicator(opcode.args[0]);
						memory.push(new Array<Dynamic>());
						register[output] = memory.length - 1;
					}
					
				// 동적 문자열 할당	
				case "SSA":
					if (true) {
						var address:Int = parseInt(parseValue(opcode.args[0]));
						memory[address] = "";
					}
					
				// 동적 실수형 할당	
				case "SNA":
					if (true) {
						var address:Int = parseInt(parseValue(opcode.args[0]));
						memory[address] = 0;
					}
					
				// 동적 배열 할당	
				case "SAA":
					if (true) {
						var address:Int = parseInt(parseValue(opcode.args[0]));
						memory[address] = new Array<Dynamic>();
					}
					
				// 리턴값이 있는 외부 명령 실행	
				case "EXR":
					if (true) {
						var output:Int = parseIndicator(opcode.args[0]);
						var command:String = Std.string(parseValue(opcode.args[1]));						
						var returnValue:Dynamic = null;						
						
						switch (command) {
							case "abs": returnValue = OrcinusAPI.abs(cast(parseValue(opcode.args[1]), Float));
							case "acos": returnValue = OrcinusAPI.acos(cast(parseValue(opcode.args[1]), Float));
							case "asin": returnValue = OrcinusAPI.asin(cast(parseValue(opcode.args[1]), Float));
							case "atan": returnValue = OrcinusAPI.atan(cast(parseValue(opcode.args[1]), Float));
							case "atan2": returnValue = OrcinusAPI.atan2(cast(parseValue(opcode.args[1]), Float), cast(parseValue(opcode.args[2]), Float));
							case "ceil": returnValue = OrcinusAPI.ceil(cast(parseValue(opcode.args[1]), Float));
							case "floor": returnValue = OrcinusAPI.floor(cast(parseValue(opcode.args[1]), Float));
							case "round": returnValue = OrcinusAPI.round(cast(parseValue(opcode.args[1]), Float));
							case "cos": returnValue = OrcinusAPI.cos(cast(parseValue(opcode.args[1]), Float));
							case "sin": returnValue = OrcinusAPI.sin(cast(parseValue(opcode.args[1]), Float));
							case "tan": returnValue = OrcinusAPI.tan(cast(parseValue(opcode.args[1]), Float));
							case "log": returnValue = OrcinusAPI.log(cast(parseValue(opcode.args[1]), Float));
							case "sqrt": returnValue = OrcinusAPI.sqrt(cast(parseValue(opcode.args[1]), Float));
							case "pow": returnValue = OrcinusAPI.pow(cast(parseValue(opcode.args[1]), Float), cast(parseValue(opcode.args[2]), Float));
							case "exp": returnValue = OrcinusAPI.exp(cast(parseValue(opcode.args[1]), Float));
							case "random": returnValue = OrcinusAPI.random();
						}
						
						register[output] = returnValue;
					}
					
				// 리턴값이 없는 외부 명령 실행	
				case "EXE":
					if (true) {
						var command:String = Std.string(parseValue(opcode.args[0]));
						
						switch (command) {
							case "print": OrcinusAPI.print(parseValue(opcode.args[1]));
							case "whoami": OrcinusAPI.whoAmI();
						}
						
					}
					
				// 프로그램 종료	
				case "END":
					break;
					
				// 정의되지 않은 명령	
				default:
					trace("Undefined opcode error.");
					break;
			}
			
			pointer ++;
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
		}
		return null;
	}
	
	private function parseInt(value:Dynamic):Int {
		return Std.parseInt(Std.string(value));
	}
	
	/**
	 * 레지스터 표지 데이터의 실제 값을 구한다.
	 * 
	 * @param	code
	 * @return
	 */
	private function parseValue(code:String):Dynamic {
		
		// 레지스터 표지라면 레지스터를 깐 후 리턴한다.
		if (code.charAt(0) == "&") {
			return register[Std.parseInt(code.substring(1))];
		}
		
		// 메모리 값 읽기
		else if (code.charAt(0) == "@") {
			if (code.charAt(1) == "&") {
				return memory[parseInt(parseValue(code.substring(1)))];
			} else
				return memory[Std.parseInt(code.substring(1))];
		}
		
		// VM 상태 변수
		else if (code.charAt(0) == "$") {
			switch(code.substring(1)) {
				case "0": return pointer + 2;
				case "1": return 0;
			}
		}
		
		return code;
	}
	
	/**
	 * 레지스터 표지 데이터를 실제 값 표지로 파싱한다.
	 * 
	 * @param	code
	 * @return
	 */
	private function parseIndicator(code:String):Int {
		
		// 레지스터 표지라면 레지스터를 깐 후 재처리한다.
		if (code.charAt(0) == "&") {
			return parseIndicator(Std.string(register[Std.parseInt(code.substring(1))]));
		}

		// 데이터가 메모리주소 참조이면 메모리 주소를 깐 후 리턴한다.
		else if (code.charAt(0) == "@") {
			return parseIndicator(Std.string(memory[Std.parseInt(code.substring(1))]));
		}

		// 그 외의 경우 파싱하여 리턴한다.
		else {
			return Std.parseInt(code);
		}
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
		var instructionNumber:Int = 0;

		// 메타데이터를 읽는다.
		freeMemoryIndex = Std.parseInt(lines[0]);
		
		for ( i in 1...lines.length) { 

			var line:String = lines[i];
			
			// 명령의 ID를 취득한다.
			var instructionID:String = line.substring(0, 3);

			// 단문형 명령이라면 매개변수를 파싱하지 않는다.
			if (line.length < 4) {
				instructions.push(new Instruction(instructionID));
				continue;
			}

			// 명령의 매개 변수를 취득한다.
			var args:Array<String> = line.substring(4).split(",");

			// 각각의 매개변수를 trim한다.
			for ( i in 0...args.length) {
				args[i] = StringTools.trim(args[i]);
				if (args[i].indexOf("/") >= 0)
					args[i] = args[i].split("/")[1];
			}

			// 명령 객체를 생성한다.
			instructions.push(new Instruction(instructionID, args));
		}

		return instructions;
	}
	
}

enum Status {
	IDLE; LOADED; RUNNING;
}

class Instruction {
	
	public var id:String;
	public var args:Array<String>;
	
	public function new(id:String, args:Array<String> = null) {
		this.id = id;
		this.args = args;
	}
}