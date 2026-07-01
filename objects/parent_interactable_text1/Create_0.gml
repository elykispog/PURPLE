myTextbox = noone;

myText[0] = ""

interact = function() {
    if (myTextbox == noone) {
        myTextbox = instance_create_layer(x, y, "Text", obj_textbox_bottom);
        myTextbox.text = myText;
        myTextbox.creator = self;
		global.cutscene_active = true;
    }
};