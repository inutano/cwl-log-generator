require 'json'
require 'cwllog/env'
require 'cwllog/env/aws'
require 'cwllog/docker'
require 'cwllog/cwl'

module CWLlog
  class << self
    def generate
      JSON.dump(CWLlog::Env.generate)
    end
  end
end
