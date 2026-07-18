function file_read(_fname) {
	var _file = file_text_open_read(_fname);
	var _text = "";
	
	while (!file_text_eof(_file)) {
		_text += file_text_read_string(_file);
		file_text_readln(_file);
	}
	
	file_text_close(_file);
	
	return _text;
}

function file_list(_path) {
	var _result = [];
	
	var _item = file_find_first(_path + "*", fa_archive);
	
	while (_item != "") {
		array_push(_result, _item);
		_item = file_find_next();
	}
	
	file_find_close();
	
	return _result;
}

function file_list_recursive(_path, _filter = undefined) {
	var _result = [];
	var _dirs = [];

	var _item = file_find_first(_path + "*", fa_archive | fa_directory);

	while (_item != "") {
		var _full = _path + _item;
		
		if (directory_exists(_full)) {
			array_push(_dirs, _item);
		}
		else if (_filter == undefined || filename_ext(_item) == _filter) {
			array_push(_result, _item);
		}

		_item = file_find_next();
	}
	
	file_find_close();
	
	for (var i = 0; i < array_length(_dirs); ++i) {
		var _children = file_list_recursive(_path + _dirs[i] + "/", _filter);

		for (var j = 0; j < array_length(_children); ++j) {
			array_push(_result, _dirs[i] + "/" + _children[j]);
		}
	}
	
	return _result;
}