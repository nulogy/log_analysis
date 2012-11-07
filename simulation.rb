# adapted from https://github.com/jdleesmiller/discrete_event

require 'rubygems'
require 'discrete_event'

class Request
  attr_accessor :arrival_time, :duration, :queue_length_on_arrival, :service_begin, :service_end

  def initialize(arrival_time, duration)
    @arrival_time = arrival_time
    @duration = duration
  end

  def queue_time
    service_begin - arrival_time
  end
end

class SingleQueueMultipleServers < DiscreteEvent::Simulation

  attr_reader :request_queue, :served

  def initialize requests, server_count
    super()
    @requests = requests.reverse # treat this array like a queue!
    @server_count = server_count
    @request_queue = []
    @being_served = []
    @served = []
  end

  # Called by super.run.
  def start
    new_request
  end

  # The at method is provided by {DiscreteEvent::Simulation}.
  def new_request
    return if done?
    request = next_arrival
    at request.arrival_time do
      request.queue_length_on_arrival = queue_length
      request_queue.push request
      serve_request
      new_request
    end
  end

  def serve_request
    return unless server_available?
    request_to_serve = request_queue.pop
    request_to_serve.service_begin = now
    @being_served.push request_to_serve

    after request_to_serve.duration do
      @being_served.delete(request_to_serve)

      request_to_serve.service_end = now
      served << request_to_serve
      serve_request unless request_queue.empty?
    end
  end

  # Number of requests currently waiting for service
  def queue_length
    request_queue.length
  end

  def done?
    @requests.empty?
  end

  def next_arrival
    @requests.pop
  end

  def server_available?
    @being_served.length < @server_count
  end
end

require 'time'
require 'csv'

def run_simulation file_name='peak-time-requests.csv'

  puts "loading data from #{file_name}"
  requests = []
  # assumes the requests are sorted asc by arrival time
  CSV.foreach(file_name) do |row|
    # using number of millis since epoch as time
    requests << Request.new(Time.parse(row[2]).to_i * 1000, row[3].to_i)
  end

  puts "data loaded"

  (10..24).each do |server_count|
    puts "simulating with #{server_count} servers"
    # Run simulation and accumulate stats.
    q = SingleQueueMultipleServers.new requests, server_count
    num_served = 0
    total_queue = 0.0
    total_wait = 0.0
    q.run do
      unless q.served.empty?
        raise "confused" if q.served.size > 1
        request = q.served.pop
        total_queue += request.queue_length_on_arrival
        total_wait  += request.queue_time
        num_served  += 1
      end
    end
    puts "average queue length upon request arrival: #{total_queue / num_served}"
    puts "average queue time per request (ms): #{total_wait / num_served}"
  end
end
