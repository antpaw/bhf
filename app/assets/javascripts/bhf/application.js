//= require turbolinks
//= require activestorage
//= require ./MooTools-More-1.6.0.js
//= require ./mootools_ujs
//= require ./trix
//= require_tree ./locales/
//= require_tree ./classes/

(function(){
	var lang = document.html.get('lang').split('-')[0];
	lang = (lang === 'en') ? 'en-US' : lang.toLowerCase()+'-'+lang.toUpperCase();
	Locale.use(lang);

	var ajaxNote = new Ajaxify();

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
					rowElem.addClass('animate');
					setTimeout(function(){
						rowElem.removeClass('animate');
					}, 600);
					linkElem = rowElem;
				}
				setTimeout(function(){
					linkElem.removeClass('live_edit');
				});
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
			onSuccess: function (a, b, html) {
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
		var entry = linkElem.getParent('.quick_edit_entry');
		var entryTemplate, newEntryInjectArea, relation, parsedTemplate;
		if (parent) {
			entryTemplate = parent.getElement('.quick_edit_template');
			newEntryInjectArea = parent.getElement('.quick_edit_inject');
			relation = parent.getElement('.relation');
		}
		if ( ! entry) {
			entry = parent.getElement('.quick_edit_active');
		}

		if (entryTemplate) {
			entryTemplate = entryTemplate.clone();
			entryTemplate.getElements('.js_remove_disabled').each(function(elem){
				elem.removeProperty('disabled');
			});
			if (json) {
				parsedTemplate = entryTemplate.innerHTML.replace(new RegExp('%7Bobject_id%7D', 'g'), '{object_id}').substitute(json);
			}
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
			if (entry && parsedTemplate) {
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

	var scrollContent = function(){
		editStack.bricksArray.each(function(quickEdit){
			var innerForm = quickEdit.holder.getElement('form');
			if ( ! innerForm) { return; }
			var scroll = document.body.scrollTop - 83;
			if (scroll + innerForm.getSize().y > document.body.clientHeight) { return; }
			quickEdit.holder.setStyle('padding-top', scroll);
		});
	};


	window.addEvent('bhfDomChunkReady', function(mainScope){

		var areaSelect = mainScope.getElement('#area_select');
		if (areaSelect) {
			areaSelect.addEvent('change', function(){
				location.href = this.value;
			});
		}

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
			onStartRequest: function(){
				ajaxNote.loading();
			},
			onFormInjected: function(){
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

		mainScope.getElements('.quick_edit_select').addEvent('change', function(){
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
				'ajax:success': function(){
					updateElementsAfterQuickEditSuccess(['successAndRemove'], e.target);
				},
				'ajax:failure': function(){
					alert(Locale.get('Notifications.failure'));
				}
			});
		});

		mainScope.addEvent('click:relay(.js_toggle)', function(e){
			e.target.addEvents({
				'ajax:success': function(xhr, responseJSON){
					updateElementsAfterQuickEditSuccess(['successAndChange'], e.target, responseJSON);
				},
				'ajax:failure': function(){
					alert(Locale.get('Notifications.failure'));
				}
			});
		});

		if (platforms.length) {
			quickEditOptions = Object.merge({
				onSuccessAndNext: function(){
					var tr = this.linkElem.getParent('tr');
					var nextTr = tr.getNext('tr');

					if (nextTr) {
						editStack.removeAllStacks();
						editStack.addEditBrick(quickEditOptions, nextTr.getElement('a'), nextTr);
					}
					else {
						var trIndex;
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
						window.history.pushState({ turbolinks: true, url: request.url }, '', request.url);
					}
				});
			});
		}
		else if (mainForm) {
			quickEditOptions = Object.merge({
				onSuccessAndNext: function(){
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

		mainScope.getElements('.js_sortable').each(function(sortableElems){
			new Sortables(sortableElems, {
				handle: '.handle',
				onStart: function(element){
					element.addClass('dragged');
				},
				onComplete: function(element){
					element.removeClass('dragged');
					new Request({
						method: 'put',
						headers: {
							'X-CSRF-Token': rails && rails.csrf && rails.csrf.token
						},
						url: sortableElems.get('data-sort-url')
					}).send({data: {order: this.serialize()}});
				}
			});
		});

		var fm = document.id('flash_massages');
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

		mainScope.getElements('.ninja_file_field').addEvent('change', function(){
			var text = (this.value || '').split('\\');
			var parent = this.getParent();
			var newText = parent.get('data-empty-field-text');
			if (this.value) {
				newText = text.getLast() || this.value;
			}
			parent.getElement('.h_text').set('text', newText);
		});

		mainScope.getElements('.js_submit_form_on_change').addEvent('change', function(e){
			e.target.getParent('form').submit();
		});

		// picture preview handler on input
		mainScope.getElements('.preview_input').addEvent('change', function(e) {
			var img = this.getNext('img');
			if (img) {
				img.src = URL.createObjectURL(e.target.files[0]);
			}
		});

		// picture preview handler on hover
		mainScope.getElements('.thumbnail_image').addEvents({
			mousemove: function(e) {
				this.getNext('img').setStyles({
					top: e.page.y - 260,
					left: e.page.x + 10
				});
			},
			mouseenter: function() {
				var popup = new Element('img', {'class': 'popped_image', src: this.src});
				popup.inject(this, 'after');
			},
			mouseleave: function() {
				mainScope.getElements('.popped_image').destroy();
			}
		});

		ajaxNote.success();


		// direct_uploads.js
    mainScope.addEventListener("direct-upload:initialize", function (event) {
      var target = event.target;
      var detail = event.detail;
      var id = detail.id;
      var file = detail.file;
      target.insertAdjacentHTML("beforebegin",
        '<div id="direct-upload-' + id + '" class="direct-upload direct-upload--pending">' +
        '<div id="direct-upload-progress-' + id + '" class="direct-upload__progress" style="width: 0%"></div>' +
        '<span class="direct-upload__filename">' + file.name + '</span>' +
        '</div>'
      );
    });

    mainScope.addEventListener("direct-upload:start", function (event) {
      var id = event.detail.id;
      var element = document.getElementById('direct-upload-' + id);
      element.classList.remove("direct-upload--pending");
    });

    mainScope.addEventListener("direct-upload:progress", function (event) {
      var id = event.detail.id;
      var progress = event.detail.progress;
      var progressElement = document.getElementById('direct-upload-progress-' + id);
      progressElement.style.width = progress + "%";
    });

    mainScope.addEventListener("direct-upload:error", function (event) {
      event.preventDefault();
      var id = event.detail.id;
      var error = event.detail.error;
      var element = document.getElementById('direct-upload-' + id);
      element.classList.add("direct-upload--error");
      element.setAttribute("title", error);
    });

    mainScope.addEventListener("direct-upload:end", function (event) {
      var id = event.detail.id;
      var element = document.getElementById('direct-upload-' + id);
      element.classList.add("direct-upload--complete");
    });
	});


	var bodyCallback = function () {
		window.fireEvent('bhfDomChunkReady', [document.body]);
	};
	var scopeCallback = function (scope) {
		window.fireEvent('bhfDomChunkReady', [scope]);
	};
	document.addEventListener('turbolinks:request-start', function () {
		ajaxNote.loading();
	});
	document.addEventListener('turbolinks:load', bodyCallback);
	window.addEvent('platformUpdate', scopeCallback);
	window.addEvent('quickEditFormInject', scopeCallback);
}());
