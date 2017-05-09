## WebScraping & 並行処理
並行処理にて指定したタグ名のフォロワー数・投稿数をQiita からWebスクレイピングしてレンダリング

## exs
- cli.ex  
  コマンドラインインターフェイス

- single.ex  
  シングルプロセスで処理を行う

- parallel.ex  
  並行処理で処理を行う

## how to
1. シングルプロセスで処理  
iex(1)> webscraping single

2. 並行処理  
iex(1)> webscraping parallel



#

