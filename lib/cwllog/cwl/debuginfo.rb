require 'date'

module CWLlog
  class CWL
    class DebugInfo
      class << self
        def load(debug_info_path)
          @@debuginfo = open(debug_info_path).read
          @@events = get_events
          @@timestamps = get_timestamps
        end

        def cidfile_dir(cid_dir)
          @@cid_dir = cid_dir
        end

        #
        # Methods for class variables
        #
        def get_events
          @@debuginfo.split(/\n\[/m)
        end

        def get_timestamps
          @@events.map{|line| parse_date_prefix(line) }.compact.sort
        end

        def parse_date_prefix(line)
          DateTime.parse(line.split("]").first)
        rescue ArgumentError
          nil
        end

        #
        # Generate output object
        #

        def generate
          {
            workflow: {
              start_date: @@timestamps.first.strftime("%Y-%m-%d %H:%M:%S"),
              end_date: @@timestamps.last.strftime("%Y-%m-%d %H:%M:%S"),
              cwlfile: get_cwlfile_name,
              genome_version: get_genome_version,
            },
            steps: generate_step_info,
          }
        end

        def get_cwlfile_name
          ev = @@events.select{|str| str =~ /Resolved/ }
          File.basename(ev.first.split("\s").last.delete("'"))
        end

        def get_genome_version
          evnts = @@events.select{|str| str =~ /"genome_version":/ }.first
          if evnts
            evnts.split("\n").select{|str| str =~ /"genome_version":/ }.first.delete("\s\",").delete("genome_version:")
          end
        end

        def generate_step_info
          step_info = {}
          steps.each do |step|
            step_info[step] = {
              stepname: step,
              cwlfile: get_tool_cwl_file_path(step),
              container_id: get_container_id(step),
              tool_status: get_tool_status(step),
              input_files: input_object(step),
              output_files: output_object(step),
            }
          end
          step_info
        end

        def get_container_id(step_name)
          cid_path = File.join(@@cid_dir, get_cid_file_name(step_name))
          if File.exist?(cid_path)
            open(cid_path).read
          end
        end

        def get_cid_file_name(step_name)
          ev = @@events.select{|str| str =~ /job #{step_name}.*--cidfile/m }.first
          line = ev.split("\n").select{|line| line =~ /--cidfile/ }.first
          File.basename(line.split("=").last.delete("\s\\"))
        end

        def get_tool_status(step_name)
          if @@events.select{|str| str =~ /\[job #{step_name}\] completed success/ }.first
            "success"
          else
            "failed"
          end
        end

        def get_tool_cwl_file_path(step_name)
          @@events.select{|str| str =~ /\[job #{step_name}\] initializing from/ }.first.split("\s").last
        end

        def input_object(step_name)
          load_object(select_io_object(step_name, :input))
        end

        def output_object(step_name)
          load_object(select_io_object(step_name, :output))
        end

        def load_object(object_str)
          JSON.load("{" + object_str.sub(/^.*\{/,""))
        end

        def select_io_object(step_name, in_or_out)
          method = case in_or_out
                   when :input
                     :first
                   when :output
                     :last
                   end
          io_object_lines(step_name).send(method)
        end

        def io_object_lines(step_name)
          @@events.select{|str| str =~ /\[job #{step_name}\] \{\n/m }
        end

        def steps
          @@events.select{|str| str =~ /\] \[job / }.map{|str| str.split("\s")[3].delete("]") }.uniq.reject{|name| name == "step" }
        end
      end
    end
  end
end
