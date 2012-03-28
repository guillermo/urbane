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
	
	# the keys define the column headers in the spreadsheet
	# the values define the name of the folder for a given language
	languages = {
	  :english => 'en',
	  :german => 'de',
	  :french => 'fr',
	  :italian => 'it',
	  :turkish => 'tr',
	  :spanish => 'es',
	  :portuguese => 'pt'
    }

	Urbane::Generator.new({
	  :spreadsheet_id => spreadsheet_id,
	  :target_dir => target_dir,
    :format => :json,
	  :file_name => file_name,
      :languages => languages,
      :fallback_language => :english
	}).run

## Output format

Support for YAML, JSON, XML and Apple Strings Files

  VALID_FORMATS = [:json, :yaml, :xml, :apple_strings]

## Output structure

	target_dir
		- en
			- text_ids.json
		- fr
			- text_ids.json

## Requirements

### A google spreadsheet

For now it needs to have a certain format. Check the [demo document](https://docs.google.com/spreadsheet/ccc?key=0Auo5c2PWMqR4dHlOSjlXcjY0X01udzNPdHlKZ09QTVE&hl=en_US). You have several sheets in one document


### A google spreadsheet id

1. Create a spreadsheet on google docs
2. Click on File -> Publish To The Web
3. Check 'Automatically republish when changes are made'
4. Find the spreadsheet id in the generated link. It is marked with 'key='. In the following url, the key would be '0Auo5c2PWMqR4dHlOSjlXcjY0X01udzNPdHlKZ09QTVE': https://docs.google.com/spreadsheet/pub?hl=en_US&hl=en_US&key=0Auo5c2PWMqR4dHlOSjlXcjY0X01udzNPdHlKZ09QTVE&output=html
5. Click on the close button
