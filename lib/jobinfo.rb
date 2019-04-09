require 'json'

class JobInfo
  attr_reader :stepname, :start_date, :end_date, :cwl_file, :container_info, :tool_status,
              :inputs, :outputs

  def initialize(step_name, events, config)
    tag = events.select{|e| e.contents =~ /^initializing from / }.first.tag
    events = events.select{ |e| e.tag == tag }
    @stepname = step_name
    @start_date = events.first.date
    @end_date = events.last.date
    @cwl_file = get_cwlfile_name(events)
    @tool_status = get_tool_status(events)
    @inputs = get_input_object(events)
    @outputs = get_output_object(events)
    @container_info = nil # TODO
    @platform = nil # TODO
  end

  def to_h
    {
      stepname: @stepname,
      start_date: @start_date,
      end_date: @end_date,
      cwl_file: @cwl_file,
      tool_status: @tool_status,
      inputs: @inputs,
      outputs: @outputs,
      container: @container_info,
      platform: @platform,
    }
  end
end

def get_cwlfile_name(events)
  ev = events.select{|e| e.contents =~ /^initializing from / }.first
  File.basename(ev.contents.split.select{|e| e.end_with? '.cwl' }.first)
end

def get_container_info(events)
  nil
end

def get_cid_file_name(events)
  contents = events.select{|e| e.contents =~ /--cidfile=/m }.first.contents
  line = contents.split("\n").select{|l| l =~ /--cidfile/ }.first
  line.split("=").last.delete("\s\\")
end

def get_tool_status(events)
  if events.select{|e| e.contents == "completed success" }.first
    "success"
  else
    "failed"
  end
end

def get_input_object(events)
  JSON.load(events.select{|e| e.contents =~ /\{\n/m }.first.contents)
end

def get_output_object(events)
  JSON.load(events.select{|e| e.contents =~ /\{\n/m }.last.contents)
end
