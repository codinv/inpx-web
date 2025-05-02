#!/bin/bash

# Скрипт для переименования FB2-файлов на основе метаданных
# Использование: ./worker.sh <filefolder/filename.fb2> [configuration.toml]

if [ $# -lt 1 ]; then
    echo "Usage: $0 <filefolder/filename.fb2> [configuration.toml]"
    exit 1
fi

SCRIPT_DIR="$(dirname "$0")"
FULL_PATH="$1"
INPUT_FOLDER="$(dirname "$FULL_PATH")"
INPUT_FILE="$(basename "$FULL_PATH")"
TOML_FILE="${2:-configuration.toml}"

# Проверяем существование файла
if [ ! -f "$FULL_PATH" ]; then
    echo "Error: File not found - $FULL_PATH"
    exit 1
fi

# Извлекаем новое имя из метаданных FB2 (из title-info)
NEW_NAME=$(sed -n '/<title-info>/,/<\/title-info>/ {
    s/.*<sequence.*number="\([0-9]\{1,\}\)".*/\1/p
    s/.*<book-title>\(.*\)<\/book-title>.*/\1/p
}' "$FULL_PATH" | awk '
    /^[0-9]+$/ { num=$0; next }
    { 
        sub(/ *\[.*$/, "", $0)
        gsub(/[\/:*?"<>|]/, "_", $0)
        gsub(/^ +| +$/, "", $0)
        gsub(/  +/, " ", $0)
        title=$0 
    }
    END {
        if (num != "" && num != "0") 
            printf "%02d %s", num, title 
        else 
            printf "%s", title 
    }
')

# Определяем конечное имя файла
if [ -z "$NEW_NAME" ]; then
    # Если не удалось извлечь метаданные
    DEST_FILE="${FULL_PATH%.*}.fb2"
else
    # Если метаданные найдены
    DEST_FILE="${INPUT_FOLDER}/${NEW_NAME}.fb2"
fi

# Переименовываем файл
echo "Processing: $INPUT_FILE -> $(basename "$DEST_FILE")"
mv -v "$FULL_PATH" "$DEST_FILE"

# Проверяем результат
if [ $? -eq 0 ]; then
    echo "Successfully created: $DEST_FILE"
else
    echo "Error: Failed to create $DEST_FILE"
    exit 1
fi

# Запускаем конвертацию в epub 
"${SCRIPT_DIR}/app-fb2c/fb2c" -c "${SCRIPT_DIR}/app-fb2c/${TOML_FILE}" convert --to epub --ow --stk --nodirs "${DEST_FILE}" "${SCRIPT_DIR}/app-export"

# Перемещаем log файл в папку ./log
mv -f "${INPUT_FOLDER}/conversion.log" "${SCRIPT_DIR}/log/"

# Очищаем папку с временными файлами
rm -f "${INPUT_FOLDER}/"*
