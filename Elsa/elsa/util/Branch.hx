package elsa.util;

/**
 * ...
 * @author 김 현준
 */
class Branch<T> {

	/**
	 * 파생 가지를 가지고 있는지의 여부
	 */
	public var hasBranch:Bool = false;
	
	/**
	 * 파생 가지
	 */
	public var branch:Array<Branch<T>>;
	
	public function new() {
		
	}
	
}