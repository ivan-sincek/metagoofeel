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

## Images

<p align="center"><img src="https://github.com/ivan-sincek/metagoofeel/blob/master/img/help.png" alt="Help"></p>

<p align="center">Figure 1 - Help</p>

<p align="center"><img src="https://github.com/ivan-sincek/metagoofeel/blob/master/img/crawling.png" alt="Crawling"></p>

<p align="center">Figure 2 - Crawling</p>

<p align="center"><img src="https://github.com/ivan-sincek/metagoofeel/blob/master/img/importing_urls.png" alt="Importing URLs"></p>

<p align="center">Figure 3 - Importing URLs</p>
