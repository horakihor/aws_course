import logging
from logging.handlers import RotatingFileHandler

log = logging.getLogger('werkzeug')
file_handler = RotatingFileHandler('main.log', 'a', 1 * 1024 * 1024, 10)
file_handler.setFormatter(logging.Formatter('%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'))
log.setLevel(logging.DEBUG)
log.addHandler(file_handler)
