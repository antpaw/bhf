var Amatriciana = new Class({
	version: '0.1',
	// 
	// Implements: [Options, Events],
	// 
	// options: {/*
	// 	a: $empty(b),*/
	// },

	initialize: function(_object, _options) {
		if ( ! _object) { return; }
		// this.setOptions(_options);

		this.inputElem = _object;

		// ie fucks up button values sometimes, use data-dvalue attr to store the same value
		var val = this.inputElem.get('data-dvalue');
		val = val? val : this.inputElem.get('value');

		this.elemData = {
			tagname: this.inputElem.tagName.toLowerCase(),
			value: val,
			name: this.inputElem.get('name'),
			html: this.inputElem.get('html'),
			type: this.inputElem.get('type'),
			cssClass: this.inputElem.get('class')
		};

		var text = this.elemData.html;
		if (this.elemData.tagname === 'input') {
			text = this.elemData.value;
		}

		this.anchor = new Element('a', {
			html: text,
			'class': this.elemData.cssClass
		})
		.inject(this.inputElem, 'after');

		this.buttonForm = this.inputElem.getParent('form');

		if (this.elemData.type === 'submit') {
			// hide the button so enter still submits stuff
			this.inputElem.set('style', 'display:block;border:0;height:0;width:0;float:left;padding:0;margin:0;text-indent:-9999px');
		}
		else {
			this.inputElem.dispose();			
		}

		this.anchor.addEvent('click', function(e){
			e.stop();

			new Element('input', {
				type: 'hidden',
				name: this.elemData.name,
				value: this.elemData.value,
				'class': this.elemData.cssClass
			})
			.inject(this.anchor, 'after');

			this.buttonForm.submit();
		}.bind(this));
	}
});