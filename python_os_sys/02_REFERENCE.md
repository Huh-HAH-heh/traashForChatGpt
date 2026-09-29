# Быстрый справочник `os` / `sys`

## Импорт

```python
import os
import sys
```

## Рабочий каталог

`os.getcwd()` — получить текущий каталог.

`os.chdir(path)` — сменить каталог.

## Файлы и каталоги

`os.listdir(path)` — содержимое каталога.

`os.mkdir(path)` — создать один каталог.

`os.makedirs(path, exist_ok=True)` — создать дерево каталогов.

`os.rmdir(path)` — удалить пустой каталог.

`os.remove(path)` — удалить файл.

`os.rename(src, dst)` — переименовать/переместить.

`os.walk(path)` — рекурсивный обход.

`os.scandir(path)` — получить `DirEntry` с информацией об объектах.

## `os.path`

```python
os.path.join("data", "file.txt")
os.path.exists(path)
os.path.isfile(path)
os.path.isdir(path)
os.path.abspath(path)
os.path.basename(path)
os.path.dirname(path)
os.path.splitext(path)
```

Запоминание:

`join` — собрать путь; `exists` — существует; `isfile` — файл; `isdir` — каталог;
`abspath` — абсолютный путь; `basename` — последняя часть; `dirname` — родительская часть;
`splitext` — имя + расширение.

## Окружение

```python
os.environ.get("NAME")
os.environ.get("NAME", "default")
os.environ["NAME"] = "value"
```

## `sys`

```python
sys.argv
sys.path
sys.executable
sys.platform
sys.version
sys.exit(1)
```

`argv` — аргументы запуска; `path` — пути поиска модулей;
`executable` — используемый Python; `platform` — платформа;
`version` — версия Python; `exit` — завершение.

## CLI-шаблон

```python
import sys

if len(sys.argv) != 2:
    print("Usage: python app.py <path>")
    sys.exit(2)

path = sys.argv[1]
print(path)
```

## Обход

```python
for root, dirs, files in os.walk("project"):
    for filename in files:
        path = os.path.join(root, filename)
        print(path)
```

Современный аналог:

```python
from pathlib import Path

for path in Path("project").rglob("*"):
    if path.is_file():
        print(path)
```

## Процессы

```python
import subprocess

subprocess.run(["python", "script.py", "arg1"], check=True)
```

С результатом:

```python
result = subprocess.run(
    ["python", "script.py"],
    capture_output=True,
    text=True,
)
print(result.returncode)
print(result.stdout)
print(result.stderr)
```

## Диагностика

`FileNotFoundError`:

```python
print(os.getcwd())
print(os.path.abspath(path))
print(os.path.exists(path))
```

`ModuleNotFoundError`:

```python
print(sys.executable)
print(sys.path)
```

Не передавай непроверенный пользовательский ввод в shell-команды вроде
`os.system("command " + user_input)`. По возможности используй список аргументов
в `subprocess.run()`.