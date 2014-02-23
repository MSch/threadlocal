# threadlocal

Ruby's thread local variables are badly designed compared to other languages, even [Java](http://docs.oracle.com/javase/7/docs/api/java/lang/ThreadLocal.html) or [Python](http://docs.python.org/2/library/threading.html#threading.local).

This gem fixes that.

## Why?

In Ruby there's a global namespace of thread local names that are accessed like that:

```ruby
Thread.current.thread_variable_get(:some_global_name)
```

This has two implications:

1. If e.g. Rails uses the `:time_zone` thread variable you can't. Obviously.
2. If an object uses a thread variable it has to make sure it cleans up after itself when it gets garbage collected.

In Java or Python instead of a global namespace where you assign keys to values you just create a new instance of a 
`ThreadLocal` (or `threading.local`) object, like this:

```ruby
class MyThingy
  def initialize
    @some_setting = ThreadLocal.new(false)
  end

  def do_something
    if @some_setting.get == true
      # Do something only if it's enabled
    end
  end

  def enable_setting
    @some_setting.set(true)
  end
end

a = MyThingy.new
b = MyThingy.new
```

`a` and `b` have different ivars which means their thread-local setting will never clash. And when one of them gets
garbage collected the thread local variable is cleaned up across all threads (not that important for a boolean but really
important in the general case.) Success!

Obviously this works just as well
```ruby
class MyThingy
  @settings = ThreadLocal.new({})

  def settings
    @settings.get
  end
end

MyThingy.settings[:whatever] # this is per thread now
```

The `threadlocal` gem works and is tested on Ruby 2.0 and 2.1, JRuby can use Java's built-in `ThreadLocal` (making this
transparent is on the roadmap.)

Acknowledgements
----------------

Thanks to

* [Konstantin Haase](http://twitter.com/konstantinhaase) for finally getting me to write this. Also see [this gist](https://gist.github.com/rkh/e24edafd8747e7b91b7a).
