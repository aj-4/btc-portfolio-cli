# btc-portfolio-cli
simple btc portfolio tracker for terminal

install dependencies
```sh
  npm i -g bitcoin-chart-cli
```

optional for auto-update
```sh
  brew install watch
```


then run
```sh
    watch -t -n 60 --color sh btc.sh -q 2
```
-t flag hides the header of "watch"
-n flag asks "watch" to refresh every 60 seconds
-q flag is quantity of btc you have. if you own 2 btc, put -q 2
