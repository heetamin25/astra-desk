import io, os, unittest, urllib.error
from unittest.mock import patch
from backend import chat

class GeminiRetryTests(unittest.TestCase):
    def failure(self, code):
        return urllib.error.HTTPError('https://provider.invalid',code,'failure',{},io.BytesIO(b'{"error":{"message":"private-provider-body"}}'))

    @patch.dict(os.environ,{'GEMINI_API_KEY':'test-only'})
    def test_transient_failure_recovers_before_response(self):
        with patch.object(chat.urllib.request,'urlopen',side_effect=[self.failure(503),io.BytesIO(b'{"ok":true}')]) as call, patch.object(chat.time,'sleep') as wait:
            self.assertEqual(chat.remote('/models/test:generateContent',{}, {'provider':'gemini'}),{'ok':True})
            self.assertEqual(call.call_count,2);wait.assert_called_once_with(1.0)

    @patch.dict(os.environ,{'GEMINI_API_KEY':'test-only'})
    def test_transient_failure_has_bounded_retries_and_safe_error(self):
        with patch.object(chat.urllib.request,'urlopen',side_effect=[self.failure(503) for _ in range(3)]) as call, patch.object(chat.time,'sleep') as wait:
            with self.assertRaises(chat.ChatError) as result:chat.remote('/models/test:generateContent',{}, {'provider':'gemini'})
            self.assertEqual(call.call_count,3);self.assertEqual([x.args[0] for x in wait.call_args_list],[1.0,2.0])
            self.assertIn('HTTP 503',str(result.exception));self.assertNotIn('private-provider-body',str(result.exception))

    @patch.dict(os.environ,{'GEMINI_API_KEY':'test-only'})
    def test_quota_and_credentials_are_not_retried(self):
        for code in (400,401,403,404,429):
            with self.subTest(code=code),patch.object(chat.urllib.request,'urlopen',side_effect=self.failure(code)) as call,patch.object(chat.time,'sleep') as wait:
                with self.assertRaises(chat.ChatError):chat.remote('/embeddings',{}, {'provider':'gemini'})
                self.assertEqual(call.call_count,1);wait.assert_not_called()
