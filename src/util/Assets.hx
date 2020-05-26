package util;

import haxe.io.Path;
/**
 * Macro for copying assets from one folder to another
 */
class Assets {
	#if macro
	public static function copy() {
		var cwd:String = Sys.getCwd();
		var assetsDstFolder = Path.join([cwd, "bin"]);

		// make sure the assets folder exists
		if (!sys.FileSystem.exists(assetsDstFolder)) sys.FileSystem.createDirectory(assetsDstFolder);

		// copy files
		copyProjectAssets(assetsDstFolder);
		copyPackageJson(assetsDstFolder);
	}
	static function copyProjectAssets(targetDir:String) {
		var cwd:String = Sys.getCwd();
		var assetSrcFolder = Path.join([cwd, "assets"]);

		// copy it!
		var numCopied = copyDir(assetSrcFolder, targetDir);
		Sys.println('Copied ${numCopied} project assets to ${targetDir}!');
	}

	static function copyPackageJson(targetDir:String) {
		var cwd:String = Sys.getCwd();
		var packageFile = Path.join([cwd, "package.json"]);
		var dstFile:String = Path.join([targetDir, "package.json"]);

		// copy it!
		sys.io.File.copy(packageFile, dstFile);
		Sys.println('Copied package.json to ${targetDir}!');
	}

	static function copyDir(sourceDir:String, targetDir:String):Int {
		var numCopied:Int = 0;

		if (!sys.FileSystem.exists(targetDir)) sys.FileSystem.createDirectory(targetDir);

		for (entry in sys.FileSystem.readDirectory(sourceDir)) {
			var srcFile:String = Path.join([sourceDir, entry]);
			var dstFile:String = Path.join([targetDir, entry]);

			if (sys.FileSystem.isDirectory(srcFile)) numCopied += copyDir(srcFile, dstFile);
			else {
				sys.io.File.copy(srcFile, dstFile);
				numCopied++;
			}
		}
		return numCopied;
	}
	#end
}