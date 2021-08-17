- Build the mutator
  ```
  make
  ```

- Replace the mutator in `ReCFA/bin` with this mutator.

- Instrument the binaries with the new mutator, run the instrumented program with SPEC2k6 standard workloads, and capture the runtime control-flow events in the event files i.e., `*-re`. 

- Build
  ```
  g++ event_counter.cpp -o event_counter -no-pie
  ```

- Count the number of control-flow events.
  ```
  ./event_counter [event_file_name]
  ```
