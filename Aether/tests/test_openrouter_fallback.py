from unittest.mock import patch
from pi_agent_client import PiAgentClient


def _make_client():
    client = PiAgentClient(
        use_ollama=False,
        ollama_cloud={"enabled": True, "api_key_env": "X"},
        openrouter={"enabled": True, "api_key_env": "Y"},
    )
    client.ollama_cloud_api_key = "dummy_oc_key"
    client.openrouter_api_key = "dummy_or_key"
    return client


def test_no_fallback_if_ollama_cloud_succeeds():
    client = _make_client()
    with patch.object(client, "_call_ollama_cloud", return_value="Ollama Cloud success") as mock_cloud, \
         patch.object(client, "_call_openrouter") as mock_router:
        result = client._call_ollama("system prompt", "user prompt")
        assert result == "Ollama Cloud success"
        mock_cloud.assert_called_once_with("system prompt", "user prompt", timeout=None)
        mock_router.assert_not_called()


def test_fallback_to_openrouter_if_cloud_fails():
    client = _make_client()
    with patch.object(client, "_call_ollama_cloud", return_value="[OLLAMA_CLOUD_ERROR: limit exceeded]") as mock_cloud, \
         patch.object(client, "_call_openrouter", return_value="OpenRouter success") as mock_router:
        result = client._call_ollama("system prompt", "user prompt")
        assert result == "OpenRouter success"
        mock_cloud.assert_called_once_with("system prompt", "user prompt", timeout=None)
        mock_router.assert_called_once_with("system prompt", "user prompt", timeout=None)


def test_all_tiers_fail_returns_error():
    client = _make_client()
    with patch.object(client, "_call_ollama_cloud", return_value="[OLLAMA_CLOUD_ERROR: limit exceeded]") as mock_cloud, \
         patch.object(client, "_call_openrouter", return_value="[OPENROUTER_ERROR: fail]") as mock_router:
        result = client._call_ollama("system prompt", "user prompt")
        assert result == "[API_ERROR] All API tiers failed (Ollama Cloud and OpenRouter exhausted/disabled)."
        mock_cloud.assert_called_once()
        mock_router.assert_called_once()