require 'date'

class CWLEvent
  attr_reader :date, :tag, :contents

  def initialize(line)
    if line.match(/^(?:\[)?(.+?)\] (?:\[(.+?)\])? (.+)/m)
      date, @tag, @contents = $1, $2, $3.chomp
      @date = DateTime.parse date
    else
      raise "Invalid event: #{line}"
    end
  end
end
