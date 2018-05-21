#
# generate_cwl_log.rb: assemble log data of a CWL workflow run
#

$LOAD_PATH << __dir__
$LOAD_PATH << File.join(__dir__, "lib")

require 'lib/cwllog'

if __FILE__ == $0
  CWLlog::CWL::DebugInfo.load(ARGV[0]) # --debug output with timestamps
  CWLlog::CWL::JobConf.load(ARGV[1]) # job conf yaml or json
  CWLlog::CWL::DebugInfo.cidfile_dir(ARGV[2]) # --debug output with timestamps
  puts CWLlog.generate
end
