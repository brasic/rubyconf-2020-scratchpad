#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'

DIGESTERS = [Digest::SHA2, Digest::MD5, Digest::SHA256, Digest::SHA384, Digest::SHA512]
ALPHABET = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9).freeze

def mine_raffle_number(id, digest, digester)
  ALPHABET.repeated_permutation(5).each do |candidate|
    if digester.base64digest(id + candidate.join) == digest
      puts "Found it! Your raffle number is #{candidate.join}."
      puts "#{digester}.base64digest(#{id.inspect} + #{candidate.join.inspect}) == #{digest.inspect}"
      exit
    end
  end
end

def launch_miners(id, digest)
  pids = DIGESTERS.map do |digester|
    fork do
      mine_raffle_number(id, digest, digester)
    end
  end
  Process.wait
ensure
  cleanup(pids)
end

def now
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

def cleanup(pids)
  pids.each do |pid|
    Process.kill("KILL", pid)
  rescue Errno::ESRCH
  end
end

start = now
launch_miners(ARGV[0], ARGV[1])
puts "Done in #{now - start} seconds"
