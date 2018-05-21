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
        get_system_info("grep ^MemTotal /proc/meminfo | awk '{ print $2 }'")
      end

      def get_disk_size
        get_system_info("df -k --output=size / | awk 'NR==2 { print $1 }'")
      end
    end
  end
end
