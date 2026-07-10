# inpx-web

***Веб-сервер для поиска по .inpx-коллекции книг.***

Более подробно у автора проекта [bookpauk/inpx-web](https://github.com/bookpauk/inpx-web)

Приложение собрано из исходников [makss/inpx-web](https://github.com/makss/inpx-web) forked from [bookpauk/inpx-web](https://github.com/bookpauk/inpx-web)

Данная сборка позволяет подключать внешние программы (конвертеры, читалки, экспорт). [подробнее тут](https://github.com/makss/inpx-web/tree/feature_external?tab=readme-ov-file#%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2%D0%BD%D0%B5%D1%88%D0%BD%D0%B8%D1%85-%D0%BF%D1%80%D0%BE%D0%B3%D1%80%D0%B0%D0%BC%D0%BC-%D0%BA%D0%BE%D0%BD%D0%B2%D0%B5%D1%80%D1%82%D0%B5%D1%80%D1%8B-%D1%87%D0%B8%D1%82%D0%B0%D0%BB%D0%BA%D0%B8-%D1%8D%D0%BA%D1%81%D0%BF%D0%BE%D1%80%D1%82)

#### 📦 Используемые утилиты:

- 📖 **[fb2cng (fbc)](https://github.com/rupor-github/fb2cng)** — конвертация FB2 в EPUB3
- ✉️ **[sync2kindle (s2k)](https://github.com/rupor-github/sync2kindle)** — отправка книг на Kindle по email


## 🐳 Запуск с помощью Docker Compose
( пример [docker-compose.yaml](https://github.com/codinv/inpx-web/blob/main/examples/docker-compose.yaml) )

```yaml
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
<span style="color:red">**LIB_DIR**</span> : полный путь к папке с архивами книг внутри контейнера \
> всегда начинается с <span style="color:red">**/library**</span>, так как именно в эту папку монтируется ваша библиотека через `volumes:` \
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


## Скрипт автоматизации:
( [worker.sh](https://github.com/codinv/inpx-web/blob/main/examples/worker.sh) )

### Скрипт выполняет следующие действия:

1. Конвертирует FB2-книгу в EPUB3 с помощью fb2cng

2. Формирует имя файла в формате `Фамилия И. - Название`
   - Автор: фамилия + инициалы (первая буква имени и отчества)
   - Разделитель: ` - `
   - Название очищается от символов: `/\:*?<>"` и кавычек `«»“”„`
   - Удаляются квадратные скобки `[...]` и лишние пробелы

3. Формирует внутренний заголовок книги (метаданные) в формате `XX. Название`
   - Если у книги есть серия с номером — добавляется префикс `XX.` 
   - Если серий несколько — берётся первая, у которой есть номер
   - Если номера нет — префикс не добавляется
   - Название очищается от кавычек, скобок и лишних пробелов

4. Сохраняет готовый EPUB-файл в папку `/app-export`

5. Отправляет на почту Kindle готовый EPUB-файл с помощью sync2kindle

6. Очищает временные папки


---

### Пример настроек для конвертирования в epub3<br>с помощью приложения fb2cng [fbc-config.yaml](https://github.com/codinv/inpx-web/blob/main/examples/fbc-config.yaml)

### Пример настроек для отправки на email Kindle<br>с помощью приложения sync2kindle [s2km-config.yaml](https://github.com/codinv/inpx-web/blob/main/examples/s2km-config.yaml)