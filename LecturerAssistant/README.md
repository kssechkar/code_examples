# Lecturer Assistant

Утилита (сайт и телеграм бот) для продуктивного взаимодействия преподавателя с аудиторией во время занятия. 

Итоговый проект для курса "Углубленный Python" ПМИ ФКН НИУ ВШЭ, 2022. 

Авторы: [Пеньков Алексей](https://github.com/vvauijij), [Сечкарь Константин](https://github.com/kssechkar), [Оникова Даша](https://github.com/myramystin). 

[Презентация](https://github.com/vvauijij/LecturerAssistant/blob/develop/Lecturer%20Assistant.pdf)

[Шаблоны опросов](https://github.com/vvauijij/LecturerAssistant/tree/develop/csv_templates)


## Usage

### The utility is hosted on the YandexСloud and has a public IP address 

Since Yandex Cloud services are paid, ask [@vvauijij](https://t.me/vvauijij) to deploy server


### The image is available on [DockerHub](https://hub.docker.com/r/vvauijij/lecturerassistant/tags) for both ARM64 and AMD64 architectures


## Local usage

### Prepare virlual env

```
pipenv shell 
```

### Install packages

```
pipenv install -r requirements.txt 
```


### Flask settings

``` 
export FLASK_APP=app

export FLASK_DEBUG=1
```

### Database settings

```
flask shell

from app import db

import models

db.create_all()

exit()
```

### Bot settings (unique telegram bot token is required)

```
echo TELEGRAM_BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN > .env
```

### Launching

```
pipenv run python exe.py
```
