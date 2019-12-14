package project.data;

import sys.io.File;
import js.node.vm.Script;

class ProjectHooks
{
  private var script:Script;
  private var beforeSaveLevelFn:Dynamic;
  private var beforeSaveProjectFn:Dynamic;

  public function new(scriptFile:String) {
    if (scriptFile.length <= 0) {
      return;
    }

    if (!sys.FileSystem.exists(scriptFile)) {
      return;
    }

    var contents:String = File.getContent(scriptFile);
    script = new Script(contents, {filename: scriptFile});
    var scriptObject:Dynamic = script.runInThisContext();

    if (js.Lib.typeof(scriptObject) != "object") {
      return;
    }

    beforeSaveLevelFn = js.Lib.typeof(scriptObject.beforeSaveLevel) == "function" ? scriptObject.beforeSaveLevel : null;
    beforeSaveProjectFn = js.Lib.typeof(scriptObject.beforeSaveProject) == "function" ? scriptObject.beforeSaveProject : null; 
  }

  public function BeforeSaveLevel(project:Project, data:Dynamic):Dynamic {
    if (beforeSaveLevelFn == null) {
      return data;
    }
    
    return beforeSaveLevelFn(project, data);
  }

  public function BeforeSaveProject(project:Project, data:Dynamic):Dynamic {
    if (beforeSaveProjectFn == null) {
      return data;
    }
    
    return beforeSaveProjectFn(project, data);
  }
}