require '../lib/tagfu/tagger.rb'
require 'rspec/expectations'
require 'tmpdir'

RSpec.configure do |config|
	@dir = Dir.mktmpdir
	config.before(:all) do
		files = {
			:no_tags => 
			"""
				Feature: No Tags in feature file
				
				Scenario: sample story
					Given I have a feature file with no tags
					When I run it through the tagger
					Then I see nothing changed
			""",
			:add_tags => 
			"""
				Feature: No Tags in feature file
				
				Scenario: sample story
					Given I have a feature file with no tags
					When I run it through the tagger
					Then I see nothing changed
			""",
			:one_tag_to_delete =>
			"""
				@wip
				Feature: One tag to delete in feature file		
				
				Scenario: sample story
					Given I have a feature file with one tag
					When I run it through the tagger
					Then I see that the tag has been deleted
			""", 
			:one_tag_add_update => 
			"""
				Feature: No Tags in feature file
				
				@pass
				Scenario: sample story
					Given I have a feature file with no tags
					When I run it through the tagger
					Then I see nothing changed
			""",
			:one_tag_to_update =>
			"""
				@wip
				Feature: One tag to update in feature file		
				
				Scenario: sample story
					Given I have a feature file with one tag
					When I run it through the tagger
					Then I see that the tag has been updated
			""",
			:three_tags_delete_update =>
			"""
				Feature: Three tags to update in feature file		
				
				@wip @story1 @story2
				@story3
				Scenario: sample story
					Given I have a feature file with three tags
					When I run it through the tagger
					Then I see that the tags has been updated
			""",
			:four_tags_add_delete =>
			"""
				@wip @story1
				Feature: One tag to update in feature file		
				
				@wip 
				@story1 
				@story2
				Scenario: sample story
					Given I have a feature file with three tags
					When I run it through the tagger
					Then I see that the tags has been updated
			""",
			:all_tags_delete =>
			"""
				@wip @smoke
				@story1
				Feature: One tag to delete in feature file		
					
				@story2
				@story3 @story4
				Scenario: sample story
					Given I have a feature file with one tag
					When I run it through the tagger
					Then I see that the tag has been deleted
			""" 
		}
		files.each_pair do |feature_name, feature|
			File.open("#{feature_name.to_s}.feature", 'w') { |f| f.write(feature) }
		end
	end

	config.after(:all) do
		#FileUtils.remove_entry_secure @dir
		files = Dir.glob("*.feature")
		#files.each {|file| File.unlink(file)}
	end

	describe Tagfu::Tagger do
		it "should not change feature file when no tags present" do
			file = "no_tags.feature"
			file_before = File.readlines(file)
			Tagfu::Tagger.new({:path => file, :delete_tags => ["smoke"]}).get_files
			File.readlines(file).each_with_index do |line, index|
				line.should == file_before[index]
			end
		end

		it "should update tags when present in feature file" do
			file = "one_tag_to_update.feature"
			Tagfu::Tagger.new({:path => file, :update_tags => ["wip", "woot"]}).get_files
			File.readlines(file).any? {|line| line =~ /@wip/}.should be_false
			File.readlines(file).any? {|line| line =~ /@woot/}.should be_true
		end

		it "should delete tags when present in feature file" do
			file = "one_tag_to_delete.feature"
			Tagfu::Tagger.new({:path => file, :delete_tags => ["wip"]}).get_files
			File.readlines(file).any? {|line| line =~ /@/}.should be_false
		end

		it "should add tags to feature file" do
			file = "add_tags.feature"
			Tagfu::Tagger.new({:path => file, :add_tags => ["wip"]}).get_files
			File.readlines(file).any? {|line| line =~ /@wip/}.should be_true
		end

		it "should add/update tags in feature file" do
			file = "one_tag_add_update.feature"
			Tagfu::Tagger.new({:path => file, :add_tags => ["wip", "woot"], :update_tags => ["pass", "smoke"]}).get_files
			File.readlines(file).any? {|line| line =~ /@smoke/}.should be_true
		end

		it "should delete/update tags in feature file" do
			file = "three_tags_delete_update.feature"
			Tagfu::Tagger.new({:path => file, :delete_tags => ["wip", "story3"], :update_tags => ["story1", "smoke"]}).get_files
			File.readlines(file).any? {|line| line =~ /@story3/}.should be_false
			File.readlines(file).any? {|line| line =~ /@wip/}.should be_false
			File.readlines(file).any? {|line| line =~ /@smoke/}.should be_true
		end

		it "should add/delete tags in feature file" do
			file = "four_tags_add_delete.feature"
			Tagfu::Tagger.new({:path => file, :delete_tags => ["wip", "story1"], :update_tags => ["story2", "story3"]}).get_files
			File.readlines(file).any? {|line| line =~ /@story1/}.should be_false
			File.readlines(file).any? {|line| line =~ /@wip/}.should be_false
			File.readlines(file).any? {|line| line =~ /@story2/}.should be_false
			File.readlines(file).any? {|line| line =~ /@story3/}.should be_true
		end

		it "should delete all tags in feature file" do
			file = "all_tags_delete.feature"
			Tagfu::Tagger.new({:path => file, :delete_all => true}).get_files
			File.readlines(file).any? {|line| line =~ /@/}.should be_false
		end
	end
end
