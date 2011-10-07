require "urbane/version"
require "json"
require "open-uri"

module Urbane
  class Generator

    def initialize(options)
      @target_dir = options[:target_dir]
      @spreadsheet_id = options[:spreadsheet_id]
      @file_name_for_translation_file = options[:file_name]
      @language_locale_map = options[:languages]
      @languages = @language_locale_map.keys
      @fallback_language = options[:fallback_language]
    end

    def run
      @text_ids = {}
      @languages.each do |language|
        @text_ids[language] = {}
      end

      process_spreadsheet
      write_files
    end

    def google_spreadsheet_url
      "http://spreadsheets.google.com/feeds/worksheets/#{@spreadsheet_id}/public/values/?alt=json"
    end

    private

    def write_files
      @language_locale_map.each do |language, locale|
        `mkdir -p #{@target_dir}/#{locale}`
        File.open("#{@target_dir}/#{locale}/#{@file_name_for_translation_file}", 'w') do |f|
          f.write JSON.pretty_generate(sorted_hash_for_language(language))
        end
      end
    end

    def sorted_hash_for_language(language)
      @text_ids[language].sort.inject({}) do |sorted_hash, translation|
        sorted_hash[translation[0]] = translation[1]
        sorted_hash
      end
    end

    def process_spreadsheet
      worksheet_list.each do |entry|
        rows_in_worksheet(entry).each do |row|
          assign_ids_for_row(row)
        end
      end
    end

    def assign_ids_for_row(row)
      key = (row['gsx$key'] || {})['$t'].to_s
      unless key.empty?
        @languages.each do |language|
          value = (row["gsx$#{language.to_s}"] || {})['$t'].to_s
          if value == ''
            @text_ids[language][key] = row["gsx$#{@fallback_language}"]['$t']
          else
            @text_ids[language][key] = value
          end
        end
      end
    end

    def rows_in_worksheet(entry)
      JSON.parse(open("#{url_for_worksheet(entry)}?alt=json"){|r| r.read})['feed']['entry'] || []
    end

    def url_for_worksheet(entry)
      entry['link'].select{|link| link['rel'] == 'http://schemas.google.com/spreadsheets/2006#listfeed'}.first['href']
    end

    def worksheet_list
      response = JSON.parse(open(google_spreadsheet_url){|r| r.read})
      response['feed']['entry']
    end

  end
end
