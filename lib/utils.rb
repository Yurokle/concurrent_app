def at_least_n_seconds_block(seconds, &block)
  time = Time.now
  block.call
  time_taken = Time.now - time
  sleep_for = seconds - time_taken
  sleep(sleep_for) if sleep_for > 0
end