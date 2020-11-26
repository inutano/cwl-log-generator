require 'lib/jobinfo'

class WorkflowInfo
  attr_reader :start_date, :end_date, :cwl_file, :genome_version, :inputs, :outputs, :steps

  def initialize(events, config)
    @start_date = events.first.date
    @end_date = events.last.date
    @cwl_file = get_cwlfile_name(events)
    @genome_version = get_genome_version(events)
    @inputs = get_input_object(events)
    @outputs = get_output_object(events)
    @steps = Hash[get_step_chunks(events).map{|stepname, es| [stepname, JobInfo.new(stepname, es, config)] }]
  end

  def to_h
    {
      workflow: {
        start_date: @start_date.strftime("%Y-%m-%d %H:%M:%S"),
        end_date: @end_date.strftime("%Y-%m-%d %H:%M:%S"),
        cwl_file: @cwl_file,
        genome_version: @genome_version,
        inputs: @inputs,
        outputs: @outputs,
      },
      steps: @steps.transform_values{|s| s.to_h }
    }
  end
end

def get_cwlfile_name(events)
  ev = events.select{|e| e.contents =~ /^(initialized|initializing) from / }
  File.basename(ev.first.contents.split.last)
end

def get_genome_version(events)
  ev = events.select{|e| e.contents =~ /"genome_version":/ }.first
  if ev
    ev.contents.split("\n").select{|str| str =~ /"genome_version":/ }.first.delete("\s\",").delete("genome_version:")
  end
end

def get_step_chunks(events)
  steps = events.select{|e| e.tag =~ /^step \S+$/ and e.contents == 'start' }.map{|e| e.tag.split[1] }

  steps.map do |s|
    from = events.index{|e| e.tag =~ /^step #{s}/ and e.contents == 'start' }
    to = events.index{|e| e.tag =~ /^step #{s}/ and e.contents =~ /^completed \S+$/ }
    [s, events[from..to]]
  end
end

def get_input_object(events)
  JSON.load(events.select{|e| e.contents =~ /inputs \{/ }.first.contents.gsub('inputs ',''))
end

def get_output_object(events)
  JSON.load(events.select{|e| e.contents =~ /outputs \{/ }.last.contents.gsub('outputs ',''))
end
