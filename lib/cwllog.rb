require 'json'
require 'cwllog/env'
require 'cwllog/docker'
require 'cwllog/cwl'

module CWLlog
  class << self
    def generate
      JSON.dump(merge_info)
    end

    def merge_info
      {
        env: CWLlog::Env.generate,
        cwl: CWLlog::CWL.generate,
        docker: CWLlog::Docker.generate,
      }
    end
  end
end
