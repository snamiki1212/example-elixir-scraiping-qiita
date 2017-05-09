defmodule Webscraping.Single do
  require HTTPoison
  require Floki
  require Logger

  @doc """

  """
  def get_qiita_num(url,word) do
    find_url="#{url}/#{word}"
    case HTTPoison.get(find_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        #IO.puts body
        body
        |>Floki.find(".count")
        |>Enum.map(&(elem(&1,2)))
        |>Enum.to_list
        |>List.flatten
        |>List.insert_at(0,word)
        #list [検索タグ、投稿数、フォロワー数]

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


  @moduledoc """
  main module
  """
  def main(argv\\[]) do
    # table
    title="Qiite"
    header = ["Tag", "ThredNum", "FollowNum"]

    # web scraiping

    url="https://qiita.com/tags"

    # web scraipping >> get Tag name
    page_num=1
    #words=get_qitta_tag(url,page_num)
    #words=["Rails","Elixir","JavaScript","Ruby","Python","iOS","PHP","Rails","Android","Swift","Java","AWS","Linux","Git","Mac",]
    words=["Rails","Elixir","Ruby"]

    # web scraiping >> get num & HTML parse
    rows=for word<-words, do: get_qiita_num(url,word)
    Logger.info "row is #{rows}"

    # display
    TableRex.quick_render!(rows, header, title)|> IO.puts


  end


end
