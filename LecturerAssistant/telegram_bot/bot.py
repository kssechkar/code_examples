from collections import defaultdict
from typing import Union
import telebot
from telebot import types
from lecture_templates.poll_template import Poll


def get_message_text(message: types.Message) -> str:
    text = message.json['text']
    return text[text.rfind(' ') + 1:]


class LecturerAssistantBot:
    __slots__ = ['_bot',
                 '_rooms',
                 '_users',
                 '_polls',
                 '_feedback']

    def __init__(self, bot: telebot.TeleBot) -> None:
        """
        initializing bot
        """
        self._bot = bot
        self._rooms = defaultdict(set)  # room_code - (chat_id1 ... chat_id2)
        self._users = defaultdict(str)  # chat_id - room_code

        self._polls = defaultdict(list)  # poll_id - (chat_id, poll_message_id)
        # room_code - [feedback1 ... feedback2]
        self._feedback = defaultdict(list)

    def launch(self) -> None:
        """
        launch bot
        """
        self._bot.polling(none_stop=True, interval=0)

    def stop(self) -> None:
        """
        stop bot
        """
        self._bot.stop_polling()

    def create_room(self, room_code: str) -> bool:
        """
        create room with given room code

        return True if room was created, False otherwise

        :param room_code: str
        :return: room_created: bool
        """
        if room_code not in self._rooms.keys():
            self._rooms[room_code] = set()
            self._feedback[room_code] = list()
            return True
        else:
            return False

    def delete_room(self, room_code: str) -> bool:
        """
        delete room with given room code

        return True if room was deleted, False otherwise

        :param room_code: str
        :return: room_deleted: bool
        """
        if room_code in self._rooms.keys():
            for [chat_id, user_room_code] in self._users:
                if user_room_code == room_code:
                    self._users.pop(chat_id)
            self._rooms.pop(room_code)
            self._feedback.pop(room_code)
            return True
        else:
            return False

    def join(self, message: types.Message) -> bool:
        """
        BOT USER ONLY: for user to join room
        """
        room_code = get_message_text(message)
        if room_code in self._rooms.keys():
            self._rooms[room_code].add(message.chat.id)
            self._users[message.chat.id] = room_code
            return True
        else:
            return False

    def leave(self, message: types.Message) -> bool:
        """
        BOT USER ONLY: for user to leave room
        """
        chat_id = message.chat.id
        if chat_id in self._users.keys():
            self._rooms[self._users[chat_id]].remove(chat_id)
            self._users.pop(chat_id)
            return True
        else:
            return False

    def feedback(self, message: types.Message) -> bool:
        """
        BOT USER ONLY: for user to send feedback
        """
        chat_id = message.chat.id
        if chat_id in self._users.keys():
            self._feedback[self._users[chat_id]].append(
                get_message_text(message))
            return True
        else:
            return False

    def send_poll(self, room_code: str, poll_id: str, poll: Poll) -> bool:
        """
        create Poll from dict and send poll to room with given room code

        return True if poll was sent, False otherwise

        :param room_code: str
        :param poll_id: str
        :param poll: Poll
        :return: poll_created: bool
        """

        if room_code in self._rooms.keys():
            for chat_id in self._rooms[room_code]:
                try:
                    self._polls[poll_id].append((chat_id, self._bot.send_poll(chat_id,
                                                                              question=poll.question,
                                                                              options=poll.options,
                                                                              type=poll.poll_type,
                                                                              correct_option_id=poll.correct_option_id,
                                                                              explanation=poll.explanation,
                                                                              is_closed=poll.is_closed,
                                                                              is_anonymous=poll.is_anonymous).id))
                except Exception:
                    return False
            return True
        else:
            return False

    def get_poll_result(self, room_code: str, poll_id: str) -> Union[dict, None]:
        """
        return dict of poll results from room with given room code

        dict['no_vote'] stores amount of those who did not vote

        return None, if room code is invalid

        :param room_code: str
        :param poll_id: str
        :return: feedback: list[str] or None
        """
        poll_results = defaultdict(int)
        if room_code in self._rooms.keys() and poll_id in self._polls.keys():
            voters_amount = len(self._rooms[room_code])
            for [chat_id, poll_message_id] in self._polls[poll_id]:
                try:
                    options = self._bot.stop_poll(chat_id, poll_message_id).options
                    for option in options:
                        poll_results[option.text] += option.voter_count
                        voters_amount -= option.voter_count
                except Exception:
                    continue
            poll_results['no_vote'] = voters_amount
            self._polls.pop(poll_id)
            return poll_results
        else:
            return None

    def get_chat_feedback(self, room_code: str) -> Union[list, None]:
        """
        return list of feedback-messages from room with given room code

        return None, if room code is invalid

        :param room_code: str
        :return: feedback: list[str] or None
        """
        if room_code in self._feedback.keys():
            return self._feedback[room_code]
        else:
            return None
