package elsa;

/**
 * 어셈블리 코드 최적화 클래스
 * 
 * @author 김 현준
 */
class Optimizer {

	/**
	 * 플래그 맵
	 */
	public var flags:Map<Int, Int>;
	
	public function new() { }
	
	/**
	 * 어셈블리 코드에 대해 최적화 작업을 수행한다.
	 * 
	 * @param code
	 * @return
	 */
	public function optimize(code:String):String {

		flags = new Map<Int, Int>();

		// 줄 바꿈 문자로 코드를 분할한다.
		var lines:Array<String> = code.split("\n");

		// 점프문의 위치
		var jumps:Array<Int> = new Array<Int>();

		var totalLines:Int = 0;

		// 플래그를 쭉 스캔한다.
		for (i in 0...lines.length) {

			// 빈 라인이라면 넘어가기
			if (lines[i].length < 1)
				continue;
			if (lines[i].length < 5) {
				totalLines++;
				continue;
			}
			// 라벨 플래그 생성이라면
			if (lines[i].substring(0, 5) == "FLG %")
				flags.set(Std.parseInt(lines[i].substring(5)), totalLines);
			else
				totalLines++;

			// 점프문이라면
			if (lines[i].substring(0, 3) == "JMP")
				jumps.push(i);
		}

		// JUMP 명령에 있는 플래그를 모두 치환한다.
		for (i in 0...jumps.length) { 

			var jump:String = lines[jumps[i]];

			// 플래그가 없는 JUMP 명령은 무시한다.
			if (jump.indexOf("%") < 0)
				continue;

			// 플래그 라인 넘버를 취득한다.
			var lineNumber:Int = flags.get(Std.parseInt(jump.substring(jump.indexOf("%") + 1)));

			// 플래그를 라인 넘버로 치환한다.
			lines[jumps[i]] = jump.substring(0, jump.indexOf("%")) + Std.string(lineNumber);

		}

		var buffer:String = "";

		// 새 명령을 반환한다.
		for (i in 0...lines.length) { 
			if (lines[i].length < 1)
				continue;
			if (lines[i].substring(0, 3) != "FLG")
				buffer += lines[i] + "\n";
		}

		return buffer;
	}
	
}