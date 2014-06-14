//= require turbolinks
//= require ./mootools-core-1.5.0-full-compat.js
//= require ./mootools-more-1.5.0.js
//= require ./mootools_ujs
//= require_tree ./classes/

// Turbolinks bugs out on popState if you add own pushState events, so we cancel it
Turbolinks.pagesCached(0);

var initHelper = function(callback){
	var scopedCallback = function(){
		callback(document.body);
	};
	document.addEventListener('page:load', scopedCallback);
	window.addEvent('domready', scopedCallback);
	window.addEvent('platformUpdate', callback);
	window.addEvent('quickEditFormInject', callback);
};

(function(){
	var stackIndexCounter = 0;
	var lang = document.html.get('lang');
	Locale.use(lang = (lang === 'en') ? 'en-US' : lang = lang+'-'+lang.toUpperCase());

	var ajaxNote = new Ajaxify();
	document.addEventListener('page:fetch', function(){
		ajaxNote.loading();
	});

	var editStack = new QuickEditStack({
		permanentQuickEditEvents: {
			startRequest: function(){
				var linkElem = this.linkElem;
				var rowElem = this.linkElem.getParent('tr');
				if (rowElem) {
					linkElem = rowElem;
				}
				linkElem.addClass('live_edit');
			},
			closed: function(){
				var linkElem = this.linkElem;
				var rowElem = this.linkElem.getParent('tr');
				if (rowElem) {
					linkElem = rowElem;
				}
				linkElem.addClass('animate');
				setTimeout(function(){
					linkElem.removeClass('live_edit');
				});
				setTimeout(function(){
					linkElem.removeClass('animate');
				}, 600);
			}
		}
	});
			
	var triggerPlatformPagination = function(href, platform, callback){
		window.history.pushState({ turbolinks: true, url: href }, '', href);
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

	var updateElementsAfterQuickEditSuccess = function(eventNames, linkElem, json){
		var parent = linkElem.getParent('.quick_edit_block');
		var entryTemplate = parent.getElement('.quick_edit_template');
		var newEntryInjectArea = parent.getElement('.quick_edit_inject');
		var relation = parent.getElement('.relation');
		var entry = linkElem.getParent('.quick_edit_entry');
		if ( ! entry) {
			entry = parent.getElement('.quick_edit_active');
		}
		
		if (json) {
			var parsedTemplate = entryTemplate.innerHTML.replace(new RegExp('%7Bobject_id%7D', 'g'), '{object_id}').substitute(json)
		}
		
		if (eventNames.contains('successAndAdd')) {
			if (newEntryInjectArea && entryTemplate) {
				newEntryInjectArea.appendHTML(parsedTemplate);
				if (newEntryInjectArea) {
					newEntryInjectArea.fireEvent('quickEditEntryAdded');
				}
			}
			
			if (relation) {
				if (relation.getPrevious('.empty')) {
					relation.getPrevious('.empty').addClass('hide');
				}
				if (relation.hasClass('has_one') || relation.hasClass('embeds_one')) {
					relation.getNext('.js_add_field').addClass('hide');
				}
			}
		}
		if (eventNames.contains('successAndChange')) {
			if (entry) {
				entry.innerHTML = parsedTemplate;
			}
		}
		if (eventNames.contains('successAndRemove')) {
			if (entry) {
				entry.dispose();
			}
			if (newEntryInjectArea) {
				newEntryInjectArea.fireEvent('quickEditEntryRemoved');
			}
			
		}
	};
	
	initHelper(function(mainScope){
		
		var areaSelect = mainScope.getElement('#area_select');
		if (areaSelect) {
			areaSelect.addEvent('change', function(){
				location.href = this.value;
			});
		}
		
		var quickEditArray = [];
		var quickEditOptions;
		
		ajaxNote.setup();

		var jsForm = new FormHelper();
		mainScope.getElements('.js_bhf_form').each(function(form){
			jsForm.setup(form);
		});
		
		var sharedQuickEditOptions = {
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
			onSave: function(eventNames, linkElem, json){
				updateElementsAfterQuickEditSuccess(eventNames, linkElem, json);
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
		
		mainScope.getElements('.quick_edit_select').addEvent('change', function(e){
			var parent = this.getParent('.quick_edit_block');
			var optionElem = this.options[this.selectedIndex];
			var editElem = parent.getElement('.js_edit_field');
			if (editElem) {
				editElem.href = optionElem.get('data-edit');
			}
			var deleteElem = parent.getElement('.js_delete');
			if (deleteElem) {
				deleteElem.href = optionElem.get('data-delete');
			}
			this.getElements('.quick_edit_active').removeClass('quick_edit_active');
			optionElem.addClass('quick_edit_active');
		}).addEvent('quickEditEntryAdded', function(){
			this.selectedIndex = this.options.length - 1;
			this.fireEvent('change');
		}).addEvent('quickEditEntryRemoved', function(){
			this.selectedIndex = 0;
			this.fireEvent('change');
		}).fireEvent('change');
		
		mainScope.addEvent('click:relay(.js_delete)', function(e){
			e.target.addEvents({
				'ajax:success': function(html){
					updateElementsAfterQuickEditSuccess(['successAndRemove'], e.target);
				},
				'ajax:failure': function(html){
					alert(Locale.get('Notifications.failure'));
				}
			});
		});
		

		if (platforms.length) {
			quickEditOptions = Object.merge({
				onSuccessAndNext: function(json){
					var tr = this.linkElem;
					var qe;
					var nextTr = tr.getNext('tr');

					if (nextTr) {
						editStack.removeAllStacks();
						editStack.addEditBrick(quickEditOptions, nextTr.getElement('a'), nextTr);
					}
					else {
						var platform = tr.getParent('.platform');
						var loadMore = platform.getElement('.load_more');
						if (loadMore) {
							trIndex = tr.getParent('tbody').getElements('tr').indexOf(tr);
							triggerPlatformPagination(loadMore.get('href'), platform, function(){
								platform.getElements('tbody tr').each(function(newTr, index){
									if (trIndex === index) {
										nextTr = newTr.getNext('tr');
										
										editStack.removeAllStacks();
										editStack.addEditBrick(quickEditOptions, nextTr.getElement('a'), nextTr);
									}
								});
							});
						}
						else {
							nextTr = platform.getElements('tbody tr')[0];
							
							editStack.removeAllStacks();
							editStack.addEditBrick(quickEditOptions, nextTr.getElement('a'), nextTr);
						}
					}
				}
			}, sharedQuickEditOptions);
			

			platforms.each(function(p){
				new PlatformHelper(p, {
					onPaginationStart: function(link){
						triggerPlatformPagination(link.get('href'), link.getParent('.platform'));
					},
					onQuickEditStart: function(link){
						editStack.removeAllStacks();
						editStack.addEditBrick(quickEditOptions, link, link.getParent('tr'));
					},
					onSearch: function(){
						ajaxNote.loading();
					},
					onSearchFailure: function(){
						ajaxNote.failure();
					},
					onSearchSuccess: function(request){
						window.fireEvent('platformUpdate', [p.getParent()]);
						// TODO: remove the mootools hack for request.url don't 
						window.history.pushState({ turbolinks: true, url: request.url }, '', request.url);
					}
				});
			});
		}
		else if (mainForm) {
			quickEditOptions = Object.merge({
				onSuccessAndNext: function(json){
					var a = this.linkElem;
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
					editStack.addEditBrick(quickEditOptions, holder.getElement('a'));
				}
			}, sharedQuickEditOptions);
			
			mainForm.addEvent('click:relay(.quick_edit)', function(e){
				e.preventDefault();
				editStack.removeAllStacks();
				editStack.addEditBrick(quickEditOptions, this);
			});
		}
		else if (mainScope.hasClass('quick_edit_holder')) {
			quickEditOptions = Object.merge({
				onClosed: function(){
					editStack.removeStack();
				},
				hideNext: true
			}, sharedQuickEditOptions);
			
			mainScope.addEvent('click:relay(.quick_edit)', function(e){
				e.preventDefault();
				editStack.addStack();
				editStack.addEditBrick(quickEditOptions, this);
			});
		}
		
		
		var scrollContent = function(){
			quickEditArray.each(function(quickEdit){
				var innerForm = quickEdit.holder.getElement('form');
				if ( ! innerForm) { return; }
				var scroll = document.body.scrollTop - 83;
				if (scroll + innerForm.getSize().y > document.body.clientHeight) { return; }
				quickEdit.holder.setStyle('padding-top', scroll);
			});
		};
		// window.onscroll = scrollContent;
		
		
		mainScope.getElements('.js_sortable').each(function(sortableElems){
			new Sortables(sortableElems, {
				handle: '.handle',
				onStart: function(element, clone){
					element.addClass('dragged');
				},
				onComplete: function(element){
					element.removeClass('dragged');
					new Request({
						method: 'put',
						url: sortableElems.get('data-sort-url')
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
