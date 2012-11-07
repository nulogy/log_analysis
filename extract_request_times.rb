raw_requests = `pcregrep -M "Started.*\\s\\s|Processing by|Completed.*\\s\\s" logs/production-20101102-*.log` .split("\n\n")
#lines = `pcregrep -Mrni "Started|Processing by|Completed.*\s\s" production-20101102-359.log` .split("\n")

RequestRecord = Struct.new(:action, :type, :request_at, :duration)

requests = []

raw_requests.each do |rr|
  parts = rr.split("\n")
  if parts.size >= 3
    begin
      request = RequestRecord.new
      request.duration = /in (\d*)ms/.match(parts.last)[1].to_i
      request.request_at = /at (.*)/.match(parts.first)[1]
      request.type = /as (.*)/.match(parts[1])[1]
      request.action = /by (.*) as/.match(parts[1])[1]
      requests << request
    rescue
      puts '*****************************************************************************'
      puts '*****************************************************************************'
      puts '*****************************************************************************'
      puts "Bad record: #{rr}"
      puts '*****************************************************************************'
      puts '*****************************************************************************'
      puts '*****************************************************************************'
    end
  else
    puts "odd record: #{rr}"
  end
end

requests.sort { |r1, r2| r1.request_at <=> r2.request_at }

require 'csv'

CSV.open("requests.csv", "w") do |csv|
  requests.each do |request|
    csv << request.to_a
  end
end
