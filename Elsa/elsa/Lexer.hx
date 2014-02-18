package elsa;
import elsa.Lexer.Lextree;
import elsa.debug.Debug;

/**
 * 어휘 분석 클래스
 * 
 * 코드를 분석하여 어휘 계층 트리를 생성한다.
 * 
 * @author 김 현준
 */
class Lexer {

	/**
	 * 어휘 분석 중인 라인 넘버
	 */
	private var processingLine:Int = 1;
	
	public function new() {
		
		// 토큰 정의가 비었다면 예약 어휘를 추가한다.
		if (Token.definitions.length < 1)
			defineTokens();
	}
	
	public function analyze(code:String):Lextree {		
		processingLine = 1;
		
		// 어휘 트리를 생성한다.
		var tree:Lextree = new Lextree(true, processingLine);
		
		// 문자열 처리 상태 변수를 초기화한다.
		var isString:Bool = false;
		var buffer:String = "";		
		
		var i:Int = -1;
		
		while( ++i < code.length){		
			
			var char:String = code.charAt(i);
			
			// 줄바꿈 문자일 경우 줄 번호를 하나 증가시킨다.
			if (char == "\n") 
				processingLine ++;
			
			// 문자열의 시작과 종결 부분을 감지하여 상태를 업데이트한다.
			if (char == "\"") {
				isString = !isString;
				buffer += char;
				continue;
			}

			// 모든 문자열 정보는 버퍼에 저장한다.
			if (isString) {
				buffer += char;
				continue;
			}
			
			// 주석을 제거한다.
			if (char == "/" && i + 1 < code.length) {
				var j:Int = 2;
				
				// 단일 행 주석일 경우
				if (code.charAt(i + 1) == "/") {

					// 문장의 끝(줄바꿈 문자)를 만날 때까지 넘긴다.
					while (i + j <= code.length) {
						if (code.charAt(i + (j++)) == "\n")
							break;
					}
					i += j - 1;
					processingLine++;
					continue;
				}
				
				// 여러 행 주석일 경우
				else if (code.charAt(i + 1) == "*") {

					// 종결 문자열 시퀸스('*/')를 만날 때까지 넘긴다.
					while (i + j < code.length) {
						if (code.charAt(i + j) == "\n")
							processingLine++;

						if (code.charAt(i + (j++)) == "*")
							if (code.charAt(i + (j++)) == "/")
								break;
					}
					i += j - 1;
					continue;
				}
			}
			
			// 세미콜론을 찾으면 진행 상황을 스택에 저장한다.
			if (char == ";") {

				// 진행 상황을 스택에 저장한다.
				if (buffer.length > 0){
					var lextree:Lextree = new Lextree(false, processingLine);
					lextree.lexData = tokenize(buffer);
					tree.branch.push(lextree);
				}

				// 버퍼를 초기화한다.
				buffer = "";
			}
			
			// 중괄호 열기 문자('{')를 찾으면 괄호로 묶인 그룹을 재귀적으로 처리하여 저장한다.
			else if (char == "{") {
		
				// 중괄호 앞의 데이터를 저장한다.
				if (buffer.length > 0){
					var lextree:Lextree = new Lextree(false, processingLine);
					lextree.lexData = tokenize(buffer);
					tree.branch.push(lextree);
				}
				
				// 괄호의 끝을 찾는다.
				var j:Int = 1;
				var depth:Int = 0;
				
				while (i + j <= code.length) {
					var char:String = code.charAt(i + (j++));
					if (char == "{")
						depth++;
					else if (char == "}")
						depth--;
					else if (char == "\n")
						processingLine++;
					if (depth < 0)
						break;
				}

				// 괄호의 전체 내용에 대해 구문 분석을 수행한 후, 유닛에 추가한다. (시작, 끝 괄호 제외)
				var block:Lextree = analyze(code.substring(i + 1, i + j - 1));				
				tree.branch.push(block);

				// 다음 과정을 준비한다.
				buffer = "";
				i += j;
			}
			
			// 처리하지 않는 문자일 경우 버퍼에 쓴다.
			else {
				buffer += char;
			}	
		}
		
		// 맨 뒤의 데이터도 쓴다.
		if (buffer.length > 0){
			var lextree:Lextree = new Lextree(false, processingLine);
			lextree.lexData = tokenize(buffer);
			tree.branch.push(lextree);
		}

		// 분석 결과를 리턴한다.
		return tree;
	}
	
