require 'open-uri'

module CWLlog
  class Env
    class AWS
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
    end
  end
end
