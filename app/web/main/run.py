from flask import Flask
from web.main.config import config_by_name
from web.main.views import api
from web.main.model import db

def create_app(config_name):
    app = Flask(__name__)
    app.config.from_object(config_by_name[config_name])
    db.init_app(app)
    app.register_blueprint(api, url_prefix='/')
    return app
