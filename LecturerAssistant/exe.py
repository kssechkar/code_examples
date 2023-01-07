from telegram_bot import lecturer_assistant_bot
import app
import threading

if __name__ == "__main__":
    threading.Thread(target=lambda: lecturer_assistant_bot.launch()).start()
    app.app.run(host="0.0.0.0", port=80)
