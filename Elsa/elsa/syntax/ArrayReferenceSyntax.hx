package elsa.syntax;

import elsa.Token;
import elsa.TokenTools;
import elsa.debug.Debug;

/**
 * 배열 참조 구문 패턴
 * 
 * 형식: A[B][C][D]...[Z]
 * 
 * @author 김 현준
 */
class ArrayReferenceSyntax implements Syntax {

	public var array:Token;
	public var references:Array<Array<Token>>;

	public function new(array:Token, references:Array<Array<Token>>) {
		this.array = array;
		this.references = references;
	}

	/**
	 * 토큰열이 배열 참조 구문 패턴과 일치하는지 확인한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function match(tokens:Array<Token>):Bool {

		var indexOfLPO:Int = TokenTools.indexOfLPO(tokens);

		if (indexOfLPO < 0)
			return false;

		if (tokens[indexOfLPO].type != Token.Type.ARRAY_OPEN)
			return false;
			
		return true;
	}

	/**
	 * 토큰열을 분석하여 배열 구문 요소를 추출한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public static function analyze(tokens:Array<Token>, lineNumber:Int):ArraySyntax {

		var depth:Int = 0;
		var seperations:Array<Int> = new Array<Int>();

		for ( i in 0...tokens.length) { 
			if (tokens[i].type == Token.Type.ARRAY_OPEN) {
				if (depth == 0)
					seperations.add(i);
				depth++;
			}

			else if (tokens[i].type == Token.Type.ARRAY_CLOSE) {
				if (depth == 1)
					seperations.add(i);
				depth--;
			}
		}

		if (depth > 0) {
			Debug.report("구문 오류", "괄호가 완전히 닫히지 않았습니다.", lineNumber);			
			return null;
		}

		if (depth < 0) {
			Debug.report("구문 오류", "잉여 괄호 닫기 문자가 있습니다.", lineNumber);	
			return null;
		}

		// 대상 변수의 타입이 ID가 아닐 경우 에러 발생
		if (tokens[0].type != Token.Type.ID) {
			Debug.report("구문 오류", "유효하지 않은 배열입니다.", lineNumber);	
			return null;
		}

		// 배열의 인덱스 배열이 저장될 공간
		var references:Array<Array<Token>> = new Array<Array<Token>>();

		var indexCount:Int = 0;
		var indexStart:Int = 0;

		// 데이터를 뽑아 낸다
		for ( i in 0...seperations.length ) { 
			if (i % 2 == 0)
				indexStart = seperations[i] + 1;
			else
				references[indexCount++] = tokens.slice(indexStart, seperations[i]);
		}

		// 레퍼런스를 리턴한다.
		return new ArrayReferenceSyntax(tokens[0], references);
	}
}