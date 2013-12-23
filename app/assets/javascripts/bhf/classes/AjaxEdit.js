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
		this.clean();
		this.wrapElement = wrapElement ? wrapElement : element;
		this.wrapElement.addClass('live_edit');
		this.newEntry = this.wrapElement.hasClass('add_field');
		
		this.fireEvent('startRequest');
		new Request.HTML({
			method: 'get',
			evalScripts: false,
			url: element.get('href'),
			onFailure: function(invalidForm){
				this.fireEvent('failure');
			}.bind(this),
			onSuccess: function(responseTree, responseElements, responseHTML, responseJavaScript){
				this.injectForm(responseHTML);
				eval(responseJavaScript);
				
				if (this.options.hideNext) {
					this.holder.getElement('.save_and_next').addClass('hide');
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
		this.fireEvent('closed')
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