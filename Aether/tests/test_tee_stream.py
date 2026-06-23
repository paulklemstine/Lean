"""Tests for TeeStream per-line timestamping.

The log file must get a `[YYYY-MM-DD HH:MM:SS]` prefix on every line even when
stdout was already redirected to the same file via shell `>>` (the _is_duplicate
case), which previously skipped timestamping entirely.
"""
import io
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


def _timestamp_re():
    return re.compile(r"^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] ")


def test_teestream_timestamps_when_duplicate(tmp_path):
    """When stdout is already the log file (_is_duplicate), the file still
    receives per-line timestamps."""
    from aether_tick import TeeStream
    file_buf = io.StringIO()
    orig_buf = io.StringIO()
    ts = TeeStream(file_buf, orig_buf, tmp_path / "x.log")
    ts._is_duplicate = True  # simulate shell `>> aether_daemon.log` redirection
    ts.write("[Tick] Sleeping 900s until next tick...\n")
    written = orig_buf.getvalue()
    assert _timestamp_re().match(written), f"Expected timestamped line, got: {written!r}"
    assert "Sleeping 900s until next tick" in written
    # The file handle must NOT also be written (would duplicate).
    assert file_buf.getvalue() == ""


def test_teestream_timestamps_when_not_duplicate(tmp_path):
    """Distinct file + console: file gets timestamps, console gets raw."""
    from aether_tick import TeeStream
    file_buf = io.StringIO()
    orig_buf = io.StringIO()
    ts = TeeStream(file_buf, orig_buf, tmp_path / "x.log")
    ts._is_duplicate = False
    ts.write("[Poll] hello\n")
    assert _timestamp_re().match(file_buf.getvalue()), file_buf.getvalue()
    assert orig_buf.getvalue() == "[Poll] hello\n"  # console raw, no timestamp


def test_teestream_multi_line_all_timestamped(tmp_path):
    """Each line in a multi-line write gets its own timestamp."""
    from aether_tick import TeeStream
    file_buf = io.StringIO()
    orig_buf = io.StringIO()
    ts = TeeStream(file_buf, orig_buf, tmp_path / "x.log")
    ts._is_duplicate = True
    ts.write("line one\nline two\nline three\n")
    out = orig_buf.getvalue()
    for line in out.rstrip("\n").split("\n"):
        assert _timestamp_re().match(line), f"Line missing timestamp: {line!r}"


def test_teestream_strips_ansi_in_file(tmp_path):
    """ANSI color codes are stripped from the file copy."""
    from aether_tick import TeeStream
    file_buf = io.StringIO()
    orig_buf = io.StringIO()
    ts = TeeStream(file_buf, orig_buf, tmp_path / "x.log")
    ts._is_duplicate = True
    ts.write("\033[31mred text\033[0m\n")
    out = orig_buf.getvalue()
    assert "\033" not in out
    assert "red text" in out