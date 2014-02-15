package elsa;
import elsa.vm.Orcinus;
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
		var temp_test:String = File.getContent("test/temp.orca");
		var variable_test:String = File.getContent("test/variable_test.orca");
		var function_test:String = File.getContent("test/function_test.orca");
		var array_test:String = File.getContent("test/array_test.orca");
		var class_test:String = File.getContent("test/class_test.orca");
		var if_test:String = File.getContent("test/if_test.orca");
		var for_test:String = File.getContent("test/for_test.orca");
		var while_test:String = File.getContent("test/while_test.orca");
		
		var parser:Parser = new Parser();
		
		var compiledCode:String = parser.compile(class_test);
		trace(compiledCode);
		
		var vm:Orcinus = new Orcinus();
		vm.load(compiledCode);
		
		trace("-----------------init-----------------");
		vm.run();
		trace("--------------------------------------");
		
		File.saveContent("program.orx", compiledCode);
		Sys.sleep(10000);	
	}	
}