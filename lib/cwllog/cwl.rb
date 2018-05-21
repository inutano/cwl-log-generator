require 'cwllog/cwl/jobconf'
require 'cwllog/cwl/debuginfo'

module CWLlog
  class CWL
    class << self
      def generate
        {
          debug_info: CWLlog::CWL::DebugInfo.generate,
          input_jobfile: CWLlog::CWL::JobConf.generate,
        }
      end
    end
  end
end
