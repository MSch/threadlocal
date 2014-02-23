require 'threadlocal/version'
require 'delegate'

class ThreadLocal
  @mutex = Mutex.new
  @counter = 0
  def self.next_id
    @mutex.synchronize { @counter += 1 }
  end

  def self.finalizer_proc(id)
    proc do |_object_id|
      Thread.list.each do |thread|
        if thread_locals = Thread.current.thread_variable_get(:thread_locals)
          thread_locals.delete id
        end
      end
    end
  end

  def initialize(default=nil, &default_proc)
    raise ArgumentError.new("either supply default or default_proc, not both") if default && default_proc
    @default = default.dup if default
    @default_proc = default_proc if default_proc

    @id = ThreadLocal.next_id
    ObjectSpace.define_finalizer(self, ThreadLocal.finalizer_proc(@id))
  end

  def set(obj)
    self.locals_hash[@id] = obj
  end

  def get
    if self.exist?
      self.locals_hash[@id]
    elsif @default
      self.set @default.dup
    elsif @default_proc
      self.set @default_proc.call
    else
      nil
    end
  end

  def delete
    self.locals_hash.delete @id
  end

  def exist?
    self.locals_hash.has_key? @id
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
