#
# generate_cwl_log.rb: assemble log data of a CWL workflow run
#

$LOAD_PATH << __dir__

require 'lib/cwllog'

if __FILE__ == $0
  CWLlog.generate
end
