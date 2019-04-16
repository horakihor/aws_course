from flask_sqlalchemy import SQLAlchemy
import psycopg2
from web.main import log

db = SQLAlchemy()

class Visits(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    visits = db.Column(db.Integer)

    def __init__(self, visits):
        self.visits = visits

    def __repr__(self):
        return '<Id: {}: visits:{}>'.format(self.id, str(self.visits))

    @staticmethod
    def check_db_status():
        try:
            if db.session.query("1").all():
                db_status = True
        except Exception as ex:
                db_status = False
                log.error(ex)
        return db_status

    @staticmethod
    def get_visitors():
        try:
            v = Visits.query.filter_by(id=1).first()
            v.visits += 1
            db.session.add(v)
            db.session.commit()
            visits = v.visits
        except Exception as ex:
            visits = 0
            log.error(ex)
        return visits
