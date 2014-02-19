package elsa.nlib;

import elsa.symbol.Symbol;
import elsa.symbol.SymbolTable;
import elsa.symbol.VariableSymbol;
import elsa.symbol.FunctionSymbol;
import elsa.symbol.ClassSymbol;

/**
 * ...
 * @author 김 현준
 */
class NativeLibrary {

	public static var initialized:Bool = false;
	
	public var classes:Array<NativeClass>;
	public var functions:Array<NativeFunction>;
	
	public function new() {
		initialize();
	}
	
	public function initialize() {
		if (initialized) return;
		initialized = true;
		
		classes = new Array<NativeClass>();
		functions = new Array<NativeFunction>();

		var number:NativeClass = new NativeClass("number", []);
		var string:NativeClass = new NativeClass("string", []);
		var boolean:NativeClass = new NativeClass("bool", []);
		var array:NativeClass = new NativeClass("array", []);
		var void:NativeClass = new NativeClass("void", []);

		var print:NativeFunction = new NativeFunction("print", ["*"], "void");
		print.write("POP 0");
		print.write("EXE print, &0");
		
		var exit:NativeFunction = new NativeFunction("exit", [], "void");
		exit.write("END");

		var whoami:NativeFunction = new NativeFunction("whoami", [], "void");
		whoami.write("EXE whoami");
		
		var abs:NativeFunction = new NativeFunction("abs", ["number"], "number");
		abs.write("POP 0");
		abs.write("EXE abs, &0");
		
		var acos:NativeFunction = new NativeFunction("acos", ["number"], "number");
		acos.write("POP 0");
		acos.write("EXE acos, &0");
		
		var asin:NativeFunction = new NativeFunction("asin", ["number"], "number");
		asin.write("POP 0");
		asin.write("EXE asin, &0");
		
		var atan:NativeFunction = new NativeFunction("atan", ["number"], "number");
		atan.write("POP 0");
		atan.write("EXE atan, &0");
		
		var atan2:NativeFunction = new NativeFunction("atan2", ["number", "number"], "number");
		atan2.write("POP 0");
		atan2.write("POP 1");
		atan2.write("EXE atan2, &0, &1");
		
		var ceil:NativeFunction = new NativeFunction("ceil", ["number"], "number");
		ceil.write("POP 0");
		ceil.write("EXE ceil, &0");
		
		var floor:NativeFunction = new NativeFunction("floor", ["number"], "number");
		floor.write("POP 0");
		floor.write("EXE floor, &0");
		
		var round:NativeFunction = new NativeFunction("round", ["number"], "number");
		round.write("POP 0");
		round.write("EXE round, &0");
		
		var cos:NativeFunction = new NativeFunction("cos", ["number"], "number");
		cos.write("POP 0");
		cos.write("EXE cos, &0");
		
		var sin:NativeFunction = new NativeFunction("sin", ["number"], "number");
		sin.write("POP 0");
		sin.write("EXE sin, &0");
		
		var log:NativeFunction = new NativeFunction("log", ["number"], "number");
		log.write("POP 0");
		log.write("EXE abs, &0");
		
		var sqrt:NativeFunction = new NativeFunction("sqrt", ["number"], "number");
		sqrt.write("POP 0");
		sqrt.write("EXE abs, &0");
		
		var pow:NativeFunction = new NativeFunction("pow", ["number", "number"], "number");
		pow.write("POP 0");
		pow.write("POP 1");
		pow.write("EXE pow, &0, &1");
		
		var random:NativeFunction = new NativeFunction("random", [], "number");
		random.write("POP 0");
		random.write("EXE random, &0");		
		
		addClass(number);
		addClass(string);
		addClass(array);
		addClass(boolean);
		addClass(void);
		
		addFunction(print);
		addFunction(exit);
		addFunction(whoami);
	}
	
	/**
	 * 네이티브 라이브러리에 클래스를 추가한다.
	 * 
	 * @param	nativeClass
	 */
	public function addClass(nativeClass:NativeClass):Void {
		classes.push(nativeClass);
	}

	/**
	 * 네이티브 라이브러리에 함수를 추가한다.
	 * 
	 * @param	nativeFunction
	 */
	public function addFunction(nativeFunction:NativeFunction):Void {
		functions.push(nativeFunction);
	}

	/**
	 * 네이티브 라이브러리를 심볼 테이블에 로드한다.
	 * 
	 * @param symbolTable
	 */
	public function load(symbolTable:SymbolTable):Void {

		// 클래스 입력
		for ( i in 0...classes.length ) {
			symbolTable.add(new ClassSymbol(classes[i].className));
		}

		// 함수 입력
		for ( i in 0...functions.length ) {
			var parameters:Array<VariableSymbol> = new Array<VariableSymbol>();
			
			// 파라미터 처리
			for (j in 0...functions[i].parameters.length)
				parameters.push(new VariableSymbol("native_arg_" + Std.string(j), functions[i].parameters[j]));

			// 함수 심볼 객체 생성
			var functn:FunctionSymbol = new FunctionSymbol(functions[i].functionName, functions[i].returnType, parameters);
						
			functn.isNative = true;
			functn.nativeFunction = functions[i];

			symbolTable.add(functn);
		}
	}
}