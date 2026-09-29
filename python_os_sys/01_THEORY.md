# Теория без воды

## 1. Модули

Модуль — Python-компонент, который можно импортировать:

```python
import os
import sys
```

`os` в основном даёт интерфейс к ОС, `sys` — к Python-интерпретатору и параметрам процесса.

## 2. Текущий рабочий каталог

```python
import os

print(os.getcwd())
os.chdir("data")
```

Относительный путь считается относительно **текущего рабочего каталога процесса**,
а не автоматически относительно файла `.py`.

## 3. Пути

```python
os.path.join("data", "images", "unit.png")
os.path.exists(path)
os.path.isfile(path)
os.path.isdir(path)
os.path.abspath(path)
os.path.basename(path)
os.path.dirname(path)
os.path.splitext(path)
```

Не склеивай пути вручную через `"/"`.

Современный вариант:

```python
from pathlib import Path

path = Path("data") / "images" / "unit.png"
print(path.exists())
print(path.parent)
print(path.name)
print(path.suffix)
```

## 4. Каталоги

```python
os.listdir(".")
os.mkdir("data")
os.makedirs("data/images/units", exist_ok=True)
os.rmdir("data")
```

`os.rmdir` удаляет только пустой каталог.

## 5. Файлы

```python
os.rename("old.txt", "new.txt")
os.remove("old.txt")
```

Для копирования и более богатых операций обычно нужен `shutil`.

## 6. Рекурсивный обход

```python
for root, dirs, files in os.walk("project"):
    for name in files:
        print(os.path.join(root, name))
```

Модель:

`root` — текущий каталог, `dirs` — подкаталоги, `files` — файлы.

Для большого числа объектов полезен также `os.scandir()`.

## 7. Переменные окружения

```python
token = os.environ.get("API_TOKEN")
mode = os.environ.get("APP_MODE", "development")
```

`os.environ["NAME"]` требует существующий ключ; `get()` может вернуть `None`
или заданное значение по умолчанию.

## 8. `sys.argv`

Аргументы командной строки:

```text
python app.py hello 123
```

```python
import sys
print(sys.argv)
# примерно ["app.py", "hello", "123"]
```

`sys.argv[0]` — имя/путь программы. Пользовательские аргументы начинаются с 1.

Всегда проверяй количество:

```python
if len(sys.argv) < 2:
    print("Usage: python app.py <name>")
    sys.exit(1)
```

## 9. `sys.path`

Это список мест, где Python ищет импортируемые модули.

```python
import sys
print(sys.path)
```

Он объясняет множество `ModuleNotFoundError` и `ImportError`.
Ручное изменение `sys.path` годится для диагностики и отдельных специальных
случаев, но не должно заменять нормальную структуру проекта.

## 10. `sys.exit`

```python
sys.exit(1)
```

Ненулевой код обычно означает ошибку. Это важно для скриптов и CI/CD.

## 11. Внешние процессы

Старый простой подход:

```python
os.system("python other.py")
```

Для современного кода обычно лучше:

```python
import subprocess

result = subprocess.run(
    ["python", "other.py"],
    capture_output=True,
    text=True,
    check=True,
)
print(result.stdout)
```

`subprocess` позволяет нормально передавать аргументы, получать stdout/stderr
и контролировать код завершения.

## Карта выбора

```text
ОС / файловая система -> os
Путь -> os.path или pathlib
Список файлов -> os.listdir / os.scandir
Рекурсивный обход -> os.walk
Переменная окружения -> os.environ
Аргументы CLI -> sys.argv
Поиск импортов -> sys.path
Завершение -> sys.exit
Внешний процесс -> subprocess
```

Если эта карта восстанавливается из памяти — основная теория темы усвоена.