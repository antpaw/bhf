var ArrayFields = new Class({
	version: 0.1,

	// Implements: [Options, Events],

	initialize: function(_object, _options) {
		if ( ! _object) { return; }
		// this.setOptions(_options);
		var elem = _object;
		var template = elem.getElement('input').clone().erase('value');
		var currentNr = 0;
		
		new Element('span.plus_button.qe_button.default_form_align', {text: '+'})
			.inject(elem)
			.addEvent('click', function(e){
				var newInput = template.clone();
				var arrayI = newInput.get('name').match(/.+?\[(\d+)\].+/);
				if (arrayI && arrayI[1]) {
					currentNr += 1;
					newInput.set('name',
						newInput.get('name')
							.replace(/(.+?\[)\d+(\].+)/, '$1'+(parseInt(arrayI[1], 10)+currentNr)+'$2')
					);
				}
				newInput.inject(e.target, 'before');
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