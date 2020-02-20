# Feb20

I started to benchmark this yesterday and was interested in how different a
reduce vs for comprehension vs filter + map approach would be.

Then, when we got a submission that used NimbleParsec, I added it to the
benchmark script. Here is the result:

Here is the output of running: `mix run lib/benchmark.exs`:

```
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-8750H CPU @ 2.20GHz
Number of Available Cores: 12
Available memory: 16 GB
Elixir 1.9.1
Erlang 22.0.7

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 28 s

Benchmarking filter_map...
Benchmarking for_comprehension...
Benchmarking reduce...
Benchmarking trarbr_nimble...

Name                        ips        average  deviation         median         99th %
reduce                  94.25 K       10.61 μs    ±88.53%          10 μs          24 μs
for_comprehension       93.15 K       10.74 μs    ±84.56%          10 μs          22 μs
filter_map              90.56 K       11.04 μs    ±65.85%          10 μs          24 μs
trarbr_nimble           67.90 K       14.73 μs    ±54.39%          14 μs          40 μs

Comparison: 
reduce                  94.25 K
for_comprehension       93.15 K - 1.01x slower +0.125 μs
filter_map              90.56 K - 1.04x slower +0.43 μs
trarbr_nimble           67.90 K - 1.39x slower +4.12 μs
```
