package elsa;
import sys.io.File;
/**
 * ...
 * @author 김 현준
 */
class Launcher {
	
	public static function main() {
		for( i in 0...10)
		trace(Token.Affix.SUFFIX);
		
		var token:Token = new Token(Token.Type.ADDITION);
		var lexer:Lexer = new Lexer();
		
		var source:String = File.getContent("test_code.el");
		trace(source);
		
		var lextree:Lexer.Lextree = lexer.analyze(source);
		lexer.viewHierarchy(lextree, 0);
		
		Sys.sleep(10000);
		
	}
	
}