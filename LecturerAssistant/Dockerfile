#NOTICE: FOR USING THIS DOCKER FILE YOUR_TELEGRAM_BOT_TOKEN HAVE TO BE FILLED LOCALLY
#NOTICE: FOR USING THIS DOCKER FILE database.db HAVE TO BE CREATED LOCALLY

# start by pulling the python image
FROM python:3.8-slim-buster


# upgrade pip to the latest version
RUN pip install --upgrade pip

# switch working directory
WORKDIR /LecturerAssistant

# copy every content from the local file to the image
COPY . /LecturerAssistant

# install the dependencies and packages in the requirements file
RUN pip install -r requirements.txt --use-deprecated=legacy-resolver

# set port
EXPOSE 80

CMD ["python", "./exe.py"]
