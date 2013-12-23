var AjaxEditStack = new Class({
	version: 0.1,

	options: {
	},
	bricksArray: [],
	bricksIndex: 0,

	Implements: [Options, Events],

	initialize: function(_options) {
		this.setOptions(_options);
	},
	addEditBrick: function(editOptions, link, linkParent){
		var qi = this.bricksIndex;
		var qe = this.bricksArray[qi];
		if ( ! qe) {
			qe = new AjaxEdit(editOptions);
			this.bricksArray.push(qe);
		}
		
		this.bricksArray.each(function(b, i){
			if (i === qi) {
				b.show();
			}
			else if (i > qi) {
				b.close();
			}
		});
		
		var fadeTm;
		qe.addEvents({
			startRequest: function(){
				this.wrapElement.addClass('live_edit');
				setTimeout(function(){
					this.wrapElement.addClass('live_edit');
				}.bind(this), 10);
			},
			closed: function(){
				this.wrapElement.addClass('animate');
				setTimeout(function(){
					this.wrapElement.removeClass('live_edit');
				}.bind(this));
				setTimeout(function(){
					this.wrapElement.removeClass('animate');
				}.bind(this), 600);
			}
		});
		qe.startEdit(link, linkParent);
	},
	addStack: function(){
		this.bricksIndex = this.bricksIndex + 1;
		this.bricksArray.each(function(b){
			b.hide();
		});
	},
	removeStack: function(){
		this.bricksArray[this.bricksIndex] = undefined;
		this.bricksIndex = this.bricksIndex - 1;
		this.bricksArray = this.bricksArray.clean();
		(this.bricksArray.getLast() || {show: function(){}}).show();
	},
	removeAllStacks: function(){
		this.bricksArray.clean().each(function(b, i){
			b.close();
		});
		this.bricksArray = [];
		this.bricksIndex = 0;
	}
});