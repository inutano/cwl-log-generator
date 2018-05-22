module CWLlog
  class Docker
    class << self
      def load_docker_ps(ps)
        @@ps = if File.exist?(ps)
          open(ps).read
        else
          ps
        end
      end

      def load_docker_info(info)
        @@info = if File.exist?(info)
          open(info).read
        else
          info
        end
      end

      def generate
        {
          ps: parse_docker_ps,
          info: parse_docker_info,
        }
      end

      def parse_docker_ps
        ps = {}
        @@ps.split("\n").each do |line|
          line_a = line.split(/\s\s+/)
          ps[line_a[0]] = {
            docker_image: line_a[1],
            docker_cmd: line_a[2].delete("\""),
            docker_status: line_a[4],
          }
        end
        ps
      end

      def parse_docker_info
        info_raw = {}
        @@info.split("\n").each do |line|
          l = line.split(": ")
          info_raw[l[0].delete("\s")] = l[1]
        end
        {
          running_containers: info_raw["Running"],
          server_version: info_raw["Server Version"],
          storage_driver: info_raw["Storage Driver"],
          number_of_cpu: info_raw["CPUs"],
          total_memory: info_raw["Total Memory"],
        }
      end
    end
  end
end
