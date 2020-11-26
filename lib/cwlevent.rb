require 'date'

class CWLEvent
  attr_reader :date, :log_lv, :tag, :contents

  def initialize(line)
    if line.match(/^(?:\[)?(.+?)\] (.+?) (?:\[(.+?)\])? (.+)/m)
      date, @log_lv, @tag, @contents = $1, $2, $3, $4.chomp
      @date = DateTime.parse date
    else
      raise "Invalid event: #{line}"
    end
  end
end