	/**
	 * 정의된 토큰 정보를 바탕으로 문자열을 토큰화한다.
	 * 
	 * @param	code
	 * @return
	 */
	public function tokenize(code:String):Array<Token> {
		
		var tokens:Array<Token> = new Array<Token>();
		var buffer:String = "";
		
		var usingQuoteChar:String = null;
		
		var isString:Bool = false;
		var isNumber:Bool = false;
		var isFloat:Bool = false;

		var i:Int = -1;
		
		while ( ++i < code.length) {
			
			var char:String = code.charAt(i);

			// 문자열 처리
			if (((char == "\"" || char == "\'") && !isString) || (char == usingQuoteChar && isString)) {
				
				// 처음일 경우
				if (!isString) usingQuoteChar = char;
				
				isString = !isString;

				// 문자열이 시작되었을때 기존의 버퍼를 저장한다.
				if (isString){
					if (buffer.length > 0)
						tokens.push(Token.findByValue(buffer, true));
				}
				
				// 문자열이 종결되었을 때 문자열 토큰 추가
				if (!isString)
					tokens.push(new Token(Token.Type.String, buffer));

				// 버퍼 초기화
				buffer = "";
				continue;
			}

			if (isString) {
				buffer += char;
				continue;
			}

			// 만약 숫자이고, 버퍼의 처음이라면 숫자 리터럴 처리를 시작한다.
			if (char.charCodeAt(0) >= "0".charCodeAt(0) && char.charCodeAt(0) <= "9".charCodeAt(0)) {
				if (buffer.length < 1)
					isNumber = true;
					
				if (isNumber) {
					buffer += char;
					continue;
				}
			}

			// 만약 숫자 리터럴 처리 중 '.'이 들어온다면 소수점 처리를 해 준다.
			if (isNumber && char == ".") {
				
				// .이 여러번 쓰였다면, .을 여러 번 쓴 게 어떤 의미가 있는 것이다.		
				if (isFloat) {
					tokens.push(new Token(Token.Type.Number, buffer.substring(0, buffer.length -1)));

					// 버퍼 초기화
					buffer = "";
					isNumber = false;
					isFloat = false;					
					i -= 2;
					continue;
				} else {
					isFloat = true;
					buffer += char;
					continue;
				}
			}

			// 만약 그 외의 문자가 온다면 숫자 리터럴을 종료한다.
			if (isNumber) {

				tokens.push(new Token(Token.Type.Number, buffer));

				// 버퍼 초기화
				buffer = "";
				isNumber = false;
				isFloat = false;
			}

			// 공백 문자가 나오면 토큰을 분리한다.
			if (char == " " || char.charCodeAt(0) == 10 || char.charCodeAt(0) == 13) {
	
				var token:Token = Token.findByValue(StringTools.trim(buffer), true);
				
				if (buffer.length > 0 && token != null)
					tokens.push(token);

				// 버퍼 초기화
				buffer = "";
				continue;
			}
			
			// 토큰 분리 문자의 존재 여부를 검사한다.
			else if (i < code.length) {

				// 토큰을 찾는다.
				var result:Token = Token.findByValue(code.substring(i, (i + 2 < code.length ? i + 3
						: (i + 1 < code.length ? i + 2 : i + 1))), false);

				// 만약 토큰이 존재한다면,
				if (result != null) {

					// 토큰을 이루는 문자만큼 건너 뛴다.
					i += result.value.length - 1;

					// 버퍼를 쓴다
					
					var token:Token = Token.findByValue(StringTools.trim(buffer), true);
					if (buffer.length > 0 && token != null) 
						tokens.push(token);
					

					var previousToken:Token = null;
					var previousTarget:Bool = false;

					if (tokens.length > 0)
						previousToken = tokens[tokens.length - 1];
					else 
						previousTarget = false;
					
					
					// 더하기 연산자의 경우 앞에 더할 대상이 존재
					if (tokens.length > 0
							&& (previousToken.type == Token.Type.ID
							|| previousToken.type == Token.Type.Number
							|| previousToken.type == Token.Type.String
							|| previousToken.type == Token.Type.ArrayClose
							|| previousToken.type == Token.Type.ShellClose)) {
						previousTarget = true;
					}

					// 연산자 수정
					if (result.type == Token.Type.Addition && !previousTarget)
						result = Token.findByType(Token.Type.UnraryPlus);
					else if (result.type == Token.Type.UnraryPlus && previousTarget)
						result = Token.findByType(Token.Type.Addition);
					else if (result.type == Token.Type.Subtraction && !previousTarget)
						result = Token.findByType(Token.Type.UnraryMinus);
					else if (result.type == Token.Type.UnraryMinus && previousTarget)
						result = Token.findByType(Token.Type.Subtraction);
					else if (result.type == Token.Type.SuffixIncrement && !previousTarget)
						result = Token.findByType(Token.Type.PrefixIncrement);
					else if (result.type == Token.Type.PrefixIncrement && previousTarget)
						result = Token.findByType(Token.Type.SuffixIncrement);
					else if (result.type == Token.Type.SuffixDecrement && !previousTarget)
						result = Token.findByType(Token.Type.PrefixDecrement);
					else if (result.type == Token.Type.PrefixDecrement && previousTarget)
						result = Token.findByType(Token.Type.SuffixDecrement);

					// 발견된 토큰을 쓴다
					tokens.push(result);

					// 버퍼 초기화
					buffer = "";
					continue;
				}
			}

			// 버퍼에 현재 문자를 쓴다
			buffer += char;
		}

		// 버퍼가 남았다면 마지막으로 써 준다
		if (isNumber) {
			tokens.push(new Token(Token.Type.Number, buffer));
		} else {
			var token:Token = Token.findByValue(StringTools.trim(buffer), true);
			if (buffer.length > 0 && token != null)
				tokens.push(token);
		}

		if (isString)
			Debug.reportError("Syntax error", "insert \" to complete expression", processingLine);

		return tokens;
	}
	
