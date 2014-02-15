package elsa.symbol;

/**
 * 리터럴 심볼
 */
class LiteralSymbol extends Symbol {
	
	public static var NUMBER:String = "number";
	public static var STRING:String = "string";

	public var value:String;

	public function new(value:String, type:String) {
				
		super();
		
		this.value = value;
		this.type = type;
	}
}