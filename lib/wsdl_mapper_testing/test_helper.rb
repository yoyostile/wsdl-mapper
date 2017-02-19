require 'wsdl_mapper/dom_parsing/default_resolver'

module WsdlMapperTesting
  module TestHelper
    extend self

    def get_fixture(name)
      path = File.join ::TEST_FIXTURE_PATH, name
      File.read(path)
    end

    def get_xml_doc(name)
      Nokogiri::XML::Document.parse get_fixture name
    end

    def parse_schema(name, import_resolver: nil)
      import_resolver ||= ::WsdlMapper::DomParsing::DefaultResolver.new ::TEST_FIXTURE_PATH
      WsdlMapper::DomParsing::Parser.new(import_resolver: import_resolver).parse get_xml_doc name
    end

    def parse_wsdl(name)
      WsdlMapper::SvcDescParsing::Parser.new.parse(get_xml_doc(name)).first
    end

    def get_tmp_path
      TmpPath.new
    end

    def assert_same_xml(this, that)
      xml1 = normalize_xml this
      xml2 = normalize_xml that

      assert_equal xml1, xml2
    end

    def normalize_xml(xml)
      xml.gsub(/>\s+</, '><').gsub('><', ">\n<").strip
    end
  end
end
