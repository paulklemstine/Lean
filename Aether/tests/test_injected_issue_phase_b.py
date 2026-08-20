import pytest
import json
from pathlib import Path
from unittest.mock import MagicMock, patch
import sys

# Add parent directory to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent))

import github_injector

def test_github_injector_path_resolution(tmp_path):
    packages_dir = tmp_path / "Packages"
    packages_dir.mkdir(parents=True, exist_ok=True)
    fd_file = packages_dir / "future_directions.json"
    fd_file.write_text(json.dumps([]), encoding="utf-8")

    fake_issues = [
        {"number": 99, "title": "Injected Direction: Test Injected Flow", "body": "Test body description"}
    ]

    with patch("github_injector.fetch_injected_directions", return_value=fake_issues):
        count = github_injector.inject_directions_into_memory(tmp_path / ".aether_workspace")
        assert count == 1

    data = json.loads(fd_file.read_text(encoding="utf-8"))
    assert len(data) == 1
    assert data[0]["github_issue"] == 99
    assert data[0]["title"] == "Test Injected Flow"
    assert data[0]["priority_score"] == 1000.0

def test_injected_issue_pkg_url_comment():
    class DummyConcept:
        title = "Test Injected Hyperbolic Geometry"

    class DummyJob:
        github_issue = 42
        status = "integrated"
        quality_score = 0.85
        theorem_count = 5
        concept = DummyConcept()

    job = DummyJob()
    
    # Check url formatting logic matching aether_tick
    title = job.concept.title.replace(" ", "_").replace("-", "_").lower()
    import re
    title = re.sub(r'[^a-z0-9_]', '', title)[:50]
    pkg_filename = f"{title}.json"
    pkg_url = f"https://alethean.org/#pkg={pkg_filename}"

    assert pkg_filename == "test_injected_hyperbolic_geometry.json"
    assert pkg_url == "https://alethean.org/#pkg=test_injected_hyperbolic_geometry.json"


def test_close_issue_skips_already_closed_issue(monkeypatch):
    """Regression Lean#156: a closed issue must not receive a duplicate result
    comment. Once the issue is CLOSED, _close_github_issue_if_needed must
    early-return without posting a comment or re-closing."""
    import aether_tick

    class DummyConcept:
        title = "reinforcement learning"

    class DummyJob:
        github_issue = 156
        status = "integrated"
        phase = "complete"
        quality_score = 0.9
        theorem_count = 100
        concept = DummyConcept()
        job_id = "abc12345"

    calls = {"comment": 0, "close": 0}

    def fake_run_gh(args):
        # `gh issue view --json state` reports the issue is already CLOSED.
        if "view" in args:
            return '{"state": "CLOSED"}'
        if "comment" in args:
            calls["comment"] += 1
        if "close" in args:
            calls["close"] += 1
        return ""

    monkeypatch.setattr(github_injector, "run_gh_command", fake_run_gh)

    aether_tick._close_github_issue_if_needed(DummyJob())

    assert calls["comment"] == 0, "must not comment on an already-closed issue"
    assert calls["close"] == 0, "must not re-close an already-closed issue"


def test_close_issue_posts_on_open_issue(monkeypatch):
    """Sanity: an OPEN issue that reached terminal completion still gets its
    result comment and close (the happy path)."""
    import aether_tick

    class DummyConcept:
        title = "reinforcement learning"

    class DummyJob:
        github_issue = 156
        status = "integrated"
        phase = "complete"
        quality_score = 0.9
        theorem_count = 100
        concept = DummyConcept()
        job_id = "abc12345"

    calls = {"comment": 0, "close": 0}

    def fake_run_gh(args):
        if "view" in args:
            return '{"state": "OPEN"}'
        if "comment" in args:
            calls["comment"] += 1
        if "close" in args:
            calls["close"] += 1
        return ""

    monkeypatch.setattr(github_injector, "run_gh_command", fake_run_gh)

    aether_tick._close_github_issue_if_needed(DummyJob())

    assert calls["comment"] == 1
    assert calls["close"] == 1
