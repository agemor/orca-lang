package elsa;
import sys.io.File;
/**
 * ...
 * @author 김 현준
 */
class Launcher {
	
	public static function main() {
		
		haxe.Log.trace = function (log, ?d) Sys.print(log +  "\n");
		
		var token:Token = new Token(Token.Type.ADDITION);
		var lexer:Lexer = new Lexer();
		
		var source:String = File.getContent("test_code.el");
		var lextree:Lexer.Lextree = lexer.analyze(source);
		//lexer.viewHierarchy(lextree, 0);
		
		//TokenTools.view2D(TokenTools.getArguments(lexer.analyze("A,B,C,D,E,,F     G,G").branch[0].lexData));
		TokenTools.view2D(TokenTools.split(lexer.analyze("A,B,C,D,E,,F     G,G").branch[0].lexData, Token.Type.COMMA));
		Sys.sleep(10000);
		
	}
	
}