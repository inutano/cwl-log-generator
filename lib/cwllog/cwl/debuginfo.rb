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
          DateTime.parse(line)
        rescue ArgumentError
          nil
        end

        #
        # Generate output object
        #

        def generate
          {
            workflow: {
              start_date: @@timestamps.first.to_s,
              end_date: @@timestamps.last.to_s,
              cwlfile: get_cwlfile_name,
              genome_version: get_genome_version,
            },
            steps: generate_step_info,
          }
        end

        def get_cwlfile_name
          @@events.select{|str| str =~ /\s\[workflow\s/ }.first.split("\s")[3].sub(/\]$/,"")
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
              # container_id: ,
              # container_name: ,
              # container_cmd: ,
              # container_status: ,
              # tool_version: ,
              tool_status: get_tool_status(step),
              input_files: input_object(step),
              output_files: output_object(step),
            }
          end
          step_info
        end

        def get_tool_status(step_name)
          if @@events.select{|str| str =~ /\[job #{step_name}\] completed success/ }.first
            "success"
          else
            "failed"
          end
        end

        def get_tool_cwl_file_path(step_name)
          @@events.select{|str| str =~ /\[job #{step_name}\] initializing from/ }.first.split("\s")[6]
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
          @@events.select{|str| str =~ /\] \[job step / }.map{|str| str.split("\s")[4].delete("]") }.uniq
        end
      end
    end
  end
end
