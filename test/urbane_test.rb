# encoding: UTF-8
require 'test_helper'

class Urbane::GeneratorTest < Test::Unit::TestCase
  FIXTURE_FILE_PATH = File.join('test', 'fixtures')
  TARGET_DIR = File.join('/tmp', 'translation_generator_test')

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
        :fallback_language => :english
      }
   end

    teardown do
      FileUtils.rm_rf(TARGET_DIR)
    end

    should 'create a folder and a document for each locale' do
      generator = Urbane::Generator.new(@options).run
      @options[:languages].values.each do |locale|
        expected_file = File.join(TARGET_DIR, locale,'text_ids.json')
        assert File.exists?(expected_file), "file #{expected_file} should exist"
      end
    end

    should 'fall back if a key is empty' do
      generator = Urbane::Generator.new(@options).run
      info_hash_fr = JSON.parse(File.open(File.join(TARGET_DIR,'fr', 'text_ids.json'), "r"){ |f| f.read  })
      info_hash_us = JSON.parse(File.open(File.join(TARGET_DIR,'en', 'text_ids.json'), "r"){ |f| f.read  })
      assert_equal info_hash_us['sun_intro_step2'], info_hash_fr['sun_intro_step2']
    end

    should 'handle special chars' do
      generator = Urbane::Generator.new(@options).run
      info_hash_de = JSON.parse(File.open(File.join(TARGET_DIR,'de', 'text_ids.json'), "r"){ |f| f.read  })
      assert info_hash_de['sun_intro_step2'].include?('äÄö')
    end
  end
end
