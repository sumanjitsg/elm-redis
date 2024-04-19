# Redistil
A minimalist Redis implementation in Elm, bringing the power of functional programming to Redis interactions.
## Why Redistil?
- **Functional Purity**: Elm's guarantees of immutable data and no side effects promote predictable code, making it easier to reason about Redis interactions and maintain the database's state.
- **Type Safety**: Elm's robust type system helps catch potential Redis protocol errors at compile time, preventing a range of runtime issues.
- **Elegant Command Handling**: Elm functions naturally model Redis commands, enhancing code readability and composability.
- **Learning Experience**: This project offers a unique way to understand the synergy between functional programming and database design principles.
## Features
- **RESP Parsing**: Accurate decoding and encoding of the Redis Serialization Protocol.
- **Command Processing**: Handles Redis commands, currently supporting PING with more to come.
- **Error Handling**: Handles RESP protocol errors returned by Redis (e.g., responses for unknown commands or invalid arguments).
- **Concurrent Connections**: Supports managing multiple Redis connections simultaneously.
