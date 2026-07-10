#!/bin/bash

# Скрипт для конвертирования и отправки на email FB2-файлов с помощью программ fb2cng и sync2kindle
# Использование: ./worker.sh <filefolder/filename.fb2> [s2km-config.yaml] [fbc-config.yaml]

if [ $# -lt 1 ]; then
    echo "Usage: $0 <filefolder/filename.fb2> [s2km-config.yaml] [fbc-config.yaml]"
    exit 1
fi

# Определение базовой директории скрипта
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Входные параметры файла
FULL_PATH="$1"
INPUT_FOLDER="$(dirname "$FULL_PATH")"

# Проверка существования исходного файла
if [ ! -f "$FULL_PATH" ]; then
    echo "Error: File not found - $FULL_PATH"
    exit 1
fi

# Переменные конфигураций (S2KM & FBC)
S2KM_CONFIG="${2:-s2km-config.yaml}"
FBC_CONFIG="${3:-fbc-config.yaml}"

# Относительные пути к папкам приложений
FBC_DIR="${SCRIPT_DIR}/app-fb2cng"
S2KM_DIR="${SCRIPT_DIR}/app-sync2kindle"
EXPORT_DIR="${SCRIPT_DIR}/app-export"
LOG_DIR="${SCRIPT_DIR}/log"

# Создание папок экспорта и логов
mkdir -p "$EXPORT_DIR"
mkdir -p "$LOG_DIR"

# Очистка временных файлов перед стартом
rm -rf "${EXPORT_DIR:?}/"* 2>/dev/null || true
rm -rf "${LOG_DIR:?}/"* 2>/dev/null || true

# Запуск конвертации fb2 -> epub3 в папку app-export через fb2cng
"$FBC_DIR/fbc" -c "$FBC_DIR/$FBC_CONFIG" convert --to epub3 "$FULL_PATH" "$EXPORT_DIR"

# Запуск отправки книг из папки app-export на Kindle через sync2kindle
"$S2KM_DIR/s2km" -c "$S2KM_DIR/$S2KM_CONFIG" mail

# Перемещение всех .log файлов
find "$FBC_DIR" "$S2KM_DIR" "$INPUT_FOLDER" -maxdepth 1 -name "*.log" -type f -exec mv -f {} "$LOG_DIR/" \; 2>/dev/null

# Очистка временных файлов
rm -rf "${INPUT_FOLDER:?}/"* 2>/dev/null || true
rm -rf "${EXPORT_DIR:?}/"* 2>/dev/null || true
