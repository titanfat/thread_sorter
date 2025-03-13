# thread_sorter
Test external sorter with Thread/Ractor/Fiber(async)

start engine.rb

require Rspec test/ data generator. Data dir sorting_data


```
With Threads

       user     system      total        real
   0.010001   0.001461   0.011462 (  0.011500)
```

```
With Ractor

       user     system      total        real
   0.012769   0.001676   0.014445 (  0.013843)
```
```
With Async(Fiber)

       user     system      total        real
   0.009986   0.001039   0.011025 (  0.011465)
```

Best choice Async sugar and performance 🚀🚀