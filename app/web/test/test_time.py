from manage import app
from unittest import TestCase
import datetime
import json


class TimeTestCase(TestCase):

# helper methods

  def time(self):
    return str(datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"))

# setup and teardown

  def setUp(self):
     self.test_app = app.test_client()

  def tearDown(self):
    pass

# tests

  def test_main_page(self):
    response = self.test_app.get('/', follow_redirects=True)
    self.assertEqual(response.status_code, 200)

  def test_health_page(self):
    response = self.test_app.get('/health', follow_redirects=True)
    self.assertEqual(response.status_code, 200)
    data = json.loads(response.get_data(as_text=True))
    self.assertEqual(data['status'], "OK")

  def test_time_page(self):
    response = self.test_app.get('/time', follow_redirects=True)
    self.assertEqual(response.status_code, 200)
    data = json.loads(response.get_data(as_text=True))
    self.assertEqual(data['Current time'], self.time())
