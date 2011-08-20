var ArrayFields = new Class({
	version: 0.1,

	// Implements: [Options, Events],

	initialize: function(_object, _options) {
		if ( ! _object) { return; }
		// this.setOptions(_options);
		var elem = _object;
		var template = elem.getElement('input').clone().erase('value');
		new Element('span.add_field', {text: '+'})
			.inject(elem)
			.addEvent('click', function(e){
				template.clone().inject(e.target, 'before');
			});
		
		elem.getParent('form').addEvent('submit', function(){
			elem.getElements('.array_fields').each(function(input){
				if (input.value) { return; }
				input.erase('name');
			});
			return true;
		});
	}
});