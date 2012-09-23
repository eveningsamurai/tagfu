require 'optparse'
require 'tagfu/tagger'

module Tagfu
	def self.run(*args)
		options = {}

		option_parser = OptionParser.new do |opts|
			opts.banner = 'Usage: tagfu [PATH] [OPTIONS]'

			opts.on('-d', '--delete TAG1,TAG2', Array, 'Delete comma seperated list of tags from scenario(s), e.g. smoke, regression, wip') do |tags|
				options[:delete_tags] = tags
			end

			opts.on('--delete-all', 'Delete all tags from specified feature files') do |t|
				options[:delete_all] = true
			end

			opts.on('-u', '--update FROM_TAG,TO_TAG', Array, 'Update tag names in scenario(s) e.g. "wip" to "smoke"') do |tags|
				options[:update_tags] = tags
			end

			opts.on('-a', '--add TAG1,TAG2', Array, 'Add comma seperated list of tags at the feature level, e.g. smoke, regression, wip') do |tags|
				options[:add_tags] = tags
			end
	
			opts.on('-p PATH', '--path PATH', 'Path to the cucumber feature file(s)') do |path|
				options[:path] = path
			end
		end

		begin 
			option_parser.parse!
			raise OptionParser::MissingArgument, "Atleast one of the options '--update', '--delete', '--add' or '--delete-all' should be specified" if op_tags_absent?(options)
			raise OptionParser::MissingArgument, "Path '--path' should be specified" if path_absent?(options[:path])
		rescue OptionParser::ParseError => e
			puts e.message
			puts
			puts option_parser
			exit -1
		end

		Tagger.new(options).get_files
	end
	
	def self.op_tags_absent?(options)		
		tags = [:update_tags, :delete_tags, :add_tags, :delete_all]
		(tags & options.keys).empty?
	end

	def self.path_absent?(path)
		path.nil?
	end
	
end

