package orca.build;
import orca.vm.Machine;
import sys.FileSystem;
import sys.io.File;

/**
 * Orca VM
 * 
 * @author 김 현준
 */
class OrcaV {

	public static function main() {
		var arguments:Array<String> = Sys.args();
		
		if (arguments.length < 1) {
			Sys.println("Orca 1.0.3 - (C)2014 HyunJun Kim\n");
			Sys.println("Usage: orca <.orx file>");
			return;
		}
		
		var program:String = readProgram(arguments[0]);		
		if (program == null) return;		
		
		var machine:Machine = new Machine();
		machine.load(program);
		machine.run();
		
		Sys.println("press any key to exit...");
		Sys.getChar(false);
	}
	
	public static function readProgram(path:String):String {
		if (!FileSystem.exists(path)) {
			Sys.println("Error: program path '" + path + "' not exists.");
			return null;
		}
		return File.getContent(path);
	}
}