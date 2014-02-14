package elsa;
import sys.io.File;
/**
 * ...
 * @author 김 현준
 */
class Launcher {
	
	public static function main() {
		
		haxe.Log.trace = function (log, ?d) Sys.println(log);
		
		trace("Orca Compiler 2.0 (Unstable)");
		
		// 테스트용 오르카 소스
		var variable_test:String = File.getContent("test/variable_test.orca");
		var function_test:String = File.getContent("test/function_test.orca");
		var array_test:String = File.getContent("test/array_test.orca");
		var class_test:String = File.getContent("test/class_test.orca");
		var if_test:String = File.getContent("test/if_test.orca");
		var for_test:String = File.getContent("test/for_test.orca");
		var while_test:String = File.getContent("test/while_test.orca");
		
		var parser:Parser = new Parser();
		
		var compiledCode:String = parser.compile(variable_test);
		trace(compiledCode);
		
		
		var machine: elsa.vm.Machine = new elsa.vm.Machine(1024 * 20, 20);
		//var oasm = File.getContent("test_code.oasm");
		trace("-- orca assembly --");
		//trace(oasm);
		machine.load(compiledCode);
		//machine.load("EXE print, test\nEXE whoami\nEND");
		machine.run();
		
		Sys.sleep(10000);	
	}	
}