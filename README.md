# RedWeb
RedWeb is a program, which lets you access webpages all around your world. It works a bit like the World Wide Web. A webpage is just a normal lua file, unlike others (quest, firewolf...).  
***RedWeb works with lua programs. Therefore you should not use this on a server (because of hacking etc.)***  
***RedWeb is still under construction. It should be ready 1st ~~February~~ March.***

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
  **How to use:** Run RedWeb and insert a URL, like: `web://website.cc/page`.  
  *Pastebin coming soon.*

- **Computer 2:**  
  This is the IDS (ID Server). It is comparable with an DNS server in real-life and there is only one of it.  
  **How to use:** Just run the ID Server software.  
  *Pastebin coming soon.*

- **Computer 3:**  
  These are the webservers. One webserver can have multiple domains hosted, that are registered on the IDS.  
  **How to use:** Open the server program and click `START`, in the bottom-right corner.  
  *Pastebin coming soon.*

### Create a website
Run the server software on a server computer. Click on the `=` in the top-left corner, and click register.  
Insert the desired domain name (with domain extension, like `.cc`), and insert the path to the base folder, like `/domains/mywebsite.mc` or `/disk/files`.

Then, the first page to add is `index` or `index.lua`. As you can see by the extension, the files are **just lua programs**. Therefore, **you should not use this in a server**, only for personal use. It is way too easy to take over a computer this way (like adding/changing the startup file :wink:)
