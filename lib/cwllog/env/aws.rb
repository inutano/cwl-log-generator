require 'open-uri'

module CWLlog
  class Env
    class AWS
      def generate
        if is_aws?
          {
            ami_id: get_ami_id,
            instance_type: get_instance_type,
            region: get_region,
          }
        else
          {}
        end
      end

      def metadata_endpoint_base
        "http://169.254.169.254/latest/meta-data/"
      end

      def get_aws_metadata(category)
        open(metadata_endpoint_base+category).read
      end

      def is_aws?
        if get_aws_metadata("").include?("ami-id")
      end

      def get_instance_type
        get_aws_metadata("instance-type")
      end

      def get_region
        get_aws_metadata("availability-zone")
      end

      def get_ami_id
        get_aws_metadata("ami-id")
      end
    end
  end
end
