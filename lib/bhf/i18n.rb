module Bhf
  module I18nTranslationFallbackHelper
    def self.included(base) 
      base.module_eval do
        class << self
          def translate_with_fallback(text, options = {})
            return translate_without_fallback(text, options) unless text.to_s.split('.')[0] == 'bhf'

            default = options.delete(:default)
          
            [locale, :en].each do |lookup_locale|
              translation_found, translation = attempt_translation(text, options.merge(locale: lookup_locale))
              return translation if translation_found
            end
          
            # Ensure 'translation missing' return is exactly the default behaviour
            translate_without_fallback(text, options.merge(default: default))
          end
        
          def attempt_translation(text, options = {})
            puts "Attempting translation of '#{text}' with locale '#{options[:locale]}'." if options[:debug]
            translation = translate_without_fallback(text, options.merge(raise: true))
            translation_found = options[:locale]
          rescue I18n::MissingTranslationData
            translation_found = nil
            translation = "translation missing: #{options[:locale]}, #{text}"
          ensure
            return translation_found, translation
          end
          
          alias_method_chain :translate, :fallback
          alias_method :t, :translate_with_fallback
        end
      end 
    end
  end
end