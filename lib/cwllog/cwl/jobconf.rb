require 'yaml'

module CWLlog
  class CWL
    class JobConf
      class << self
        @@job_conf = nil

        def load(conf_path)
          @@job_conf = JSON.load(open(conf_path).read)
        rescue JSON::ParserError
          @@job_conf = YAML.load(open(conf_path).read)
        end

        def generate
          @@job_conf
        end
      end
    end
  end
end
