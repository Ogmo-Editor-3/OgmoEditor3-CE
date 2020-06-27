package util;

class About
{
    public static inline var WEBSITE_URL = "https://ogmo-editor-3.github.io/";
    public static inline var USER_MANUAL_URL = "https://ogmo-editor-3.github.io/docs/#/manual/introduction.md";
    public static inline var COMMUNITY_FORUM_URL = "https://ogmoeditor.itch.io/editor/community";
    public static inline var SOURCE_CODE_URL = "https://github.com/Ogmo-Editor-3/OgmoEditor3-CE";
    public static inline var REPORT_ISSUE_URL = "https://github.com/Ogmo-Editor-3/OgmoEditor3-CE/issues";

    public  static inline var MATT_THORSON_URL = "https://twitter.com/mattthorson";
    public  static inline var NOEL_BERRY_URL = "https://twitter.com/noelfb";
    public  static inline var KYLE_PULVER_URL = "https://twitter.com/kylepulver";
    public  static inline var CALEB_CORNETT_URL = "https://twitter.com/thespydog";
    public  static inline var WILL_BLANTON_URL = "https://twitter.com/x01010111";
    public  static inline var AUSTIN_EAST_URL = "https://twitter.com/austinweast";

    public static function getPopupHTML(version:String)
    {
        return '
<div class="about-ogmo">
    <p><img src="gfx/logo.png" draggable="false"></p>
    <p class="version">VERSION $version</p>
    <p>
        <p class="list-header">LINKS</p>
        <ul>
            <li>${link("Website", WEBSITE_URL)}</li>
            <li>${link("User Manual", USER_MANUAL_URL)}</li>
            <li>${link("Community Forum", COMMUNITY_FORUM_URL)}</a></li>
            <li>${link("Source Code", SOURCE_CODE_URL)}</li>
            <li>${link("Report Issue", REPORT_ISSUE_URL)}</li>
        </ul>
    </p>
    <p>
        <p class="list-header">CREDITS</p>
        <ul>
            <li>Created by ${link("Matt Thorson", MATT_THORSON_URL)} and ${link("Noel Berry", NOEL_BERRY_URL)}</li>
            <li>Icons & Logo by ${link("Kyle Pulver", KYLE_PULVER_URL)}</li>
            <li>Ported to Haxe and extended by ${link("Caleb Cornett", CALEB_CORNETT_URL)}, ${link("Will Blanton", WILL_BLANTON_URL)}, and ${link("Austin East", AUSTIN_EAST_URL)}</li>
        </ul>
    </p>
</div>
';
    }

    private static function link(label:String, url:String):String
    {
        return '<a href="$url" draggable="false">$label</a>';
    }
}
