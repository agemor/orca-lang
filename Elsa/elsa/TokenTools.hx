package elsa;
import elsa.Token.Type;

/**
 * 토큰열 처리 관련 유틸
 * 
 * @author 김 현준
 */
class TokenTools {

	/**
	 * 토큰열에서 매개변수열을 취득한다.
	 * 
	 * @param	tokens
	 * @return
	 */
	public static function getArguments(tokens:Array<Token>):Array<Array<Token>> {
		return split(tokens, Token.Type.Comma, true);
	}
	
	/**
	 * 토큰열을 구분자를 기준으로 분리한다.
	 * 
	 * sensitive 플래그가 참일 경우, 소, 중괄호 뎁스가 모두 최상위일 경우에만 구분자를
	 * 분리한다.
	 * 
	 * @param tokens
	 * @param delimiter
	 * @param sensitive
	 * @return
	 */
	public static function split(tokens:Array<Token>, delimiter:Type, sensitive:Bool = false):Array<Array<Token>> {

		// 유효 범위 내에 있는 나열을 구한다.
		var i:Int = 0;
		var subscriptDepth:Int = 0;
		var shellDepth:Int = 0;		
		trace("aaaaaaaaaaaa");
		// 원소
		var elements:Array<Array<Token>> = new Array<Array<Token>>();
		var lastIndex = i - 1;
		var elementIndex:Int = 0;
		
		// 현재 스코프에서 유효한 매개변수 구분 문자를 찾는다.
		while (i < tokens.length) {
			if (tokens[i].type == Token.Type.ArrayOpen)
				subscriptDepth++;
			else if (tokens[i].type == Token.Type.ArrayClose)
				subscriptDepth--;
			else if (tokens[i].type == Token.Type.ShellOpen)
				shellDepth++;
			else if (tokens[i].type == Token.Type.ShellClose)
				shellDepth--;
			else if (tokens[i].type == delimiter && ((subscriptDepth == 0 && shellDepth == 0) || !sensitive)){				
				elements[elementIndex++] = tokens.slice(lastIndex + 1, i);
				lastIndex = i;
			}
			i++;
		}
		elements[elementIndex++] = (tokens.slice(lastIndex + 1, tokens.length)); 
		
		return elements;
	}
	
	/**
	 * 토큰을 껍데기가 둘러싸고 있을 경우 벗긴다.
	 * 
	 * @param tokens
	 * @return
	 */
	public static function pill(tokens:Array<Token>):Array<Token>  {
		if (tokens[0].type == Token.Type.ShellOpen)
			if (indexOfShellClose(tokens, 1) == tokens.length - 1)
				return tokens.slice(1, tokens.length - 1);
		return tokens;
	}
	
	/**
	 * 토큰열에서 주어진 토큰 타입의 인덱스를 찾는다.
	 * 
	 * @param tokens
	 * @param type
	 * @param start
	 * @return
	 */
	public static function indexOf(tokens:Array<Token>, type:Type, start:Int = 0):Int {
		for ( i in start...tokens.length)
			if (tokens[i].type == type)
				return i;
		return -1;
	}

	/**
	 * 유효한 껍데기 닫기 문자의 위치를 찾는다.
	 * 
	 * 단, 반드시 start는 첫 괄호의 인덱스보다 커야 한다.
	 * 
	 * @param tokens
	 * @param start
	 * @return
	 */
	public static function indexOfShellClose(tokens:Array<Token>, start:Int = 1):Int {
		return indexOfClose(tokens, Token.Type.ShellOpen, Token.Type.ShellClose, start);
	}

	/**
	 * 유효한 껍데기 닫기 문자의 위치를 찾는다.
	 * 
	 * 단, 반드시 start는 첫 괄호의 인덱스보다 커야 한다.
	 * 
	 * @param tokens
	 * @param start
	 * @return
	 */
	public static function indexOfArrayClose(tokens:Array<Token>, start:Int = 1):Int {
		return indexOfClose(tokens, Token.Type.ArrayOpen, Token.Type.ArrayClose, start);
	}
	
	/**
	 * 쌍이 있는 문자에서 닫기 문자의 위치를 반환한다.
	 * 
	 * @param	tokens
	 * @param	open
	 * @param	close
	 * @param	start
	 */
	public static function indexOfClose(tokens:Array<Token>, open:Type, close:Type, start:Int = 1) {
		
		var depth:Int = 1;

		// 시작점부터 체크한다.
		for (i in start...tokens.length) { 

			// 껍데기 열기 문자를 만나면 뎁스를 증가시킨다.
			if (tokens[i].type == open)
				depth++;

			// 껍데기 닫기 문자를 만나면 뎁스를 감소시킨다.
			else if (tokens[i].type == close)
				depth--;

			// 유효하면
			if (depth == 0)
				return i;
		}

		return -1;
	}

	/**
	 * 최하위 우선순위의 연산자(lowest precedence operator, LPO)의 유효한 위치를 찾는다.
	 * 
	 * @param tokens
	 * @param start
	 * @return
	 */
	public static function indexOfLPO(tokens:Array<Token> , targetDepth:Int = 0, start:Int = 0):Int {
		
		var shellDepth:Int = 0;
		var subscriptDepth:Int = 0;

		// 후보 토큰의 우선순위와 위치를 저장하기 위한 플래그
		var candidatePrecedence:Int = 0;
		var candidateIndex:Int = -1;

		for (i in start...tokens.length) { 

			// 중간에 괄호 부분(비유효 구간) 이 나오면 건너뛴다.
			if (tokens[i].type == Token.Type.ShellOpen)
				shellDepth++;
			else if (tokens[i].type == Token.Type.ShellClose)
				shellDepth--;

			// 유효 구간에서 연산자가 발견되면 후보 여부를 검토한다.
			if (targetDepth == shellDepth && subscriptDepth == 0) {
				var precedence:Int = tokens[i].getPrecedence();
				if (candidatePrecedence < precedence) {
					candidatePrecedence = precedence;
					candidateIndex = i;
				}
			}

			if (tokens[i].type == Token.Type.ArrayOpen)
				subscriptDepth++;
			else if (tokens[i].type == Token.Type.ArrayClose)
				subscriptDepth--;
		}

		return candidatePrecedence == 0 ? -1 : candidateIndex;
	}
	
	/**
	 * 2차원 배열을 1차원으로 편다.
	 * 
	 * @param	args
	 * @return
	 */
	public static function merge(args:Array<Array<Token>>):Array<Token> {
		
		var result:Array<Token> = new Array<Token>();
		
		for (i in 0...args.length) {
			for (j in 0...args[i].length) {
				result.push(args[i][j]);
			}
		}	
		
		return result;
	}
	
	
	/**
	 * 1차원 토큰열의 내용을 출력한다.
	 * 
	 * @param	tokens
	 */
	public static function view1D(tokens:Array<Token>):Void {		
		var buffer:String = "[";
		
		for ( i in 0...tokens.length) { 
			buffer += StringTools.trim(tokens[i].value) + "@" + tokens[i].type;
			if (i != tokens.length - 1) buffer += ",  ";
		}
		buffer += "]";

		trace(buffer);
	}
	
	/**
	 * 2차원 토큰열의 내용을 출력한다.
	 * @param	tokens
	 */
	public static function view2D(tokens:Array<Array<Token>>):Void {
		for ( i in 0...tokens.length) 
			view1D(tokens[i]);
		
	}
}