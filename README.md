# Coding Challenge - Twitter Statistics

## Requirements

  * Total number of tweets received
  * Average tweets per hour/minute/second
  * Top emojis in tweets
  * Percent of tweets that contains emojis
  * Top hashtags
  * Percent of tweets that contain a url
  * Percent of tweets that contain a photo url
  * Top domains of urls in tweets
  
## Running

  * Export `TWITTER_CONSUMER_KEY` environment variable
  * Export `TWITTER_CONSUMER_SECRET` environment variable
  * Export `TWITTER_ACCESS_TOKEN` environment variable
  * Export `TWITTER_ACCESS_SECRET` environment variable
  * Install dependencies with `mix deps.get`
  * Run server with `mix phx.server`
  
## Getting Stats

  * Go to `http://localhost:8000/api` with a browser
  
## Example Output

```json
{
    "top_photos": [],
    "top_hash_tags": [
        "#serendipity",
        "#izmirescort",
        "#jusapolunepnygc",
        "#laborday",
        "#love_yourself",
        "#pushawardsmaywards",
        "#kcacolombia",
        "#daca",
        "#방탄소년단"
    ],
    "top_emojis": [
        "joy",
        "heart",
        "sob",
        "heart_eyes",
        "fire",
        "two_hearts",
        "recycle",
        "scream",
        "sparkles",
        "point_down"
    ],
    "top_domains": [
        "t.co",
        "t",
        "t.c",
        "t."
    ],
    "percents": {
        "photo": 0,
        "hash_tag": 18,
        "emoji": 15,
        "domain": 47
    },
    "counts": {
        "total": 12711,
        "photo": 0,
        "hash_tag": 2328,
        "emoji": 1978,
        "domain": 5982
    },
    "averages": {
        "second": 31,
        "minute": 36,
        "hour": 37
    }
}
```
