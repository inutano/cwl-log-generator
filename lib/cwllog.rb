require 'json'
require 'cwllog/env'
require 'cwllog/docker'
require 'cwllog/cwl'

FormatVersion = "0.1.18"
GeneratorVersion = "0.1.22"

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
        cwl_metrics_version: FormatVersion,
        metrics_generator: {
          name: "cwl-log-generator",
          version: GeneratorVersion,
        },
        workflow: {
          start_date: @@logs[:cwl][:debug_info][:workflow][:start_date],
          end_date: @@logs[:cwl][:debug_info][:workflow][:end_date],
          cwl_file: @@logs[:cwl][:debug_info][:workflow][:cwl_file],
          genome_version: @@logs[:cwl][:debug_info][:workflow][:genome_version],
          inputs: @@logs[:cwl][:debug_info][:workflow][:inputs],
          outputs: @@logs[:cwl][:debug_info][:workflow][:outputs],
        },
        steps: concat_steps_with_docker_ps,
      }
    end

    def concat_steps_with_docker_ps
      steps = {}
      @@logs[:cwl][:debug_info][:steps].each_pair do |step_name,step_info|
        cid = step_info.delete(:container_id)
        raise NameError if !cid

        ps = @@logs[:docker][:ps][cid]
        container_obj = {
          process: {
            id: cid,
            image: ps[:docker_image],
            cmd: ps[:docker_cmd],
            status: ps[:docker_status],
            start_time: ps[:docker_inspect][:start_time],
            end_time: ps[:docker_inspect][:end_time],
            exit_code: ps[:docker_inspect][:exit_code],
          },
          runtime: @@logs[:docker][:info]
        }

        steps[step_name] = step_info
        steps[step_name][:container] = container_obj
        steps[step_name][:platform] = @@logs[:env]
      end
      steps
    end
  end
end
