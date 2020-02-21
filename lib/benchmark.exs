input =
  "START RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69 Version: $LATEST\n2020-02-19T17:32:52.353Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting metadata\n2020-02-19T17:32:52.364Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting projects\n2020-02-19T17:32:52.401Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting Logflare sources\nEND RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\nREPORT RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\tDuration: 174.83 ms\tBilled Duration: 200 ms\tMemory Size: 1024 MB\tMax Memory Used: 84 MB\t\n"

Benchee.run(%{
  "filter_map" => fn -> Solution1.parse(input) end,
  "reduce" => fn -> Solution2.parse(input) end,
  "for_comprehension" => fn -> Solution3Greg.parse(input) end,
  "trarbr_nimble1" => fn -> TrarbrNimble1.parse(input) end,
  "trarbr_nimble2" => fn -> TrarbrNimble2.parse(input) end
})