	/**
	 * 어휘 분석에 사용될 토큰을 정의한다.
	 */
	public function defineTokens():Void {
		
		Token.define(null, Token.Type.String);
		Token.define(null, Token.Type.Number);
		Token.define(null, Token.Type.Array);
		Token.define(null, Token.Type.CastToNumber);
		Token.define(null, Token.Type.CastToString);
		Token.define(null, Token.Type.Append);
		Token.define(null, Token.Type.AppendAssignment);
		Token.define(null, Token.Type.ArrayReference);
		Token.define(null, Token.Type.Instance);
		Token.define(null, Token.Type.LoadContext);
		Token.define(null, Token.Type.SaveContext);

		Token.define("include", Token.Type.Include, true);		
		Token.define("define", Token.Type.Define, true);
		Token.define("var", Token.Type.Variable, true);
		Token.define("if", Token.Type.If, true);
		Token.define("elif", Token.Type.ElseIf, true);
		Token.define("else", Token.Type.Else, true);
		Token.define("for", Token.Type.For, true);
		Token.define("while", Token.Type.While, true);
		Token.define("continue", Token.Type.Continue, true);
		Token.define("break", Token.Type.Break, true);
		Token.define("return", Token.Type.Return, true);
		Token.define("new", Token.Type.New, true);
		Token.define("true", Token.Type.True, true);
		Token.define("false", Token.Type.False, true);
		Token.define("as", Token.Type.As, true);
		Token.define("in", Token.Type.In, true);
		
		Token.define("->", Token.Type.Right, false);
		Token.define("?", Token.Type.RuntimeValueAccess, false);
		Token.define("[", Token.Type.ArrayOpen, false);
		Token.define("]", Token.Type.ArrayClose, false);
		Token.define("{", Token.Type.BlockOpen, false);
		Token.define("}", Token.Type.BlockClose, false);
		Token.define("(", Token.Type.ShellOpen, false);
		Token.define(")", Token.Type.ShellClose, false);
		Token.define("...", Token.Type.From, false);
		Token.define(".", Token.Type.Dot, false);
		Token.define(",", Token.Type.Comma, false);
		Token.define(":", Token.Type.Colon, false);
		Token.define(";", Token.Type.Semicolon, false);
		Token.define("++", Token.Type.PrefixIncrement, false, Token.Affix.PREFIX);
		Token.define("--", Token.Type.PrefixDecrement, false, Token.Affix.PREFIX);
		Token.define("++", Token.Type.SuffixIncrement, false, Token.Affix.SUFFIX);
		Token.define("--", Token.Type.SuffixDecrement, false, Token.Affix.SUFFIX);
		Token.define("+", Token.Type.UnraryPlus, false, Token.Affix.PREFIX);
		Token.define("-", Token.Type.UnraryMinus, false, Token.Affix.PREFIX);
		Token.define("=", Token.Type.Assignment, false);
		Token.define("+=", Token.Type.AdditionAssignment, false);
		Token.define("-=", Token.Type.SubtractionAssignment, false);
		Token.define("*=", Token.Type.MultiplicationAssignment, false);
		Token.define("/=", Token.Type.DivisionAssignment, false);
		Token.define("%=", Token.Type.ModuloAssignment, false);
		Token.define("&=", Token.Type.BitwiseAndAssignment, false);
		Token.define("^=", Token.Type.BitwiseXorAssignment, false);
		Token.define("|=", Token.Type.BitwiseOrAssignment, false);
		Token.define("<<=", Token.Type.BitwiseLeftShiftAssignment, false);
		Token.define(">>=", Token.Type.BitwiseRightShiftAssignment, false);
		Token.define("==", Token.Type.EqualTo, false);
		Token.define("!=", Token.Type.NotEqualTo, false);
		Token.define(">", Token.Type.GreaterThan, false);
		Token.define(">=", Token.Type.GreaterThanOrEqualTo, false);
		Token.define("<", Token.Type.LessThan, false);
		Token.define("<=", Token.Type.LessThanOrEqualTo, false);
		Token.define("+", Token.Type.Addition, false);
		Token.define("-", Token.Type.Subtraction, false);
		Token.define("*", Token.Type.Multiplication, false);
		Token.define("/", Token.Type.Division, false);
		Token.define("%", Token.Type.Modulo, false);
		Token.define("!", Token.Type.LogicalNot, false, Token.Affix.PREFIX);
		Token.define("not", Token.Type.LogicalNot, true, Token.Affix.PREFIX);
		Token.define("&&", Token.Type.LogicalAnd, false);
		Token.define("and", Token.Type.LogicalAnd, true);
		Token.define("||", Token.Type.LogicalOr, false);
		Token.define("or", Token.Type.LogicalOr, true);
		Token.define("~", Token.Type.BitwiseNot, false, Token.Affix.PREFIX);
		Token.define("&", Token.Type.BitwiseAnd, false);
		Token.define("|", Token.Type.BitwiseOr, false);
		Token.define("^", Token.Type.BitwiseXor, false);
		Token.define("<<", Token.Type.BitwiseLeftShift, false);
		Token.define(">>", Token.Type.BitwiseRightShift, false);
	}
	
