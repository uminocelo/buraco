# Buraco

Buraco is a small in-memory key-value store written in Elixir.

The project was created as a practical introduction to Elixir processes, OTP, GenServer, supervision, process state, synchronous and asynchronous communication, public API design, testing, and runtime observability.

Buraco stores arbitrary Elixir terms as keys and values inside a supervised GenServer process.

## Features

* Store arbitrary Elixir keys and values
* Retrieve values with explicit success and error results
* Delete keys and return their previous values
* Check whether a key exists
* Inspect the number of stored entries
* List keys and values
* Retrieve a snapshot of all entries
* Clear the complete store
* Perform acknowledged synchronous writes
* Perform asynchronous writes for learning purposes
* Automatically restart the server through an OTP supervisor
* Start isolated store processes in tests
* Log lifecycle and unexpected-message events

## Requirements

* Elixir
* Erlang/OTP
* Mix

Confirm that Elixir and Mix are available:

```bash
elixir --version
mix --version
```

## Installation

Clone the repository:

```bash
git clone https://github.com/<your-user>/buraco.git
cd buraco
```

Install dependencies:

```bash
mix deps.get
```

Compile the project:

```bash
mix compile
```

Run the tests:

```bash
mix test
```

## Starting Buraco

Start an interactive Elixir session with the application loaded:

```bash
iex -S mix
```

`Buraco.Server` is started automatically by the application supervisor. It is not necessary to call `Buraco.Server.start_link/1` manually.

## Basic usage

### Store a value

```elixir
:ok = Buraco.put(:language, "Elixir")
```

`put/2` is synchronous. When it returns `:ok`, the server has processed the write.

### Retrieve a value

```elixir
Buraco.get(:language)
# {:ok, "Elixir"}
```

A missing key returns:

```elixir
Buraco.get(:missing)
# :error
```

This result format distinguishes a missing key from a key that stores `nil`:

```elixir
:ok = Buraco.put(:answer, nil)

Buraco.get(:answer)
# {:ok, nil}

Buraco.get(:missing)
# :error
```

### Replace a value

```elixir
:ok = Buraco.put(:language, "Elixir")
:ok = Buraco.put(:language, "Erlang")

Buraco.get(:language)
# {:ok, "Erlang"}
```

### Delete a value

```elixir
:ok = Buraco.put(:language, "Elixir")

Buraco.delete(:language)
# {:ok, "Elixir"}
```

Deleting a missing key returns:

```elixir
Buraco.delete(:missing)
# :error
```

### Store a value asynchronously

```elixir
:ok = Buraco.put_async(:runtime, "BEAM")
```

`put_async/2` sends a cast and returns without waiting for server-side acknowledgement. It exists primarily to demonstrate the difference between `GenServer.call/2` and `GenServer.cast/2`.

## Utility operations

### Check whether a key exists

```elixir
Buraco.has_key?(:language)
# true
```

### Count entries

```elixir
Buraco.size()
# 2
```

### List keys

```elixir
Buraco.keys()
# Example: [:language, :runtime]
```

The ordering of keys is not part of the API contract.

### List values

```elixir
Buraco.values()
# Example: ["Elixir", "BEAM"]
```

The ordering of values is not part of the API contract.

### Retrieve every entry

```elixir
Buraco.get_all()
# %{language: "Elixir", runtime: "BEAM"}
```

The returned map is an immutable snapshot. Changing that map does not directly change the state owned by `Buraco.Server`.

### Clear the store

```elixir
:ok = Buraco.clear()

Buraco.size()
# 0
```

## Result conventions

Buraco uses explicit return values for lookup and deletion operations.

```text
Successful lookup
└── {:ok, value}

Missing key
└── :error

Successful insertion
└── :ok

Successful deletion
└── {:ok, deleted_value}
```

For example:

```elixir
case Buraco.get(:language) do
  {:ok, language} ->
    IO.puts("Found #{language}")

  :error ->
    IO.puts("Language was not found")
end
```

## Architecture

```text
Application code
      │
      ▼
Buraco
Public API façade
      │
      ▼
Buraco.Server
Supervised GenServer
      │
      ▼
Map
In-memory state
```

