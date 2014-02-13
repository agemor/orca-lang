package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 인스턴스 생성 구문 패턴
 * 
 * 형식: new A;
 * 
 * @author 김 현준
 */
class InstanceCreationSyntax implements Syntax {

	public var instanceType:Token;
	
	public function new(instanceType:Token) {
		this.instanceType = instanceType;
	}
	
	/**
	 * 토큰열이 인스턴스 생성 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		
		if (tokens.length != 2)
			return false;

		// 토큰의 첫 원소가 new여야 한다.
		if (tokens[0].type != Type.NEW)
			return false;

		// 토큰의 두 번째 원소가 id여야 한다.
		if (tokens[1].type != Type.ID)
			return false;

		return true;
	}
	
	/**
	 * 토큰열을 분석하여 인스턴스 생성 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):InstanceCreationSyntax {

		// 생성자의 길이는 2이다.
		if (tokens.length != 2) {
			Debug.report("구문 오류", "인스턴스 생성문의 끝에 불필요한 추가 문자가 있습니다.", lineNumber);
			return null;
		}

		return new InstanceCreationSyntax(tokens[1]);
	}
}