# Metagoofeel

Web crawler and downloader based on GNU Wget.

The goal is to be less intrusive than simply mirroring an entire website.

You can also import your own list with already crawled URLs (e.g. from Burp Suite).

Current regular expression for extracting URLs from GNU Wget's output is `(?<=URL\:\ )[^\s]+(?=\ 200\ OK)` and for downloading is simply to check if the supplied keyword is contained in a URL.

Tweak this tool to your liking by modifying regular expressions.

Tested on Kali Linux v2021.2 (64-bit).

Made for educational purposes. I hope it will help!

## How to Run

Open your preferred console from [/src/](https://github.com/ivan-sincek/metagoofeel/tree/master/src) and run the commands shown below.

Install required packages:

```fundamental
apt-get -y install bc
```

Change file permissions:

```fundamental
chmod +x metagoofeel.sh
```

Run the script:

```fundamental
./metagoofeel.sh
```

Tail the crawling progress (optional):

```fundamental
tail -f metagoofeel_urls.txt
```

## Usage

```fundamental
Metagoofeel v2.2 ( github.com/ivan-sincek/metagoofeel )

--- Crawl ---
Usage:   ./metagoofeel.sh -d domain              [-r recursion]
Example: ./metagoofeel.sh -d https://example.com [-r 20       ]

--- Crawl and download ---
Usage:   ./metagoofeel.sh -d domain              -k keyword [-r recursion]
Example: ./metagoofeel.sh -d https://example.com -k all     [-r 20       ]

--- Download from a file ---
Usage:   ./metagoofeel.sh -f file                 -k keyword
Example: ./metagoofeel.sh -f metagoofeel_urls.txt -k pdf

DESCRIPTION
    Crawl through an entire website and download specific or all files
DOMAIN
    Domain you want to crawl
    -d <domain> - https://example.com | https://192.168.1.10 | etc.
KEYWORD
    Keyword to download only specific files
    Use 'all' to download all files
    -k <keyword> - pdf | js | png | all | etc.
RECURSION
    Maximum recursion depth
    Use '0' for infinite
    Default: 10
    -r <recursion> - 0 | 5 | etc.
FILE
    File with [already crawled] URLs
    -f <file> - metagoofeel_urls.txt | etc.
```
