package project.editor.value;

import js.jquery.JQuery;
import project.data.value.ValueTemplate;

class ValueTemplateEditor
{
  public var template:ValueTemplate;

  public function new(template:ValueTemplate)
  {
    this.template = template;
  }

  /**
   * Originally `import`. Name changed to due to keyword being reserved in Haxe
   * @param into 
   */
  public function importInto(into:JQuery) {}

  public function save() {}
}