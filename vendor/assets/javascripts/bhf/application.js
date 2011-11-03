//= require ./mootools-core-1.3.2-full-compat-yc.js
//= require ./mootools-more-1.3.2.1.js
//= require mootools_ujs
//= require_tree ./classes/

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
		
		scope.getElements('.multiple_fields').each(function(elem){
			new MultipleFields(elem);
		});
		scope.getElements('.array_holder').each(function(elem){
			new ArrayFields(elem);
		});
		
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
			scrollContent();
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
	var mainForm = document.id('main_form');

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
						method: 'put',
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
					windowHight = document.body.clientHeight;
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
				this.addClass('clicked');
			},
			'click:relay(.delete)': function(e){
				e.target.addEvents({
					'ajax:success': function(html){
						this.getParent('tr').dispose();
					},
					'ajax:failure': function(html){
						alert('Something went wrong!');
					}
				});
			}
		});

		quickEdit.addEvents({
			successAndChange: function(json){
				var tr = this.wrapElement;
				tr.getElements('td').each(function(td){
					var name = td.get('data-column-name');
					if ( ! name) { return; }
					var a = td.getElement('a.quick_edit');
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
	else if (mainForm) {
		setupJsForm(mainForm);

		mainForm.addEvents({
			'click:relay(.quick_edit)': function(e){
				e.preventDefault();
				quickEdit.startEdit(this);
			},
			'click:relay(.delete)': function(e){
				e.target.addEvents({
					'ajax:success': function(html){
						var relation = e.target.getParent('.relation');
						if (relation.getElements('li').length < 2) {
							relation.getPrevious('.empty').removeClass('hide');
							if (relation.hasClass('has_one') || relation.hasClass('embeds_one')) {
								relation.getNext('.add_field').removeClass('hide');
							}
						}
						e.target.getParent('li').dispose();
					},
					'ajax:failure': function(html){
						alert('Something went wrong!');
					}
				});
			}
		});

		quickEdit.addEvents({
			successAndAdd: function(json){
				var relation = this.wrapElement.getPrevious('.relation');
				relation.getPrevious('.empty').addClass('hide');
				if (relation.hasClass('has_one') || relation.hasClass('embeds_one')) {
					relation.getNext('.add_field').addClass('hide');
				}
				relation.adopt(
					new Element('li').adopt(
						new Element('a.quick_edit', {text: json.to_bhf_s || '', href: json.edit_path})
					)
				);
			},
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
	var windowHight = document.body.clientHeight;
	window.onresize = function(e){
		windowHight = document.body.clientHeight;
	};
	var scrollContent = function(){
		var innerForm = quickEdit.holder.getElement('form');
		if ( ! innerForm) { return; }
		var scroll = document.body.scrollTop-70;
		if (scroll < 10) {
			scroll = 10;
		}
		if (scroll + innerForm.getSize().y > windowHight) { return; }
		quickEdit.holder.setStyle('padding-top', scroll);
	};
	window.onscroll = scrollContent;
	
	var fm = $('flash_massages');
	if (fm) {
		fm.addClass('show').removeClass.delay(4000, fm, 'show');
	}
	
	new BrowserUpdate({vs:{i:8,f:3,o:10.01,s:2,n:9}});
});