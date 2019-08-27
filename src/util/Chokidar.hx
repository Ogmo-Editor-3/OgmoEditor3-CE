package util;

import js.Error;
import js.node.fs.Stats;
import haxe.ds.Either;

typedef WatchOptions =
{
  /**
   * Indicates whether the process should continue to run as long as files are being watched. If
   * set to `false` when using `fsevents` to watch, no more events will be emitted after `ready`,
   * even if the process continues to run.
   */
  ?persistent:Bool,
  /**
   * ([anymatch](https://github.com/es128/anymatch)-compatible definition) Defines files/paths to
   * be ignored. The whole relative or absolute path is tested, not just filename. If a function
   * with two arguments is provided, it gets called twice per path - once with a single argument
   * (the path), second time with two arguments (the path and the
   * [`fs.Stats`](http://nodejs.org/api/fs.html#fs_class_fs_stats) object of that path).
   */
  ?ignored:Dynamic,
  /**
   * If set to `false` then `add`/`addDir` events are also emitted for matching paths while
   * instantiating the watching as chokidar discovers these file paths (before the `ready` event).
   */
  ?ignoreInitial:Bool,
  /**
   * When `false`, only the symlinks themselves will be watched for changes instead of following
   * the link references and bubbling events through the link's path.
   */
  ?followSymlinks:Bool,
  /**
   * The base directory from which watch `paths` are to be derived. Paths emitted with events will
   * be relative to this.
   */
  ?cwd:String,
  /**
   *  If set to true then the strings passed to .watch() and .add() are treated as literal path
   *  names, even if they look like globs. Default: false.
   */
  ?disableGlobbing:Bool,
  /**
   * Whether to use fs.watchFile (backed by polling), or fs.watch. If polling leads to high CPU
   * utilization, consider setting this to `false`. It is typically necessary to **set this to
   * `true` to successfully watch files over a network**, and it may be necessary to successfully
   * watch files in other non-standard situations. Setting to `true` explicitly on OS X overrides
   * the `useFsEvents` default.
   */
  ?usePolling:Bool,
  /**
   * Whether to use the `fsevents` watching interface if available. When set to `true` explicitly
   * and `fsevents` is available this supercedes the `usePolling` setting. When set to `false` on
   * OS X, `usePolling: true` becomes the default.
   */
  ?useFsEvents:Bool,
  /**
   * If relying upon the [`fs.Stats`](http://nodejs.org/api/fs.html#fs_class_fs_stats) object that
   * may get passed with `add`, `addDir`, and `change` events, set this to `true` to ensure it is
   * provided even in cases where it wasn't already available from the underlying watch events.
   */
  ?alwaysStat:Bool,
  /**
   * If set, limits how many levels of subdirectories will be traversed.
   */
  ?depth:Int,
  /**
   * Interval of file system polling.
   */
  ?interval:Float,
  /**
   * Interval of file system polling for binary files. ([see list of binary extensions](https://gi
   * thub.com/sindresorhus/binary-extensions/blob/master/binary-extensions.json))
   */
  ?binaryInterval:Int,
  /**
   *  Indicates whether to watch files that don't have read permissions if possible. If watching
   *  fails due to `EPERM` or `EACCES` with this set to `true`, the errors will be suppressed
   *  silently.
   */
  ?ignorePermissionErrors:Bool,
  /**
   * `true` if `useFsEvents` and `usePolling` are `false`). Automatically filters out artifacts
   * that occur when using editors that use "atomic writes" instead of writing directly to the
   * source file. If a file is re-added within 100 ms of being deleted, Chokidar emits a `change`
   * event rather than `unlink` then `add`. If the default of 100 ms does not work well for you,
   * you can override it by setting `atomic` to a custom value, in milliseconds.
   */
  ?atomic:Dynamic,
  /**
   * can be set to an object in order to adjust timing params:
   */
  ?awaitWriteFinish:Dynamic
}

extern class FSWatcher extends js.node.fs.FSWatcher
{
  public var options:WatchOptions;

  /**
   * Constructs a new FSWatcher instance with optional WatchOptions parameter.
   */
  public function new(?options:WatchOptions);

  /**
   * Add files, directories, or glob patterns for tracking. Takes an array of strings or just one
   * string.
   */
  @:overload(function(path:String):Void {})
  public function add(paths:Array<String>):Void;

  /**
   * Stop watching files, directories, or glob patterns. Takes an array of strings or just one
   * string.
   */
  @:overload(function(path:String):Void {})
  public function unwatch(paths:Array<String>):Void;

  /**
   * Returns an object representing all the paths on the file system being watched by this
   * `FSWatcher` instance. The object's keys are all the directories (using absolute paths unless
   * the `cwd` option was used), and the values are arrays of the names of the items contained in
   * each directory.
   */
  public function getWatched(): Map<String, String>;

  /**
   * Removes all listeners from watched files.
   */
  public function close():Void;

  @:overload(function(event:String, listener:String->Void):FSWatcher {})
  @:overload(function(event:String, listener:String->Stats->Void):FSWatcher {})
  @:overload(function(event:String, listener:String->String->Stats->Void):FSWatcher {})
  @:overload(function(event:String, listener:String->String->Dynamic->Void):FSWatcher {})
  @:overload(function(event:String, error:js.lib.Error->Void):FSWatcher {})
  public function on(event:String, listener:Void->Void):FSWatcher;
}

// TODO - ran tests and decided not to use. Separate out into its own haxelib lib? - austin
@:jsRequire("chokidar")
extern class Chokidar
{
  @:overload(function(path:String, ?options: WatchOptions):FSWatcher {})
  public static function watch(paths:Array<String>, ?options: WatchOptions):FSWatcher;
}