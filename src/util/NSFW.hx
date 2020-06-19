package util;

import js.Promise;

@:enum
abstract EventAction (Int) from Int to Int
{
	var CREATED;
	var DELETED;
	var MODIFIED;
	var RENAMED;
}

typedef Event =
{
	/**
	 * The type of event that occurred.
	 */
	action:EventAction,
	/**
	 * The location the event took place.
	 */
	directory:String,
	/**
	 * The name of the file that was changed (Not available for rename events).
	 */
	?file:String,
	/**
	 * The name of the file before a rename (Only available for rename events).
	 */
	 ?oldFile:String,
	 /**
		* The new location of the file (Only available for rename events, only useful on linux).
		*/
	 ?newDirectory:String,
	 /**
		* The name of the file after a rename (Only available for rename events).
		*/
	 ?newFile:String
}

@:jsRequire('nsfw')
extern class NSFW
{
	// public function new():Void;

	@:selfCall
	public static function create(path:String, events:Array<Event>->Void):Promise<NSFW>;

	public function start():Promise<Void>;

	public function stop():Promise<Void>;
}