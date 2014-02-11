package elsa;

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
		
	}
	
}