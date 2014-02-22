package elsa;

import elsa.debug.Debug;
import elsa.Lexer.Lextree;
import elsa.nlib.BelugaNativeLibrary;
import elsa.Token.Type;
import elsa.BelugaParser.ParsedPair;
import elsa.BelugaParser.ParseOption;
import elsa.BelugaParser.ScanOption;
import elsa.symbol.SymbolTable;
import elsa.symbol.Symbol;
import elsa.symbol.VariableSymbol;
import elsa.symbol.FunctionSymbol;
import elsa.symbol.ClassSymbol;
import elsa.symbol.LiteralSymbol;
import elsa.syntax.ArrayReferenceSyntax;
import elsa.syntax.ArraySyntax;
import elsa.syntax.CastingSyntax;
import elsa.syntax.ClassDeclarationSyntax;
import elsa.syntax.ElseSyntax;
import elsa.syntax.ForSyntax;
import elsa.syntax.FunctionCallSyntax;
import elsa.syntax.FunctionDeclarationSyntax;
import elsa.syntax.IfSyntax;
import elsa.syntax.ElseIfSyntax;
import elsa.syntax.InfixSyntax;
import elsa.syntax.InstanceCreationSyntax;
import elsa.syntax.MemberReferenceSyntax;
import elsa.syntax.PrefixSyntax;
import elsa.syntax.SuffixSyntax;
import elsa.syntax.VariableDeclarationSyntax;
import elsa.syntax.WhileSyntax;
import elsa.syntax.ContinueSyntax;
import elsa.syntax.BreakSyntax;
import elsa.syntax.ReturnSyntax;
import elsa.syntax.ParameterDeclarationSyntax;
import elsa.syntax.IncludeSyntax;
import sys.io.File;

/**
 * 구문 분석/재조립 파서
 * 
 * @author 김 현준
 */
class BelugaParser {

	/**
	 * 어휘 분석기
	 */
	public var lexer:Lexer;
	
	/**
	 * 코드 최적화
	 */
	public var optimizer:BelugaOptimizer;
	
	/**
	 * 심볼 테이블
	 */
	public var symbolTable:SymbolTable;
	
	/**
	 * 어셈블리 코드 저장소
	 */
	private var assembly:BelugaAssembly;
	
	/**
	 * 네이티브 라이브러리
	 */
	public var nlib:BelugaNativeLibrary;
	
	/**
	 * 빌드 패스
	 */
	public var buildPath:String;
	
	/**
	 * 플래그 카운터
	 */
	private var flagCount:Int = 0;
	
	private function assignFlag():Int {
		return flagCount ++;
	}
	
	public function new() { }
	
	/**
	 * 코드를 오르카 어셈블리 코드로 컴파일한다.
	 * 
	 * @param	code
	 * @param	path
	 * @return
	 */
	public function compile(code:String, buildPath:String = ""):String {
		
		// 파싱 시 필요한 객체를 초기화한다.
		lexer = new Lexer();
		optimizer = new BelugaOptimizer();	
		symbolTable = new SymbolTable();		
		assembly = new BelugaAssembly(symbolTable);
		
		this.buildPath = buildPath;
		flagCount = 0;

		// 네이티브 라이브러리를 로드한다.
		nlib = new BelugaNativeLibrary();
		nlib.load(symbolTable);
		
		// 어휘 트리를 취득한다.
		var lextree:Lextree = lexer.analyze(code);
		//lexer.viewHierarchy(lextree, 0);
		
		// 현재 스코프를 스캔한다. 현재 스코프에서는 오브젝트 정의와 프로시저 정의만을 스캔한다.
		scan(lextree, new ScanOption());
		parseBlock(lextree, new ParseOption());

		assembly.freeze();
		
		// 리터럴을 어셈블리에 쓴다.
		for ( i in 0...symbolTable.literals.length ) {			
			var literal:LiteralSymbol = symbolTable.literals[i];
			
			assembly.writeCode("SAL "+ literal.address);
			
			if (literal.type == "number")
				assembly.writeCode("PSH " + literal.value);				
			else if (literal.type == "string") 
				assembly.writeCode("PSH " + literal.value + "s");			
			
			assembly.writeCode("PSH " + literal.address);
			assembly.writeCode("STO");
		}

		assembly.melt();
		assembly.writeCode("END");

		// 모든 파싱이 끝나면 어셈블리 코드를 최적화한다.
		assembly.code = optimizer.optimize(assembly.code);
		
		// 메타데이터 추가
		assembly.code = Std.string(symbolTable.availableAddress) + "\n" + assembly.code;
		
		return assembly.code;
	}
	
