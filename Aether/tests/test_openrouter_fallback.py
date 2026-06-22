import pytest
from unittest.mock import MagicMock, patch
import httpx
from pi_agent_client import PiAgentClient


@pytest.fixture(autouse=True)
def _isolate_circuit_breaker(monkeypatch):
    """Force the Pollinations circuit breaker to CLOSED for these fallback-chain
    tests so they are not affected by persisted OPEN state from real daemon usage
    (the breaker skips Pollinations when OPEN, which would break the mock-call
    assertions). Also no-op _save_cb_state so the tests never write to the real
    pollinations_pollen_state.json."""
    monkeypatch.setattr(
        PiAgentClient, "_load_cb_state",
        lambda self: {"state": "CLOSED", "consecutive_402": 0, "opened_at": 0.0},
    )
    monkeypatch.setattr(PiAgentClient, "_save_cb_state", lambda self, updates: None)


def test_no_fallback_if_pollinations_succeeds():
    client = PiAgentClient(
        use_ollama=False,
        openrouter={"enabled": True, "model": "google/gemini-2.5-flash"},
        ollama_cloud={"enabled": True, "model": "gpt-oss:120b-cloud"}
    )
    client.openrouter_api_key = "dummy_or_key"
    client.ollama_cloud_api_key = "dummy_oc_key"

    with patch.object(client, "_call_pollinations", return_value="Pollinations success") as mock_poll, \
         patch.object(client, "_call_ollama_cloud") as mock_cloud, \
         patch.object(client, "_call_openrouter") as mock_router:
        
        result = client._call_ollama("system prompt", "user prompt")
        assert result == "Pollinations success"
        mock_poll.assert_called_once_with("system prompt", "user prompt", timeout=None, skip_wait_on_depletion=True)
        mock_cloud.assert_not_called()
        mock_router.assert_not_called()


def test_fallback_to_ollama_cloud_if_pollinations_fails():
    client = PiAgentClient(
        use_ollama=False,
        openrouter={"enabled": True, "model": "google/gemini-2.5-flash"},
        ollama_cloud={"enabled": True, "model": "gpt-oss:120b-cloud"}
    )
    client.openrouter_api_key = "dummy_or_key"
    client.ollama_cloud_api_key = "dummy_oc_key"

    with patch.object(client, "_call_pollinations", return_value="[API_ERROR: Pollen depleted]") as mock_poll, \
         patch.object(client, "_call_ollama_cloud", return_value="Ollama Cloud success") as mock_cloud, \
         patch.object(client, "_call_openrouter") as mock_router:
        
        result = client._call_ollama("system prompt", "user prompt")
        assert result == "Ollama Cloud success"
        mock_poll.assert_called_once()
        mock_cloud.assert_called_once_with("system prompt", "user prompt", timeout=None)
        mock_router.assert_not_called()


def test_fallback_to_openrouter_if_pollinations_and_cloud_fail():
    client = PiAgentClient(
        use_ollama=False,
        openrouter={"enabled": True, "model": "google/gemini-2.5-flash"},
        ollama_cloud={"enabled": True, "model": "gpt-oss:120b-cloud"}
    )
    client.openrouter_api_key = "dummy_or_key"
    client.ollama_cloud_api_key = "dummy_oc_key"

    with patch.object(client, "_call_pollinations", return_value="[API_ERROR: Pollen depleted]") as mock_poll, \
         patch.object(client, "_call_ollama_cloud", return_value="[OLLAMA_CLOUD_ERROR: limit exceeded]") as mock_cloud, \
         patch.object(client, "_call_openrouter", return_value="OpenRouter success") as mock_router:
        
        result = client._call_ollama("system prompt", "user prompt")
        assert result == "OpenRouter success"
        mock_poll.assert_called_once()
        mock_cloud.assert_called_once()
        mock_router.assert_called_once_with("system prompt", "user prompt", timeout=None)


def test_openrouter_api_call_formatting():
    client = PiAgentClient(
        use_ollama=False,
        openrouter={
            "enabled": True,
            "model": "google/gemini-2.5-flash",
            "base_url": "https://openrouter.ai/api/v1",
            "timeout": 150
        }
    )
    client.openrouter_api_key = "test_api_key"

    mock_response = MagicMock()
    mock_response.json.return_value = {
        "choices": [
            {
                "message": {
                    "content": "Expected response content"
                }
            }
        ]
    }
    mock_response.status_code = 200

    with patch.object(client.client, "post", return_value=mock_response) as mock_post:
        result = client._call_openrouter("sys_msg", "user_msg")
        assert result == "Expected response content"
        
        mock_post.assert_called_once()
        args, kwargs = mock_post.call_args
        assert args[0] == "https://openrouter.ai/api/v1/chat/completions"
        assert kwargs["headers"]["Authorization"] == "Bearer test_api_key"
        assert kwargs["headers"]["HTTP-Referer"] == "https://github.com/paulklemstine/Lean"
        assert kwargs["headers"]["X-Title"] == "Aether Research"
        assert kwargs["json"]["model"] == "google/gemini-2.5-flash"
        assert kwargs["json"]["messages"] == [
            {"role": "system", "content": "sys_msg"},
            {"role": "user", "content": "user_msg"}
        ]
        assert kwargs["timeout"] == 150


def test_openrouter_free_model_fallback_on_429():
    client = PiAgentClient(
        use_ollama=False,
        openrouter={
            "enabled": True,
            "model": "meta-llama/llama-3.3-70b-instruct:free",
            "base_url": "https://openrouter.ai/api/v1",
            "timeout": 120
        }
    )
    client.openrouter_api_key = "test_api_key"

    # Set up mock responses: first one fails with 429, second succeeds
    response_429 = MagicMock(spec=httpx.Response)
    response_429.status_code = 429
    response_429.text = "Rate Limit Exceeded"
    # Make raise_for_status raise an HTTPStatusError for the 429 response
    response_429.raise_for_status.side_effect = httpx.HTTPStatusError(
        message="429 Too Many Requests",
        request=MagicMock(),
        response=response_429
    )

    response_200 = MagicMock(spec=httpx.Response)
    response_200.status_code = 200
    response_200.json.return_value = {
        "choices": [
            {
                "message": {
                    "content": "Succeeded on fallback free router model"
                }
            }
        ]
    }

    with patch.object(client.client, "post", side_effect=[response_429, response_200]) as mock_post:
        result = client._call_openrouter("sys_msg", "user_msg")
        assert result == "Succeeded on fallback free router model"
        
        # Verify that it tried the primary model first and then the fallback
        assert mock_post.call_count == 2
        
        first_call_kwargs = mock_post.call_args_list[0][1]
        assert first_call_kwargs["json"]["model"] == "meta-llama/llama-3.3-70b-instruct:free"
        
        second_call_kwargs = mock_post.call_args_list[1][1]
        assert second_call_kwargs["json"]["model"] == "openrouter/free"

