#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'

DIGESTERS = [Digest::SHA2, Digest::MD5, Digest::SHA256, Digest::SHA384, Digest::SHA512].freeze
ALPHABET = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9).freeze

def mine_raffle_number
  id, digest, digester, alphabet  = Ractor.recv
  alphabet.repeated_permutation(5).each do |candidate|
    if digester.base64digest(id + candidate.join) == digest
      puts "done! #{candidate.join}"
      Ractor.yield candidate.join
      return
    end
  end
end

def launch_miners(id, digest)
  ractors = DIGESTERS.map do |digester|
    Ractor.new { mine_raffle_number }.tap { |r| r << [id, digest, digester, ALPHABET.dup] }
  end
  result = Ractor.select(*ractors)
  puts result.inspect
end

def now
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

start = now
launch_miners(ARGV[0], ARGV[1])
puts "Done in #{now - start} seconds"
