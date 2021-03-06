require 'wsdl_mapper/svc_generation/svc_generator'
require 'wsdl_mapper/svc_generation/documented_port_generator'
require 'wsdl_mapper/svc_generation/documented_service_generator'
require 'wsdl_mapper/svc_generation/documented_operation_generator'
require 'wsdl_mapper/svc_generation/documented_proxy_generator'
require 'wsdl_mapper/generation/yard_doc_formatter'

module WsdlMapper
  module SvcGeneration
    class DocumentedSvcGenerator < SvcGenerator
      def initialize(context,
        formatter_factory: DefaultFormatter,
        namer: WsdlMapper::Naming::DefaultNamer.new,
        service_namer: WsdlMapper::Naming::DefaultServiceNamer.new,
        service_generator_factory: DocumentedServiceGenerator,
        port_generator_factory: DocumentedPortGenerator,
        proxy_generator_factory: DocumentedProxyGenerator,
        operation_generator_factory: DocumentedOperationGenerator,
        operation_s8r_generator_factory: OperationS8rGenerator,
        operation_d10r_generator_factory: OperationD10rGenerator,
        schema_generator: nil)
        super
      end

      def generate_api_service_accessors(f, services)
        yard = WsdlMapper::Generation::YardDocFormatter.new f
        services.each do |s|
          attr_name = s.property_name.attr_name
          type = s.name.name
          yard.attribute! attr_name, type, nil do
            yard.tag :soap_name, s.type.name.name
          end
          f.attr_readers attr_name
        end
      end
    end
  end
end
