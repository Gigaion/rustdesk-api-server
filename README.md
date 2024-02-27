# rustdesk-api-server

## This is is an English translated fork of https://github.com/kingmo888/rustdesk-api-server 

[The more accurate english explanation is available by clicking here.](https://github.com/gigaion/rustdesk-api-server/blob/master/README_EN.md)

<p align="center">
    <i>A python implementation of the Rustdesk API interface that supports WebUI management</i>
    <br/>
    <img src ="https://img.shields.io/badge/Version-1.4.5-blueviolet.svg"/>
    <img src ="https://img.shields.io/badge/Python-3.7|3.8|3.9|3.10|3.11-blue.svg" />
    <img src ="https://img.shields.io/badge/Django-3.2+|4.x-yelow.svg" />
    <br/>
    <img src ="https://img.shields.io/badge/Platform-Windows|Linux-green.svg"/>
    <img src ="https://img.shields.io/badge/Docker-arm|arm64|amd64-blue.svg" />
</p>

![Home Page](images/front_main.png)

## Features

- Support independent registration and login on the front page.
   - Registration page and login page:
  ![Front Registration](images/front_reg.png)
  ![Front Login](images/front_login.png)

- Supports display of device information at the front desk, divided into administrator version and user version.
- Support custom aliases (remarks).
- Support background management.
- Support color labels.
![Rust Books](images/rust_books.png)

-Support device online statistics.
-Support device password saving.
- Use the heartbeat interface to automatically manage tokens and keep them alive.
- Support sharing devices with other users.
![Rust Share](images/share.png)
- Supports web control terminal (currently only supports non-SSL mode, see usage instructions below)
![Rust Share](images/webui.png)

Backend homepage:
![Admin Main](images/admin_main.png)

## Install

### Method 1: Use it out of the box

Only supports Windows, please go to release to download. No installation environment is required, just run `start.bat` directly. screenshot:

![window direct run version](/images/windows_run.png)


### Method 2: Code running

```bash
# Clone the code locally
git clone https://github.com/Gigaion/rustdesk-api-server.git
# Enter directory
cd rustdesk-api-server
# Install dependencies
pip install -r requirements.txt
# After ensuring that the dependencies are installed correctly, execute:
# Please modify the port number yourself. It is recommended to keep 21114 as the default port of Rustdesk API.
python manage.py runserver 0.0.0.0:21114
```

At this time, you can use the form of `http://local-IP:port` to access.

**Note**: If Django4 will have problems when configuring CentOS because the system's sqlite3 version is too low, please modify the files in the dependent library. Path: `xxxx/Lib/site-packages/django/db/backends/sqlite3/base.py` (find the address of the package according to the situation), modify the content:
```python
# from sqlite3 import dbapi2 as Database   #(Comment out this line)
from pysqlite3 import dbapi2 as Database # Enable pysqlite3
```

### Method 3: Docker run

#### Docker method 1: Build it yourself
```bash
git clone https://github.com/Gigaion/rustdesk-api-server.git
cd rustdesk-api-server
docker compose --compatibility up --build -d
```
Thanks to the enthusiastic netizen @ferocknew for providing it.

#### Docker Method 2: Pre-build Run

docker run command：

```bash
docker run -d \
  --name rustdesk-api-server \
  -p 21114:21114 \
  -e CSRF_TRUSTED_ORIGINS=http://yourdomain.com:21114 \ #防跨域信任来源，可选
  -e ID_SERVER=yourdomain.com \ #ID server used by the web control
  -v /yourpath/db:/rustdesk-api-server/db \ #Modify /yourpath/db to be the mounting directory for your host database
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  --network bridge \
  --restart unless-stopped \
  ghcr.io/Gigaion/rustdesk-api-server:latest
```

docker-compose command:

```yaml
version: "3.8"
services:
  rustdesk-api-server:
    container_name: rustdesk-api-server
    image: ghcr.io/Gigaion/rustdesk-api-server:latest
    environment:
      - CSRF_TRUSTED_ORIGINS=http://yourdomain.com:21114 #Prevent cross-domain trust sources, optional
      - ID_SERVER=yourdomain.com #ID server used by the web control
    volumes:
      - /yourpath/db:/rustdesk-api-server/db #Modify /yourpath/db to be the mounting directory for your host database
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    network_mode: bridge
    ports:
      - "21114:21114"
    restart: unless-stopped
```

## Environment Variables

| Variable name | Reference value | Remarks |
| ---- | ------- | ----------- |
| `HOST` | Default `0.0.0.0` | Binding service IP |
| `TZ` | Default `America/Los_Angeles`, optional | Time zone |
| `SECRET_KEY` | Optional, customize a string of random characters | Program encryption key |
| `CSRF_TRUSTED_ORIGINS` | Optional, verification is turned off by default;<br>If you need to turn it on, fill in your access address `http://yourdomain.com:21114` <br>**If you need to turn off verification, please delete this variable instead Leave blank** | Prevent cross-domain trust sources |
| `ID_SERVER` | Optional, the default is the same host as the API server. <br>Can be customized such as `yourdomain.com` | ID server used by the web control terminal |
| `DEBUG` | Optional, default `False` | Debug mode |

## Usage issues

- Administrator settings

   When there is no account in the database, the first registered account will directly obtain super administrator privileges, and the accounts registered thereafter will be ordinary accounts.

- Device Information

   After testing, the client will regularly send device information to the API interface in non-green version mode when installed as a service. Therefore, if you want device information, you need to install the rustdesk client and start the service.

- Slow connection speed

   The link speed of the new version of Key mode is slow. When starting the service on the server, do not use the -k parameter. At this time, the client cannot configure the key.

- Web console configuration

   - Set the ID_SERVER environment variable, or modify the ID_SERVER configuration item in the rustdesk_server_api/settings.py file and fill in the ID server/relay server IP or domain name.

- The web console keeps spinning in circles

   - Check whether the ID server is filled in correctly

   - The Web control terminal currently only supports non-SSL mode. If the webui is accessed via https, please remove the s, otherwise the ws will not be able to connect and will keep spinning. For example: https://domain.com/webui, change to http://domain.com/webui

- When logging in or out during background operations: CSRF verification failed. The request was interrupted.

   This operation is most likely a combination of docker configuration + nginx reverse generation + SSL. Pay attention to modifying CSRF_TRUSTED_ORIGINS. If it is ssl, it starts with https, otherwise it is http.

## Development Plan

- [x] Share device with other registered users (v1.3+)

   > Description: Similar to network disk url sharing, after activating the url, you can get the devices under a certain group or label.
   > Note: In fact, as a middleware, web api can't do much. More functions still need to be modified on the client side, which is not worth it.

- [x] Integrated web client form (v1.4+)

   > Integrate the web client of Master, it has been integrated. [Source](https://www.52pojie.cn/thread-1708319-1-1.html)
  
- [ ] Filtering of expired (offline) devices to distinguish between online & offline devices

   > Through configuration, clean or filter devices that have expired beyond the specified time.

- [ ] The first screen is split into a user list page and an administrator list page, and paging is added.

- [ ] Support exporting information to xlsx file.


## Other related tools

- [CMD script that can modify client ID](https://github.com/abdullah-erturk/RustDesk-ID-Changer)

- [rustdesk](https://github.com/rustdesk/rustdesk)

- [rustdesk-server](https://github.com/rustdesk/rustdesk-server)

## Stargazers over time
[![Stargazers over time](https://starchart.cc/Gigaion/rustdesk-api-server.svg?variant=adaptive)](https://starchart.cc/Gigaion/rustdesk-api-server)
