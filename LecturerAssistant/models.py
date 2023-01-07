from flask_login import UserMixin
from app import db


class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(100), unique=True)
    password = db.Column(db.String(100))
    name = db.Column(db.String(1000))


class LectureSample(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))

    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.relationship('User', backref=db.backref('Lectures', lazy=True))


class LectureResult(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    time = db.Column(db.DateTime)

    lecture_sample_id = db.Column(
        db.Integer, db.ForeignKey('lecture_sample.id'))
    lecture_sample = db.relationship(
        'LectureSample', backref=db.backref('LectureResults', lazy=True))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.relationship('User', backref=db.backref('lectures', lazy=True))


class PollSample(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    # name = db.Column(db.String(100))
    # лимит в телеге такой, вынести в файл с константами
    question = db.Column(db.String(255))
    poll_type = db.Column(db.Enum('quiz', 'regular', name='poll_type'))
    correct_answer = db.Column(db.Integer)  # номер правильного ответа
    # лимит в телеге такой, вынести в файл с константами
    hint = db.Column(db.String(255))
    answer_variants = db.Column(db.Text)  # json-ка с вариантами ответов

    lecture_sample_id = db.Column(
        db.Integer, db.ForeignKey('lecture_sample.id'))
    lecture_sample = db.relationship(
        'LectureSample', backref=db.backref('polls', lazy=True))


class ThemeSample(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    themes = db.Column(db.Text)

    lecture_sample_id = db.Column(
        db.Integer, db.ForeignKey('lecture_sample.id'))
    lecture_sample = db.relationship(
        'LectureSample', backref=db.backref('themes', lazy=True))


class PollResult(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    answers = db.Column(db.Text)  # json-ка со статистикой ответов

    poll_sample_id = db.Column(db.Integer, db.ForeignKey('poll_sample.id'))
    poll_sample = db.relationship(
        'PollSample', backref=db.backref('results', lazy=True))

    lecture_result_id = db.Column(
        db.Integer, db.ForeignKey('lecture_result.id'))
    lecture_result = db.relationship(
        'LectureResult', backref=db.backref('polls_results', lazy=True))
