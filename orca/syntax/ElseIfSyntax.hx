package orca.syntax;

import orca.Token;
import orca.TokenTools;
import orca.debug.Debug;

/**
 * 조건문 구문 패턴
 * 
 * 형식: elif( C )
 * 
 * @author 김 현준
 */
class ElseIfSyntax implements Syntax {

	public var condition:Array<Token>;
	
	public function new(condition:Array<Token>) {
		this.condition = condition;
	}	
	
	/**
	 * 토큰열이 조건문 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length > 1 && tokens[0].type == Type.Else && tokens[1].type == Type.If)
			return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 조건문 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):ElseIfSyntax {
		
		// 미완성된 제어문의 경우
		if (tokens.length < 5) {
			Debug.reportError("Syntax error", "Else - If syntax is not valid", lineNumber);
			return null;
		}

		// 괄호로 시작하는지 확인한다
		if (tokens[2].type != Type.ShellOpen) {
			Debug.reportError("Syntax error", "Condition must start with \"(\"", lineNumber);
			return null;
		}

		// 괄호로 끝나는지 확인한다.
		if (tokens[tokens.length - 1].type != Type.ShellClose) {
			Debug.reportError("Syntax error", "insert \")\" to complete Expression", lineNumber);
			return null;
		}

		return new ElseIfSyntax(tokens.slice(3, tokens.length - 1));
	}
}