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
		
		var source:String = File.getContent("test_code.el");
		var parser:Parser = new Parser();
		
		trace(parser.compile(source));
		
		var machine: elsa.vm.Machine = new elsa.vm.Machine(1024 * 20, 20);
		var oasm = File.getContent("test_code.oasm");
		trace("-- orca assembly --");
		trace(oasm);
		//machine.load(oasm);
		machine.load("EXE print, test\nEXE whoami\nEND");
		machine.run();
		
		Sys.sleep(10000);	
	}	
}