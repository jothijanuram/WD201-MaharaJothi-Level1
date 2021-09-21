def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  new_dns = dns_raw
  res_dns = []
  new_dns.map.with_index{
    |x, i| res_dns[i] = x.split(", ")
  }
  # res_dns.each do |a|
  #  puts a
  #end
  dns_records1 = Hash.new{|hash, key| hash[key] = {} }

  res_dns.map.with_index{
    |v, i|
    resv = v[1].to_s
    resv=resv.strip()
    dns_records1[resv][:type] = v[0].strip()
    dns_records1[resv][:target] = v[2].strip()
  }
  dns_records1.delete("")
  return dns_records1
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records[domain][:type] == "A"
    lookup_chain.push(dns_records[domain][:target])
  elsif dns_records[domain][:type] == "CNAME"
    lookup_chain.push(dns_records[domain][:target])
    #puts (dns_records[domain][:target])
    resolve(dns_records, lookup_chain, dns_records[domain][:target])
  else
    puts "Error: record not found for #{domain}"
  end
  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")



