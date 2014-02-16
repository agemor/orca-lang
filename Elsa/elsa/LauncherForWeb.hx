package elsa;
import elsa.vm.Orcinus;
import sys.io.File;

/**
 * ...
 * @author 김 현준
 */
class LauncherForWeb {

	public static function main() {
		haxe.Log.trace = function (log, ?d) Sys.println(log+"<br/>");
		
		var targetCode:String = File.getContent("target.orca");
		
		var parser:Parser = new Parser();
		
		var compiledCode:String = parser.compile(targetCode);
		
		var vm:Orcinus = new Orcinus();
		vm.load(compiledCode);		
		vm.run();
		
		trace("<br/><br/>참고: 이 프로그램의 오르카 어셈블리는:");
		trace(StringTools.replace(compiledCode, "\n", "<br/>"));
		
	}
	
}