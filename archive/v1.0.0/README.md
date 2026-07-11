# 📦 inpx-web (архивная версия v1.0.0)
***Веб-сервер для поиска по .inpx-коллекции книг.***

> **⚠️ Данная версия больше не поддерживается**

Это архив первой версии проекта **inpx-web**.  
Она использовала утилиту `fb2converter` для конвертации книг в формате FB2 в MOBI с последующей отправкой на электронную почту ридера.

---

## ❗ Важное обновление

**С 13 февраля 2026 года** автор прекратил поддержку `fb2converter` и перевёл данную версию в архив.

Дальнейшее развитие проекта продолжается в рамках новых инструментов:

- **[fb2cng (fbc)](https://github.com/rupor-github/fb2cng)** — конвертация FB2 в MOBI
- **[sync2kindle (s2k)](https://github.com/rupor-github/sync2kindle)** — синхронизация книг с Kindle

---

## 🔗 Актуальная версия

Все новые функции и обновления доступны в **актуальной версии** проекта в корне репозитория:  
👉 [Перейти к актуальной версии](../../README.md)

---

## 📖 Старая документация для этой версии:

#### Запуск с помощью Docker Compose

```yml
# docker-compose.yaml
version: '3.8'
services:
  server:
    container_name: inpx-web
    image: ghcr.io/codinv/inpx-web
    network_mode: bridge
    ports:
      - "12380:12380/tcp"
    restart: unless-stopped
    environment:
      TZ: Europe/Moscow
      LIB_DIR: /library/lib.rus.ec
      INPX_FILE: /library/librusec_local_fb2.inpx
    volumes:
      - ./:/data
      - /volume1/MyLibrary:/library:ro
```

> Параметры в **<span style="color:green">environment:</span>** \
<span style="color:red">**LIB_DIR**</span> : полный путь к папке с архивами книг в docker контейнере: \
> всегда должен начинаться с <span style="color:red">**/library**</span> - это папка в контейнере, куда подключается библиотека с книгами: \
`volumes: /ваш_путь_к_библиотеке:library:ro`  \
<span style="color:red">**INPX_FILE**</span> : полный путь к INPX файлу в docker контейнере: \
так же всегда должен начинаться с <span style="color:red">**/library**</span>, если файл дополнительно не подключен через **<span style="color:green">volumes</span>**

в данном примере используется следующая структура:

```
📁 volume1/
└── 📂 MyLibrary/
    ├── 📄 librusec_local_fb2.inpx         # Основной INPX-файл
    └── 📂 lib.rus.ec/                     # Основное хранилище книг c fb2-архивами
        ├── 📦 fb2-000001-010000.zip
        ├── 📦 fb2-010001-020000.zip
        └── 📦 fb2-020001-030000.zip
```

#### Пример настроек external_tools.json для конвертирования в epub и отправки на email Kindle

```json
{
  "epubExport": {
    "active": true,
    "title": "(Kindle)",
    "hint": "Отправить на Kindle",
    "ext": "fb2",
    "cmd": "cp '${HASHFILE}.raw' '${FILENAME}'; ${EXTDIR}/app-fb2c/fb2c -c ${EXTDIR}/app-fb2c/configuration.toml convert --to epub --ow --stk --nodirs '${FILENAME}' '${EXTDIR}/app-export'; mv -f conversion.log '${EXTDIR}/log/'; rm -f ./*",
    "debug": true,
    "type": "cmd"
  }
}
```

#### Пример минимальных настроек configuration.toml

```toml
[logger]

	#---- controls terminal (stdout, stderr) output
	[logger.console]
		#---- logging level
		#---- "none"   - suppress all console logging
		#---- "normal" - messages INFO level and higher are outputted
		#---- "debug"  - all log messages are outputted
		level = "normal"

	#---- controls logging to a file (could duplicate CONSOLE messages)
	[logger.file]
		#---- logging level
		#---- "none"   - suppress logging
		#---- "normal" - messages INFO level and higher are printed
		#---- "debug"  - all log output is printed
		level = "debug"
		#---- path to the log file, if relative - relative to current working directory
		# destination = "conversion.log"
		#---- how to handle output file during consecutive program runs
		#---- "append"    - keep all old log messages, append new ones at the end
		#---- "overwrite" - keep only messages from the last run, log is overwritten
		mode = "overwrite"

[sendtokindle]
	#---- In case book sent successfully - delete it from disk
	delete_sent_book = true

	#---- SMTP server parameters
	smtp_server = "smtp.yandex.ru"
	smtp_port = 587
	smtp_user = "your_mail_user@yandex.ru"
	smtp_password = "your_mail_password"

	#---- Required by Amazon service
	from_mail = "your_mail_user@yandex.ru"
	to_mail = "your_kindle_email@kindle.com"
````

### Скрипт для переименования файла книги перед конвертацией:

Добавил скрипт, переименовывающий файл в формат:  
**"Название книги.fb2"** или **"ХХ Название книги.fb2"**,  
если несколько книг в одной серии, где **ХХ** номер книги в серии.

Скрипт worker.sh [скачать тут](https://github.com/codinv/inpx-web/blob/main/archive/v1.0.0/worker.sh), сохранить в корень папки с контейнером **inpx-web**

#### Пример настроек external_tools.json для использования скрипта

```json
{
  "epubExport": {
    "active": true,
    "title": "(Kindle)",
    "hint": "Отправить на Kindle",
    "ext": "fb2",
    "cmd": "cp '${HASHFILE}.raw' '${FILENAME}'; sh '${EXTDIR}/worker.sh' '${FILENAME}'",
    "debug": true,
    "type": "cmd"
  }
}
```

либо так, если надо указать свое имя файлу configuration.toml (по умолчанию подставляется имя configuration.toml)

```json
{
  "epubExport": {
    "active": true,
    "title": "(Kindle)",
    "hint": "Отправить на Kindle",
    "ext": "fb2",
    "cmd": "cp '${HASHFILE}.raw' '${FILENAME}'; sh '${EXTDIR}/worker.sh' '${FILENAME}' 'my_config.toml'",
    "debug": true,
    "type": "cmd"
  }
}
```
