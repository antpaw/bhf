var ArrayFields = new Class({
	version: 0.1,

	// Implements: [Options, Events],

	initialize: function(_object, _options) {
		if ( ! _object) { return; }
		// this.setOptions(_options);
		var elem = _object;
		var template = elem.getElement('.array_fields').clone();
		var currentNr = 0;
		
		new Element('span.plus_button.qe_button.default_form_align', {text: '+'})
			.inject(elem)
			.addEvent('click', function(e){
			  var holder = template.clone();
				var newInput = (holder.getElement('input') || holder).erase('value');
				var arrayI = newInput.get('name').match(/.+?\[(\d+)\].+/);
				if (arrayI && arrayI[1]) {
					currentNr += 1;
					newInput.set('name',
						newInput.get('name')
							.replace(/(.+?\[)\d+(\].+)/, '$1'+(parseInt(arrayI[1], 10)+currentNr)+'$2')
					);
				}
				holder.inject(e.target, 'before');
				window.fireEvent('bhfDomChunkReady', [holder]);
			});
		
		elem.getParent('form').addEvent('submit', function(){
			elem.getElements('.array_fields').each(function(fieldElem){
				var input = (fieldElem.getElement('input') || fieldElem);
				if (input.value) { return; }
				input.erase('name');
			});
			return true;
		});
	}
});