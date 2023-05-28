# frozen_string_literal: true

require 'fileutils'

top_level = self

using(Module.new do
  refine(top_level.singleton_class) do
    def generate_type_signature(dir_name)
      files = Dir.glob("app/#{dir_name}/**/*")

      files.each do |file|
        next unless file.include?('.rb')

        result = `bundle exec typeprof #{file}`

        dir_name = File.dirname(file)

        FileUtils.mkdir_p("sig/#{dir_name}")

        File.write("sig/#{file}s", result)
      end
    end
  end
end)

namespace :type do
  namespace :prof do
    task models: :environment do
      generate_type_signature('models')
    end

    task controllers: :environment do
      generate_type_signature('controllers')
    end

    task helpers: :environment do
      generate_type_signature('helpers')
    end

    task lib: :environment do
      generate_type_signature('lib')
    end

    task presenters: :environment do
      generate_type_signature('presenters')
    end

    task serializers: :environment do
      generate_type_signature('serializers')
    end

    task services: :environment do
      generate_type_signature('services')
    end

    task validators: :environment do
      generate_type_signature('validators')
    end

    task workers: :environment do
      generate_type_signature('workers')
    end
  end

  task prof: ['prof:models', 'prof:controllers', 'prof:helpers', 'prof:lib', 'prof:presenters', 'prof:serializers', 'prof:services', 'prof:validators', 'prof:workers']
end
