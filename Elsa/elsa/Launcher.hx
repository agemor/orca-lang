package elsa;
import elsa.vm.Machine;
import elsa.debug.Debug;
import sys.io.File;
/**
 * Orca Compiler & VM Launcher
 * 
 * @author 김 현준
 */
class Launcher {
	
	public static function main() {
		
		Debug.print("Orca BELUGA Compiler 2.0 (Unstable)");		
		
		// 테스트용 오르카 소스
		var temp_test:String = File.getContent("test/temp.orca");
		var variable_test:String = File.getContent("test/variable_test.orca");
		var function_test:String = File.getContent("test/function_test.orca");
		var array_test:String = File.getContent("test/array_test.orca");
		var class_test:String = File.getContent("test/class_test.orca");
		var if_test:String = File.getContent("test/if_test.orca");
		var for_test:String = File.getContent("test/for_test.orca");
		var while_test:String = File.getContent("test/while_test.orca");
		var include_test:String = File.getContent("test/include_test.orca");
		var evaluator:String = File.getContent("test/evaluator.orca");
		
		var parser:Parser = new Parser();
		
		var compiledCode:String = parser.compile(include_test, "test/");
		//Debug.print(compiledCode);
		
		if (!Debug.errorReported){		
		
			var vm:Machine = new Machine();
			vm.load(compiledCode);
			
			Debug.print("-----------------init-----------------");
			vm.run();
			Debug.print("--------------------------------------");
		}
		Debug.print("Press any key to exit...");
		Sys.getChar(false);
	}	
}