var PlatformHelper = new Class({
	version: 0.1,
	
	options: {
	},

	Implements: [Options, Events],

	initialize: function(_object, _options) {
		if ( ! _object) { return; }
		this.setOptions(_options);
		var scope = _object;
		var _this = this;

		scope.getElements('.pagination a, thead a').addEvent('click', function(e){
			e.preventDefault();
			_this.fireEvent('paginationStart', [this])
		});
		scope.getElements('.search').addEvent('submit', function(e){
			_this.fireEvent('search');
			e.preventDefault();
			var hidden_search = this.getElement('.hidden_search');
			if (hidden_search) {
				hidden_search.destroy();
			}
			var a = new Request.HTML({
				method: 'get',
				url: e.target.get('action'),
				onFailure: function(){
					_this.fireEvent('searchFailure');
				},
				onSuccess: function(a, b, html){
					scope.innerHTML = html;
					_this.fireEvent('searchSuccess')
				}
			}).send({data: e.target});
			window.history.pushState({ turbolinks: true, url: a.url }, '', a.url);
		});
		scope.getElements('.quick_edit').addEvent('click', function(e){
			e.preventDefault();
			_this.fireEvent('quickEditStart', [this]);
		});
		scope.getElements('.action a').addEvent('click', function(e){
			this.addClass('clicked');
			setTimeout(function(){
				this.removeClass('clicked');
			}.bind(this), 1500);
		});
		scope.getElements('.delete').addEvent('click', function(e){
			e.target.addEvents({
				'ajax:success': function(html){
					this.getParent('tr').dispose();
				},
				'ajax:failure': function(html){
					alert(Locale.get('Notifications.failure'));
				}
			});
		});
	}
});