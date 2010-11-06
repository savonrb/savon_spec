module Savon
  module Spec

    # = Savon::Spec::Fixture
    #
    # Loads SOAP response fixtures.
    class Fixture
      class << self

        def path
          @path ||= Rails.root.join("spec", "fixtures").to_s if defined? Rails
          
          raise ArgumentError, "Savon::Spec::Fixture.path needs to be specified" unless @path
          @path
        end

        attr_writer :path

        def load(*args)
          file = args.map { |arg| arg.to_s.snakecase }.join("/")
          fixtures[file] ||= load_file file
        end

        alias [] load

      private

        def fixtures
          @fixtures ||= {}
        end

        def load_file(file)
          full_path = File.expand_path File.join(path, "#{file}.xml")
          raise ArgumentError, "Unable to load: #{full_path}" unless File.exist? full_path
          
          File.read full_path
        end

      end
    end
  end
end
