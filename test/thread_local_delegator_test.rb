require_relative './test_helper'

describe ThreadLocalDelegator do
  it "can be created with no arguments" do
    ThreadLocalDelegator.new.class.must_equal ThreadLocalDelegator
  end

  it "can be created with a default object" do
    ThreadLocalDelegator.new({}).class.must_equal ThreadLocalDelegator
  end

  it "can be created with a default proc" do
    ThreadLocalDelegator.new{5}.class.must_equal ThreadLocalDelegator
  end

  it "can not be created with a default object and default proc" do
    lambda { ThreadLocalDelegator.new({}){5} }.must_raise ArgumentError
  end

  it "returns different objects depending on which Thread it's being called on" do
    l = ThreadLocalDelegator.new({})
    l["thread"] = 1
    l["foo"] = "bar"
    Thread.new{ l["thread"] = 2; l["thread"] }.value.must_equal 2
    l["thread"].must_equal 1
  end
end
