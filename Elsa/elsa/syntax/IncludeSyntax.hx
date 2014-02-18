package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 인클루드문 구문 패턴
 * 
 * 형식: include "code.orca";
 * 
 * @author 김 현준
 */
class IncludeSyntax implements Syntax {

	public var targetFile:String;
	
	public function new(targetFile:String) {
		this.targetFile = targetFile;
	}
	
	/**
	 * 토큰열이 인클루드문 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length < 1)
			return false;
		
		if (tokens[0].type != Type.Include) 
			return false;
		return true;
	}
	
	/**
	 * 토큰열을 분석하여 인클루드문 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):IncludeSyntax {		
		
		if (tokens.length != 2) {
			Debug.reportError("Syntax error", "Not valid include syntax", lineNumber);			
			return null;
		}
		
		if (tokens[1].type != Type.String) {
			Debug.reportError("Syntax error", "Include target must be string", lineNumber);			
			return null;
		}
		
		return new IncludeSyntax(tokens[1].value);
	}
	
}