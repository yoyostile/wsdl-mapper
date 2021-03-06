require 'wsdl_mapper/svc_generation/operation_generator_base'

module WsdlMapper
  module SvcGeneration
    class OperationGenerator < OperationGeneratorBase
      def generate_operation(service, port, op, result)
        modules = get_module_names service.name

        generate_op_input_body service, port, op, result
        generate_op_input_header service, port, op, result
        generate_op_output_header service, port, op, result
        generate_op_output_body service, port, op, result

        operation_s8r_generator.generate_operation_s8r service, port, op, result
        operation_d10r_generator.generate_operation_d10r service, port, op, result

        type_file_for op.name, result do |f|
          f.requires operation_base.require_path

          f.in_modules modules do
            in_classes f, service.name.class_name, port.name.class_name do
              generate_op_class f, service, port, op
            end
          end
        end
      end

      def generate_op_class(f, service, port, op)
        f.in_sub_class op.name.class_name, operation_base.name do
          generate_op_ctr f, service, port, op
          generate_new_input f, service, port, op
          generate_new_output f, service, port, op
          generate_input_s8r f, service, port, op
          generate_output_s8r f, service, port, op
          generate_input_d10r f, service, port, op
          generate_output_d10r f, service, port, op
        end
      end

      def generate_input_s8r(f, service, port, op)
        name = service_namer.get_input_s8r_name(service.type, port.type, op.type).name
        type_directory_name = namer.get_s8r_type_directory_name.name
        f.in_def :input_s8r do
          f.call :super
          f.statement "@input_s8r ||= #{name}.new(#{type_directory_name})"
        end
      end

      def generate_output_s8r(f, service, port, op)
        name = service_namer.get_output_s8r_name(service.type, port.type, op.type).name
        type_directory_name = namer.get_s8r_type_directory_name.name
        f.in_def :output_s8r do
          f.call :super
          f.statement "@output_s8r ||= #{name}.new(#{type_directory_name})"
        end
      end

      def generate_input_d10r(f, service, port, op)
        name = service_namer.get_input_d10r_name(service.type, port.type, op.type).name
        f.in_def :input_d10r do
          f.call :super
          f.statement "@input_d10r ||= #{name}"
        end
      end

      def generate_output_d10r(f, service, port, op)
        name = service_namer.get_output_d10r_name(service.type, port.type, op.type).name
        f.in_def :output_d10r do
          f.call :super
          f.statement "@output_d10r ||= #{name}"
        end
      end

      def generate_new_input(f, service, port, op)
        f.in_def :new_input, 'header: {}', 'body: {}' do
          f.call :super
          header_name = service_namer.get_input_header_name(service.type, port.type, op.type)
          body_name = service_namer.get_input_body_name(service.type, port.type, op.type)
          header_args = get_header_parts(op.type.input).any? ? '**header' : ''
          header = "#{header_name.name}.new(#{header_args})"
          body_args = get_body_parts(op.type.input).any? ? '**body' : ''
          body = "#{body_name.name}.new(#{body_args})"
          f.call :new_message, header, body
        end
      end

      def generate_new_output(f, service, port, op)
        f.in_def :new_output, 'header: {}', 'body: {}' do
          f.call :super
          header_name = service_namer.get_output_header_name(service.type, port.type, op.type)
          body_name = service_namer.get_output_body_name(service.type, port.type, op.type)
          header_args = get_header_parts(op.type.output).any? ? '**header' : ''
          header = "#{header_name.name}.new(#{header_args})"
          body_args = get_body_parts(op.type.output).any? ? '**body' : ''
          body = "#{body_name.name}.new(#{body_args})"
          f.call :new_message, header, body
        end
      end

      def generate_op_ctr(f, service, port, op)
        f.in_def :initialize, 'api', 'service', 'port' do
          f.call :super, 'api', 'service', 'port'
          f.assignment '@name', op.property_name.attr_name.inspect
          f.assignment '@operation_name', generate_name(op.type.name)
          f.assignment '@soap_action', op.type.soap_action.inspect
          f.literal_array '@requires', get_op_requires(service, port, op)
        end
      end

      def get_op_requires(service, port, op)
        requires = []
        get_header_parts(op.type.input).each do |part|
          next if WsdlMapper::Dom::BuiltinType.builtin? get_type_name(part.type).name
          requires << part.name.require_path
        end
        get_body_parts(op.type.input).each do |part|
          next if WsdlMapper::Dom::BuiltinType.builtin? get_type_name(part.type).name
          requires << part.name.require_path
        end
        get_header_parts(op.type.output).each do |part|
          next if WsdlMapper::Dom::BuiltinType.builtin? get_type_name(part.type).name
          requires << part.name.require_path
        end
        get_body_parts(op.type.output).each do |part|
          next if WsdlMapper::Dom::BuiltinType.builtin? get_type_name(part.type).name
          requires << part.name.require_path
        end
        requires << namer.get_s8r_type_directory_name.require_path
        requires << service_namer.get_input_header_name(service.type, port.type, op.type).require_path
        requires << service_namer.get_input_body_name(service.type, port.type, op.type).require_path
        requires << service_namer.get_output_header_name(service.type, port.type, op.type).require_path
        requires << service_namer.get_output_body_name(service.type, port.type, op.type).require_path
        requires << service_namer.get_input_s8r_name(service.type, port.type, op.type).require_path
        requires << service_namer.get_input_d10r_name(service.type, port.type, op.type).require_path
        requires << service_namer.get_output_s8r_name(service.type, port.type, op.type).require_path
        requires << service_namer.get_output_d10r_name(service.type, port.type, op.type).require_path
        requires.uniq.map(&:inspect)
      end

      def generate_op_output_header(service, port, op, result)
        name = service_namer.get_output_header_name service.type, port.type, op.type
        generate_header service, port, op, op.type.output, name, result
      end

      def generate_op_input_header(service, port, op, result)
        name = service_namer.get_input_header_name service.type, port.type, op.type
        generate_header service, port, op, op.type.input, name, result
      end

      def generate_header(service, port, op, in_out, name, result)
        modules = get_module_names service.name
        parts = get_header_parts in_out

        type_file_for name, result do |f|
          f.requires header_base.require_path

          f.in_modules modules do
            in_classes f, service.name.class_name, port.name.class_name, op.name.class_name do
              generate_header_class f, name, parts
            end
          end
        end
      end

      def generate_header_class(f, name, parts)
        f.in_sub_class name.class_name, header_base.name do
          generate_accessors f, parts
          generate_ctr f, parts
        end
      end

      def generate_op_input_body(service, port, op, result)
        name = service_namer.get_input_body_name service.type, port.type, op.type
        generate_body service, port, op, op.type.input, name, result
      end

      def generate_op_output_body(service, port, op, result)
        name = service_namer.get_output_body_name service.type, port.type, op.type
        generate_body service, port, op, op.type.output, name, result
      end

      def generate_body(service, port, op, in_out, name, result)
        modules = get_module_names service.name
        parts = get_body_parts in_out

        type_file_for name, result do |f|
          f.requires body_base.require_path

          f.in_modules modules do
            in_classes f, service.name.class_name, port.name.class_name, op.name.class_name do
              generate_body_class f, name, parts
            end
          end
        end
      end

      def generate_body_class(f, name, parts)
        f.in_sub_class name.class_name, body_base.name do
          generate_accessors f, parts
          generate_ctr f, parts
        end
      end

      def generate_accessors(f, parts)
        f.attr_accessors(*parts.map { |p| p.property_name.attr_name })
      end

      def generate_ctr(f, parts)
        f.in_def :initialize, *parts.map { |p| "#{p.property_name.attr_name}: nil" } do
          parts.each do |p|
            f.assignment p.property_name.var_name, p.property_name.attr_name
          end
        end
      end
    end
  end
end
