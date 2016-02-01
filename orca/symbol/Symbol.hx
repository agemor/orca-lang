package orca.symbol;
import orca.nlib.NativeFunction;

/**
 * 심볼 클래스
 * 
 * @author 김 현준
 */
class Symbol {
	
	/**
	 * 심볼 데이터
	 */
	public var id:String;
	public var type:String;
	
	/**
	 * 심볼의 메모리 할당 주소
	 */
	public var address:Int;	
	
	public function new() {	}
	
}