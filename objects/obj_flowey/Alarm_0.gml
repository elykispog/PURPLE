


    if (myTextbox == noone) {
        myTextbox = instance_create_layer(x, y, "Text", obj_textbox);
        myTextbox.text = myText;
        myTextbox.creator = self;
		global.cutscene_active = true;
			
    }
;