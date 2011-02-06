var AjaxEdit = new Class({
	version: 0.2,

	Implements: [Options, Events],

	options: {
		holder: new Element('div.quick_edit')
	},

	initialize: function(_options) {
		this.setOptions(_options);
	},
	
	startEdit: function(form){
		var that = this;
		this.options.holder.innerHTML = form;
		this.options.holder.getElement('form').addEvent('submit', function(e){
			e.preventDefault();
			new Request({
				method: this.get('method'),
				url: this.get('action'),
				onSuccess: function(html){
					console.log(html);
					that.endEdit();
				}
			}).send({data: this});
			/*
			*/
		});
		this.options.holder.inject(document.body);
	},
	
	endEdit: function(){
		this.options.holder.dispose();
	}
});

var ajaxNote = new Ajaxify();
var quickEdit = new AjaxEdit();


window.addEvent('domready', function(){
	
	ajaxNote.applyEvents();
	
	// TODO: i18n
	// document.getElement('html').lang;
	// Locale.use('de-DE');
	
	$$('.platform').addEvents({
		'click:relay(.pagination a, thead a)': function(e){
			e.preventDefault();
		
			var parent = this.getParent('.platform');
			
			new Request({
				method: 'get',
				url: this.get('href'),
				onSuccess: function(html){
					parent.innerHTML = html;
				}
			}).send();
		},
		'submit:relay(.search)': function(e){
			e.preventDefault();
		
			var parent = this.getParent('.platform');
			
			new Request({
				method: 'get',
				url: this.get('action'),
				onSuccess: function(html){
					parent.innerHTML = html;
				}
			}).send({data: this});
		},
		'click:relay(.quick_edit)': function(e){
			e.preventDefault();
		
			var parent = this.getParent('.platform');
			
			new Request({
				method: 'get',
				url: this.get('href'),
				onSuccess: function(e){
					quickEdit.startEdit(e);
					
				}
			}).send({data: {quick_edit: true}});
		}
	});
	
	
	new BrowserUpdate({vs:{i:8,f:3,o:10.01,s:2,n:9}});
});