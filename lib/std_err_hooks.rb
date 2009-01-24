# This hooks into standard error to open backtraces in vim
class StandardError
  alias _backtrace backtrace
  def message_is_filtered?
    matches = message_filters.detect do |message_filter|
      [self.class, message].join(": ").match message_filter
    end
    puts "#{message} Matched #{matches.inspect}" if matches
    matches ? true : false
  end

  def backtrace
    old = _backtrace
    @old_backtrace ||= nil
    if old.kind_of?(Array) and @old_backtrace.nil?
      open_vims(old) unless message_is_filtered?
      @old_backtrace = true
    end
    old
  end

  def open_vims(lines)
    good_lines = lines.select { |l| l.match(/^[.\/\w][^:\s]*:\d+(?::.*)?$/) }.map do |line|
      next if backtrace_filters.detect { |n| line.match n }
      file, line_number, rest = line.split(":")
      [file, line_number]
    end.compact.uniq
    return if good_lines.size == 0
    file, line = good_lines.shift
    if file.match("->")
      window = file.split("->")[1]
      %x{screen -X select #{window}}
      %x{screen -p #{window} -X stuff ":#{line}\n"}
      return
    end
    s = "screen vim -p"
    s << " +#{line} #{file}"
    # for handling multiple levels back, disabled for now
=begin
    good_lines.each do |l|
      file, line = l
      s << " -c tabnext -c #{line} #{file} "
    end
    s << " -c tabnext " if good_lines.size > 0
=end
    %x{screen -X #{s}}
  end

  # Don't run the backtrace file opener if the exception matches this
  def backtrace_filters
    [
      "rubygems.rb:\d+:in `activate",
      "/irb/workspace.rb"
    ]
  end

  def message_filters
    [
      "Gem::Exception: can't activate"
    ]
  end
end
