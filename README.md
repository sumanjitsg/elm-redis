# Redistil
A minimalist Redis re-implementation in Elm, bringing the power of functional programming to Redis interactions.

## Why Redistil with Elm?
- **Functional Purity**: Elm's guarantees of immutable data and no side effects promote predictable code, making it easier to reason about Redis interactions and maintain the database's state.
- **Type Safety**: Elm's robust type system helps catch potential Redis protocol errors at compile time, preventing a range of runtime issues.
- **Elegant Command Handling**: Elm functions naturally model Redis commands, enhancing code readability and composability.
- **Learning Experience**: This project offers a unique way to understand the synergy between functional programming and database design principles.

## Features
- **RESP Parsing**: Accurate decoding and encoding of the Redis Serialization Protocol.
- **Command Processing**: Handles Redis commands, currently supporting PING with more to come.
- **Error Handling**: Handles RESP protocol errors returned by Redis (e.g., responses for unknown commands or invalid arguments).
- **Concurrent Connections**: Supports managing multiple Redis connections simultaneously.

## Quick Start
### Prerequisites
* Linux based environment
* Node.js v20 or later
* [Redis CLI](https://redis.io/docs/latest/develop/connect/cli/) (`sudo apt install redis-tools`)

### Install and Run
Install from npm:
```bash
npm install @sumanjitsg/redistil
```
Run server:
```bash
redistil-server
```
Connect to the server from another terminal and run supported commands (currently `PING`):
```bash
redis-cli -p 5379
127.0.0.1:5379> ping
PONG
127.0.0.1:5379> ping hello
"hello"
127.0.0.1:5379> ping hello redistil
(error) ERR wrong number of arguments for 'ping' command
127.0.0.1:5379> ping 'hello redistil'
"hello redistil"
```
