# Log Analysis

Some helpful scripts for analyzing rails logs.

## Extract request times from logs

Gives you the Controller action, request type (HTML, JS, etc.), request time, and request duration

1. Get the rails logs from your servers (usually under `<rails app dir>/logs/production.log`) and dump them in the `logs` directory. You may want to rename the logs based on which day and server they are from.
1. Modify the first line of `extract_request_times.rb` to scan the log files you want.
1. Run `ruby extract_request_times.rb`
1. Profit

## Simulate queue times

Runs a discrete event simulation using the output of the previous step. This will tell you what the average queue wait time per request is as well as the total time requests spent in the queue.

Requires the `https://github.com/jdleesmiller/discrete_event` gem.

```
irb
require 'simulation'
run_simulation
```
