
defmodule Webscraping.CLI do
  @moduledoc """
  コマンドラインでの値を取得して実行するモジュール
  ・コマンドラインの値の取得
  ・parse
  ・値から実行プロセスへの引き渡し
  """

  def main(argv) do
    argv
    |>parse
    |>process
  end
  @doc """
  `argv` can be -h or --help, which returns   `:help`.
  """


  def parse(argv) do
    parse = OptionParser.parse(argv, switched: [help: :boolean],aliases: [h: :help])
    case parse do
      {[help: true],_,_}->
        :help

      {_,[type],_}->
        [type] # parallel or single process

      _->:help
    end
  end

  def process(:help) do
    IO.puts """
    usage: webscraping <type>
    >type is only parallel / single
    """
    System.halt(0)
  end

  def process([type]) do
    case type do
      "parallel" ->
        Webscraping.Parallel.main()
      "single" ->
        Webscraping.Single.main()
      _ ->
        process(:help)
    end
  end

  def process() do
    IO.puts "error"
  end

end

#Webscraping.CLI.main(["-h"])
#Webscraping.CLI.main(["--help"])
