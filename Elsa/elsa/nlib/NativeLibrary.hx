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
		print.write("IVK 1");
		
		var read:NativeFunction = new NativeFunction("read", [], "string");
		read.write("IVK 2");
		
		var exit:NativeFunction = new NativeFunction("exit", [], "void");
		exit.write("END");

		var info:NativeFunction = new NativeFunction("info", [], "void");
		info.write("IVK 3");
		
		var abs:NativeFunction = new NativeFunction("abs", ["number"], "number");
		abs.write("IVK 4");
		
		var acos:NativeFunction = new NativeFunction("acos", ["number"], "number");
		acos.write("IVK 5");
		
		var asin:NativeFunction = new NativeFunction("asin", ["number"], "number");
		asin.write("IVK 6");
		
		var atan:NativeFunction = new NativeFunction("atan", ["number"], "number");
		atan.write("IVK 7");
		
		var atan2:NativeFunction = new NativeFunction("atan2", ["number", "number"], "number");
		atan2.write("IVK 8");
		
		var ceil:NativeFunction = new NativeFunction("ceil", ["number"], "number");
		ceil.write("IVK 9");
		
		var floor:NativeFunction = new NativeFunction("floor", ["number"], "number");
		floor.write("IVK 10");
		
		var round:NativeFunction = new NativeFunction("round", ["number"], "number");
		round.write("IVK 11");
		
		var cos:NativeFunction = new NativeFunction("cos", ["number"], "number");
		cos.write("IVK 12");
		
		var sin:NativeFunction = new NativeFunction("sin", ["number"], "number");
		sin.write("IVK 13");
		
		var tan:NativeFunction = new NativeFunction("tan", ["number"], "number");
		tan.write("IVK 14");
		
		var log:NativeFunction = new NativeFunction("log", ["number"], "number");
		log.write("IVK 15");
		
		var sqrt:NativeFunction = new NativeFunction("sqrt", ["number"], "number");
		sqrt.write("IVK 16");
		
		var pow:NativeFunction = new NativeFunction("pow", ["number", "number"], "number");
		pow.write("IVK 17");
		
		var random:NativeFunction = new NativeFunction("random", [], "number");
		random.write("IVK 18");	
		
		addClass(number);
		addClass(string);
		addClass(array);
		addClass(boolean);
		addClass(void);
		
		addFunction(print);		
		addFunction(read);
		addFunction(info);
		addFunction(exit);
		addFunction(abs);
		addFunction(asin);
		addFunction(acos);
		addFunction(atan);
		addFunction(atan2);
		addFunction(ceil);
		addFunction(floor);
		addFunction(round);
		addFunction(cos);
		addFunction(sin);
		addFunction(tan);
		addFunction(log);
		addFunction(sqrt);
		addFunction(pow);
		addFunction(random);
		
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
			symbolTable.classes.push(new ClassSymbol(classes[i].className));
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
			
			symbolTable.functions.push(functn);
		}
	}
}