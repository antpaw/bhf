var AjaxEdit = new Class({
	version: 0.2,
	
	options: {
		holderParent: 'content',
		hideNext: false
	},
	
	Implements: [Options, Events],
	
	initialize: function(_options){
		this.setOptions(_options);
		this.holder = new Element('div.quick_edit_holder');
	},
	
	startEdit: function(element, wrapElement){
		this.wrapElement = wrapElement ? wrapElement : element;
		this.newEntry = this.wrapElement.hasClass('add_field');
		
		this.fireEvent('startRequest');
		this.currentRequest = new Request.HTML({
			method: 'get',
			evalScripts: false,
			url: element.get('href'),
			onFailure: function(invalidForm){
				this.fireEvent('failure');
			}.bind(this),
			onSuccess: function(responseTree, responseElements, responseHTML, responseJavaScript){
				this.injectForm(responseHTML);
				
				var nextElem = this.holder.getElement('.save_and_next');
				if (this.options.hideNext && nextElem) {
					nextElem.addClass('hide');
				}
				
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
				window.fireEvent('quickEditReady', [this.holder]);
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
	
	close: function(){
		if (this.currentRequest) {
			this.currentRequest.cancel();
		}
		this.holder.dispose();
		this.fireEvent('closed');
	},
	
	injectForm: function(form){
		this.holder.innerHTML = form;
		
		this.holder.getElements('.open').addEvent('click', function(e){
			e.preventDefault();
			Turbolinks.visit((this.wrapElement.getElement('a') || this.wrapElement).get('href'));
		}.bind(this));
		this.holder.getElements('.cancel').addEvent('click', function(e){
			e.preventDefault();
			this.close();
		}.bind(this));
		this.holder.getElements('.save_and_next').addEvent('click', function(e){
			e.preventDefault();
			this.submit(this.newEntry ? ['successAndAdd'] : ['successAndChange', 'successAndNext']);
		}.bind(this));
		this.holder.getElements('.save').addEvent('click', function(e){
			e.preventDefault();
			this.submit(this.newEntry ? ['successAndAdd'] : ['successAndChange']);
		}.bind(this));
		this.holder.getElements('form').addEvent('submit', function(e){
			e.preventDefault();
			this.submit(this.newEntry ? ['successAndAdd'] : ['successAndChange']);
		}.bind(this));
		
		this.holder.inject($(this.options.holderParent));
		
		this.fireEvent('formInjected', [this.holder]);
	},
	
	hide: function(){
		this.holder.addClass('collapsed');
	},
	
	show: function(){
		this.holder.removeClass('collapsed');
	}
});