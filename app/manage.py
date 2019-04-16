import os
import unittest
from flask_migrate import Migrate, MigrateCommand
from flask_script import Manager
from web.main.run import create_app
from web.main.config import Config
from web.main.model import db

app = create_app(os.getenv('ENVIRONMENT') or 'dev')

app.app_context().push()

migrate = Migrate(app, db)
manager = Manager(app)

manager.add_command('db', MigrateCommand)

@manager.command
def run():
    app.run(host=Config.HOST,port=Config.PORT)

@manager.command
def test():
    """Runs the unit tests."""
    tests = unittest.TestLoader().discover('web/test', pattern='test*.py')
    result = unittest.TextTestRunner(verbosity=2).run(tests)
    if result.wasSuccessful():
        return 0
    return 1

if __name__ == '__main__':
    manager.run()