	public function parseBlock(block:Lextree, option:ParseOption):Void {
		
		// 현재 스코프에서 생성된 변수와 프로시져를 저장한다. (맨 마지막에 심볼 테이블에서 삭제를 위함)
		var definedSymbols:Array<Symbol> = new Array<Symbol>();

		// 확장된 조건문 사용 여부
		var extendedConditional:Bool = false;
		var extendedConditionalExit:Int = 0; // 조건문의 탈출 플래그 (마지막 else나 elif 문의 끝)

		var i:Int = -1;
		
		// 라인 단위로 파싱한다.
		while ( ++i < block.branch.length) {
			
			var line:Lextree = block.branch[i];
			var lineNumber:Int = line.lineNumber;

			// 다른 제어문의 도움 없이 코드 블록이 단독으로 사용될 수 없다.
			if (line.hasBranch) {
				Debug.reportError("Syntax error 1", "Unexpected code block", lineNumber);
				continue;
			}

			// 라인의 토큰열을 취득한다.
			var tokens:Array<Token> = line.lexData;

			if (tokens.length < 1)
				continue;
			
			// 변수 선언문
			if (VariableDeclarationSyntax.match(tokens)) {				
				
				// 구조체에서는 변수를 파싱하지 않는다. (이미 스캐닝에서 캐시 완료)
				if (option.inStructure)
					continue;

				var syntax:VariableDeclarationSyntax = VariableDeclarationSyntax.analyze(tokens, lineNumber);

				// 만약 구문 분석 중 오류가 발생했다면 다음 구문으로 건너 뛴다.
				if (syntax == null)
					continue;

				// 변수 타입이 유효한지 확인한다.
				if (symbolTable.getClass(syntax.variableType.value) == null) {
					Debug.reportError("Type error 6", "유효하지 않은 변수 타입입니다.", lineNumber);
					continue;
				}				

				// 변수 정의가 유효한지 확인한다.
				if (symbolTable.getVariable(syntax.variableName.value) != null) {
					Debug.reportError("Duplication error 7", "변수 정의가 중복되었습니다.", lineNumber);
					continue;
				}

				var variable:VariableSymbol  = new VariableSymbol(syntax.variableName.value, syntax.variableType.value);
				symbolTable.add(variable);				

				// 토큰에 심볼을 태그한다.
				syntax.variableName.setTag(variable);				

				// 정의된 심볼 목록에 추가한다.
				definedSymbols.push(variable);

				// 어셈블리에 변수의 메모리 어드레스 할당 명령을 추가한다.				
				if (variable.isNumber() || variable.isString())
					assembly.writeCode("SAL " + variable.address);
				else					
					assembly.writeCode("SAA " + variable.address);

				// 초기화 데이터가 존재할 경우
				if (syntax.initializer != null) {
					variable.initialized = true;

					// 초기화문을 파싱한 후 어셈블리에 쓴다.
					var parsedInitializer:ParsedPair = parseLine(syntax.initializer, lineNumber);

					if (parsedInitializer == null) continue;
					assembly.writeLine(parsedInitializer.data);
				}
			}
			
			
			else if (FunctionDeclarationSyntax.match(tokens)) {
				
				// 함수 구문을 분석한다.
				var syntax:FunctionDeclarationSyntax = FunctionDeclarationSyntax.analyze(tokens, lineNumber);

				// 만약 구문 분석 중 오류가 발생했다면 다음 구문으로 건너 뛴다.
				if (syntax == null)
					continue;
				
				var parametersTypeList:Array<String> = new Array<String>();
				
				// 매개변수 각각의 유효성을 검증하고 심볼 형태로 가공한다.
				for ( k in 0...syntax.parameters.length) {
					
					if (!ParameterDeclarationSyntax.match(syntax.parameters[k])){						
						continue;
					}
					// 매개 변수의 구문을 분석한다.
					var parameterSyntax:ParameterDeclarationSyntax = ParameterDeclarationSyntax.analyze(syntax.parameters[k], lineNumber);

					// 매개 변수 선언문에 Syntax error가 있을 경우 건너 뛴다.
					if (parameterSyntax == null)
						continue;	
						
					parametersTypeList.push(parameterSyntax.parameterType.value);
				}
					
				// 테이블에서 함수 심볼을 가져온다. (이미 스캐닝 과정에서 함수가 테이블에 등록되었으므로)
				var functn:FunctionSymbol = symbolTable.getFunction(syntax.functionName.value, parametersTypeList);
				
				// 함수 심볼을 정의된 심볼 목록에 추가한다.
				definedSymbols.push(functn);
				
				// 다음 라인이 블록 형태인지 확인한다.
				if (!hasNextBlock(block, i)) {
					Debug.reportError("Syntax error 8", "함수 구현부가 존재하지 않습니다.", lineNumber);
					continue;
				}
				
				// 프로시져가 임의로 실행되는 것을 막기 위해 프로시저의 끝 부분으로 점프한다.
				assembly.writeCode("PSH %" + functn.functionExit);
				assembly.writeCode("JMP");

				// 프로시져의 시작 부분을 알려주는 코드
				assembly.flag(functn.functionEntry);

				// 프로시져 구현부를 파싱한다. 옵션: 함수
				var functionOption:ParseOption = option.copy();

				functionOption.inStructure = false;
				functionOption.inFunction = true;
				functionOption.inIterator = false;
				functionOption.parentFunction = functn;
				
				// 파라미터 변수를 추가/할당한다.
				for ( j in 0...functn.parameters.length) {
					// 심볼 테이블에 추가한다.
					symbolTable.add(functn.parameters[j]);
				}
				
				parseBlock(block.branch[++i], functionOption);
				
				// 파라미터 변수를 제거한다.				
				for ( j in 0...functn.parameters.length) {
					symbolTable.remove(functn.parameters[j]);
				}
				
				/*
				 * 프로시져 호출 매커니즘은 다음과 같다.
				 * 
				 * 호출 스택에 기반하여 프로시져의 끝에서 마지막 스택 플래그로 이동.(pop)
				 */
				// 마지막 호출 위치를 가져온다.
				assembly.writeCode("MOC");
				
				// 마지막 호출 위치로 이동한다. (이 명령은 함수가 void형이고, 리턴 명령을 결국 만나지 못했을 때 실행되게 된다.)
				assembly.writeCode("JMP");
				
				// 프로시져의 끝 부분을 표시한다.
				assembly.flag(functn.functionExit);
			}
			
			
			else if (ClassDeclarationSyntax.match(tokens)) {
				
				// 오브젝트 구문을 분석한다.
				var syntax:ClassDeclarationSyntax = ClassDeclarationSyntax.analyze(tokens, lineNumber);

				// 만약 구문 분석 중 오류가 발생했다면 다음 구문으로 건너 뛴다.
				if (syntax == null)
					continue;

				// 다음 라인이 블록 형태인지 확인한다.
				if (!hasNextBlock(block, i)) {
					Debug.reportError("Syntax error  9", "클래스의 구현부가 존재하지 않습니다.", lineNumber);
					continue;
				}
				
				// 클래스 정의를 취득한다.
				var klass:ClassSymbol = cast(symbolTable.getClass(syntax.className.value), ClassSymbol);
				
				// 클래스 내부의 클래스일 경우 구현부를 스캔한다.
				if (option.inStructure) {
					
					var innerScanOption:ScanOption = new ScanOption();
					innerScanOption.inStructure = true;
					innerScanOption.parentClass = klass;

					scan(block.branch[i + 1], innerScanOption);
				}

				// 오브젝트 역시 스캔이 끝난 상태로, 하위 항목의 기본 선언 정보는 기록되어 있으나, 실제 명령은 파싱되지 않은
				// 상태이다. 하위 종속 항목들에 대해 파싱한다.
				var classOption:ParseOption = option.copy();
				classOption.inStructure = true;
				classOption.inIterator = false;
				classOption.inFunction = false;

				parseBlock(block.branch[++i], classOption);

				// 정의된 심볼 목록에 추가한다.
				definedSymbols.push(klass);
			}
			
			
			else if (IfSyntax.match(tokens)) {				
				
				if (option.inStructure) {
					Debug.reportError("Syntax error 2", "conditional/iteration statements couldnt be used in class structure", lineNumber);
					continue;
				}
				
				var syntax:IfSyntax = IfSyntax.analyze(tokens, lineNumber);
				
				if (syntax == null)
					continue;

				// if문은 확장된 조건문의 시작이므로 초기화한다.				
				extendedConditional = false;

				// 뒤에 else if 나 else를 가지고 있으면 확장된 조건문을 사용한다.
				if (hasNextConditional(block, i)) {
					extendedConditional = true;
					extendedConditionalExit = assignFlag();
				} else {
					extendedConditional = false;
				}				

				// 조건문을 취득한 후 파싱한다.
				var parsedCondition:ParsedPair = parseLine(syntax.condition, lineNumber);

				if (parsedCondition == null)
					continue;
				
				// 조건문 결과 타입이 정수형이 아니라면 (True:1, False:0) 에러를 출력한다.
				if (parsedCondition.type != "number" && parsedCondition.type != "bool") {
				
					Debug.reportError("Syntax error 10", "참, 거짓 여부를 판별할 수 없는 조건식입니다.", lineNumber);
					continue;
				}

				// if문의 구현부가 존재하는지 확인한다.
				if (!hasNextBlock(block, i)) {
					Debug.reportError("Syntax error 11", "if문의 구현부가 존재하지 않습니다.", lineNumber);
					continue;
				}

				// 조건문 탈출 플래그
				var ifExit:Int = assignFlag();

				// 어셈블리에 조건식을 쓴다.
				assembly.writeLine(parsedCondition.data);
				assembly.writeCode("PSH %" + ifExit);
				
				// 조건이 거짓일 경우 -> if절을 건너 뛴다.
				assembly.writeCode("JMF");

				// 구현부를 파싱한다.
				var ifOption:ParseOption = option.copy();
				ifOption.inStructure = false;

				parseBlock(block.branch[++i], ifOption);
				
				// 만약 참이라서 여기까지 실행되면, 확장 조건문인 경우 끝으로 이동
				if (extendedConditional) {
					assembly.writeCode("PSH %" + extendedConditionalExit);
					assembly.writeCode("JMP");
				}
				
				assembly.flag(ifExit);	
			}
			
			
			else if (ElseIfSyntax.match(tokens)) {
				
				if (option.inStructure) {
					Debug.reportError("Syntax error 2", "conditional/iteration statements couldnt be used in class structure", lineNumber);
					continue;
				}
				
				// 확장된 조건문을 사용하지 않는 상태에서 else if문이 등장하면 에러를 출력한다
				if (!extendedConditional) {
					Debug.reportError("Syntax error 12", "else-if문은 단독으로 쓰일 수 없습니다.", lineNumber);
					continue;
				}

				var syntax:ElseIfSyntax = ElseIfSyntax.analyze(tokens, lineNumber);
				
				if (syntax == null)
					continue;

				// 뒤에 else if 나 else를 가지고 있으면 확장된 조건문을 사용한다.
				if (hasNextConditional(block, i)) 
					extendedConditional = true;
				else
					extendedConditional = false;				
				
				// 조건문을 취득한 후 파싱한다.
				var parsedCondition:ParsedPair = parseLine(syntax.condition, lineNumber);
				
				if (parsedCondition == null)
					continue;
				
				// 조건문 결과 타입이 정수형이 아니라면 (True:1, False:0) 에러를 출력한다.
				if (parsedCondition.type != "number" && parsedCondition.type != "bool") {
					Debug.reportError("Syntax error 13", "참, 거짓 여부를 판별할 수 없는 조건식입니다.", lineNumber);
					continue;
				}

				// if문의 구현부가 존재하는지 확인한다.
				if (!hasNextBlock(block, i)) {
					Debug.reportError("Syntax error 14", "if문의 구현부가 존재하지 않습니다.", lineNumber);
					continue;
				}

				// 조건문 탈출 플래그
				var elseIfExit:Int = 0;
				if (!extendedConditional)
					elseIfExit = extendedConditionalExit;
				else
					elseIfExit = flagCount++;

				// 어셈블리에 조건식을 쓴다.
				assembly.writeLine(parsedCondition.data);
				assembly.writeCode("PSH %" + elseIfExit);

				// 조건이 거짓일 경우 구현부를 건너 뛴다.
				assembly.writeCode("JMF");

				// 구현부를 파싱한다.
				var ifOption:ParseOption = option.copy();
				ifOption.inStructure = false;

				parseBlock(block.branch[++i], ifOption);

				// 만약 참이라서 구현부가 실행되었을 경우, 조건 블록의 가장 끝으로 이동한다.
				if (extendedConditional) {
					assembly.writeCode("PSH %" + extendedConditionalExit);
					assembly.writeCode("JMP");
					assembly.flag(elseIfExit);
				}
				
				// 만약 확장 조건문이 elseIf를 마지막으로 끝나는 경우라면
				else {
					assembly.flag(extendedConditionalExit);
				} 

			}
			
			else if (ElseSyntax.match(tokens)) {
				
				if (option.inStructure) {
					Debug.reportError("Syntax error 2", "conditional/iteration statements couldnt be used in class structure", lineNumber);
					continue;
				}
				
				var syntax:ElseSyntax = ElseSyntax.analyze(tokens, lineNumber);

				// 만약 else 문이 유효하지 않을 경우 다음으로 건너 뛴다.
				if (syntax == null) 
					continue;
				

				// 확장된 조건문을 사용하지 않는 상태에서 else문이 등장하면 에러를 출력한다
				if (!extendedConditional) {
					Debug.reportError("Syntax error 15", "else문은 단독으로 쓰일 수 없습니다.", lineNumber);
					continue;
				}

				// 확장 조건문을 종료한다.
				extendedConditional = false;

				// else문의 구현부가 존재하는지 확인한다.
				if (!hasNextBlock(block, i)) {
					Debug.reportError("Syntax error 16", "else문의 구현부가 존재하지 않습니다.", lineNumber);
					continue;
				}

				// 구현부를 파싱한다. 만약 이터레이션 플래그가 있는 옵션일 경우 그대로 넘긴다.
				var elseOption:ParseOption = option.copy();
				elseOption.inStructure = false;

				parseBlock(block.branch[++i], elseOption);

				// 확장 조건문 종료 플래그를 쓴다.
				assembly.flag(extendedConditionalExit);
			}
			
			
			else if (ForSyntax.match(tokens)) {
				
				if (option.inStructure) {
					Debug.reportError("Syntax error 2", "conditional/iteration statements couldnt be used in class structure", lineNumber);
					continue;
				}
				
				var syntax:ForSyntax = ForSyntax.analyze(tokens, lineNumber);

				if (syntax == null) 
					continue;
				
				// 증감 변수가 유효한지 확인한다.
				if (symbolTable.getVariable(syntax.counter.value) != null) {
					Debug.reportError("Duplication error 17", "증감 변수 정의가 충돌합니다.", lineNumber);
					continue;
				}

				// 증감 변수를 생성한다.
				var counter:VariableSymbol = new VariableSymbol(syntax.counter.value, "number");
				counter.initialized = true;

				// 증감 변수를 태그한다.
				syntax.counter.setTag(counter);

				// 테이블에 증감 변수를 등록한다.
				symbolTable.add(counter);

				// 초기값 파싱
				var parsedInitialValue:ParsedPair = parseLine(syntax.start, lineNumber);
				
				if (parsedInitialValue == null)
					continue;
				
				if (parsedInitialValue.type != "number") {
					Debug.reportError("Type error 17", "초기 값의 타입이 실수형이 아닙니다.", lineNumber);
					continue;
				}

				// for문의 기본 구성인 n -> k 에서 이는 기본적으로 while(n <= k)를 의미하므로 동치인 명령을
				// 생성한다.
				var condition:Array<Token> = TokenTools.merge([[syntax.counter, Token.findByType(Type.LessThanOrEqualTo)], syntax.end]);
				var parsedCondition:ParsedPair = parseLine(condition, lineNumber);
				
				if (parsedCondition == null)
					continue;
				
				if (parsedCondition == null || parsedInitialValue == null)
					continue;

				// for문의 구현부가 존재하는지 확인한다.
				if (!hasNextBlock(block, i)) {
					Debug.reportError("Syntax error 18", "for문의 구현부가 존재하지 않습니다.", lineNumber);
					continue;
				}

				/*
				 * for의 어셈블리 구조는, 증감자 초기화(0) -> 귀환 플래그 -> 증감자 증감 -> 조건문(jump if
				 * false) -> 내용 ->귀환 플래그로 점프 -> 탈출 플래그 로 되어 있다.
				 */

				// 귀환/탈출 플래그 생성
				var forEntry:Int = assignFlag();
				var forExit:Int = assignFlag();

				// 증감자 초기화 (-1)
								
				assembly.writeCode("SAL " + counter.address);
				assembly.writeLine(parsedInitialValue.data);
				assembly.writeCode("PSH -1");
				assembly.writeCode("OPR 1");
				assembly.writeCode("PSH " + counter.address);
				assembly.writeCode("STO");

				// 귀환 플래그를 심는다.
				assembly.flag(forEntry);

				// 증감자 증감 (+1)
				assembly.writeCode("PSH " + counter.address);
				assembly.writeCode("IVK 27");

				// 조건문이 거짓이면 탈출 플래그로 이동
				assembly.writeLine(parsedCondition.data);
				assembly.writeCode("PSH %" + forExit);
				assembly.writeCode("JMF");

				// for문의 구현부를 파싱한다. 이 때, 기존의 옵션은 뒤의 과정에서도 동일한 내용으로 사용되므로 새로운 옵션을
				// 생성한다.
				var forOption:ParseOption = option.copy();
				forOption.inStructure = false;
				forOption.inIterator = true;
				forOption.blockEntry = forEntry;
				forOption.blockExit = forExit;

				parseBlock(block.branch[++i], forOption);

				// 귀환 플래그로 점프
				assembly.writeCode("PSH %" + forEntry);
				assembly.writeCode("JMP");

				// 탈출 플래그를 심는다.
				assembly.flag(forExit);
				
				// 증감 변수를 제거한다.
				symbolTable.remove(counter);
			}
			
			else if (WhileSyntax.match(tokens)) {
				
				if (option.inStructure) {
					Debug.reportError("Syntax error 2", "conditional/iteration statements couldnt be used in class structure", lineNumber);
					continue;
				}
				
				var syntax:WhileSyntax = WhileSyntax.analyze(tokens, lineNumber);

				if (syntax == null)
					continue;

				/*
				 * while의 어셈블리 구조는, 귀환 플래그 -> 조건문(jump if false) -> 내용 -> 귀환
				 * 플래그로 이동 -> 탈출 플래그로 되어 있다.
				 */

				// 조건문을 파싱한다.
				var parsedCondition:ParsedPair = parseLine(syntax.condition, lineNumber);

				if (parsedCondition == null)
					continue;

				// while문의 구현부가 존재하는지 확인한다.
				if (!hasNextBlock(block, i)) {
					Debug.reportError("Syntax error 19", "while문의 구현부가 존재하지 않습니다.", lineNumber);
					continue;
				}

				// 귀환/탈출 플래그 생성
				var whileEntry:Int = assignFlag();
				var whileExit:Int = assignFlag();

				// 귀환 플래그를 심는다.
				assembly.flag(whileEntry);

				// 조건문을 체크하여 거짓일 경우 탈출 플래그로 이동한다.
				assembly.writeLine(parsedCondition.data);
				assembly.writeCode("PSH %" + whileExit);
				assembly.writeCode("JMF");

				// while문의 구현부를 파싱한다.
				var whileOption:ParseOption = option.copy();
				whileOption.inStructure = false;
				whileOption.inIterator = true;
				whileOption.blockEntry = whileEntry;
				whileOption.blockExit = whileExit;

				parseBlock(block.branch[++i], whileOption);

				// 귀환 플래그로 점프한다.
				assembly.writeCode("PSH %" + whileEntry);
				assembly.writeCode("JMP");

				// 탈출 플래그를 심는다.
				assembly.flag(whileExit);
			}
			
			else if (ContinueSyntax.match(tokens)) {
				
				if (!option.inIterator) {
					Debug.reportError("Syntax error 3", "제어 명령은 반복문 내에서만 사용할 수 있습니다.", lineNumber);
					continue;
				}
				
				// 귀환 플래그로 점프한다.
				assembly.writeCode("PSH %" + option.blockEntry);
				assembly.writeCode("JMP");
			}
			
			else if (BreakSyntax.match(tokens)) {
				
				if (!option.inIterator) {
					Debug.reportError("Syntax error 3", "제어 명령은 반복문 내에서만 사용할 수 있습니다.", lineNumber);
					continue;
				}
				
				// 탈출 플래그로 점프한다.
				assembly.writeCode("PSH %" + option.blockExit);
				assembly.writeCode("JMP");
			}
			
			else if (ReturnSyntax.match(tokens)) {
				
				if (!option.inFunction) {
					Debug.reportError("Syntax error 4", "리턴 명령은 함수 정의 내에서만 사용할 수 있습니다.", lineNumber);
					continue;
				}
				
				var syntax:ReturnSyntax = ReturnSyntax.analyze(tokens, lineNumber);
				
				if (syntax == null)
					continue;
					
				if (!option.inFunction) {
					Debug.reportError("Syntax error 20", "return 명령은 함수 내에서만 사용할 수 있습니다.", lineNumber);
					continue;
				}
				
				// 만약 함수 타입이 Void일 경우 그냥 탈출 플래그로 이동한다.
				if (option.parentFunction.isVoid()) {

					// 반환값이 존재하면 에러를 출력한다.
					if (syntax.returnValue.length > 0) {
						Debug.reportError("Syntax error 20", "void형 함수는 값을 반환할 수 없습니다.", lineNumber);
						continue;
					}

					// 마지막 호출 지점을 가져온다.
					assembly.writeCode("MOC");

					// 마지막 호출 지점으로 이동한다.
					assembly.writeCode("JMP");
				}

				// 반환 타입이 있을 경우
				else {

					// 반환값이 없다면 에러를 출력한다.
					if (tokens.length < 1) {
						Debug.reportError("Syntax error 21", "return문이 값을 반환하지 않습니다.", lineNumber);
						continue;
					}

					// 반환값을 파싱한다. 파싱된 결과는 스택에 저장된다.
					var parsedReturnValue:ParsedPair = parseLine(syntax.returnValue, lineNumber);
					
					if (parsedReturnValue == null)
						continue;

					if (parsedReturnValue.type != option.parentFunction.type && parsedReturnValue.type != "*") {
						TokenTools.view1D(parsedReturnValue.data);
						Debug.reportError("Syntax error 22", "리턴된 데이터의 타입("+parsedReturnValue.type+")이 함수 리턴 타입("+option.parentFunction.type+")과 일치하지 않습니다.", lineNumber);
						continue;
					}
					
					// 리턴 값을 쓴다.
					assembly.writeLine(parsedReturnValue.data);
					
					// 마지막 호출 지점을 가져온다.
					assembly.writeCode("MOC");
					
					// 마지막 호출 지점으로 이동한다. (레지스터 값으로 점프 명령)
					assembly.writeCode("JMP");
				}
			}
			
			// 인클루드 문			
			else if (IncludeSyntax.match(tokens)) {
				
				var syntax:IncludeSyntax = IncludeSyntax.analyze(tokens, lineNumber);
				
				// 인클루드 대상 파일을 로드한다.
				var targetCode:String = null;
				try targetCode = File.getContent(buildPath + syntax.targetFile)
				catch (error:String) {
					Debug.reportError("File Not Found Error", "Cannot find including orca file.", lineNumber);
					return null;
				}
				
				// 어휘 분석한다.
				var lextree:Lextree = lexer.analyze(targetCode);
				
				// 스캔한다.
				scan(lextree, new ScanOption());
				
				for (j in 0...lextree.branch.length) {
					block.branch.insert(i + j + 1, lextree.branch[j]);
				}
			}
			
			// 일반 대입문을 파싱한다.
			else {		
				
				if (option.inStructure) {
					Debug.reportError("Syntax error 5", "구조체 정의에서 연산 처리를 할 수 없습니다.", lineNumber);
					continue;
				}
				
				/*// 스택 안전성 체크: 안전하지 않다면 명령 무시
				if (!TokenTools.checkStackSafety(tokens)) {
					Debug.reportError("Syntax error 5", "ignored", lineNumber);
					continue;
				}*/
				
				var parsedLine:ParsedPair = parseLine(tokens, lineNumber);
				if (parsedLine == null)
					continue;
					
				assembly.writeLine(parsedLine.data);
			}
		}
		
		// definition에 있던 심볼을 테이블에서 모두 제거한다.
		for (i in 0...definedSymbols.length) { 
			
			// 변수일 경우 시스템에 메모리를 반환한다.
			if(Std.is(definedSymbols[i], VariableSymbol))
				assembly.writeCode("FRE " + definedSymbols[i].address);
			
			symbolTable.remove(definedSymbols[i]);
		}
	}
	
	
	/**
	 * 토큰열을 파싱한다.
	 * 
	 * @param	tokens
	 * @param	lineNumber
	 * @return
	 */
	public function parseLine(tokens:Array<Token>, lineNumber:Int):ParsedPair {
		
		// 토큰이 비었을 경우
		if (tokens.length < 1) {
			Debug.reportError("Syntax error 23", "계산식에 피연산자가 존재하지 않습니다.", lineNumber);
			return null;
		}

		// 의미 없는 껍데기가 있다면 벗긴다.
		tokens = TokenTools.pill(tokens);

		// 토큰열이 하나일 경우 (파싱 트리의 최하단에 도달했을 경우)
		if (tokens.length == 1) {

			// 변수일 경우 토큰의 유효성 검사를 한다.
			if (tokens[0].type == Type.ID) {
				
				var variable:VariableSymbol = symbolTable.getVariable(tokens[0].value);
				
				// 태그되지 않은 변수일 경우 유효성을 검증한 후 태그한다.
				if (!tokens[0].tagged) {					
					if (variable == null) {
						Debug.reportError("Undefined Error 24", tokens[0].value + "는 정의되지 않은 변수입니다.", lineNumber);
						return null;
					}
					
					// 토큰에 변수를 태그한다.
					tokens[0].setTag(variable);
				}

				return new ParsedPair(tokens, variable.type);
			}

			var literal:LiteralSymbol = null;

			switch (tokens[0].type) {

			// true/false 토큰은 각각 1/0으로 처리한다.
			case Type.True:
				literal = symbolTable.getLiteral("1", LiteralSymbol.NUMBER);
			case Type.False:
				literal = symbolTable.getLiteral("0", LiteralSymbol.NUMBER);
			case Type.Number:
				literal = symbolTable.getLiteral(tokens[0].value, LiteralSymbol.NUMBER);
			case Type.String:
				literal = symbolTable.getLiteral(tokens[0].value, LiteralSymbol.STRING);
			default:
				Debug.reportError("Syntax error 25", "심볼의 타입을 찾을 수 없습니다.", lineNumber);
				return null;
			}

			// 토큰에 리터럴 태그하기
			tokens[0].setTag(literal);

			return new ParsedPair(tokens, literal.type);
		}

		/**
		 * 함수 호출: F(X,Y,Z)
		 */
		if (FunctionCallSyntax.match(tokens)) {
			
			// 프로시저 호출 구문을 분석한다.
			var syntax:FunctionCallSyntax = FunctionCallSyntax.analyze(tokens, lineNumber);			
			
			if (syntax == null)
				return null;			
			
			var arguments:Array<Array<Token>> = new Array<Array<Token>>();			
			var argumentsTypeList:Array<String> = new Array<String>();
			
			// 각각의 파라미터를 파싱한다.
			for( i in 0...syntax.functionArguments.length) {

				// 파라미터가 비었을 경우
				if (syntax.functionArguments[syntax.functionArguments.length - 1 - i].length < 1) {
					Debug.reportError("Syntax error 28", "파라미터가 비었습니다.", lineNumber);
					return null;
				}

				// 파라미터를 파싱한다.
				var parsedArgument:ParsedPair = parseLine(syntax.functionArguments[syntax.functionArguments.length - 1 - i], lineNumber);
					
				if (parsedArgument == null)
					return null;

				// 파라미터를 쌓는다.
				arguments.push(parsedArgument.data);
				argumentsTypeList.insert(0, parsedArgument.type);
			}
			arguments.push([syntax.functionName]);
			
			// 함수 심볼을 취득한다.
			var functn:FunctionSymbol = symbolTable.getFunction(syntax.functionName.value, argumentsTypeList);
			
			if (functn == null) {
				Debug.reportError("Undefined Error 26", syntax.functionName.value+"("+argumentsTypeList+") 는 정의되지 않은 프로시져입니다.", lineNumber);
				return null;
			}			
			syntax.functionName.setTag(functn);					
			
			var parameterPushToken:Token = new Token(Type.PushParameters);
			parameterPushToken.setTag(functn);
			if (!functn.isNative)
				arguments.insert(0, [parameterPushToken]);
				
			return new ParsedPair(TokenTools.merge(arguments), functn.type);
		}

		/**
		 * 배열 생성 : [A, B, C, D, ... , ZZZ]
		 */
		else if (ArraySyntax.match(tokens)) {

			var syntax:ArraySyntax = ArraySyntax.analyze(tokens, lineNumber);

			if (syntax == null)
				return null;
			
			var parsedElements:Array<Array<Token>> = new Array<Array<Token>>();

			// 배열 리터럴의 각 원소를 파싱한 후 스택에 쌓는다.
			for ( i in 0...syntax.elements.length) { 

				// 배열의 원소가 유효한지 체크한다.
				if (syntax.elements[syntax.elements.length - 1 - i].length < 1) {
					Debug.reportError("Syntax error 30", "배열이 비었습니다.", lineNumber);
					return null;
				}

				// 배열의 원소를 파싱한다.
				var parsedElement:ParsedPair = parseLine(syntax.elements[syntax.elements.length - 1 - i], lineNumber);

				if (parsedElement == null)
					return null;

				parsedElements.push(parsedElement.data);
				parsedElements.push([new Token(Type.Number, Std.string(syntax.elements.length - 1 - i))]);
			}

			/*
			 * 배열 리터럴의 토큰 구조는
			 * 
			 * A1, A2, A3, ... An, ARRAY_LITERAL(n)
			 */
			var mergedElements:Array<Token> = TokenTools.merge(parsedElements);
			mergedElements.push(new Token(Type.Array, Std.string(parsedElements.length)));
			
			TokenTools.view1D(mergedElements);
			
			return new ParsedPair(mergedElements, "array");
		}

		/**
		 * 객체 생성 : new A
		 */
		else if (InstanceCreationSyntax.match(tokens)) {

			// 객체 정보 취득
			var syntax:InstanceCreationSyntax = InstanceCreationSyntax.analyze(tokens, lineNumber);
			
			if (syntax == null)
				return null;
			
			var targetClass:ClassSymbol = symbolTable.getClass(syntax.instanceType.value);	
			
			if (targetClass == null) {
				Debug.reportError("Undefined error 31", "정의되지 않은 클래스입니다.", lineNumber);
				return null;
			}

			// 토큰에 오브젝트 태그
			syntax.instanceType.setTag(targetClass);

			return new ParsedPair([syntax.instanceType, Token.findByType(Type.Instance)], targetClass.id);
		}

		/**
		 * 인스턴스 참조 : A.B.C -> 배열 취급하여 파싱한다.
		 */
		else if (MemberReferenceSyntax.match(tokens)) {

			var syntax:MemberReferenceSyntax = MemberReferenceSyntax.analyze(tokens, lineNumber);
			
			if (syntax == null)
				return null;
			
			var arrayReference:Array<Token> = new Array<Token>();	
			
			// 참조 대상을 파싱한다.
			var parsedInstance:ParsedPair = parseLine(syntax.instance, lineNumber);
			if (parsedInstance == null)
				return null;
			
			var targetClass:ClassSymbol = symbolTable.getClass(parsedInstance.type);
			
			// 맴버 참조를 배열 참조로 변환한다.
			for ( j in 0...syntax.referneces.length) {	
				
				// 타겟 클래스에서 맴버 변수의 인덱스를 취득한다.							
				var targetClassMember:VariableSymbol = targetClass.findMemberByID(syntax.referneces[syntax.referneces.length - 1 - j].value);					
				var memberIndex:Int = 0;
				
				for ( k in 0...targetClass.members.length) {
						
					var member:VariableSymbol = cast(targetClass.members[k], VariableSymbol);
					
					// 일치하는 속성을 찾았으면 해당하는 인덱스를 추가한다.
					if (member.id == targetClassMember.id) {
							
						var indexValueLiteral:LiteralSymbol = symbolTable.getLiteral(Std.string(memberIndex), "number");
						var indexValueToken:Token = new Token(Token.Type.Number, Std.string(memberIndex));							
						indexValueToken.setTag(indexValueLiteral);
							
						arrayReference.push(indexValueToken);
						break;
					}
					memberIndex++;
				}
				
				targetClass = symbolTable.getClass(targetClassMember.type);
			}
			
			// A[a][b][c] 를 a b c A Array_reference(3) 로 배열한다.
			arrayReference = arrayReference.concat(parsedInstance.data);
			arrayReference.push(new Token(Type.ArrayReference, Std.string(syntax.referneces.length)));
			
			TokenTools.view1D(arrayReference);
			
			return new ParsedPair(arrayReference, targetClass.id);
		}

		/**
		 * 배열 참조: a[1][2]
		 */
		else if (ArrayReferenceSyntax.match(tokens)) {

			/*
			 * 배열 인덱스 연산자는 우선순위가 가장 높고, 도트보다 뒤에 처리되므로 배열 인덱스 열기 문자 ('[')로 구분되는
			 * 토큰은 단일 변수의 n차 접근으로만 표시될 수 있다. 즉 이 프로시져에서 걸리는 토큰열은 모두 A[N]...[N]의
			 * 형태를 하고 있다. (단 A는 변수거나 프로시져)
			 * 
			 * A[1][2] -> GET 0, A 1 -> GET 1, 0, 2 -> PSH 1
			 */

			// 배열 참조 구문을 분석한다.
			var syntax:ArrayReferenceSyntax = ArrayReferenceSyntax.analyze(tokens, lineNumber);

			if (syntax == null)
				return null;

			var array:VariableSymbol = symbolTable.getVariable(syntax.array.value);
			
			if (array == null) {
				Debug.reportError("Undefined Error 34", "정의되지 않은 배열입니다.", lineNumber);
				return null;
			}
			syntax.array.setTag(array);

			// 변수가 배열이 아닐 경우, 문자열 인덱스값 읽기로 처리
			if (array.type != "array") {

				// 변수가 문자열도 아니면, 에러
				if (array.type != "string") {
					Debug.reportError("Type error 35", "인덱스 참조는 배열에서만 가능합니다.", lineNumber);
					return null;
				}

				// 문자열 인덱스 참조 명령을 처리한다.
				if (syntax.references.length != 1) {
					Debug.reportError("Type error 36", "문자열을 n차원 배열처럼 취급할 수 없습니다.", lineNumber);
					return null;
				}

				// index A CharAt 의 순서로 배열한다.
				var parsedIndex:ParsedPair = parseLine(syntax.references[0], lineNumber);

				// 인덱스 파싱 중 에러가 발생했다면 건너 뛴다.
				if (parsedIndex == null)
					return null;

				// 인덱스가 정수가 아닐 경우
				if (parsedIndex.type != "number") {
					Debug.reportError("Type error 37", "문자열의 인덱스가 정수가 아닙니다.", lineNumber);
					return null;
				}
				
				var result:Array<Token> = new Array<Token>();
				result.push(syntax.array);
				result = result.concat(parsedIndex.data);
				result.push(Token.findByType(Type.CharAt));
				
				// 결과를 리턴한다.
				return new ParsedPair(result, "string");
			}

			// 파싱된 인덱스들
			var parsedReferences:Array<Array<Token>> = new Array<Array<Token>>();
			
			// 가장 낮은 인덱스부터 차례로 파싱한다.
			for (i in 0...syntax.references.length) { 

				var reference:Array<Token> = syntax.references[syntax.references.length - 1 - i];

				var parsedReference:ParsedPair = parseLine(reference, lineNumber);

				if (parsedReference == null)
					continue;

				// 인덱스가 정수가 아닐 경우
				if (parsedReference.type != "number") {
					Debug.reportError("Type error 38", "배열의 인덱스가 정수가 아닙니다.", lineNumber);
					continue;
				}

				// 할당
				parsedReferences.push(parsedReference.data);
			}

			// A[a][b][c] 를 c b a A Array_reference(3) 로 배열한다.
			var result:Array<Token> = TokenTools.merge(parsedReferences);
			result.push(syntax.array);
			result.push(new Token(Type.ArrayReference, Std.string(parsedReferences.length)));

			// 리턴 타입은 어떤 타입이라도 될 수 있다.
			return new ParsedPair(result, "*");
		}

		/**
		 * 캐스팅: stuff as number
		 */
		else if (CastingSyntax.match(tokens)) {

			var syntax:CastingSyntax = CastingSyntax.analyze(tokens, lineNumber);

			if (syntax == null)
				return null;

			// 캐스팅 대상을 파싱한 후 끝에 캐스팅 명령을 추가한다.
			var parsedTarget:ParsedPair = parseLine(syntax.target, lineNumber);

			if (parsedTarget == null)
				return null;

			// 문자형으로 캐스팅
			if (syntax.castingType == "string") {

				// 아직은 숫자 -> 문자만 가능하다.
				if (parsedTarget.type != "number" && parsedTarget.type != "bool" && parsedTarget.type != "*") {
					Debug.reportError("Type error 39", "이 타입을 문자형으로 캐스팅할 수 없습니다.", lineNumber);
					return null;
				}
				
				var result:Array<Token> = parsedTarget.data;				
				result.push(Token.findByType(Type.CastToString));
				
				// 캐스팅된 문자열을 출력
				return new ParsedPair(result, "string");
			}

			// 실수형으로 캐스팅
			else if (syntax.castingType == "number") {

				// 아직은 문자 -> 숫자만 가능하다.
				if (parsedTarget.type != "string" && parsedTarget.type != "bool" && parsedTarget.type != "*") {
					Debug.reportError("Type error 40", "이 타입을 실수형으로 캐스팅할 수 없습니다.", lineNumber);
					return null;
				}
	
				var result:Array<Token> = parsedTarget.data;
				result.push(Token.findByType(Type.CastToNumber));
				
				// 캐스팅된 문자열을 출력
				return new ParsedPair(result, "number");
			}

			// 그 외의 경우
			else {

				// 캐스팅 타입이 적절한지 체크한다.
				if (symbolTable.getClass(syntax.castingType) == null) {
					Debug.reportError("Undefined Error 41", "올바르지 않은 타입입니다.", lineNumber);
					return null;
				}

				// 표면적으로만 캐스팅한다. -> [경고] 실질적인 형 검사가 되지 않기 때문에 VM이 죽을 수도 있다.
				return new ParsedPair(parsedTarget.data, syntax.castingType);
			}

		}

		/**
		 * 접두형 단항 연산자: !(true) , ++a
		 */
		else if (PrefixSyntax.match(tokens)) {

			var syntax:PrefixSyntax = PrefixSyntax.analyze(tokens, lineNumber);

			if (syntax == null)
				return null;			

			// 피연산자를 파싱한다.
			var parsedOperand:ParsedPair = parseLine(syntax.operand, lineNumber);

			if (parsedOperand == null)
				return null;			
			
			// 어드레스 취급하는 경우	
			if (syntax.operator.type == Type.PrefixIncrement || syntax.operator.type == Type.PrefixDecrement) {
				
				// 배열이나 맴버 변수 대입이면
				if (parsedOperand.data[parsedOperand.data.length - 1].type == Type.ArrayReference) {
					parsedOperand.data[parsedOperand.data.length - 1].useAsAddress = true;	
					syntax.operator.useAsArrayReference = true;
				}
				
				// 전역/로컬 변수 대입이면
				else if (parsedOperand.data.length == 1) {
					parsedOperand.data[parsedOperand.data.length - 1].useAsAddress = true;
				} 
				
				// 그 외의 경우
				else {
					Debug.reportError("Type error 44", "증감 연산자 사용이 잘못되었습니다.", lineNumber);
					return null;
				}
			}
				
			// 접두형 연산자의 경우 숫자만 올 수 있다.
			if (parsedOperand.type != "number" && parsedOperand.type != "*") {
				TokenTools.view1D(tokens);
				Debug.reportError("Type error 43", "접두형 연산자 뒤에는 실수형 데이터만 올 수 있습니다.", lineNumber);
				return null;
			}
			
			var result:Array<Token> = parsedOperand.data;
			result.push(syntax.operator);
			
			// 결과를 리턴한다.
			return new ParsedPair(result, parsedOperand.type);
		}

		/**
		 * 접미형 단항 연산자: a++
		 */
		else if (SuffixSyntax.match(tokens)) {

			var syntax:SuffixSyntax = SuffixSyntax.analyze(tokens, lineNumber);

			if (syntax == null)
				return null;

			// 피연산자를 파싱한다.
			var parsedOperand:ParsedPair = parseLine(syntax.operand, lineNumber);
			
			if (parsedOperand == null)
				return null;
			
			// 어드레스 취급하는 경우	
			if (syntax.operator.type == Type.SuffixIncrement || syntax.operator.type == Type.SuffixDecrement) {
				
				// 배열이나 맴버 변수 대입이면
				if (parsedOperand.data[parsedOperand.data.length - 1].type == Type.ArrayReference) {
					parsedOperand.data[parsedOperand.data.length - 1].useAsAddress = true;	
					syntax.operator.useAsArrayReference = true;
				}
				
				// 전역/로컬 변수 대입이면
				else if (parsedOperand.data.length == 1) {
					parsedOperand.data[parsedOperand.data.length - 1].useAsAddress = true;
				} 
				
				// 그 외의 경우
				else {
					Debug.reportError("Type error 44", "증감 연산자 사용이 잘못되었습니다.", lineNumber);
					return null;
				}	
				
			}

			// 접두형 연산자의 경우 숫자만 올 수 있다.
			if (parsedOperand.type != "number" && parsedOperand.type != "*") {
				Debug.reportError("Type error 45", "접미형 연산자 앞에는 실수형 데이터만 올 수 있습니다.", lineNumber);
				return null;
			}

			var result:Array<Token> = parsedOperand.data;
			result.push(syntax.operator);
			
			// 결과를 리턴한다.
			return new ParsedPair(result, parsedOperand.type);
		}

		/**
		 * 이항 연산자: a+b
		 */
		else if (InfixSyntax.match(tokens)) {
			
			var syntax:InfixSyntax = InfixSyntax.analyze(tokens, lineNumber);

			if (syntax == null)
				return null;
			
			// 양 항을 모두 파싱한다.
			var left:ParsedPair = parseLine(syntax.left, lineNumber);
			var right:ParsedPair = parseLine(syntax.right, lineNumber);
			
			if (left == null || right == null) {				
				return null;	
			}
			
			// 대입 명령이면
			if (syntax.operator.getPrecedence() > 15) {
				
				// 배열이나 맴버 변수 대입이면
				if (left.data[left.data.length - 1].type == Type.ArrayReference) {
					left.data[left.data.length - 1].useAsAddress = true;	
					syntax.operator.useAsArrayReference = true;
				}
				
				// 전역/로컬 변수 대입이면
				else {
					left.data[left.data.length - 1].useAsAddress = true;
					syntax.operator.useAsArrayReference = false;
				}				
			}
			
			// 시스템 값 참조 연산자일 경우
			if (syntax.operator.type == Type.RuntimeValueAccess) {
				
				// 에러를 막기 위해 타입을 임의로 지정한다.
				left.type = right.type = "number";
			}
			
			// 와일드카드 처리, 와일드카드가 양 변에 한 쪽이라도 있으면
			if (left.type == "*" || right.type == "*") {

				// 와일드카드가 없는 쪽으로 통일한다.
				if (left.type != "*")
					right.type = left.type;

				else if (right.type != "*")
					left.type = right.type;

				// 모두 와일드카드라면. (배열 원소와 배열 원소끼리 연산)
				else {
					// 양 쪽 모두 숫자 처리
					left.type = right.type = "number";
				}
			}
			
			if (right.type == "bool") right.type = "number";
			if (left.type == "bool") left.type = "number";
			
			// 형 체크 프로세스: 두 항 타입이 같을 경우
			if (left.type == right.type) {

				// 만약 문자열에 대한 이항 연산이라면, 대입/더하기만 허용한다.
				if (left.type == "string") {

					// 산술 연산자를 문자열 연산자로 수정한다.
					switch (syntax.operator.type) {
					case Type.AdditionAssignment:
						syntax.operator = Token.findByType(Type.AppendAssignment);
					case Type.Addition:
						syntax.operator = Token.findByType(Type.Append);
					case Type.EqualTo, Type.NotEqualTo:
						left.type = right.type = "number";
					// 문자열 - 문자열 대입이면 SDW명령을 활성화시킨다.
					case Type.Assignment:
						syntax.operator.value = "string";
					default:
						Debug.reportError("Syntax error 47", "이 연산자로 문자열 연산을 수행할 수 없습니다.", lineNumber);
						return null;
					}

				}

				// 숫자에 대한 이항 연산일 경우
				else if (left.type == "number") {

					switch (syntax.operator.type) {
					// 실수형 - 실수형 대입이면 NDW명령을 활성화시킨다.
					case Type.Assignment:
						syntax.operator.value = "number";
					default:
					}

				}

				// 그 외의 배열이나 인스턴스의 경우
				else {
					switch (syntax.operator.type) {
					// 인스턴스 - 인스턴스 대입이면 NDW명령을 활성화시킨다.
					case Type.Assignment:
						syntax.operator.value = "instance";						
					default:
						Debug.reportError("Syntax error 48", "대입 명령을 제외한 이항 연산자는 문자/숫자 이외의 처리를 할 수 없습니다.", lineNumber);
						return null;
					}
				}

			}

			// 형 체크 프로세스: 두 항의 타입이 다를 경우
			else {
				
				// 자동 캐스팅을 시도한다.
				switch (syntax.operator.type) {
				case Type.Addition:

					// 문자 + 숫자
					if (left.type == "string" && right.type == "number") {

						right.data.push(Token.findByType(Type.CastToString));
						right.type = "string";

						// 연산자를 APPEND로 수정한다.
						syntax.operator = Token.findByType(Type.Append);

					}

					// 숫자 + 문자
					else if (left.type == "number" && right.type == "string") {

						left.data.push(Token.findByType(Type.CastToString));
						left.type = "string";

						// 연산자를 APPEND로 수정한다.
						syntax.operator = Token.findByType(Type.Append);

					}

					else {
						Debug.reportError("Syntax error 49", "다른 두 타입 간 연산을 실행할 수 없습니다.", lineNumber);
						return null;
					}
				case Type.AdditionAssignment:
					
					// 문자 + 숫자
					if (left.type == "string" && right.type == "number") {
						right.data.push(Token.findByType(Type.CastToString));
						right.type = "string";

						// 연산자를 APPEND로 수정한다.
						syntax.operator = Token.findByType(Type.AppendAssignment);

					}

					else {
						Debug.reportError("Syntax error 49", "다른 두 타입 간 연산을 실행할 수 없습니다.", lineNumber);
						return null;
					}
						
				default:
					//TokenTools.view1D(right.data);
					Debug.reportError("Syntax error 50", "다른 두 타입(" + left.type + "," + right.type + ") 간 연산을 실행할 수 없습니다.", lineNumber);
					return null;
				}
			}
			
			// 시스템 값 참조 연산자일 경우
			if (syntax.operator.type == Type.RuntimeValueAccess) {
				
				// 에러를 막기 위해 타입을 임의로 지정한다.
				left.type = right.type = "*";
			}
			
			// 형 체크가 끝나면 좌, 우 변을 잇고 리턴한다.
			var result:Array<Token> = left.data.concat(right.data);
			result.push(syntax.operator);
			
			return new ParsedPair(result, right.type);
		}

		Debug.reportError("Syntax error 51", "연산자가 없는 식입니다.", lineNumber);
		return null;
	}
	
	
	/**
	 * 스코프 내의 프로시져와 오브젝트 정의를 읽어서 테이블에 기록한다.
	 * 
	 * @param	block
	 * @param	scanOption
	 */
	public function scan(block:Lextree, option:ScanOption):Void {
		
		// 구조체 스캔일 경우 맴버변수를 저장할 공간 생성
		var members:Array<VariableSymbol> = null;
	
		// 임시 스코프용
		var definedSymbols:Array<Symbol> = new Array<Symbol>();
		
		if (option.inStructure) {
			members = new Array<VariableSymbol>();
		}
	
		var i:Int = -1;
		while (++i < block.branch.length) {

			var line:Lextree = block.branch[i];
			var lineNumber:Int = line.lineNumber;

			// 만약 유닛에 가지가 있다면 넘어감
			if (line.hasBranch)
				continue;
				
			var tokens:Array<Token> = line.lexData;
			
			if (tokens.length < 1)
				continue;
			
			if (VariableDeclarationSyntax.match(tokens)) {
				
				// 변수(맴버 변수)는 구조체에서만 스캔한다.
				if (!option.inStructure)
					continue;

				// 스캔시에는 에러를 표시하지 않는다. (파싱 단계에서 표시)
				Debug.supressError(true);

				var syntax:VariableDeclarationSyntax = VariableDeclarationSyntax.analyze(tokens, lineNumber);

				Debug.supressError(false);

				if (syntax == null)
					continue;

				// 변수 심볼을 생성한다.
				var variable:VariableSymbol = new VariableSymbol(syntax.variableName.value, syntax.variableType.value);

				// 이미 사용되고 있는 변수인지 체크
				if (symbolTable.getVariable(variable.id) != null) {
					Debug.reportError("Duplication error 52", "변수 정의가 충돌합니다.", lineNumber);
					continue;
				}
				
				// 심볼 테이블에 추가
				definedSymbols.push(variable);
				symbolTable.add(variable);
				
				// 메모리에 할당
				if (variable.type == "number" || variable.type == "string" || variable.type == "bool")
					assembly.writeCode("SAL " + variable.address);
				else 
					assembly.writeCode("SAA " + variable.address);				
				
				// 초기화 데이터가 존재할 경우
				if (syntax.initializer != null) {
					variable.initialized = true;

					// 초기화문을 파싱한 후 어셈블리에 쓴다.
					var parsedInitializer:ParsedPair = parseLine(syntax.initializer, lineNumber);

					if (parsedInitializer == null) continue;
					assembly.writeLine(parsedInitializer.data);
				}
				
				
				
				members.push(variable);	
			}
			
			else if (FunctionDeclarationSyntax.match(tokens)) {
				
				// 올바르지 않은 선언문일 경우 건너 뛴다.
				var syntax:FunctionDeclarationSyntax = FunctionDeclarationSyntax.analyze(tokens, lineNumber);				
				
				// 스캔시에는 에러를 표시하지 않는다. (파싱 단계에서 표시)
				Debug.supressError(true);

				if (syntax == null)
					continue;

				Debug.supressError(false);
				
				var parameters:Array<VariableSymbol> = new Array<VariableSymbol>();
				var parametersTypeList:Array<String> = new Array<String>();
				
				// 매개변수 각각의 유효성을 검증하고 심볼 형태로 가공한다.
				for ( k in 0...syntax.parameters.length) {
					
					if (!ParameterDeclarationSyntax.match(syntax.parameters[k])){
						Debug.reportError("Syntax error 53", "파라미터 정의가 올바르지 않습니다.", lineNumber);
						continue;
					}
					// 매개 변수의 구문을 분석한다.
					var parameterSyntax:ParameterDeclarationSyntax = ParameterDeclarationSyntax.analyze(syntax.parameters[k], lineNumber);

					// 매개 변수 선언문에 Syntax error가 있을 경우 건너 뛴다.
					if (parameterSyntax == null)
						continue;

					// 매개 변수 이름의 유효성을 검증한다.
					if (symbolTable.getVariable(parameterSyntax.parameterName.value) != null) {
						Debug.reportError("Duplication error 54", parameterSyntax.parameterName.value+" 변수 정의가 충돌합니다.", lineNumber);
						continue;
					}

					// 매개 변수 타입의 유효성을 검증한다.
					if (symbolTable.getClass(parameterSyntax.parameterType.value) == null) {
						Debug.reportError("Duplication error 55", "매개 변수 타입이 유효하지 않습니다.", lineNumber);
						continue;
					}
						
					// 매개 변수 심볼을 생성한다
					var parameter:VariableSymbol = new VariableSymbol(parameterSyntax.parameterName.value, parameterSyntax.parameterType.value);
					parameterSyntax.parameterName.setTag(parameter);
					parameters[k] = parameter;
				}				
				
				// 함수 정의 충돌을 검사한다.
				if (symbolTable.getFunction(syntax.functionName.value, parametersTypeList) != null) {
					Debug.reportError("Duplication error 56", "함수 정의가 충돌합니다.", lineNumber);
					continue;
				}
				
				var functn:FunctionSymbol = new FunctionSymbol(syntax.functionName.value, syntax.returnType.value, parameters);				
				
				// 프로시져 시작 부분과 종결 부분을 나타내는 플래그를 생성한다.
				functn.functionEntry = assignFlag();
				functn.functionExit = assignFlag();				
				
				// 함수 토큰을 태그한다.
				syntax.functionName.setTag(functn);
				
				// 프로시져를 심볼 테이블에 추가한다.
				symbolTable.add(functn);			
			}
			
			else if (ClassDeclarationSyntax.match(tokens)) {
				
				// 오브젝트 선언 구문을 분석한다.
				var syntax:ClassDeclarationSyntax = ClassDeclarationSyntax.analyze(tokens, lineNumber);

				// 오브젝트 선언 구문에 에러가 있을 경우 건너 뛴다.
				if (syntax == null)
					continue;

				// 오브젝트 이름의 유효성을 검증한다.
				if (symbolTable.getClass(syntax.className.value) != null) {
					Debug.reportError("Syntax error 56", "오브젝트 정의가 중복되었습니다.", lineNumber);
					continue;
				}

				// 오브젝트 구현부가 존재하는지 확인한다.
				if (!hasNextBlock(block, i)) {
					Debug.reportError("Syntax error 57", "구조체의 구현부가 존재하지 않습니다.", lineNumber);
					continue;
				}

				// 오브젝트를 심볼 테이블에 추가한다.
				var klass:ClassSymbol = new ClassSymbol(syntax.className.value);

				symbolTable.add(klass);

				// 클래스 내부의 클래스는 지금 스캔하지 않는다.
				if (option.inStructure)
					continue;

				// 오브젝트의 하위 항목을 스캔한다.
				var objectOption:ScanOption = option.copy();
				objectOption.inStructure = true;
				objectOption.parentClass = klass;

				scan(block.branch[++i], objectOption);
			}
		}

		// 만약 구조체 스캔일 경우 맴버 변수와 프로시져 정의를 오브젝트 심볼에 쓴다.
		if (option.inStructure) {
			option.parentClass.members = members;
		}
		
		for ( i in 0...definedSymbols.length) {
			symbolTable.remove(definedSymbols[i]);
		}
	}	
	
