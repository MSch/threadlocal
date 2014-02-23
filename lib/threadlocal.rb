require 'delegate'

class ThreadLocal
  @finalizer_proc = lambda do |object_id|
    Thread.list.each do |thread|
      if thread_locals = Thread.current.thread_variable_get(:thread_locals)
        thread_locals.delete object_id
      end
    end
  end
  def self.finalizer_proc ; @finalizer_proc ; end

  def initialize(default=nil, &default_proc)
    raise ArgumentError.new("either supply default or default_proc, not both") if default && default_proc
    @default = default.dup if default
    @default_proc = default_proc if default_proc

    ObjectSpace.define_finalizer(self, ThreadLocal.finalizer_proc)
  end

  def set(obj)
    self.locals_hash[self.object_id] = obj
  end

  def get
    if self.exist?
      self.locals_hash[self.object_id]
    elsif @default
      self.set @default.dup
    elsif @default_proc
      self.set @default_proc.call
    else
      nil
    end
  end

  def delete
    self.locals_hash.delete self.object_id
  end

  def exist?
    self.locals_hash.has_key? self.object_id
  end

  def has_default?
    @default_value || @default_proc
  end

  protected
  def locals_hash
    Thread.current.thread_variable_get(:thread_locals) || Thread.current.thread_variable_set(:thread_locals, {})
  end
end

class ThreadLocalDelegator < Delegator
  def initialize(default=nil, &default_proc)
    @threadlocal = ThreadLocal.new(default, &default_proc)
  end

  def __getobj__
    @threadlocal.get
  end

  def __setobj__(obj)
    @threadlocal.set obj
  end
end