	/**
	 * 어휘 분석이 끝난 계층 트리의 구조를 보여준다.
	 * 
	 * @param units
	 * @param level
	 */
	public function viewHierarchy(tree:Lextree, level:Int):Void {
		
		var space:String = "";
		
		for (i in 0...level)
			space += "      ";
			
		for (i in 0...tree.branch.length) {
			
			// 새 가지일 때
			if (tree.branch[i].hasBranch) {
				Sys.print(space + "<begin>\n");
				viewHierarchy(tree.branch[i], level + 1);
				Sys.print(space + "<end>\n");
			}
			
			// 어휘 데이터일 때
			else {
				if (tree.branch[i].lexData.length < 1)
					continue;
					
					
				var buffer:String =  "";
				for (j in 0...tree.branch[i].lexData.length) {
					var token:Token = tree.branch[i].lexData[j];
					buffer += StringTools.trim(token.value) + "@" + token.type;
					if (j != tree.branch[i].lexData.length - 1) buffer += ",  ";
				}
				Sys.print(space + buffer+"\n");
			}
		}
	}
}


/**
 * 어휘 트리
 */
class Lextree {
	
	/**
	 * 파생 가지가 있는지의 여부
	 */
	public var hasBranch:Bool = false;
	
	/**
	 * 파생 가지
	 */
	public var branch:Array<Lextree>;
	
	/**
	 * 어휘 데이터 (잎사귀)
	 */
	public var lexData:Array<Token>;
	
	/**
	 * 컴파일 시 에러 출력에 사용되는 라인 넘버
	 */
	public var lineNumber:Int = 1;
	
	public function new(hasBranch:Bool, lineNumber:Int) {
		
		this.hasBranch = hasBranch;
		this.lineNumber = lineNumber;
		
		if (hasBranch)
			branch = new Array<Lextree>();
	}
	
}