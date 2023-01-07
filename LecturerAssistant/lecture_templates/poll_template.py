import json


class PollResult:
    """
    question: str

    votes: dict[option: str] = voter_count: int

    poll_type: str

    correct_option_id: int
    """
    __slots__ = ['question',
                 'votes',
                 'poll_type',
                 'correct_option_id']

    def __init__(self,
                 question='question?',
                 votes=None,
                 poll_type='regular',
                 correct_option_id=0):

        self.question = question

        if votes is None:
            self.votes = dict()
        else:
            self.votes = votes

        self.poll_type = poll_type
        self.correct_option_id = correct_option_id


class Poll:
    """
    question: str

    options: list[option_0: str ... option_n: str]

    poll_type: str

    correct_option_id: int

    explanation: str

    is_closed: bool

    is_anonymous:bool
    """
    __slots__ = ['question',
                 'options',
                 'poll_type',
                 'correct_option_id',
                 'explanation',
                 'is_closed',
                 'is_anonymous']

    def __init__(self,
                 question='question?',
                 options=None,
                 poll_type='regular',
                 correct_option_id=0,
                 explanation='explanation',
                 is_closed=False,
                 is_anonymous=False):

        self.question = question

        if options is None:
            self.options = ['option_0', 'option_1']
        elif type(options) == str:
            self.options = json.loads(options)
        else:
            self.options = options

        self.poll_type = poll_type
        self.correct_option_id = correct_option_id
        self.explanation = explanation
        self.is_closed = is_closed
        self.is_anonymous = is_anonymous

    def __dict__(self):
        return {
            'question': self.question,
            'options': self.options,
            'poll_type': self.poll_type,
            'correct_option_id': self.correct_option_id,
            'explanation': self.explanation,
            'is_closed': self.is_closed,
            'is_anonymous': self.is_anonymous
        }


def poll_from_dict(poll_dict: dict) -> Poll:
    """
    create lecture from dict

    :param
    lecture_dict: dict
    :return: lecture: Lecture
    """

    poll = Poll(question=poll_dict['question'],
                options=poll_dict['options'],
                poll_type=poll_dict['poll_type'])

    if 'correct_option_id' in poll_dict.keys():
        poll.correct_option_id = poll_dict['correct_option_id']

    if 'explanation' in poll_dict.keys():
        poll.explanation = poll_dict['explanation']

    if 'is_closed' in poll_dict.keys():
        poll.is_closed = poll_dict['is_closed']

    if 'is_anonymous' in poll_dict.keys():
        poll.is_anonymous = poll_dict['is_anonymous']

    return poll
