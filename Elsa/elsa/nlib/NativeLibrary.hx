package elsa.nlib;
import elsa.Symbol.Class;
import elsa.Symbol.Function;
import elsa.Symbol.Variable;
import elsa.SymbolTable;

/**
 * 네이티브 라이브러리
 * 
 * @author 김 현준
 */
class NativeLibrary {

	public static var classes:Array<NativeClass>;
	public static var functions:Array<NativeFunction>;
	private static var initialized:Bool = false;
	
	/**
	 * 네이티브 라이브러리를 초기화한다.
	 */
	public static function initialize():Void {
		
		if (initialized) return;
		initialized = true;
		
		classes = new Array<NativeClass>();
		functions = new Array<NativeFunction>();

		var number:NativeClass = new NativeClass("number");
		var string:NativeClass = new NativeClass("string");
		var array:NativeClass = new NativeClass("array");

		var print:NativeFunction = new NativeFunction("print", ["string"], "void");
		print.write("POP 0");
		print.write("EXE print, &0");

		var whoami:NativeFunction = new NativeFunction("whoami", [], "void");
		whoami.write("EXE whoami");

		addClass(number);
		addClass(string);
		addClass(array);

		addFunction(print);
		addFunction(whoami);
	}

	public NativeLibrary() { }

	/**
	 * 네이티브 라이브러리에 클래스를 추가한다.
	 * 
	 * @param	nativeClass
	 */
	public static function addClass(nativeClass:NativeClass):void {
		classes.push(nativeClass);
	}

	/**
	 * 네이티브 라이브러리에 함수를 추가한다.
	 * 
	 * @param	nativeFunction
	 */
	public static function addFunction(nativeFunction:NativeFunction):void {
		functions.push(nativeFunction);
	}

	/**
	 * 네이티브 라이브러리를 심볼 테이블에 로드한다.
	 * 
	 * @param symbolTable
	 */
	public static function load(symbolTable:SymbolTable):Void {

		// 클래스 입력
		for ( i in 0...classes.length ) {
			var classs:Class = new Class(classes[i].className);
		
			symbolTable.local.set(classs.id, classs);
		}

		// 함수 입력
		for ( i in 0...functions.length ) {
			var parameters:Array<Variable> = new Array<Variable>();
			
			// 파라미터 처리
			for (j in 0...functions[i].parameters.length)
				parameters.push(new Variable("native_arg_" + Std.string(j), functions[i].parameters[j]));

			// 함수 심볼 객체 생성
			var functn:Function = new Function(functions[i].functionName, functions[i].returnType, parameters);

			functn.isNative = true;
			functn.nativeFunction = functions[i];

			symbolTable.local.set(functn.id, functn);
		}

	}
	
}