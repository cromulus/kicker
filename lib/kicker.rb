$:.unshift File.expand_path('../../vendor', __FILE__)
require 'rucola/fsevents'

class Kicker
  attr_accessor :path
  attr_writer :command
  attr_reader :file
  
  def initialize(options)
    self.path = options[:path] if options[:path]
    @command = options[:command]
  end
  
  def path=(path)
    @path = File.expand_path(path)
    @file, @path = @path, File.dirname(@path) unless File.directory?(@path)
  end
  
  def start
    validate_options!
    
    watch_dog = Rucola::FSEvents.start_watching(path) { |events| process(events) }
  end
  
  def command
    "sh -c #{@command.inspect}"
  end
  
  def process(events)
    unless file && !events.find { |e| e.last_modified_file == file }
      #log "Change occured. Executing command:"
      `#{command}` #.strip.split("\n").each { |line| log "  #{line}" }
      #log "Command #{$?.success? ? 'succeeded' : "failed (#{$?})"}"
    end
  end
  
  private
  
  def log(message)
    puts "[#{Time.now}] #{message}"
  end
  
  def validate_options!
    validate_path_and_command!
    validate_path_exists!
  end
  
  def validate_path_and_command!
    unless @path && @command
      puts "Usage: #{$0} [PATH] [COMMAND]"
      exit
    end
  end
  
  def validate_path_exists!
    unless File.exist?(@path)
      puts "The given path `#{@path}' does not exist."
      exit 1
    end
  end
end