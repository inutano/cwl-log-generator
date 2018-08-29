require 'cwllog/cwl/debuginfo'

module CWLlog
  class CWL
    class << self
      def generate
        {
          debug_info: CWLlog::CWL::DebugInfo.generate,
        }
      end
    end
  end
end
