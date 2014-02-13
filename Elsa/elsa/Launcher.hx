package elsa;
import sys.io.File;
/**
 * ...
 * @author 김 현준
 */
class Launcher {
	
	public static function main() {
		
		haxe.Log.trace = function (log, ?d) Sys.print(log +  "\n");
		
		trace("Orca Compiler 2.0 (Unstable)");
		
		var source:String = File.getContent("test_code.el");
		var parser:Parser = new Parser();
		
		trace(parser.compile(source));
		
		Sys.sleep(10000);	
	}	
}