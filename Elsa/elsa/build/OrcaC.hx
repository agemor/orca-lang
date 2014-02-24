package elsa.build;
import elsa.debug.Debug;
import elsa.Parser;
import sys.FileSystem;
import sys.io.File;

/**
 * Orca compilation program
 * 
 * @author 김 현준
 */
class OrcaC {

	public static function main() {
		Sys.println("Orca Compiler 1.0.1 - (C)2014 HyunJun Kim\n");
		
		var arguments:Array<String> = Sys.args();	
		if(arguments.length < 1){
			Sys.println("Usage: orcac <.orca file> <.orx file> [options]");
			return;
		} else if (arguments.length < 2) {
			arguments[1] = arguments[0].substring(0, arguments[0].lastIndexOf(".")) + ".orx";
		}
		
		var source:String = readSource(arguments[0]);		
		if (source == null) return;
		
		var parser:Parser = new Parser();
		var program:String = parser.compile(source, Sys.getCwd());
		
		if (!Debug.errorReported) {
			writeExcutable(arguments[1], program);
			Sys.println("Successfully compiled.");
		}
		
	}
	
	public static function readSource(path:String):String {
		if (!FileSystem.exists(path)) {
			Sys.println("Error: source path '" + path + "' not exists.");
			return null;
		}
		return File.getContent(path);
	}
	
	public static function writeExcutable(path:String , program:String):Void {
		try {
			File.saveContent(path, program);
		} catch (error:String) {
			Sys.println("Error: cannot write .orx file. " + error);
		}
		
	}
	
}