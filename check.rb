class MonitorArray < Array
  include MonitorMixin

  def initialize(*args)
    super(*args)
    @cond = new_cond
  end

  alias :old_push :push
  def push(item)
    synchronize do
      old_push item
      @cond.signal
    end
  end

  def wait_until_size_reached(cond_size)
    synchronize do
      @cond.wait_until { self.size == cond_size }
    end
  end
end

list = MonitorArray.new
queue = Queue.new
pool = 3.times.map do |ix|
  Thread.new(ix) do |num|
    loop do
      item = queue.deq
      list.push("#{num}: #{item}x#{item}")
      sleep 0.1
    end
  end
end

[5, 12, 234, 1234, 21, 12, 1, 2, 3, 32].each{ |a| queue.enq(a) }

list.wait_until_size_reached(10)
puts 'Size reached'
p list
pool.each(&:exit)