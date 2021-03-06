class String
  def matches(x)
    return self == x
  end
end

class Regexp
  def matches(x)
    return self.match(x)
  end
end

class Integer
  def matches(x)
    return self == x
  end
end

class TrueClass
  def matches(x)
    self.== x
  end
end

class FalseClass
  def matches(x)
    self.== x
  end
end

module HashExtension
  # Returns a hash that only contains pairs with the specified keys
  def extract(*keys)
    keys = keys[0] if keys[0].is_a?(Array)
    hash = self.class.new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end

  alias :slice :extract
end

class Hash
  include HashExtension
end

class String
  class << self
    def random(size=15, charset=:alnum)
      charset =
      case charset
        when :alnum
        [('0'..'9'),('A'..'Z'),('a'..'z')]
        when :word
        [('0'..'9'),('A'..'Z'),('a'..'z'),'_']
        when :alpha
        [('A'..'Z'),('a'..'z')]
        when :digit
        ['0'..'9']
        when :ascii
         (0..127).map{|c|c.chr}
        when :asciiiso
         (0..255).map{|c|c.chr}
      else
        charset
      end.map{|it|it.to_a}.flatten
         (0...size).inject(""){|s,c| s << charset[rand(charset.size)]}
    end
  end

  def strip_number_formatting
    self.gsub!(/\$|,/,'')
    self.gsub!(/\.00/,'')
    return self
  end

  # Some of the search widgets will abbreviate long
  # strings so return an abbreviated string
  def abbreviate(maxlength)
    return self if length < maxlength
    self[0..maxlength-2] + '...'
  end
end


class Array
  def diff(a)
    ary = dup
    a.each {|i| ary.delete_at(i) if i = ary.index(i)}
    ary
  end
end


#############################
# From Why's Pognant Guide
#############################
class Object
  def meta_class; class << self; self; end; end
  def meta_eval &blk; meta_class.instance_eval &blk; end

  # Adds methods to a metaclass
  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end

  # Defines an instance method within a class
  def class_def name, &blk
    class_eval { define_method name, &blk }
  end
end


# This would be better to be a struct because it would match the models we're
# using for inputs to the controllers. The problem is that with legacy code,
# we have a lot of input hashes that don't necessarily always have a page
# object keyword for every member of the hash. As such I've chosen to use
# OpenStruct. Fixing this would be a little hit/miss until all input data uses
# models

require 'ostruct'

class ModelOpenStruct < OpenStruct
  def update(x)
    x.each_pair {|key, value| self.send "#{key}=", value}
    self
  end

  def keys
    self.marshal_dump.keys
  end
  alias :members :keys

  def has_key?(x)
    members.include? x
  end
  alias :key? :has_key?

  def to_h
    h = {}
    members.each { |name| h[name.to_sym] = self.send name}
    h
  end
end