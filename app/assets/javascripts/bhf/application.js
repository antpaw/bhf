//= require turbolinks
//= require ./mootools-core-1.5.0-full-compat.js
//= require ./mootools-more-1.5.0.js
//= require ./mootools_ujs
//= require_tree ./classes/

var initHelper = function(callback){
	var scopedCallback = function(){
		callback(document.body);
	};
	document.addEventListener('page:load', scopedCallback);
	window.addEvent('domready', scopedCallback);
	window.addEvent('platformUpdate', callback);
	window.addEvent('quickEditReady', callback);
	window.addEvent('newQuickEditLink', callback);
};

(function(){
	var stackIndexCounter = 0;
	var lang = document.html.get('lang');
	Locale.use(lang = (lang === 'en') ? 'en-US' : lang = lang+'-'+lang.toUpperCase());

	var ajaxNote = new Ajaxify();
	document.addEventListener('page:fetch', function(){
		ajaxNote.loading();
	});

	var editStack = new AjaxEditStack();
	
	var insertNewLi = function(relation, json){
		var elems = [];
		if (json.can_edit) {
			elems.push(new Element('a.quick_edit', {text: json.to_bhf_s || '', href: json.edit_path}));
		}
		else {
			elems.push(new Element('a', {text: json.to_bhf_s}));
		}
		if (json.can_delete) {
			elems.push(new Element('a.delete', {html: '&times;' || '', href: json.delete_path, 'data-confirm': json.delete_confirm, 'data-remote': 'true'}))
		}
		var newLi = new Element('li').adopt(elems);
		relation.adopt(newLi);
		window.fireEvent('newQuickEditLink', [newLi]);
	}
	var setupDefaultDeleteQuickEditEvents = function(scope, options){		
		scope.addEvent('click:relay(.delete)', function(e){
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
					alert(Locale.get('Notifications.failure'));
				}
			});
		});
	}
	
	initHelper(function(mainScope){
		var areaSelect = mainScope.getElement('#area_select');
		if (areaSelect) {
			areaSelect.addEvent('change', function(){
				location.href = this.value;
			});
		}
		
		var quickEditArray = [];
		var ajaxEditOptions;
		
		ajaxNote.setup();

		rails.applyEvents(mainScope);
		
		var jsForm = new FormHelper();
		mainScope.getElements('.js_bhf_form').each(function(form){
			jsForm.setup(form);
		});
		
		var sharedAjaxEditOptions = {
			onFailure: function(){
				ajaxNote.failure();
			},
			onStartRequest: function(form){
				ajaxNote.loading();
			},
			onFormInjected: function(form){
				scrollContent();
				ajaxNote.success();
			},
			onSave: function(form){
				ajaxNote.success();
			},
			onBeforeSubmit: function(){
				ajaxNote.loading();
				jsForm.wysiwyg.each(function(editor){
					editor.saveContent();
				});
			}
		};

		var platforms = mainScope.getElements('.platform');
		var mainForm = mainScope.getElementById('main_form');

		if (platforms.length) {
			ajaxEditOptions = Object.merge({
				onSuccessAndChange: function(json){
					var tr = this.wrapElement;
					tr.getElements('td').each(function(td){
						var name = td.get('data-column-name');
						if ( ! name) { return; }
						var a = td.getElement('a.quick_edit');
						(a ? a : td).innerHTML = json[name] || '';
					});
				},
				onSuccessAndNext: function(json){
					var tr = this.wrapElement;
					var qe;
					var nextTr = tr.getNext('tr');

					if (nextTr) {
						editStack.removeAllStacks();
						editStack.addEditBrick(ajaxEditOptions, nextTr.getElement('a'), nextTr);
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
										
										editStack.removeAllStacks();
										editStack.addEditBrick(ajaxEditOptions, nextTr.getElement('a'), nextTr);
									}
								});
							});
						}
						else {
							nextTr = platform.getElements('tbody tr')[0];
							
							editStack.removeAllStacks();
							editStack.addEditBrick(ajaxEditOptions, nextTr.getElement('a'), nextTr);
						}
					}
				}
			}, sharedAjaxEditOptions);
			
			
			var updatePlatform = function(href, platform, callback){
				ajaxNote.loading();
				new Request.HTML({
					method: 'get',
					url: href,
					onFailure: function(){
						ajaxNote.failure();
					},
					onSuccess: function(a, b, html){
						platform.innerHTML = html;
						if (callback) {
							callback.call();
						}
						window.fireEvent('platformUpdate', [platform.getParent()]);
					}
				}).send();
			};

			platforms.each(function(p){
				new PlatformHelper(p, {
					onPaginationStart: function(link){
						updatePlatform(link.get('href'), link.getParent('.platform'));
					},
					onQuickEditStart: function(link){
						editStack.removeAllStacks();
						editStack.addEditBrick(ajaxEditOptions, link, link.getParent('tr'));
					},
					onSearch: function(){
						ajaxNote.loading();
					},
					onSearchFailure: function(){
						ajaxNote.failure();
					},
					onSearchSuccess: function(){
						window.fireEvent('platformUpdate', [p.getParent()]);
					}
				});
			});
		}
		else if (mainForm) {
			ajaxEditOptions = Object.merge({
				onSuccessAndAdd: function(json){
					var relation = this.wrapElement.getPrevious('.relation');
					relation.getPrevious('.empty').addClass('hide');
					if (relation.hasClass('has_one') || relation.hasClass('embeds_one')) {
						relation.getNext('.add_field').addClass('hide');
					}
					insertNewLi(relation, json);
				},
				onSuccessAndChange: function(json){
					this.wrapElement.set('text', json.to_bhf_s || '');
				},
				onSuccessAndNext: function(json){
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
					
					editStack.removeAllStacks();
					editStack.addEditBrick(ajaxEditOptions, holder.getElement('a'));
				}
			}, sharedAjaxEditOptions);
			
			setupDefaultDeleteQuickEditEvents(mainForm, ajaxEditOptions);
			mainForm.addEvent('click:relay(.quick_edit)', function(e){
				e.preventDefault();
				editStack.removeAllStacks();
				editStack.addEditBrick(ajaxEditOptions, this);
			});
		}
		else if (mainScope.hasClass('quick_edit_holder')) {
			ajaxEditOptions = Object.merge({
				onSuccessAndAdd: function(json){
					var relation = this.wrapElement.getPrevious('.relation');
					relation.getPrevious('.empty').addClass('hide');
					if (relation.hasClass('has_one') || relation.hasClass('embeds_one')) {
						relation.getNext('.add_field').addClass('hide');
					}
					insertNewLi(relation, json);
				},
				onSuccessAndChange: function(json){
					this.wrapElement.set('text', json.to_bhf_s || '');
				},
				onClosed: function(){
					editStack.removeStack();
				},
				hideNext: true
			}, sharedAjaxEditOptions);
			
			setupDefaultDeleteQuickEditEvents(mainScope, ajaxEditOptions);
			mainScope.addEvent('click:relay(.quick_edit)', function(e){
				e.preventDefault();
				editStack.addStack();
				editStack.addEditBrick(ajaxEditOptions, this);
			});
		}
		
		
		var windowHight = document.body.clientHeight;
		window.onresize = function(e){
			windowHight = document.body.clientHeight;
		};
		var scrollContent = function(){
			quickEditArray.each(function(quickEdit){
				var innerForm = quickEdit.holder.getElement('form');
				if ( ! innerForm) { return; }
				var scroll = document.body.scrollTop - 83;
				if (scroll + innerForm.getSize().y > windowHight) { return; }
				quickEdit.holder.setStyle('padding-top', scroll);
			});
		};
		// window.onscroll = scrollContent;
		
		
		mainScope.getElements('.sortable').each(function(sortableElems){
			new Sortables(sortableElems, {
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
		});
		
		var fm = $('flash_massages');
		if (fm) {
			fm.removeClass.delay(10000, fm, 'show');
		}
		
		mainScope.getElements('.initial_referral').each(function(elem){
			setTimeout(function(){
				elem.removeClass('live_edit');
				setTimeout(function(){
					elem.removeClass('animate');
				}, 600);
			}, 500);
		});
		
		ajaxNote.success();
	});
})();
