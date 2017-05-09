require HTTPoison
require Floki
require Logger

defmodule Webscraping.Parallel do
  url="https://qiita.com/tags"

  @moduledoc """
  main module
  """

  def main(argv\\[]) do
    ####
    # ready
    ####
    title ="Qiite"
    header = ["Tag", "ThredNum", "FollowNum"]
    module=Server
    func=:server

    ####
    # web scraiping >> get num & HTML parse
    #
    ####
    # factor
    #words=Server.get_qitta_tag(url,page_num//1)
    #words=["Rails","Elixir","Ruby"]
    words=["Rails","Elixir","JavaScript","Ruby","Python","iOS","PHP","Rails","Android","Swift","Java","AWS","Linux","Git","Mac",]
    num_process=3 #num_process is parallel process number

    rows=Client.execute(num_process,words,module,func,words)
    Logger.info "main:rows are #{rows}"

    ####
    # display
    ####
    TableRex.quick_render!(rows, header, title)|> IO.puts
  end
end

defmodule Client do
  def execute(num_process,words,module,func,words) do
    Logger.info "execute:start ------"

    (1..num_process)
    |>Enum.map(fn(_)->spawn(module,func,[self()])end)
    |>client(words,[])

  end

  defp client(server_pids,words,results) do
    Logger.info "client:start ------"
    Logger.info "client:results is #{results}"

    Logger.info "client:waiting"
    receive do
      {:ready,received_server_pids} when length(words)>0 ->
        Logger.info "client:receive>ready"
        [word|tail]=words
        send received_server_pids, {:get,word,self}
        client(server_pids,tail,results)

      {:ready,received_server_pids}  ->
        Logger.info "client:receive>ready"
        send received_server_pids, {:shutdown}
        if length(server_pids)>1 do
          Logger.info "client:List.delete"
          client(List.delete(server_pids,received_server_pids),words,results)
        else
          Logger.info "client:results are #{results}"
          Logger.info "client:end ------"
          results
        end

      {:answer,result,word,received_server_pids}->
        Logger.info "client:receive>answer:"
        Logger.info "-> result is #{result}"
        client(server_pids,words,[result|results])

      {:error}->
        Logger.info "client:receive>error:"
        IO.puts "error"

      after
        5_000 ->
          Logger.info "client:timeout"
          IO.puts "trapp"
          exit(:error)
    end
  end
end

defmodule Server do
    def server(client_pid) do
      url="https://qiita.com/tags"
      Logger.info "server:start ------"
      send client_pid,{:ready,self}

      Logger.info "server:waitting"
      receive do
        {:get,word,received_client_pid} ->
          Logger.info "server:receive->:get"
          Logger.info "-> word is #{word}"
          send received_client_pid,{:answer,get_qiita_num(url,word),word,self}
          server(client_pid)
        {:shutdown}->
          Logger.info "server:receive->:shutdown"
          exit(:normal)
      end
    end

    def get_qiita_num(url,word) do
      find_url="#{url}/#{word}"
      case HTTPoison.get(find_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          body
          |>Floki.find(".count")
          |>Enum.map(&(elem(&1,2)))
          |>Enum.to_list
          |>List.flatten
          |>List.insert_at(0,word)
          #|>IO.inspect # debug
          # return->list [検索タグ、投稿数、フォロワー数]

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          IO.puts "Not found :("
        {:error, %HTTPoison.Error{reason: reason}} ->
          IO.inspect reason
      end
    end


  def get_qitta_tag(url,page_num)do
    case HTTPoison.get("#{url}?page=#{page_num}")do
      {:ok,%HTTPoison.Response{status_code: 200, body: body}}->
        body
        |>Floki.find(".TagList__label")
        |>Enum.map(&(elem(&1,2)))
        |>Enum.map(&(List.last(&1)))

        {:ok, %HTTPoison.Response{status_code: 404}}->
          IO.puts "Not found"
        {:error, %HTTPoison.Error{reason: reason}}->
          IO.inspect reason
    end
  end
end
