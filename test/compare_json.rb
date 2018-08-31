#!/usr/bin/env ruby
require 'json'
require 'optparse'

class ComparisonError < StandardError
  def initialize(msg = nil)
    super(msg)
  end
end

#
# Check whether `actual` almost equals to `expected`.
# If `actual` has different structures or values, fail with exception.
#
def must_almost_equals(expected, actual)
  case expected
  when nil
    true
  when Array
    unless actual.instance_of?(Array)
      raise ComparisonError, "Inconsistent type: expected type of #{expected}: Array, actual type of #{actual}: #{actual.class}"
    end
    unless expected.size == actual.size
      raise ComparisonError, "Different size of arrays: expected size of #{expected}: #{expected.size}, actual size of #{actual}: #{actual.size}"
    end

    expected.to_enum.with_index.each do |e, i|
      must_almost_equals(e, actual[i])
    rescue ComparisonError => e
      raise ComparisonError, "Different value of #{i}-th element of array"
    end
  when Hash
    # Note: It is OK when `actual` has additional entries.
    unless actual.instance_of?(Hash)
      raise ComparisonError, "Incensistent type: expected type of #{expected}: Hash, actual type of #{actual}: #{actual.class}"
    end

    expected.each do |k, v|
      unless actual.include?(k)
        raise ComparisonError, "Missing key `#{k}` in actual: #{actual}"
      end
      must_almost_equals(v, actual[k])
    rescue ComparisonError => e
      if not e.cause.nil? and e.cause.message.match(/^Missing key `#{k}`/)
        raise e
      end
      raise ComparisonError, "Different value for `#{k}`"
    end
  else
    unless expected == actual
      raise ComparisonError, "Comparison failed: #{expected} == #{actual}"
    end
  end
end


if $0 == __FILE__
  opt = OptionParser.new
  opt.banner = "Usage: #{$0} expected.json actual.json"
  opt.parse!(ARGV)
  unless ARGV.length == 2
    puts opt.help
    exit
  end

  exp, act = ARGV
  unless File.exist? exp
    warn "No such file: #{exp}"
    exit 1
  end
  unless File.exist? act
    warn "No such file: #{act}"
    exit 1
  end

  expected = JSON.load(open(exp))
  actual = JSON.load(open(act))

  begin
    must_almost_equals(expected, actual)
  rescue ComparisonError => e
    indent = 2
    cur_indent = 0
    until e.nil?
      warn ' '*cur_indent+e.to_s
      cur_indent += indent
      e = e.cause
    end
    exit 1
  end
end
