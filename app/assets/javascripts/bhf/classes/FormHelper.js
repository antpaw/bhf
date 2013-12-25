var FormHelper = new Class({
	version: 0.1,
	
	wysiwyg: [],
	
	options: {
	},

	// Implements: [Options, Events],

	setup: function(_object, _options) {
		if ( ! _object) { return; }
		// this.setOptions(_options);
		var scope = _object;
		
		scope.getElements('.wysiwyg').each(function(elem){
			this.wysiwyg.push(elem.mooEditable());
		}.bind(this));

		scope.getElements('.multiple_field').each(function(elem){
			new MultipleFields(elem);
		});
		scope.getElements('.array_holder').each(function(elem){
			new ArrayFields(elem);
		});

		scope.getElements('.picker').each(function(input){
			var options = {
				timePicker: true,
				format: '%B %d, %Y %H:%M'
			};
			if (input.hasClass('date')) {
				options = {
					timePicker: false,
					format: '%B %d, %Y'
				};
			}
			else if (input.hasClass('time')) {
				options = {
					pickOnly: 'time',
					format: '%H:%M'
				};
			}

			var hiddenInput = input.clone();
			input.value = new Date().parse(input.value).format(options.format);
			input.erase('name');
			hiddenInput.set('type', 'hidden').inject(input, 'after');

			new Picker.Date(input, Object.merge({
				onSelect: function(date){
					hiddenInput.value = date.format('db');
				}
			}, options));
		});

		scope.getElements('.wmd_editor').each(function(mdTa){
			var headline, toggleHtmlPreview, toggleLivePreview, livePreview, htmlPreview;

			var togglePreview = function(e){
				var htmlMode = e.target.hasClass('toggle_html_preview');
				livePreview.toggleClass('hide', htmlMode);
				htmlPreview.toggleClass('hide', !htmlMode);
				toggleLivePreview.toggleClass('active', !htmlMode);
				toggleHtmlPreview.toggleClass('active', htmlMode);
			};

			headline = new Element('h6.preview_switch', {text: 'Preview'});

			toggleHtmlPreview = new Element('span.toggle_html_preview', {text: 'HTML'})
				.addEvent('click', togglePreview)
				.inject(headline);
			toggleLivePreview = new Element('span.toggle_live_preview', {text: 'Live'})
				.addEvent('click', togglePreview)
				.inject(headline);

			headline.inject(mdTa, 'after');

			livePreview = new Element('div.wmd-preview.hide').inject(headline, 'after');
			htmlPreview = new Element('div.wmd-output.hide').inject(livePreview, 'after');

			new WMDEditor({
				input: mdTa,
				button_bar: new Element('div').inject(mdTa, 'before'),
				preview: livePreview,
				output: htmlPreview,
				buttons: 'bold italic link image  ol ul heading hr  undo redo',
				modifierKeys: false,
				autoFormatting: false
			});
		});

		scope.getElements('.map_data_lat').each(function(lat){
			new Setlatlng(lat);
	    });
	}
});