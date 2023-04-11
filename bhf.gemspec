# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: bhf 1.0.0.beta16 ruby lib

Gem::Specification.new do |s|
  s.name = "bhf".freeze
  s.version = "1.0.0.beta16"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Anton Pawlik".freeze]
  s.date = "2023-04-11"
  s.description = "A simple to use Rails-Engine-Gem that offers an admin interface for trusted user. Easy integratable and highly configurable and agnostic. Works with ActiveRecord and Mongoid.".freeze
  s.email = "anton.pawlik@gmail.com".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".editorconfig",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "app/assets/images/bhf/ajax_loader.gif",
    "app/assets/images/bhf/bg.png",
    "app/assets/images/bhf/logo_bhf.svg",
    "app/assets/images/bhf/mooeditable-toolbarbuttons-tango.png",
    "app/assets/images/bhf/pictos.png",
    "app/assets/images/bhf/pictos_2x.png",
    "app/assets/images/bhf/small_ajax_loader.gif",
    "app/assets/images/bhf/small_ajax_loader_h.gif",
    "app/assets/images/bhf/wmd-buttons.png",
    "app/assets/javascripts/bhf/MooTools-More-1.6.0.js",
    "app/assets/javascripts/bhf/application.js",
    "app/assets/javascripts/bhf/classes/Ajaxify.js",
    "app/assets/javascripts/bhf/classes/ArrayFields.js",
    "app/assets/javascripts/bhf/classes/FormHelper.js",
    "app/assets/javascripts/bhf/classes/MooEditable.js",
    "app/assets/javascripts/bhf/classes/MultipleFields.js",
    "app/assets/javascripts/bhf/classes/Picker.js",
    "app/assets/javascripts/bhf/classes/Picker_Attach.js",
    "app/assets/javascripts/bhf/classes/Picker_Date.js",
    "app/assets/javascripts/bhf/classes/PlatformHelper.js",
    "app/assets/javascripts/bhf/classes/QuickEdit.js",
    "app/assets/javascripts/bhf/classes/QuickEditStack.js",
    "app/assets/javascripts/bhf/classes/Request_bhf.js",
    "app/assets/javascripts/bhf/classes/Setlatlng.js",
    "app/assets/javascripts/bhf/classes/showdown.js",
    "app/assets/javascripts/bhf/classes/wmd.js",
    "app/assets/javascripts/bhf/locales/Locale.de-DE.js",
    "app/assets/javascripts/bhf/locales/Locale.en-US.js",
    "app/assets/javascripts/bhf/locales/Locale.pt-PT.js",
    "app/assets/javascripts/bhf/mootools_ujs.js",
    "app/assets/javascripts/bhf/trix.js",
    "app/assets/stylesheets/bhf/MooEditable.scss",
    "app/assets/stylesheets/bhf/application.sass",
    "app/assets/stylesheets/bhf/functions.sass",
    "app/assets/stylesheets/bhf/reset.sass",
    "app/assets/stylesheets/bhf/trix.scss",
    "app/assets/stylesheets/bhf/typo.scss",
    "app/controllers/bhf/application_controller.rb",
    "app/controllers/bhf/embed_entries_controller.rb",
    "app/controllers/bhf/entries_controller.rb",
    "app/controllers/bhf/pages_controller.rb",
    "app/helpers/bhf/application_helper.rb",
    "app/helpers/bhf/entries_helper.rb",
    "app/helpers/bhf/frontend_helper.rb",
    "app/helpers/bhf/pages_helper.rb",
    "app/views/bhf/_footer.html.haml",
    "app/views/bhf/_user.html.haml",
    "app/views/bhf/application/index.html.haml",
    "app/views/bhf/entries/_form.html.haml",
    "app/views/bhf/entries/_validation_errors.html.haml",
    "app/views/bhf/entries/edit.html.haml",
    "app/views/bhf/entries/new.html.haml",
    "app/views/bhf/entries/show.html.haml",
    "app/views/bhf/form/belongs_to/_radio.html.haml",
    "app/views/bhf/form/belongs_to/_select.html.haml",
    "app/views/bhf/form/belongs_to/_static.html.haml",
    "app/views/bhf/form/column/_activestorage_attachment.html.haml",
    "app/views/bhf/form/column/_activestorage_attachments.html.haml",
    "app/views/bhf/form/column/_array.html.haml",
    "app/views/bhf/form/column/_attachment_presenter.html.haml",
    "app/views/bhf/form/column/_boolean.html.haml",
    "app/views/bhf/form/column/_date.html.haml",
    "app/views/bhf/form/column/_hash.html.haml",
    "app/views/bhf/form/column/_hidden.html.haml",
    "app/views/bhf/form/column/_image_file.html.haml",
    "app/views/bhf/form/column/_mappin.html.haml",
    "app/views/bhf/form/column/_markdown.html.haml",
    "app/views/bhf/form/column/_multiple_fields.html.haml",
    "app/views/bhf/form/column/_number.html.haml",
    "app/views/bhf/form/column/_password.html.haml",
    "app/views/bhf/form/column/_rich_text.html.haml",
    "app/views/bhf/form/column/_static.html.haml",
    "app/views/bhf/form/column/_string.html.haml",
    "app/views/bhf/form/column/_text.html.haml",
    "app/views/bhf/form/column/_type.html.haml",
    "app/views/bhf/form/column/_wysiwyg.html.haml",
    "app/views/bhf/form/embeds_many/_static.html.haml",
    "app/views/bhf/form/embeds_one/_static.html.haml",
    "app/views/bhf/form/has_and_belongs_to_many/_check_box.html.haml",
    "app/views/bhf/form/has_and_belongs_to_many/_static.html.haml",
    "app/views/bhf/form/has_many/_check_box.html.haml",
    "app/views/bhf/form/has_many/_static.html.haml",
    "app/views/bhf/form/has_one/_select.html.haml",
    "app/views/bhf/form/has_one/_static.html.haml",
    "app/views/bhf/helper/_definition_item.html.haml",
    "app/views/bhf/helper/_field_errors.html.haml",
    "app/views/bhf/helper/_flash.html.haml",
    "app/views/bhf/helper/_frontend_edit.html.haml",
    "app/views/bhf/helper/_info.html.haml",
    "app/views/bhf/helper/_node.html.haml",
    "app/views/bhf/helper/_reflection_node.html.haml",
    "app/views/bhf/pages/_platform.html.haml",
    "app/views/bhf/pages/_search.html.haml",
    "app/views/bhf/pages/show.html.haml",
    "app/views/bhf/table/belongs_to/_default.html.haml",
    "app/views/bhf/table/column/_array.html.haml",
    "app/views/bhf/table/column/_boolean.html.haml",
    "app/views/bhf/table/column/_carrierwave.html.haml",
    "app/views/bhf/table/column/_date.html.haml",
    "app/views/bhf/table/column/_empty.html.haml",
    "app/views/bhf/table/column/_extern_link.html.haml",
    "app/views/bhf/table/column/_file.html.haml",
    "app/views/bhf/table/column/_hash.html.haml",
    "app/views/bhf/table/column/_image.html.haml",
    "app/views/bhf/table/column/_number.html.haml",
    "app/views/bhf/table/column/_primary_key.html.haml",
    "app/views/bhf/table/column/_string.html.haml",
    "app/views/bhf/table/column/_text.html.haml",
    "app/views/bhf/table/column/_thumbnail.html.haml",
    "app/views/bhf/table/column/_toggle.html.haml",
    "app/views/bhf/table/column/_type.html.haml",
    "app/views/bhf/table/embeds_many/_default.html.haml",
    "app/views/bhf/table/embeds_one/_default.html.haml",
    "app/views/bhf/table/has_and_belongs_to_many/_default.html.haml",
    "app/views/bhf/table/has_many/_default.html.haml",
    "app/views/bhf/table/has_one/_default.html.haml",
    "app/views/kaminari/bhf/_gap.html.haml",
    "app/views/kaminari/bhf/_next_page.html.haml",
    "app/views/kaminari/bhf/_page.html.haml",
    "app/views/kaminari/bhf/_paginator.html.haml",
    "app/views/kaminari/bhf/_prev_page.html.haml",
    "app/views/layouts/bhf/application.haml",
    "app/views/layouts/bhf/quick_edit.haml",
    "bhf.gemspec",
    "config/locales/de.yml",
    "config/locales/en.yml",
    "config/locales/pt.yml",
    "config/routes.rb",
    "lib/bhf.rb",
    "lib/bhf/action_view/form_builder.rb",
    "lib/bhf/action_view/form_options.rb",
    "lib/bhf/active_record/base.rb",
    "lib/bhf/controller/extension.rb",
    "lib/bhf/mongoid/document.rb",
    "lib/bhf/platform/attribute/abstract.rb",
    "lib/bhf/platform/attribute/column.rb",
    "lib/bhf/platform/attribute/reflection.rb",
    "lib/bhf/platform/base.rb",
    "lib/bhf/platform/pagination.rb",
    "lib/bhf/settings/base.rb",
    "lib/bhf/settings/platform.rb",
    "lib/bhf/settings/yaml_parser.rb",
    "lib/rails/generators/bhf/templates/initializer.rb",
    "test/database.yml",
    "test/test_helper.rb"
  ]
  s.homepage = "https://antpaw.github.io/bhf".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.9".freeze
  s.summary = "A simple to use Rails-Engine-Gem that offers an admin interface for trusted user.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 5.2.2.1"])
      s.add_runtime_dependency(%q<sass-rails>.freeze, [">= 6"])
      s.add_runtime_dependency(%q<turbolinks>.freeze, [">= 2"])
      s.add_runtime_dependency(%q<kaminari>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<haml-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<shoulda>.freeze, [">= 3"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 3"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 1"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 2"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 5.2.2.1"])
      s.add_dependency(%q<sass-rails>.freeze, [">= 6"])
      s.add_dependency(%q<turbolinks>.freeze, [">= 2"])
      s.add_dependency(%q<kaminari>.freeze, [">= 0"])
      s.add_dependency(%q<haml-rails>.freeze, [">= 0"])
      s.add_dependency(%q<shoulda>.freeze, [">= 3"])
      s.add_dependency(%q<rdoc>.freeze, [">= 3"])
      s.add_dependency(%q<bundler>.freeze, [">= 1"])
      s.add_dependency(%q<jeweler>.freeze, [">= 2"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 5.2.2.1"])
    s.add_dependency(%q<sass-rails>.freeze, [">= 6"])
    s.add_dependency(%q<turbolinks>.freeze, [">= 2"])
    s.add_dependency(%q<kaminari>.freeze, [">= 0"])
    s.add_dependency(%q<haml-rails>.freeze, [">= 0"])
    s.add_dependency(%q<shoulda>.freeze, [">= 3"])
    s.add_dependency(%q<rdoc>.freeze, [">= 3"])
    s.add_dependency(%q<bundler>.freeze, [">= 1"])
    s.add_dependency(%q<jeweler>.freeze, [">= 2"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
  end
end

