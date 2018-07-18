require 'json'
require 'cwllog/env'
require 'cwllog/docker'
require 'cwllog/cwl'

module CWLlog
  class << self
    def generate
      JSON.dump(cwl_log)
    end

    def parse_logs
      @@logs = logs
    end

    def logs
      {
        env: CWLlog::Env.generate,
        cwl: CWLlog::CWL.generate,
        docker: CWLlog::Docker.generate,
      }
    end

    def cwl_log
      parse_logs
      {
        workflow: {
          docker: @@logs[:docker][:info],
          start_date: @@logs[:cwl][:debug_info][:workflow][:start_date],
          end_date: @@logs[:cwl][:debug_info][:workflow][:end_date],
          cwl_file: @@logs[:cwl][:debug_info][:workflow][:cwlfile],
          genome_version: @@logs[:cwl][:debug_info][:workflow][:genome_version],
          input_jobfile: logs[:cwl][:input_jobfile],
        },
        steps: concat_steps_with_docker_ps,
      }
    end

    def concat_steps_with_docker_ps
      steps = {}
      @@logs[:cwl][:debug_info][:steps].each_pair do |step_name,step_info|
        cid = step_info[:container_id]
        ps  = @@logs[:docker][:ps]
        if cid && ps
          dps = ps[cid]
          steps[step_name] = step_info.merge(dps)
        else
          steps[step_name] = step_info
        end
        steps[step_name][:platform] = @@logs[:env]
      end
      steps
    end
  end
end
