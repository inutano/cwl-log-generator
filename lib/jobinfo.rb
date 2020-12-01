require 'json'
require 'etc'

require 'lib/providers/aws'

class JobInfo
  attr_reader :stepname, :start_date, :end_date, :cwl_file, :container, :container_id,
              :tool_status, :inputs, :outputs, :docker_image, :docker_cmd, :docker_status,
              :docker_inspect

  def initialize(step_name, events, config)
    tag = events.select{|e| e.contents =~ /^initializing from / }.first.tag
    events = events.select{ |e| e.tag == tag }
    @stepname = step_name
    @start_date = events.first.date
    @end_date = events.last.date
    @cwl_file = get_cwlfile_name(events)
    @tool_status = get_tool_status(events)
    @inputs = get_job_input_object(events)
    @outputs = get_job_output_object(events)
    @container_runtime = get_container_runtime(config)
    @container_process = get_container_process(events, config)
    @platform = get_platform
  end

  def to_h
    ret = {
      start_date: @start_date,
      end_date: @end_date,
      cwl_file: @cwl_file,
      tool_status: @tool_status,
      inputs: @inputs,
      outputs: @outputs,
      container: {
        process: @container_process,
        runtime: @container_runtime,
      },
      platform: @platform,
    }
    ret[:stepname] = @stepname if @stepname
    ret
  end
end

def get_cwlfile_name(events)
  ev = events.select{|e| e.contents =~ /^initializing from / }.first
  File.basename(ev.contents.split.select{|e| e.end_with? '.cwl' }.first)
end

def get_container_runtime(config)
  if File.exist?(config.info_file)
    info_raw = Hash[open(config.info_file).each_line.map{ |line|
                      l = line.split(": ")
                      [l.first.strip, l.last.chomp]
                    }]
    {
      running_containers: info_raw["Running"],
      server_version: info_raw["Server Version"],
      storage_driver: info_raw["Storage Driver"],
      number_of_cpu: info_raw["CPUs"],
      total_memory: info_raw["Total Memory"],
    }
  else
    {}
  end
end

def get_container_process(events, config)
  e = events.select{ |e| e.contents.split("\n").first.match(/ docker /m) }.first
  cid_base = File.basename(e.contents.match(/--cidfile=(.+\.cid)/m)[1])
  cid_path = File.join(config.cidfile_dir, cid_base)
  cid = open(cid_path).read if File.exist?(cid_path)

  if cid
    inspect = JSON.load(`docker inspect #{cid}`).first
    {
      id: cid,
      image: inspect["Config"]["Image"],
      cmd: inspect["Config"]["Cmd"].join(" "),
      status: inspect["State"]["Status"],
      start_time: inspect["State"]["StartedAt"],
      end_time: inspect["State"]["FinishedAt"],
      exit_code: inspect["State"]["ExitCode"],
    }

  end
end

def get_platform
  mem = case RUBY_PLATFORM
        when /linux/
          `grep ^MemTotal /proc/meminfo | awk '{ print $2 }'`.chomp.to_i
        when /darwin/
          `sysctl hw.memsize | awk '{ print $2 }'`.chomp.to_i
        else
          # unsupported
        end
  info = {
    hostname: `hostname`.chomp,
    ncpu_cores: Etc.nprocessors,
    total_memory: mem,
    disk_size: `df -k / | awk 'NR==2 { print $2 }'`.chomp.to_i,
  }

  info.merge(
    *[
      aws_platform_info,
    ])
end

def get_tool_status(events)
  if events.select{|e| e.contents == "completed success" }.first
    "success"
  else
    "failed"
  end
end

def get_job_input_object(events)
  JSON.load(events.select{|e| e.contents =~ /\{\n/m }.first.contents)
end

def get_job_output_object(events)
  JSON.load(events.select{|e| e.contents =~ /outputs \{/ }.last.contents.gsub('outputs ',''))
end
