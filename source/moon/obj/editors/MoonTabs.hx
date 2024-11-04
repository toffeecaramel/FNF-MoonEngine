package moon.obj.editors;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import moon.obj.editors.*;

class MoonTabs extends FlxGroup
{
    private var tabs:Array<{name:String, tag:String}>;
    private var tabGroups:Map<String, FlxGroup>;
    private var activeTab:String;
    private var labels:Array<WhiteButton>;
    private var xPos:Float;
    private var yPos:Float;

    public function new(x:Float, y:Float, tabs:Array<{name:String, tag:String}>)
    {
        super();
        this.tabs = tabs;
        this.tabGroups = new Map<String, FlxGroup>();
        this.labels = [];
        this.xPos = x;
        this.yPos = y;
        
        initializeTabs();
    }

    private function initializeTabs():Void
    {
        var yOffset:Float = 0;

        for (tab in tabs)
        {
            var labelButton:WhiteButton = createTabLabel(tab, xPos, yPos + yOffset);
            labels.push(labelButton);
            add(labelButton);
            yOffset += labelButton.height + 4;
            
            var tabGroup = new FlxGroup();
            tabGroup.visible = false;
            tabGroups.set(tab.tag, tabGroup);
            add(tabGroup);
        }
        
        if (tabs.length > 0)
            activateTab(tabs[0].tag);
    }

    var labelButton:WhiteButton;
    private function createTabLabel(tab:{name:String, tag:String}, x:Float, y:Float):WhiteButton
    {
        labelButton = new WhiteButton(x, y, Paths.image('editors/bIcons/${cast tab.tag}'), () -> activateTab(tab.tag), true, flixel.util.FlxColor.BLACK);
        labelButton.tag = tab.tag;
        labelButton.sizeByHalf = true;
        labelButton.hasAlphaChange = false;
        return labelButton;
    }

    private function activateTab(tag:String):Void
    {
        // Hide all tab groups
        for (tabGroup in tabGroups)
            tabGroup.visible = false;

        activeTab = tag;
        tabGroups.get(tag).visible = true;
        
        for (label in labels)
            label.alpha = (label.tag == activeTab) ? 1 : 0.6;
    }

    /**
     * Adds an object to a specific tab by tag.
     * @param tag The tag of the tab to add to.
     * @param obj The FlxObject to add to the tab.
     */
    public function addToTab(tag:String, obj:Dynamic):Void
    {
        (tabGroups.exists(tag)) ? tabGroups.get(tag).add(obj) : trace('Tab with tag \'$tag\' does not exist. Please specify a valid one!', "ERROR");
    }
}
