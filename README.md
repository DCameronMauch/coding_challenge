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
    "top_hashtags": [
        "#izmirescort",
        "#DACA",
        "#PushAwardsKathNiels",
        "#'D39H/JG_'DJ'('F",
        "#DefendDACA",
        "#PushAwardsMayWards",
        "#SpiritualTeacher_SaintRampalJi",
        "#BurmaMassacre",
        "#EXO_POWER",
        "#VeranoMTV2017"
    ],
    "top_emojis": [
        "joy",
        "heart",
        "sob",
        "heart_eyes",
        "recycle",
        "two_hearts",
        "pray",
        "sparkles",
        "fire",
        "clap"
    ],
    "top_domains": [
        "t.co",
        "&",
        "t&",
        "t.c&",
        "t.&",
        "t.co&",
        "twitter.com",
        null,
        "denver.joblink.direcdtory",
        "ift.tt"
    ],
    "percents": {
        "photos": 0,
        "hashtags": 16,
        "emojis": 14,
        "domains": 45
    },
    "counts": {
        "total": 90190,
        "photos": 0,
        "hashtags": 14796,
        "emojis": 13045,
        "domains": 41422
    },
    "averages": {
        "second": 38,
        "minute": 46,
        "hour": 49
    }
}
```
