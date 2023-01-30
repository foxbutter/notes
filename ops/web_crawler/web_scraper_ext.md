# Web Scraper -- 轻量数据爬取利器

> https://webscraper.io/
>
> https://www.cnblogs.com/web-scraper/


## curl <> python3

测试Python下载html页面
```python
import requests

proxies = {
    'http': 'http://tentacle-zone-custom-region-jp:CvuXngvjPXnf7HYYQw27@proxy.ipidea.io:2333',
    'https': 'http://tentacle-zone-custom-region-jp:CvuXngvjPXnf7HYYQw27@proxy.ipidea.io:2333',
}

headers = {
        'authority': 'brandavenue.rakuten.co.jp',
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'cache-control': 'no-cache',
        'pragma': 'no-cache',
        'sec-ch-ua': '"Not?A_Brand";v="8", "Chromium";v="108", "Google Chrome";v="108"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"macOS"',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'none',
        'sec-fetch-user': '?1',
        'upgrade-insecure-requests': '1',
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
    }

response = requests.get('https://brandavenue.rakuten.co.jp/ba/shop-atmospink/?sort=2&inventory_flg=1&sale=0&used=0', headers=headers, proxies=proxies)

with open('/tmp/rakuten_list_page.html', 'wb') as f:
    f.write(response.content)


```