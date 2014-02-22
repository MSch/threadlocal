require 'threadlocal/version'

class ThreadLocal
  @mutex = Mutex.new
  @counter = 0
  def self.next_id
    @mutex.synchronize { @counter += 1 }
  end

  def self.finalize(id, _object_id)
    Thread.list.each do |thread|
      if thread_locals = Thread.current.thread_variable_get(:thread_locals)
        thread_locals.delete id
      end
    end
  end

  def initialize
    @id = ThreadLocal.next_id
    ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc.curry(2)[@id])
  end

  def set(value)
    thread_locals = Thread.current.thread_variable_get(:thread_locals) || Thread.current.thread_variable_set(:thread_locals, {})
    thread_locals[@id] = value
  end

  def get
    if thread_locals = Thread.current.thread_variable_get(:thread_locals)
      thread_locals[@id]
    end
  end
end
