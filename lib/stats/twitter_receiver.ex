defmodule CodingChallenge.Stats.TwitterReceiver do
  @moduledoc false

  use Task, restart: :permanent

  def start_link do
    Task.start_link(__MODULE__, :runner, [])
  end

  def runner do
    Process.register(self(), __MODULE__)

    ExTwitter.configure(
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
      access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
    )

    stream = ExTwitter.stream_sample()

    for message <- stream do
      CodingChallenge.Stats.Progress.tick()
      :poolboy.transaction(:text_processor_pool, fn(pid) ->
        GenServer.cast(pid, {:text, message.text})
      end)
    end
  end
end