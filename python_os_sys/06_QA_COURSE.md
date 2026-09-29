# 06 — Q&A для быстрого прохождения курса

> Быстрая шпаргалка по теме курса «Модули Python: os и sys».
> Формат: **вопрос → короткий ответ → минимальный пример**.
>
> Это не дословная выгрузка всех формулировок Stepik; это собранный практический набор ответов по темам курса.

---

## 1. Модули и import

### Что такое модуль?
Модуль — Python-файл с кодом, который можно импортировать в другую программу.

### Как подключить модуль?
```python
import os
```

### Как обратиться к функции модуля?
```python
os.getcwd()
```

### Можно ли импортировать конкретную функцию?
Да:
```python
from os import getcwd
```

### В чём разница между `import os` и `from os import getcwd`?
В первом случае обращаемся как `os.getcwd()`, во втором — напрямую как `getcwd()`.

### Как посмотреть, где находится Python?
```python
import sys
print(sys.executable)
```

---

# 2. Модуль os

### Для чего нужен `os`?
Для взаимодействия Python с операционной системой: файлы, каталоги, пути, переменные окружения и т. д.

### Как узнать текущую рабочую директорию?
```python
import os
print(os.getcwd())
```

### Как сменить текущую директорию?
```python
os.chdir("C:/work")
```

### Что делает `os.listdir()`?
Возвращает содержимое каталога.

```python
os.listdir(".")
```

### Что возвращает `os.listdir()`?
Список имён файлов и каталогов, а не полных путей.

### Как получить содержимое конкретного каталога?
```python
os.listdir("data")
```

### Как проверить существование пути?
```python
os.path.exists("data/file.txt")
```

### Как проверить, что путь является файлом?
```python
os.path.isfile("data/file.txt")
```

### Как проверить, что путь является каталогом?
```python
os.path.isdir("data")
```

---

# 3. Пути

### Почему лучше не склеивать пути через `+`?
Потому что разделитель пути отличается между ОС.

Плохо:
```python
path = folder + "/" + filename
```

Правильно:
```python
path = os.path.join(folder, filename)
```

### Как объединить части пути?
```python
os.path.join("data", "images", "test.png")
```

### Как получить абсолютный путь?
```python
os.path.abspath("test.txt")
```

### Как получить имя файла из пути?
```python
os.path.basename("/home/user/test.txt")
# test.txt
```

### Как получить каталог из пути?
```python
os.path.dirname("/home/user/test.txt")
# /home/user
```

### Как разделить имя файла и расширение?
```python
os.path.splitext("image.png")
# ("image", ".png")
```

### Что такое расширение файла?
Последняя часть имени после точки, например `.txt`, `.png`, `.py`.

---

# 4. Создание и удаление

### Как создать каталог?
```python
os.mkdir("data")
```

### Как создать вложенные каталоги?
```python
os.makedirs("data/images/cache")
```

### Что делать, если каталог уже может существовать?
```python
os.makedirs("data", exist_ok=True)
```

### Как переименовать файл или каталог?
```python
os.rename("old.txt", "new.txt")
```

### Как удалить файл?
```python
os.remove("test.txt")
```

### Как удалить пустой каталог?
```python
os.rmdir("empty_folder")
```

### Можно ли `os.rmdir()` удалить каталог с файлами?
Нет. Каталог должен быть пустым.

---

# 5. Рекурсивный обход

### Как пройти по всем файлам и каталогам внутри дерева?
```python
for root, dirs, files in os.walk("."):
    print(root)
    print(dirs)
    print(files)
```

### Что такое `root` в `os.walk()`?
Текущий каталог.

### Что такое `dirs`?
Список каталогов внутри текущего `root`.

### Что такое `files`?
Список файлов внутри текущего `root`.

### Как найти все PNG?
```python
for root, dirs, files in os.walk("."):
    for name in files:
        if name.lower().endswith(".png"):
            print(os.path.join(root, name))
```

### Почему нужен `os.path.join(root, name)`?
Потому что `name` — только имя файла, а `root` — его каталог.

---

# 6. os.scandir

### Для чего нужен `os.scandir()`?
Для более удобного обхода каталога с объектами `DirEntry`, содержащими информацию о файлах.

```python
for entry in os.scandir("."):
    print(entry.name, entry.is_file(), entry.is_dir())
```

### Чем `scandir()` отличается от `listdir()`?
`listdir()` даёт имена, а `scandir()` — объекты с дополнительной информацией о каждом элементе.

---

# 7. Информация о файлах

### Как получить информацию о файле?
```python
info = os.stat("test.txt")
print(info.st_size)
```

### Как узнать размер файла?
```python
os.path.getsize("test.txt")
```

### В каких единицах размер файла?
В байтах.

### Как найти самый большой файл?
Сравнивать размеры через `os.path.getsize()`.

```python
largest = None

for root, dirs, files in os.walk("."):
    for name in files:
        path = os.path.join(root, name)
        size = os.path.getsize(path)

        if largest is None or size > largest[1]:
            largest = (path, size)

print(largest)
```

---

# 8. Переменные окружения

### Что такое переменная окружения?
Значение, переданное операционной системой процессу программы.

### Как получить переменную окружения?
```python
os.environ.get("PATH")
```

### Как обратиться к переменной напрямую?
```python
os.environ["PATH"]
```