### `Buraco`

`Buraco` is the public client API. Application code should normally call this module rather than communicating directly with the GenServer.

### `Buraco.Server`

`Buraco.Server` owns the internal map and implements the GenServer callbacks.

It handles synchronous requests for:

* retrieving values;
* inserting values;
* deleting values;
* checking keys;
* counting entries;
* listing entries;
* clearing the store.

It also handles asynchronous writes through `put_async`.

### `Buraco.Application`

`Buraco.Application` starts the root supervisor, which starts and owns `Buraco.Server`.

```text
Buraco.Application
        │
        ▼
Buraco.Supervisor
strategy: one_for_one
        │
        ▼
Buraco.Server
```

If `Buraco.Server` crashes, the supervisor starts a new server process.

## In-memory lifecycle

Buraco does not persist its data.

The map exists only inside the current `Buraco.Server` process:

```text
Server running
└── data exists

Server restarts
└── init/1 creates a new empty map

Application stops
└── data is lost
```

Supervision restores the service process, but it does not restore previously stored data.

## Runtime inspection

Find the registered process:

```elixir
pid = Process.whereis(Buraco.Server)
```

Inspect selected process information:

```elixir
Process.info(pid, [
  :registered_name,
  :status,
  :message_queue_len,
  :links,
  :memory,
  :reductions
])
```

Inspect the internal state during development:

```elixir
:sys.get_state(Buraco.Server)
```

`:sys.get_state/1` is a debugging tool. Application code should use public functions such as:

```elixir
Buraco.get_all()
```

## Tests

Run all tests:

```bash
mix test
```

Run tests with detailed output:

```bash
mix test --trace
```

Run the test suite with a specific randomization seed:

```bash
mix test --seed 500
```

Every test starts an isolated `Buraco.Server`, preventing state from leaking between tests.

## Code quality

Format the project:

```bash
mix format
```

Verify formatting without modifying files:

```bash
mix format --check-formatted
```

Compile while treating warnings as errors:

```bash
mix compile --warnings-as-errors
```

Run the complete quality gate:

```bash
mix format --check-formatted
mix compile --warnings-as-errors
mix test
```

## Generating documentation

Install the project dependencies:

```bash
mix deps.get
```

Generate the HTML documentation:

```bash
mix docs --formatter html
```

The generated documentation is placed in:

```text
doc/
```

Open:

```text
doc/index.html
```

You can also generate and open it directly:

```bash
mix docs --formatter html --open
```

## Current limitations

* Data is stored only in memory
* Data is lost when the server restarts
* A single GenServer serializes all operations
* There is no time-to-live support
* There is no automatic expiration
* There is no disk persistence
* There is no network protocol
* There is no authentication or authorization
* There is no replication
* There is no distributed consistency model
* The store has no memory limit or eviction policy

## Learning objectives

Buraco demonstrates:

* Mix project structure
* Elixir processes
* Process identifiers and registered names
* Immutable state
* Maps
* Pattern matching
* Tagged result tuples
* GenServer initialization
* Synchronous calls
* Asynchronous casts
* `handle_call/3`
* `handle_cast/2`
* `handle_info/2`
* OTP applications
* Supervision trees
* Child specifications
* Process restarts
* Public API façades
* Type specifications
* Module and function documentation
* ExUnit
* Process-isolated tests
* Runtime inspection
* Logging
* ExDoc

## Possible next steps

Buraco can evolve into a deeper OTP and storage project by adding:

* key expiration and TTL
* periodic expired-key cleanup
* multiple dynamically supervised stores
* process discovery using `Registry`
* concurrent reads using ETS
* snapshots to disk
* DETS persistence
* an append-only event log
* telemetry events
* TCP or HTTP access
* clustered and replicated storage

A useful progression is:

```text
Single GenServer
      ↓
Multiple named stores
      ↓
DynamicSupervisor and Registry
      ↓
TTL and scheduled cleanup
      ↓
ETS-backed storage
      ↓
Disk persistence
      ↓
Network-accessible server
```

## License

Add the license selected for the project here.
