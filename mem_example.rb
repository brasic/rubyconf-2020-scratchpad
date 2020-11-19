require "get_process_mem"
mem = GetProcessMem.new

seen = 0
(1...1000).to_a.repeated_permutation(200).each do
  seen += 1
  if seen % 10000 == 0
    print "seen:#{seen}, memory:#{mem.mb}\r"
  end
end
