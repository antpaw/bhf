var AjaxEdit = new Class({
	version: 0.2,

	options: {
		holderParent: document.body
	},

	Implements: [Options, Events],

	setup: function(_options) {
		this.setOptions(_options);
		this.holder = new Element('div.quick_edit_holder').addEvents({
			'click:relay(.open)': function(e){
				e.preventDefault();
				Turbolinks.visit((this.wrapElement.getElement('a') || this.wrapElement).get('href'));
			}.bind(this),
			'click:relay(.cancel)': function(e){
				e.preventDefault();
				this.close();
			}.bind(this),
			'click:relay(.save_and_next)': function(e){
				e.preventDefault();
				this.submit(this.newEntry ? ['successAndAdd'] : ['successAndChange', 'successAndNext']);
			}.bind(this),
			'click:relay(.save)': function(e){
				e.preventDefault();
				this.submit(this.newEntry ? ['successAndAdd'] : ['successAndChange']);
			}.bind(this),
			'submit:relay(form)': function(e){
				e.preventDefault();
				this.submit(this.newEntry ? ['successAndAdd'] : ['successAndChange']);
			}.bind(this)
		});
	},

	startEdit: function(element, wrapElement){
		this.clean();
		this.wrapElement = wrapElement ? wrapElement : element;
		this.wrapElement.addClass('live_edit');
		this.newEntry = this.wrapElement.hasClass('add_field');
		
		this.fireEvent('startRequest');
		new Request.HTML({
			method: 'get',
			evalScripts: false,
			url: element.get('href'),
			onSuccess: function(responseTree, responseElements, responseHTML, responseJavaScript){
				this.injectForm(responseHTML);
				eval(responseJavaScript);
				window.fireEvent('quickEditReady', [this.holder]);
			}.bind(this)
		}).send();
	},

	submit: function(eventNames){
		var form = this.holder.getElement('form');
		this.fireEvent('beforeSubmit');

		new Request.JSON({
			method: form.get('method'),
			url: form.get('action'),
			evalScripts: true,
			onRequest: function(){
				this.disableButtons();
			}.bind(this),
			onFailure: function(invalidForm){
				this.injectForm(invalidForm.response);
				invalidForm.response.stripScripts(function(script){
					eval(script);
				});
			}.bind(this),
			onSuccess: function(json){
				if ( ! eventNames.contains('successAndNext')) {
					this.close();
				}
				eventNames.each(function(eventName){
					this.fireEvent(eventName, [json]);
				}.bind(this));
				this.fireEvent('save');
			}.bind(this)
		}).send({data: form});
	},

	disableButtons: function(){
		this.holder.getElements('.open, .cancel, .save_and_next, .save').set('disabled', 'disabled');
	},

	clean: function(){
		document.body.getElements('.live_edit').removeClass('live_edit');
	},

	close: function(){
		this.clean();
		this.holder.dispose();
	},

	injectForm: function(form){
		this.holder.innerHTML = form;
		this.holder.inject(this.options.holderParent);
		
		this.fireEvent('formInjected', [this.holder]);		
	}
});