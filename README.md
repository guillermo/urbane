# README

Read a google spreadsheet and generate translation files into a target
directory as JSON files. It uses the googles JSON api as opposed to the XML api. That means that one has to publish the doc in order to get the spreadsheet id. At some point, it makes sense to use the more powerfull XML API using credentials to load the spreadsheet.

## Installation

	gem install urbane

## Usage
  
	require 'urbane'
	
	spreadsheet_id = '0Amfbd9df0sdflkewsd09dsfkl328sdf02'
	target_dir = '/tmp/translations'
	file_name = 'text_ids.json'
	languages = [:en, :de , :fr, :it, :tr, :es]

	Urbane::Generator.new({
	  :spreadsheet_id => spreadsheet_id,
	  :target_dir => target_dir,
	  :file_name => file_name,
	  :languages => languages,
	  :fallback_language => :en
	}).run

## How to find the google spreadsheet id

To be described
