from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_migrate import Migrate
import os
import threading

app = Flask(__name__)

basedir = os.path.abspath(os.path.dirname(__file__))

app.config['SECRET_KEY'] = '123-456-789'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'
app.config['SQLALCHEMY_DATABASE_URI'] = \
    'sqlite:///' + os.path.join(basedir, 'database.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
migrate = Migrate(app, db)

login_manager = LoginManager()
login_manager.login_view = 'auth.login'
login_manager.init_app(app)


from models import User
@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))


from auth import auth as auth_blueprint
app.register_blueprint(auth_blueprint)


from main import main as main_blueprint
app.register_blueprint(main_blueprint)


from user_in import user_in as user_in_blueprint
app.register_blueprint(user_in_blueprint)