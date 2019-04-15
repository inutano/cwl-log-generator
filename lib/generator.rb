require 'lib/cwlevent'
require 'lib/jobinfo'
require 'lib/workflowinfo'

FormatVersion = "0.1.18"
GeneratorVersion = "0.1.22"

def generate(config)
    lines = open(config.debug_log).read.split(/\n\[/m)
    lines.shift(2)
    lines.pop(2)
    events = lines.map{|l| CWLEvent.new(l) }

    info = case events.first.tag.split.first
           when 'workflow'
             WorkflowInfo.new(events, config)
           when 'job'
             JobInfo.new(nil, events, config)
           else
             raise "Invalid event tag: #{events.first.tag.strip}"
           end

    info = info.to_h
    info[:cwl_metrics_version] = FormatVersion
    info[:metrics_generator] = {
      name: "cwl-log-generator",
      version: GeneratorVersion,
    }
    info
end
