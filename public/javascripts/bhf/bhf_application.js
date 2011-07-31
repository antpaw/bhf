window.addEvent('domready', function(){
	var ajaxNote = new Ajaxify();
	var lang = document.html.get('lang');
	if (lang === 'en') {
		lang = 'en-US';
	}
	else {
		lang = lang+'-'+lang.toUpperCase();
	}
	Locale.use(lang);
	var wysiwyg = [];
	var setupJsForm = function(scope){
		scope.getElements('.wysiwyg').each(function(elem){
			wysiwyg.push(elem.mooEditable());
		});
		new MultipleFields(scope.getElements('.multiple_fields'));
		
		var dateFormat = Locale.get('Date.shortDate').replace(/%/g, '');
		var timeFormat = 'H:i'; // Locale.get('Date.shortTime').replace(/%/g, '')
		var dateMonths = Locale.get('Date.months');
		var dateDays = Locale.get('Date.days');
		new DatePicker(scope.getElements('.picker.datetime, .picker.timestamp'), {
			allowEmpty: true,
			inputOutputFormat: 'Y-m-d H:i',
			months: dateMonths,
			days: dateDays,
			timePicker: true,
			format: dateFormat+' '+timeFormat
		});
		new DatePicker(scope.getElements('.picker.date'), {
			allowEmpty: true,
			inputOutputFormat: 'Y-m-d H:i',
			months: dateMonths,
			days: dateDays,
			format: dateFormat
		});
		new DatePicker(scope.getElements('.picker.time'), {
			allowEmpty: true,
			inputOutputFormat: 'Y-m-d H:i',
			months: dateMonths,
			days: dateDays,
			timePickerOnly: true,
			format: timeFormat
		});
	};

	// TODO: disable more ajax calls while ajax is loading
	var quickEdit = new AjaxEdit({
		holderParent: $('content'),
		onStartRequest: function(form){
			ajaxNote.loading();
		},
		onFormInjected: function(form){
			setupJsForm(form);
			ajaxNote.success();
		},
		onSave: function(form){
			ajaxNote.success();
		},
		onBeforeSubmit: function(){
			ajaxNote.loading();
			wysiwyg.each(function(elem){
				elem.saveContent();
			});
		}
	});

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
			ajaxNote.loading();
			new Request.HTML({
				method: 'get',
				url: href,
				onSuccess: function(a, b, html){
					platform.innerHTML = html;
					if (callback) {
						callback.call();
					}
					setupSortables(platform);
					ajaxNote.success();
				}
			}).send();
		};

		platforms.addEvents({
			'click:relay(.pagination a, thead a)': function(e){
				e.preventDefault();
				updatePlatform(this.get('href'), this.getParent('.platform'));
			},
			'submit:relay(.search)': function(e){
				ajaxNote.loading();
				e.preventDefault();
				var parent = this.getParent('.platform');
				var hidden_search = e.target.getElement('.hidden_search');
				if (hidden_search) {
					hidden_search.destroy();
				}

				new Request.HTML({
					method: 'get',
					url: this.get('action'),
					onSuccess: function(a, b, html){
						parent.innerHTML = html;
						setupSortables(parent);
						ajaxNote.success();
					}
				}).send({data: this});
			},
			'click:relay(.quick_edit)': function(e){
				e.preventDefault();
				quickEdit.startEdit(this, this.getParent('tr'));
			},
			'click:relay(.action a)': function(e){
				e.target.addClass('clicked');
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
		setupJsForm(main_form);

		main_form.addEvents({
			'click:relay(.quick_edit)': function(e){
				e.preventDefault();
				quickEdit.startEdit(this);
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
	}
	var dbch = document.body.clientHeight;
	window.onresize = function(e){
		dbch = document.body.clientHeight;
	};
	window.onscroll = function(e){
		var innerForm = quickEdit.holder.getElement('form');
		if ( ! innerForm) { return; }
		var scroll = document.body.scrollTop-70;
		if (scroll < 10) {
			scroll = 10;
		}
		if (scroll + innerForm.getSize().y > dbch) { return; }
		quickEdit.holder.setStyle('padding-top', scroll);
	};
	
	var fm = $('flash_massages');
	if (fm) {
		fm.addClass('show').removeClass.delay(4000, fm, 'show');
	}
	
	new BrowserUpdate({vs:{i:8,f:3,o:10.01,s:2,n:9}});
});