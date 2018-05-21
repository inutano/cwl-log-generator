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
            inout = @@events.select{|str| str =~ /\[job #{step}\] \{\n/m }.sort_by{|str| DateTime.parse(str) }
            input_obj = JSON.load("{" + inout.first.sub(/^.*\{/,""))
            output_obj = JSON.load("{" + inout.last.sub(/^.*\{/,""))
            step_info[step] = {
              stepname: step,
              # cwlfile: ,
              # container_id: ,
              # container_name: ,
              # container_cmd: ,
              # container_status: ,
              # tool_version: ,
              # tool_status: ,
              input_files: input_obj,
              output_files: output_obj,
            }
          end
          step_info
        end

        def steps
          @@events.select{|str| str =~ /\] \[job step / }.map{|str| str.split("\s")[4].delete("]") }.uniq
        end
      end
    end
  end
end
