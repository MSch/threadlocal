require_relative './test_helper'

describe ThreadLocal do
  it "can be created with no arguments" do
    ThreadLocal.new.must_be_instance_of ThreadLocal
  end

  it "can be created with a default object" do
    ThreadLocal.new({}).must_be_instance_of ThreadLocal
  end

  it "can be created with a default proc" do
    ThreadLocal.new{5}.must_be_instance_of ThreadLocal
  end

  it "can not be created with a default object and default proc" do
    lambda { ThreadLocal.new({}){5} }.must_raise ArgumentError
  end

  it "returns different objects depending on which Thread it's being called on" do
    l = ThreadLocal.new()
    l.set "thread 1"
    Thread.new{ l.set "thread 2"; l.get }.value.must_equal "thread 2"
    l.get.must_equal "thread 1"
  end

  it "cleans up across all threads when it gets finalized" do
    class ScopeThingy
      attr_reader :l_object_id
      def initialize
        @l = ThreadLocal.new
        @l_object_id = @l.object_id
      end

      def step1
        sync = Queue.new

        @l.set "thread 1"
        t1 = Thread.current
        t2 = Thread.new do
          @l.set "thread 2"
          sync.push(:continue)
          t1.join
          sync.pop
        end
        sync.pop

        t1.thread_variable_get(:thread_locals)[@l_object_id].must_equal "thread 1"
        t2.thread_variable_get(:thread_locals)[@l_object_id].must_equal "thread 2"

        sync.push(:continue)
      end

      def step2
        @l = nil
      end
    end

    tmp = ScopeThingy.new
    l_object_id = tmp.l_object_id
    tmp.step1
    Thread.current.thread_variable_get(:thread_locals).has_key?(l_object_id).must_equal true
    ObjectSpace.each_object(ThreadLocal).map(&:object_id).to_a.must_include(l_object_id)

    # Stop referencing the ThreadLocal
    tmp.step2
    tmp = nil

    # without defining another finalizer our threadlocal never gets collected... why? no idea :(
    # also see http://stackoverflow.com/q/14064400/625422
    ObjectSpace.define_finalizer(Object.new, lambda {})
    GC.start

    ObjectSpace.each_object(ThreadLocal).map(&:object_id).to_a.wont_include(l_object_id)
    Thread.current.thread_variable_get(:thread_locals).has_key?(l_object_id).must_equal false
  end
end
