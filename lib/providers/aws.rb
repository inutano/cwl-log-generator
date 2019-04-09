require 'open-uri'

AWS_METADATA_ENDPOINT = "http://169.254.169.254/latest/meta-data/"

def aws_platform_info
  if is_aws?
    {
      ec2_ami_id: get_aws_metadata("ami-id"),
      ec2_instance_type: get_aws_metadata("instance-type"),
      ec2_region: get_aws_metadata("placement/availability-zone"),
    }
  else
    {}
  end
end

def get_aws_metadata(category)
  open(AWS_METADATA_ENDPOINT+category, { :open_timeout => 2 }).read
rescue OpenURI::HTTPError
  nil
rescue Net::OpenTimeout
  nil
rescue Errno::EHOSTUNREACH, Errno::EHOSTDOWN
  nil
end

def is_aws?
  data = get_aws_metadata("")
  not data.nil? and data.include?("ami-id")
rescue Errno::ECONNREFUSED
  false
end
