require 'cwllog/env/aws'

module CWLlog
  class Env
    class << self
      def generate
        env_types = [
          env,
          CWLlog::Env::AWS.generate,
        ]
        env_types.inject(&:merge)
      end

      def env
        {
          hostname: get_hostname,
          total_memory: get_total_memory,
          disk_size: get_disk_size,
        }
      end

      def get_system_info(cmd)
        `#{cmd}`.chomp
      end

      def get_hostname
        get_system_info("hostname")
      end

      def get_total_memory
        case RUBY_PLATFORM
        when /linux/
          get_system_info("grep ^MemTotal /proc/meminfo | awk '{ print $2 }'")
        when /darwin/
          get_system_info("sysctl hw.memsize | awk '{ print $2 }'")
        else
          # unsupported
        end
      end

      def get_disk_size
        get_system_info("df -k / | awk 'NR==2 { print $2 }'")
      end
    end
  end
end
