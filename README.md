# RedWeb
RedWeb is a program, which lets you access webpages all around your world. It works a bit like the World Wide Web. A webpage is just a normal lua file, unlike others (quest, firewolf...).  
***RedWeb works with lua programs. Therefore you should not use this on a server (because of malicious programs etc.)***  
:exclamation: **RedWeb is still in beta. Some features may not work well.**

### Installation
For RedWeb, you will need at least 3 computers with wireless modems.  
Scheme:
```
Client 1  -----|                 |-----  Webserver 1
               |                 |
Client 2  -----+-----  IDS  -----+-----  Webserver 2
               |                 |
Client 3  -----|                 |-----  Webserver 3
...            |                 |       ...
    1                   2                     3
```

- **Computer 1:**  
  These are the clients. An advanced computer and DvgFiles are required.  
  **Pastebin:** `KA29CCek`

- **Computer 2:**  
  This is the IDS (ID Server). It is comparable with an DNS server in real-life and there is only one of it.  
  **Pastebin:** `011rPiSP`

- **Computer 3:**  
  These are the webservers. One webserver can have multiple domains hosted, that are registered on the IDS.  
  **Pastebin:** `011rPiSP`

### How to use
- **Client**  
  Run RedWeb and insert a URL, like: `web://website.cc/page` or just `website.cc`. You don't need to add the `web://`, but if you are going to use the other protocol, `app://`, you need to.

- **ID Server**  
  Just run the ID Server software. After someone has first registered a domain, it will create a file at the location you gave it at install, defaults `database.db`.

- **Web server**  
  Open the server program. It will automatically start to run the server. After the first register, it will create a file at the location you gave it at install, defaults `server.cfg`.

### Create a website
Run the server software on a server computer. Click register in the top-right corner.  
Type the desired domain name (with domain extension, like `.cc`), and type the path to the base folder, like `/domains/mywebsite.mc` or `/disk/files`.

Then, the first page to add is `index` or `index.lua`. As you can see by the extension, the files are **just lua programs**. Therefore, **you should not use this in a server**, only for personal use. It is way too easy to take over a computer this way (like adding/changing the startup file :wink:)
