var MultipleFields = new Class({
	version: 0.1,

	options: {
		spliter: ';'
	},

	// Implements: [Options, Events],

	initialize: function(_object, _options) {
		if ( ! _object) { return; }
		// this.setOptions(_options);
		if (_object.get('data-spliter')) {
			this.options.spliter = _object.get('data-spliter');
		}

 		var elem = _object;
		var template = elem.clone()
			.erase('name').erase('id').erase('data-spliter').erase('value')
			.addClass('template');

		elem.set('type', 'hidden');

		new Element('span.plus_button.qe_button', {text: '+'})
			.inject(elem, 'after')
			.addEvent('click', function(e){
				this.addField(elem, template);
			}.bind(this));

		elem.get('value').toString().split(this.options.spliter).each(function(data){
			this.addField(elem, template, data);
		}.bind(this));
	},
	
	addField: function(elem, template, data){
		template
			.clone()
			.set('value', data)
			.addEvent('change', function(e){
				var values = [];
				e.target.getParent('.input').getElements('.template').each(function(template){
					if (template.value.trim()) {
						values.push(template.value.trim());
					}
				});
				elem.set('value', values.join(this.options.spliter));
			}.bind(this))
			.inject(elem.getParent('.input').getElement('.plus_button'), 'before');
	}
});