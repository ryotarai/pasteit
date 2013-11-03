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

### Paste from File

```
curl -F 'app.rb=@app.rb' -F 'README.md=@README.md' -XPOST http://localhost:9292/
```

### Paste from Stdin
```
cat foo.txt | curl -F '-=@-' -XPOST http://localhost:9292/
```

### Paste from Clipboard (on OSX)
```
pbpaste | curl -F '-=@-' -XPOST http://localhost:9292/
```

### Paste with pasteit command
```
pasteit () {
    ENDPOINT="http://localhost:9292"
    if [ $# -eq 0 ]; then
        curl -F "-=@-" -XPOST $ENDPOINT
    else
        ARGS=()
        for ARG in "$@"; do
            ARGS+=("-F" "$ARG=@$ARG")
        done
        curl $ARGS -XPOST $ENDPOINT
    fi
}
```

```
pasteit foo.txt bar.txt
cat foo.txt | pasteit
```

