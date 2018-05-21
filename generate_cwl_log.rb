#
# generate_cwl_log.rb: assemble log data of a CWL workflow run
#

$LOAD_PATH << __dir__
$LOAD_PATH << File.join(__dir__, "lib")

require 'lib/cwllog'

if __FILE__ == $0
  puts CWLlog.generate
end
