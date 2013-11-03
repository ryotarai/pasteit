# Pasteit

## Synopsis

* Upload your code snippet or log text called paste
* View the paste
* Easy to upload (You need just `curl`)
* No authentication

## Usage

Rack it up

```
$ rackup config.ru
Puma 1.6.3 starting...
* Min threads: 0, max threads: 16
* Environment: development
* Listening on tcp://0.0.0.0:9292
```

Post foo.txt

```
$ curl -F 'foo.txt=@foo.txt' -XPOST http://localhost:9292
http://localhost:9292/pastes/1234567890abcdef
```

Post data from stdin

```
$ echo "Hello, Pasteit" | curl -F '-=@-' -XPOST http://localhost:9292
http://localhost:9292/pastes/1234567890abcdef
```
