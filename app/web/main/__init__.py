import logging
from logging.handlers import RotatingFileHandler
from pythonjsonlogger import jsonlogger

log = logging.getLogger('werkzeug')
file_handler = RotatingFileHandler('main.log', 'a', 1 * 1024 * 1024, 10)
file_handler.setFormatter(jsonlogger.JsonFormatter('%(asctime) %(levelname) %(module) %(funcName) %(lineno) %(message)'))
log.setLevel(logging.DEBUG)
log.addHandler(file_handler)
