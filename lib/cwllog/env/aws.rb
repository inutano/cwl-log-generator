require 'open-uri'

module CWLlog
  class Env
    class AWS
      class << self
        def generate
          if is_aws?
            {
              ec2_ami_id: get_ami_id,
              ec2_instance_type: get_instance_type,
              ec2_region: get_region,
            }
          else
            {}
          end
        end

        def metadata_endpoint_base
          "http://169.254.169.254/latest/meta-data/"
        end

        def get_aws_metadata(category)
          open(metadata_endpoint_base+category, { :open_timeout => 2 }).read
        rescue OpenURI::HTTPError
          nil
        rescue Net::OpenTimeout
          nil
        rescue Errno::EHOSTUNREACH
          nil
        end

        def is_aws?
          data = get_aws_metadata("")
          not data.nil? and data.include?("ami-id")
        rescue Errno::ECONNREFUSED
          false
        end

        def get_instance_type
          get_aws_metadata("instance-type")
        end

        def get_region
          get_aws_metadata("placement/availability-zone")
        end

        def get_ami_id
          get_aws_metadata("ami-id")
        end
      end
    end
  end
end