	/**
	 * 다다음 인덱스에 이어지는 조건문이 존재하는지 확인한다.
	 * 
	 * 
	 * @param tree
	 * @param index
	 * @return
	 */
	private function hasNextConditional(tree:Lextree, index:Int):Bool {

		// 다다음 인덱스가 존재하고,
		if (index + 2 < tree.branch.length) {

			var possibleBranch:Lextree = tree.branch[index + 2];
			if (!possibleBranch.hasBranch && possibleBranch.lexData.length > 0) {
				var firstToken:Token = possibleBranch.lexData[0];
				
				// 이어지는 조건문이 있을 경우
				if (firstToken.type == Type.Else)
					return true;
			}
		}
		return false;
	}

	/**
	 * 다음 코드 블록이 존재하는지의 여부를 리턴한다.
	 * 
	 * @param tree
	 * @param index
	 * @return
	 */
	private function hasNextBlock(tree:Lextree, index:Int):Bool {
		if ((!(index < tree.branch.length)) || !tree.branch[index + 1].hasBranch)
			return false;
		return true;
	}	
}


/**
 * 파싱된 페어
 */
class ParsedPair {
	
	public var data:Array<Token>;
	public var type:String;
	
	public function new(data:Array<Token>, type:String) {
		this.data = data;
		this.type = type;
	}
}

