# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### 0.1.1 (2024-04-29)


### Features

* **command:** add command module with PING and error handling ([5458f1c](https://github.com/sumanjitsg/redistil/commit/5458f1c4221c989398e2fadf334bc9b19601d0a7))
* **db:** add database module supporting execution of ping command ([fcfc346](https://github.com/sumanjitsg/redistil/commit/fcfc34621522776a94e57e850b7e0fd42da25fa5))
* handle concurrent client connections ([199da57](https://github.com/sumanjitsg/redistil/commit/199da57dfcaeb0abae5ea41a080b88197e1af703))
* implement TCP echo server ([0152125](https://github.com/sumanjitsg/redistil/commit/01521254bc5457853aff9cb22c5b0391804d563b))
* on incoming messages, RESP decode, parse command, run command and send back the output ([b609bdb](https://github.com/sumanjitsg/redistil/commit/b609bdb79436d763fb970e80dc1818e153ed66d1))
* **resp:** add data to list function that maps RESP data to a list of strings ([b675c28](https://github.com/sumanjitsg/redistil/commit/b675c28cf3ceef771d11a3ad179f9f0627a9dada))
* **resp:** add RESP bulk string parser ([0e3d25e](https://github.com/sumanjitsg/redistil/commit/0e3d25eb5b4d398af4876cd9cb49db34b597c64b))
* **resp:** add simple error parser ([980e53e](https://github.com/sumanjitsg/redistil/commit/980e53e31605d8543b7448fc92a4117920767a83))
* **resp:** add simple string encode and move simple string decoder to Resp module ([a721b9e](https://github.com/sumanjitsg/redistil/commit/a721b9e222afa1f1659d0d150da9607329d115e3))
* **resp:** add simple string parser ([e5a671d](https://github.com/sumanjitsg/redistil/commit/e5a671d715b30b5d760c366666a9e4474b9e05fa))
* **resp:** add unwrap function, move simple error decoder to resp and refactor tests ([9e4d2c8](https://github.com/sumanjitsg/redistil/commit/9e4d2c819e8fef8cd4aa82bd53595edee8394ee6))
* **resp:** decoder should be able to decode any resp encoded string without needing the decoder type; add encoder for all data types and remove dataToString ([ea0642d](https://github.com/sumanjitsg/redistil/commit/ea0642dedec9336d88b20cdb81c7ace9583738fb))
* **resp:** make Problem type opaque in bulk string parser ([9b43991](https://github.com/sumanjitsg/redistil/commit/9b43991a4c58a58181407885e2ee014939a90599))
* **resp:** moved array decoder to Resp and replaced unwrap functions with dataToString ([06cd9e2](https://github.com/sumanjitsg/redistil/commit/06cd9e2eb20d50c1e2647ee41c6f995fd8bd28a0))
* **resp:** parse array of bulk strings ([01bffa0](https://github.com/sumanjitsg/redistil/commit/01bffa086a0da173199a71a32bac555af1357f03))
* **resp:** parse array of simple strings ([dc767f4](https://github.com/sumanjitsg/redistil/commit/dc767f4c8ec8344d62f7e3a083c749189aa9aa54))
* **resp:** parse RESP nested arrays ([c3e852b](https://github.com/sumanjitsg/redistil/commit/c3e852b50c6e91209881b12fc24832c9c2afc05c))
* **resp:** remove remnant of older array decoder ([3a31a4b](https://github.com/sumanjitsg/redistil/commit/3a31a4bb2a675ff7a5872e2ed46b4dd601d2085e))
* **resp:** remove remnant of older bulk string decoder ([b8326ad](https://github.com/sumanjitsg/redistil/commit/b8326adc0ac2de77114cf8d00e8f7dcaf6fbdffc))
* scaffold index.ts and Main.elm with port that logs a message on terminal ([9e5a55c](https://github.com/sumanjitsg/redistil/commit/9e5a55c74ef9ebe37e1e8483a247828a6b294a7f))
* use Elm ports to send messages from socket to Elm and echo them back ([658733a](https://github.com/sumanjitsg/redistil/commit/658733afa7329fb9bcf4e4fe055bfb26bc4a22f4))


### Bug Fixes

* **resp:** consume the trailing \r\n character ([90e307c](https://github.com/sumanjitsg/redistil/commit/90e307c66cb980b1113efb6bc8b1cd0c965dad2b))
* **socket:** fix incorrect port check before usage ([831212c](https://github.com/sumanjitsg/redistil/commit/831212cb641ac725cc5558eda9fb33bd68259d81))
