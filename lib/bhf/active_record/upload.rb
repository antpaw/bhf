module Bhf
  module ActiveRecord
    module Upload
      extend ActiveSupport::Concern

      included do
        before_save :bhf_upload
        cattr_accessor :bhf_upload_settings
      end

      module ClassMethods
        def setup_upload(settings)
          self.bhf_upload_settings = settings.each_with_object([]) do |s, obj|
            obj << {:path => '', :name => :file}.merge(s)
          end
        end
      end

      def bhf_upload
        self.class.bhf_upload_settings.each do |settings|
          name_was = send("#{settings[:name]}_was")
          param_name = read_attribute(settings[:name])
          file_string = if param_name && param_name[:delete].to_i != 0
            # File.delete(settings[:path] + name_was.to_s) if File.exist?(settings[:path] + name_was.to_s)
            nil
          else
            file = param_name && param_name[:file]
            if file.is_a? ActionDispatch::Http::UploadedFile
              # File.delete(settings[:path] + name_was.to_s) if File.exist?(settings[:path] + name_was.to_s)

              filename = Time.now.to_i.to_s+'_'+file.original_filename.downcase.sub(/[^\w\.\-]/,'_')
              path = File.join(settings[:path], filename)
              File.open(path, 'w') { |f| f.write(file.read) }
              filename
            else
              name_was
            end
          end
          write_attribute settings[:name], file_string
        end
      end

    end
  end
end