fibo = Fiber.new do
  a, b = 0, 1
  loop do
    a, b = b, a+b
    Fiber.yield a
  end
end

p 20.times.map{ fibo.resume }