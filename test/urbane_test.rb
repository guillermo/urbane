# encoding: UTF-8
require 'test_helper'

FIXTURE_FILE_PATH = File.join('test', 'fixtures')
TARGET_DIR = File.join('/tmp', 'translation_generator_test')

def read_file(path)
  File.open(File.join(TARGET_DIR, path), "r"){ |f| f.read  }
end

def read_json_file(path)
  JSON.parse(read_file(path))
end

class Urbane::GeneratorTest < Test::Unit::TestCase

  context 'generator' do
    setup do
      FileUtils.mkdir_p(TARGET_DIR)
      response = File.open(File.join(FIXTURE_FILE_PATH,'google_spreadsheet_response.json')){|f| f.read}
      FakeWeb.register_uri(:get,
        "http://spreadsheets.google.com/feeds/worksheets/0AmfBdooXTXfQdHBRRkstNlJsdkpkaVVUdU5JTm1RZmc/public/values/?alt=json",
        :body => response
        )

      response = File.open(File.join(FIXTURE_FILE_PATH,'google_worksheet_response.json')){|f| f.read}
      FakeWeb.register_uri(:get,
        "http://spreadsheets.google.com/feeds/list/0AmfBdooXTXfQdHBRRkstNlJsdkpkaVVUdU5JTm1RZmc/od6/public/values?alt=json",
        :body => response)


      @options = {
        :spreadsheet_id => '0AmfBdooXTXfQdHBRRkstNlJsdkpkaVVUdU5JTm1RZmc',
        :target_dir => TARGET_DIR,
        :file_name => 'text_ids.json',
        :languages => {
          :english => 'en',
          :german => 'de',
          :french => 'fr',
          :italian => 'it',
          :turkish => 'tr',
          :spanish => 'es',
          :portuguese => 'pt'
        },
        :fallback_language => :english,
        :format => :json
      }
   end

    teardown do
      FileUtils.rm_rf(TARGET_DIR)
    end

    should 'create a folder and a document for each locale' do
      Urbane::Generator.new(@options).run
      @options[:languages].values.each do |locale|
        expected_file = File.join(TARGET_DIR, locale,'text_ids.json')
        assert File.exists?(expected_file), "file #{expected_file} should exist"
      end
    end

    should 'fall back if a key is empty' do
      Urbane::Generator.new(@options).run
      info_hash_fr = read_json_file(File.join('fr', 'text_ids.json'))
      info_hash_us = read_json_file(File.join('en', 'text_ids.json'))
      assert_equal info_hash_us['sun_intro_step2'], info_hash_fr['sun_intro_step2']
    end

    should 'handle special chars' do
      Urbane::Generator.new(@options).run
      info_hash_de = read_json_file(File.join('de', 'text_ids.json'))
      assert info_hash_de['sun_intro_step2'].include?('äÄö')
    end

    # How do I test this? JSON is a subset of YAML, so most JSON will actually
    # be valid YAML
    should 'support yaml output' do
      @options[:format] = :yaml
      @options[:file_name] = 'text_ids.yml'
      Urbane::Generator.new(@options).run
      assert YAML.load(read_file(File.join('en', 'text_ids.yml')));
    end

    should 'support xml' do
      @options[:format] = :xml
      @options[:file_name] = 'text_ids.xml'
      Urbane::Generator.new(@options).run
      assert Nokogiri::XML(read_file(File.join('en', 'text_ids.xml')));
    end

    should 'support apples localization format' do
      @options[:format] = :apple_strings
      @options[:file_name] = 'text_ids.strings'
      Urbane::Generator.new(@options).run
      expected_first_line = '"sun_intro_step2" = "Build another one…";'
      actual_first_line = read_file(File.join('en', 'text_ids.strings')).split("\n")[0]
      assert_equal expected_first_line, actual_first_line
    end
  end
end
