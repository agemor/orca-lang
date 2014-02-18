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
		var array:NativeClass = new NativeClass("array", []);
		var void:NativeClass = new NativeClass("void", []);

		var print:NativeFunction = new NativeFunction("print", ["*"], "void");
		print.write("POP 0");
		print.write("EXE print, &0");
		
		var exit:NativeFunction = new NativeFunction("exit", [], "void");
		exit.write("END");

		var whoami:NativeFunction = new NativeFunction("whoami", [], "void");
		whoami.write("EXE whoami");

		addClass(number);
		addClass(string);
		addClass(array);
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
			var classs:ClassSymbol = new ClassSymbol(classes[i].className);
		
			symbolTable.local.set(classs.id, classs);
		}

		// 함수 입력
		for ( i in 0...functions.length ) {
			var parameters:Array<VariableSymbol> = new Array<VariableSymbol>();
			
			// 파라미터 처리
			for (j in 0...functions[i].parameters.length)
				parameters.push(new VariableSymbol("native_arg_" + Std.string(j), functions[i].parameters[j]));

			// 함수 심볼 객체 생성
			var functn:FunctionSymbol = new FunctionSymbol(functions[i].functionName, functions[i].returnType, parameters.length > 0 ? parameters : new Array<VariableSymbol>());
						
			functn.isNative = true;
			functn.nativeFunction = functions[i];

			symbolTable.local.set(functn.id, functn);
		}

	}
	
	
}