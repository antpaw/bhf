var Ajaxify = new Class({
	version: '0.1',

	Implements: [Options, Events],

	options: {/*
		a: $empty(b),*/
		events: {
			loading: {
				name: 'loading',
				text: 'Loading…'
			},
			success: {
				name: 'success',
				text: 'Changes successfully saved!'
			},
			failure: {
				name: 'failure',
				text: 'Oops, something went wrong…'
			}
		},
		holder: new Element('div#ajax_holder'),
		fadeOutDuration: 2000
	},

	initialize: function(_options) {
		this.setOptions(_options);
		this.holder = this.options.holder;
	},
	
	applyEvents: function(elements){
		elements
			.addEvent(this.options.events.loading.name, this.loading.bind(this))
			.addEvent(this.options.events.success.name, this.success.bind(this))
			.addEvent(this.options.events.failure.name, this.failure.bind(this));
	},

	loading: function(xhr){
		this.setMessage('loading', false);
	},
	success: function(xhr){
		this.setMessage('success', true);
	},
	failure: function(xhr){
		this.setMessage('failure', true);
	},

	setMessage: function(status, fadeOut) {
		this.holder
			.set('class', status)
			.set('text', this.options.events[status].text)
			.inject(document.body);

		if (fadeOut) {
			this.holder.addClass('fadeout');
			
			setTimeout(function(){
				this.holder.dispose();
			}.bind(this), this.options.fadeOutDuration);
		}
	}
});