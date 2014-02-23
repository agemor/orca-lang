package elsa;
import elsa.vm.Machine;
import sys.io.File;

/**
 * ...
 * @author 김 현준
 */
class LauncherForWeb {

	public static function main() {
		haxe.Log.Debug.print = function (log, ?d) Sys.println(log+"<br/>");
		
		var targetCode:String = File.getContent("target.orca");
		
		var parser:Parser = new Parser();
		
		var compiledCode:String = parser.compile(targetCode);
		
		var vm:Machine = new Machine();
		vm.load(compiledCode);		
		vm.run();
		
		Debug.print("<br/><br/>참고: 이 프로그램의 오르카 어셈블리는:");
		Debug.print(StringTools.replace(compiledCode, "\n", "<br/>"));
		
	}
	
}