### В чём разница между `get()` и `[]`?
`get()` может вернуть `None`, если переменной нет.
`[]` вызовет `KeyError`, если переменной нет.

### Как установить переменную для текущего процесса?
```python
os.environ["MY_VAR"] = "123"
```

---

# 9. Модуль sys

### Для чего нужен `sys`?
Для доступа к параметрам и состоянию самого Python-интерпретатора и текущего процесса.

### Как получить аргументы командной строки?
```python
import sys
print(sys.argv)
```

### Что находится в `sys.argv[0]`?
Имя или путь запущенного Python-скрипта.

### Что такое `sys.argv[1]`?
Первый аргумент, переданный программе после имени скрипта.

Пример:
```text
python app.py test.txt
```

Тогда:
```python
sys.argv[0]  # app.py
sys.argv[1]  # test.txt
```

### Как проверить количество аргументов?
```python
len(sys.argv)
```

### Как корректно завершить программу?
```python
sys.exit()
```

### Как завершить программу с кодом ошибки?
```python
sys.exit(1)
```

---

# 10. sys.path

### Что такое `sys.path`?
Список каталогов, в которых Python ищет импортируемые модули.

### Как посмотреть пути поиска?
```python
import sys
print(sys.path)
```

### Почему возникает `ModuleNotFoundError`?
Python не смог найти модуль в доступных путях импорта.

### Можно ли добавить каталог в `sys.path`?
Да:
```python
sys.path.append("/my/modules")
```

---

# 11. sys.executable

### Что делает `sys.executable`?
Показывает путь к исполняемому файлу Python, которым запущена программа.

```python
print(sys.executable)
```

### Зачем это полезно?
Чтобы понять, какой именно Python/виртуальное окружение запускает программу.

---

# 12. Частые ошибки

### Что означает `FileNotFoundError`?
Программа не нашла указанный файл или каталог.

Проверить:
```python
print(os.path.abspath(path))
print(os.path.exists(path))
```

### Что означает `NotADirectoryError`?
Программа ожидала каталог, но по указанному пути находится не каталог.

### Что означает `IsADirectoryError`?
Программа ожидала файл, но по пути находится каталог.

### Что означает `PermissionError`?
Операционная система запретила операцию из-за прав доступа.

### Что означает `ModuleNotFoundError`?
Python не нашёл импортируемый модуль.

### Что делать при проблемах с относительным путём?
Сначала вывести:
```python
print(os.getcwd())
print(os.path.abspath(path))
```

---

# 13. Минимальные задачи, которые надо уметь решать

### Вывести текущую папку
```python
import os
print(os.getcwd())
```

### Вывести файлы текущей папки
```python
for name in os.listdir("."):
    print(name)
```

### Вывести только файлы
```python
for name in os.listdir("."):
    if os.path.isfile(name):
        print(name)
```

### Вывести только каталоги
```python
for name in os.listdir("."):
    if os.path.isdir(name):
        print(name)
```

### Найти все TXT рекурсивно
```python
for root, dirs, files in os.walk("."):
    for name in files:
        if name.lower().endswith(".txt"):
            print(os.path.join(root, name))
```

### Посчитать все файлы
```python
count = 0

for root, dirs, files in os.walk("."):
    count += len(files)

print(count)
```

### Получить аргумент командной строки
```python
import sys

if len(sys.argv) > 1:
    print(sys.argv[1])
```

### Получить переменную окружения
```python
import os
print(os.environ.get("PATH"))
```

---

# 14. Что выучить в первую очередь

Если времени мало, порядок такой:

1. `import`
2. `os.getcwd()`
3. `os.listdir()`
4. `os.path.join()`
5. `os.path.exists()`
6. `os.path.isfile()`
7. `os.path.isdir()`
8. `os.path.basename()`
9. `os.path.dirname()`
10. `os.path.splitext()`
11. `os.makedirs()`
12. `os.rename()`
13. `os.remove()`
14. `os.walk()`
15. `os.environ`
16. `sys.argv`
17. `sys.path`
18. `sys.executable`
19. `sys.exit()`

После этого уже имеет смысл разбирать `scandir`, `stat`, процессы и платформенные детали.

---

# 15. Сверхкороткая шпаргалка

```python
import os
import sys

os.getcwd()                 # текущая директория
os.chdir(path)              # сменить директорию
os.listdir(path)            # содержимое
os.path.join(a, b)          # объединить путь
os.path.exists(path)        # существует?
os.path.isfile(path)        # файл?
os.path.isdir(path)         # каталог?
os.path.abspath(path)       # абсолютный путь
os.path.basename(path)      # имя
os.path.dirname(path)       # каталог
os.path.splitext(path)      # имя + расширение
os.makedirs(path)           # создать каталоги
os.rename(a, b)             # переименовать/переместить
os.remove(path)             # удалить файл
os.rmdir(path)              # удалить пустой каталог
os.walk(path)               # рекурсивный обход
os.scandir(path)            # обход с DirEntry
os.stat(path)               # информация о файле
os.environ.get("NAME")      # переменная окружения

sys.argv                    # аргументы запуска
sys.path                    # пути импорта
sys.executable              # используемый Python
sys.exit()                  # завершить программу
```

## Главный принцип

Не надо зубрить `os` целиком.

Нужно понимать:

**ОС → путь → файл/каталог → проверка → действие → результат.**

А для `sys`:

**Python-процесс → аргументы → окружение интерпретатора → импорт → завершение.**
