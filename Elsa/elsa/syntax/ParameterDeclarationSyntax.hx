package elsa.syntax;
import elsa.Token;

/**
 * 파라미터 선언문 구문 패턴
 * 
 * 형식: v:T
 * 
 * @author 김 현준
 */
class ParameterDeclarationSyntax implements Syntax {

	public var parameterName:Token;
	public var parameterType:Token;
	
	public function new(parameterName:Token, parameterType:Token) {
		this.parameterName = parameterName;
		this.parameterType = parameterType;
	}	
	
	/**
	 * 토큰열이 파라미터 선언문 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {
		if (tokens.length == 3)
			if (tokens[0].type == Token.Type.ID && tokens[1].type == Token.Type.COLON &&tokens[2].type == Token.Type.ID)
				return true;
		return false;
	}
	
	/**
	 * 토큰열을 분석하여 파라미터 선언문 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):ParameterDeclarationSyntax {
		return new ParameterDeclarationSyntax(tokens[0], tokens[2]);
	}
}