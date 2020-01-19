# -*- coding: UTF-8 -*-
import requests
import time
import re
from bs4 import BeautifulSoup

num = 83 # 终止的页数
url = "https://onejav.com/tag/Pantyhose?page="
f2 = open("allurl.txt", "a")
result = []
final = []
i = 1  # 开始的页数
while i <= num:
    print(i)
    
    success = False
    while success is not True:
        try:
            r = requests.get(url + i.__str__(), timeout=2)
            success = True
        except:
            print(url+"fail")

    content = r.text
    soup = BeautifulSoup(content, 'lxml')
    for link in soup.find_all(title="Download .torrent"):
        # result.append("https://onejav.com" + link.get("href"))
        name =  link.get("href").split("/")[-1]
        torrent = "https://onejav.com" + link.get("href")
        f2.write(torrent + '\n')
        success = False
        while success is not True:
            try:
                r = requests.get(torrent, timeout=2)
                success = True
                print(torrent + " success")
            except:
                print(torrent + " fail")
        f = open("bt/"+name, "wb")
        f.write(r.content)
        f.close()
    
    f2.flush()
    time.sleep(1)
    i += 1
# # 所有的url已经存入result
f2.close()
