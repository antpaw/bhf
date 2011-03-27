var Positioner = new Class({
	
	Implements: [Options, Events],
	
	options: {
		elemTree: null,
		dragSpan: new Element('span', {'class': 'drag'})
	},
	
	version: '0.1',
	elemTree: null,
	trs: [],
	droppablePlaceholder: [],
	drag: null,
	hoverElem: null,
	
	initialize: function(_options){
		this.setOptions(_options);
		if ( ! this.options.elemnts) { alert('naviAdmin - no object'); return; }
		
		this.elemTree = this.options.elemTree;
		
		this.createPosHelper();
		
		this.trs.each(function(elem){
			this.drag = new Drag.Move(elem, {
				handle: event.target,
				droppables: dropAndMoveAsChild.concat(this.droppablePlaceholder),
				onStart: function(element, hoverElement){
					element
						.addClass('moved')
						.getNext('li').dispose();
				},
				onEnter: function(element, hoverElement){
					hoverElement.addClass('hover');
					this.hoverElem = hoverElement;
				}.bind(this),
				onLeave: function(element, hoverElement){
					hoverElement.removeClass('hover');
				}
			});
		}.bind(this));
	}
});