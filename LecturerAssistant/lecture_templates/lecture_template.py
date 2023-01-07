import datetime

from lecture_templates.poll_template import Poll, PollResult


class LectureResult:
    """
    title: str
    lecture_id: str
    themes: list[theme: str]
    timecodes: dict[theme: str] = time_code: datetime.datetime
    polls_results: dict[poll_id: str] = poll_result: PollResult
    """
    __slots__ = ['title',
                 'lecture_id',
                 'themes',
                 'timecodes',
                 'polls_results']

    def __init__(self,
                 title='title',
                 lecture_id=None,
                 themes=None,
                 timecodes=None,
                 polls_results=None):

        self.title = title
        self.lecture_id = lecture_id

        if themes is None:
            self.timecodes = dict()
        else:
            self.themes = themes

        if timecodes is None:
            self.timecodes = dict()
        else:
            self.timecodes = timecodes

        if polls_results is None:
            self.polls_results = dict()
        else:
            self.polls_results = polls_results


class Lecture:
    """
    title: str
    lecture_id: str
    themes: list[theme_0: str ... theme_n: str]
    current_theme: str
    timecodes: dict[theme: str] = time_code: datetime.datetime
    poll_ids: list[poll_id_0: str ... poll_id_n: str]
    polls: dict[poll_id: str]  = poll: Poll
    polls_results: dict[poll_id: str] = poll_result: PollResult
    """
    __slots__ = ['title',
                 'lecture_id',
                 'themes',
                 'current_theme',
                 'timecodes',
                 'poll_ids',
                 'polls',
                 'polls_results',
                 'sent_polls_ids',
                 'polls_available']

    def __init__(self,
                 title='title',
                 themes=None,
                 poll_ids=None,
                 polls=None):

        self.title = title
        self.lecture_id = None

        if themes is None:
            self.themes = list()
        else:
            self.themes = themes

        self.current_theme = ''
        self.timecodes = dict()

        if poll_ids is None:
            self.poll_ids = list()
        else:
            self.poll_ids = poll_ids

        if polls is None:
            self.polls = dict()
            self.polls_available = list()
        else:
            self.polls = polls
            self.polls_available = [True for _ in range(len(polls))]

        self.polls_results = dict()
        self.sent_polls_ids = list()


    def start_lecture(self, lecture_id: str) -> None:

        """
        start lecture from sample
        """
        self.lecture_id = lecture_id
        self.current_theme = 'Start'
        self.timecodes = dict()
        self.timecodes['Start'] = datetime.datetime.now()
        self.polls_results = list()

    def end_lecture(self) -> LectureResult:
        """
        end lecture
        :return: lecture_result: LectureResult
        """

        return LectureResult(title=self.title,
                             lecture_id=self.lecture_id,
                             themes=self.themes,
                             timecodes=self.timecodes,
                             polls_results=self.polls_results)

    def __dict__(self):
        return {
            'title': self.title,
            'lecture_id': self.lecture_id,
            'themes': self.themes,
            'current_theme': self.current_theme,
            'timecodes': self.timecodes,
            'poll_ids': self.poll_ids,
            'polls': [poll.__dict__() for poll in self.polls],
            'polls_results': self.polls_results,
            'sent_polls_ids': self.sent_polls_ids,
            'polls_available': self.polls_available
        }


def lecture_from_dict(lecture_dict: dict) -> Lecture:
    """
    create lecture from dict
    :param
    lecture_dict: dict
    :return: lecture: Lecture
    """

    lecture = Lecture(title=lecture_dict['title'],
                      themes=lecture_dict['themes'],
                      poll_ids=[poll_id for poll_id in lecture_dict['poll_ids']],
                      polls=[Poll(**poll) for poll in lecture_dict['polls']])

    if 'lecture_id' in lecture_dict.keys():
        lecture.lecture_id = lecture_dict['lecture_id']

    if 'current_theme' in lecture_dict.keys():
        lecture.current_theme = lecture_dict['current_theme']

    if 'timecodes' in lecture_dict.keys():
        lecture.timecodes = lecture_dict['timecodes']

    if 'poll_ids' in lecture_dict.keys():
        lecture.poll_ids = lecture_dict['poll_ids']

    if 'polls_results' in lecture_dict.keys():
        lecture.polls_results = lecture_dict['polls_results']

    if 'sent_polls_ids' in lecture_dict.keys():
        lecture.sent_polls_ids = lecture_dict['sent_polls_ids']

    if 'polls_available' in lecture_dict.keys():
        lecture.polls_available = lecture_dict['polls_available']

    return lecture