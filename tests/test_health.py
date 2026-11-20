import os,unittest
from unittest.mock import patch
from pymongo.errors import OperationFailure,ServerSelectionTimeoutError
from backend import web

class HealthTests(unittest.TestCase):
 def test_missing_configuration_is_explicit(self):
  with patch.dict(os.environ,{'MONGODB_URI':''}):
   r=web.app.test_client().get('/health')
   self.assertEqual(r.status_code,503)
   self.assertEqual(r.json['reason'],'missing_configuration')
 def test_failure_categories_do_not_reveal_credentials(self):
  for error,reason in [(OperationFailure('secret-password',18),'authentication'),(OperationFailure('secret-password',13),'database_permission'),(ServerSelectionTimeoutError('secret-password'),'network_or_dns')]:
   with patch.dict(os.environ,{'MONGODB_URI':'mongodb://private.example'}),patch.object(web,'client') as client:
    client.admin.command.side_effect=error
    r=web.app.test_client().get('/health')
    self.assertEqual(r.status_code,503)
    self.assertEqual(r.json['reason'],reason)
    self.assertNotIn(b'secret-password',r.data)
