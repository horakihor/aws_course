from flask import Blueprint, url_for
from flask import render_template
from flask import jsonify, request
from web.main.model import Visits
from web.main.model import db
from web.main import log
import socket
import datetime


api = Blueprint('api', __name__)

@api.route('/')
def index():
    hostname = socket.gethostname()
    db_status = Visits.check_db_status()
    visits = Visits.get_visitors()
    return render_template('index.html', hostname=hostname, db_status=db_status, visits=visits)

@api.route("/init")
def init():
    db.create_all()
    first = Visits(0)
    db.session.add(first)
    db.session.commit()
    return 'OK'

@api.route('/time')
def time():
    time = {'Current time' : str(datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")) }
    return jsonify(time), 200

@api.route('/health')
def health():
    status = {'status' : 'OK'}
    return jsonify(status), 200