/**
 * 파싱 옵션 클래스
 */
class ParseOption {
	
	/**
	 * 파싱 옵션
	 */
	public var inStructure:Bool = false;
	public var inFunction:Bool = false;
	public var inIterator:Bool = false;
	
	/**
	 * 블록의 시작과 끝 옵션
	 */
	public var blockEntry:Int = 0;
	public var blockExit:Int = 0;
	
	/**
	 * 함수 내부일 경우의 함수 참조
	 */
	public var parentFunction:FunctionSymbol;
	
	public function new() { }
	
	/**
	 * 파싱 옵션 복사
	 * 
	 * @return
	 */
	public function copy():ParseOption {
		
		var option:ParseOption = new ParseOption();
		
		option.inStructure = inStructure;
		option.inFunction = inFunction;
		option.inIterator = inIterator;
		option.blockEntry = blockEntry;
		option.blockExit = blockExit;
		option.parentFunction = parentFunction;
		
		return option;
	}
	
}

/**
 * 스캔 옵션 클래스
 */
class ScanOption {
	
	/**
	 * 스캔 옵션
	 */
	public var inStructure:Bool = false;
	
	/**
	 * 함수 내부일 경우의 함수 참조
	 */
	public var parentClass:ClassSymbol;
	
	public function new() { }
	
	/**
	 * 스캔 옵션 복사
	 * 
	 * @return
	 */
	public function copy():ScanOption {
		
		var option:ScanOption = new ScanOption();
		
		option.inStructure = inStructure;
		option.parentClass = parentClass;
		
		return option;
	}
}
