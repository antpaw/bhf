// var ajaxNote = new Ajaxify();
var wysiwyg = [];

window.addEvent('domready', function(){
	var quickEdit = new AjaxEdit({
		holderParent: $('content')
	});
	// ajaxNote.applyEvents();

	var platforms = document.body.getElements('.platform');
	var main_form = document.id('main_form');

	if (platforms.length) {
		var setupSortables = function(scope){
			new Sortables(scope.getElements('.sortable'), {
				handle: '.handle',
				onStart: function(element, clone){
					element.addClass('dragged');
				},
				onComplete: function(element){
					element.removeClass('dragged');
					new Request({
						method: 'get',
						url: this.element.getParent('tbody').get('data-sort-url')
					}).send({data: {order: this.serialize()}});
				}
			});
		};
		var updatePlatform = function(href, platform, callback){
			new Request({
				method: 'get',
				url: href,
				onSuccess: function(html){
					platform.innerHTML = html;
					if (callback) {
						callback.call();
					}
					setupSortables(platform);
				}
			}).send();
		};

		platforms.addEvents({
			'click:relay(.pagination a, thead a)': function(e){
				e.preventDefault();
				updatePlatform(this.get('href'), this.getParent('.platform'));
			},
			'submit:relay(.search)': function(e){
				e.preventDefault();
				var parent = this.getParent('.platform');

				new Request({
					method: 'get',
					url: this.get('action'),
					onSuccess: function(html){
						parent.innerHTML = html;
						setupSortables(platform);
					}
				}).send({data: this});
			},
			'click:relay(.quick_edit)': function(e){
				e.preventDefault();
				quickEdit.startEdit(this, this.getParent('tr'));
			},
			'ajax:complete:relay(a[data-method=delete][data-remote])': function(e){
				// TODO: make this work
				e.preventDefault();
				this.getParent('tr').dispose();
			}			
		});

		quickEdit.addEvents({
			successAndChange: function(json){
				var tr = this.wrapElement;
				tr.getElements('td').each(function(td){
					var name = td.get('data-column-name');
					if ( ! name) { return; }
					var a = td.getElement('a');
					(a ? a : td).innerHTML = json[name] || '';
				});
			},
			successAndNext: function(json){
				var tr = this.wrapElement;
				var nextTr = tr.getNext('tr');

				if (nextTr) {
					quickEdit.startEdit(nextTr.getElement('a'), nextTr);
				}
				else {
					var platform = tr.getParent('.platform');
					var loadMore = platform.getElement('.load_more');
					if (loadMore) {
						// TODO: disable pagination while in quick_edit mode
						trIndex = tr.getParent('tbody').getElements('tr').indexOf(tr);
						updatePlatform(loadMore.get('href'), platform, function(){
							platform.getElements('tbody tr').each(function(newTr, index){
								if (trIndex === index) {
									nextTr = newTr.getNext('tr');
									quickEdit.startEdit(nextTr.getElement('a'), nextTr);
								}
							});
						});
					}
					else {
						nextTr = platform.getElements('tbody tr')[0];
						quickEdit.startEdit(nextTr.getElement('a'), nextTr);
					}
				}
			}
		});
		setupSortables(document.body);
	}
	else if (main_form) {
		$$('.wysiwyg').each(function(elem){
			// TODO: wtf is this
			wysiwyg.push(elem.mooEditable());
		});

		main_form.addEvents({
			'click:relay(.quick_edit)': function(e){
				e.preventDefault();
				quickEdit.startEdit(this, this);
			}
		});

		quickEdit.addEvents({
			successAndChange: function(json){
				this.wrapElement.set('text', json.to_bhf_s || '');
			},
			successAndNext: function(json){
				var a = this.wrapElement;
				var li = a.getParent('li');
				if ( ! li) { 
					this.close();
					return;
				}
				var holder = li.getNext('li');

				if ( ! holder) {
					holder = li.getParent('ul');
				}
				quickEdit.startEdit(holder.getElement('a'));
			}
		});

		new DatePicker('.datepicker.datetime', {
			timePicker: true,
			format: 'd.m.Y H:i'
		});
		new DatePicker('.datepicker.date', {
			format: 'd.m.Y'
		});
		new DatePicker('.datepicker.time', {
			timePicker: true,
			format: 'H:i'
		});
	}
	
	setTimeout(function(){
		// TODO: mootools slideUp(), maybe css3 animations
		var fm = $('flash_massages');
		if (fm) {
			fm.fade('out');
		}
	}, 4000);

	new BrowserUpdate({vs:{i:8,f:3,o:10.01,s:2,n:9}});
});