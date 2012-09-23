module Tagfu

	class Tagger
		def initialize(options={})
			@add_tags    = options[:add_tags]
			@update_tags = options[:update_tags]
			@delete_tags = options[:delete_tags]
			@delete_all  = options[:delete_all]
			@path        = options[:path]
		end
		
		def sanitize_tags(tags)
			tags.collect! {|tag| tag.match(/^@/) ? tag : "@#{tag}"}
		end

		def get_files
			if File.directory?(@path)
				current_working_dir = Dir.pwd
				Dir.chdir(@path)
				files = Dir.glob("**/*.feature")
				raise ArgumentError, "No cucumber feature files in specified path" if files.empty?
				files.each {|file| process_file(file)}
				Dir.chdir(current_working_dir)
			elsif File.file?(@path)
				process_file(@path)
			else
				raise ArgumentError, "Path specified is either invalid or not a file/directory"
			end
		end

		def process_file(file)
			lines = File.readlines(file)
			if @delete_all
				delete_all(lines)
			end
			unless @delete_tags.nil?
				sanitize_tags(@delete_tags)
				delete_tags(lines)
			end
			unless @add_tags.nil?
				sanitize_tags(@add_tags)
				add_tags(lines)
			end
			unless @update_tags.nil?
				sanitize_tags(@update_tags)
				@update_tags = {:from_tag => @update_tags.first, :to_tag => @update_tags.last}
				update_tags(lines)
			end
			File.open(file, 'w') do |fh|
				lines.each do |line|
					fh.write line
				end			
			end
		end

		def delete_all(lines)
			lines_to_delete = []
			lines.each_with_index do |line, index|
				if line.match(/@/)
					lines_to_delete << index
				end
			end
			running_index = 0
			lines_to_delete.each do |line_index|
				lines.delete_at(line_index - running_index)
				running_index += 1
			end
		end

		def delete_tags(lines)
			@delete_tags.each do |tag|
				lines.each_with_index do |line, index|
					if only_tag?(line, tag)
						lines.delete_at(index)
					else	
						indent = lines[index][/^\s+/].to_s
						line = line.strip
						next if line.empty?
						lines[index] = indent + line.chomp.split(' ').delete_if {|word| word.match(/#{tag}/)}.join(' ') + "\n" if line.match(/^@/)
					end
				end
			end
		end

		def only_tag?(line, tag)
			return line.strip == tag
		end

		def add_tags(lines)
			feature_index = find_index_of_feature(lines)
			indent = lines[feature_index][/^\s+/].to_s
			lines.insert(feature_index, indent + @add_tags.join(' ') + "\n")
		end

		def find_index_of_feature(lines)
			lines.each_with_index do |line, index|
				return index if line.strip.match(/^Feature:/)
			end
		end

		def update_tags(lines)
			lines.each_with_index do |line, index|
				indent = lines[index][/^\s+/].to_s
				if only_tag?(line, @update_tags[:from_tag])
					lines.delete_at(index)
					lines.insert(index, indent + "#{@update_tags[:to_tag]}\n")
				else
					line = line.strip
					next if line.empty?
					lines[index] = indent + line.chomp.split(' ').map! {|word| word == "#{@update_tags[:from_tag]}" ? "#{@update_tags[:to_tag]}" : word}.join(' ') + "\n" if line.match(/^@/)
				end
			end
		end
	end
end
