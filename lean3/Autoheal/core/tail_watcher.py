"""
TailWatcher — Real-time log file monitoring
============================================

Embeds a ``tail -f`` style watcher that continuously reads new lines from
the parent application's log file. Handles log rotation, truncation, and
delivers lines to registered callbacks with minimal latency.

Design Principles
-----------------
1. **Non-blocking** — runs in a dedicated daemon thread so the parent app
   is never stalled by monitoring overhead.
2. **Rotation-aware** — detects inode changes and file truncation (logrotate).
3. **Back-pressure** — uses a bounded queue so a slow consumer cannot cause
   unbounded memory growth.
4. **Graceful shutdown** — ``stop()`` drains the queue and joins the thread
   within a configurable timeout.
"""

from __future__ import annotations

import os
import time
import threading
import queue
import logging
from pathlib import Path
from dataclasses import dataclass, field
from typing import Callable, Optional, List

logger = logging.getLogger(__name__)


@dataclass
class LogLine:
    """A single line read from the log file, with metadata."""
    text: str
    line_number: int
    timestamp: float            # time.time() when the line was read
    source_file: str            # absolute path to the log file


class TailWatcher:
    """
    Watches a log file and delivers new lines to registered callbacks.

    Parameters
    ----------
    log_path : str | Path
        Path to the log file to watch.
    poll_interval : float
        Seconds between poll cycles (default 0.25).
    max_queue_size : int
        Bounded queue size for back-pressure (default 10 000).
    """

    def __init__(
        self,
        log_path: str | Path,
        poll_interval: float = 0.25,
        max_queue_size: int = 10_000,
    ) -> None:
        self.log_path = Path(log_path).resolve()
        self.poll_interval = poll_interval

        self._callbacks: List[Callable[[LogLine], None]] = []
        self._queue: queue.Queue[Optional[LogLine]] = queue.Queue(
            maxsize=max_queue_size
        )
        self._stop_event = threading.Event()
        self._reader_thread: Optional[threading.Thread] = None
        self._dispatcher_thread: Optional[threading.Thread] = None
        self._line_counter = 0
        self._last_inode: Optional[int] = None
        self._last_position: int = 0

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def on_line(self, callback: Callable[[LogLine], None]) -> None:
        """Register a callback that receives each new LogLine."""
        self._callbacks.append(callback)

    def start(self) -> None:
        """Begin watching the log file in background threads."""
        if self._reader_thread and self._reader_thread.is_alive():
            logger.warning("TailWatcher is already running.")
            return

        self._stop_event.clear()

        # Ensure log file exists
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        if not self.log_path.exists():
            self.log_path.touch()

        # Seek to end so we only see *new* output
        self._last_position = self.log_path.stat().st_size
        self._last_inode = os.stat(self.log_path).st_ino

        self._reader_thread = threading.Thread(
            target=self._reader_loop, name="autoheal-reader", daemon=True
        )
        self._dispatcher_thread = threading.Thread(
            target=self._dispatcher_loop, name="autoheal-dispatcher", daemon=True
        )
        self._reader_thread.start()
        self._dispatcher_thread.start()
        logger.info("TailWatcher started on %s", self.log_path)

    def stop(self, timeout: float = 5.0) -> None:
        """Signal shutdown and wait for threads to finish."""
        self._stop_event.set()
        # Sentinel to unblock dispatcher
        try:
            self._queue.put_nowait(None)
        except queue.Full:
            pass
        if self._reader_thread:
            self._reader_thread.join(timeout=timeout)
        if self._dispatcher_thread:
            self._dispatcher_thread.join(timeout=timeout)
        logger.info("TailWatcher stopped.")

    @property
    def is_running(self) -> bool:
        return (
            self._reader_thread is not None
            and self._reader_thread.is_alive()
        )

    # ------------------------------------------------------------------
    # Internal loops
    # ------------------------------------------------------------------

    def _reader_loop(self) -> None:
        """Poll the log file for new content and enqueue LogLines."""
        while not self._stop_event.is_set():
            try:
                self._poll_once()
            except Exception:
                logger.exception("Error in reader loop")
            self._stop_event.wait(self.poll_interval)

    def _poll_once(self) -> None:
        if not self.log_path.exists():
            return

        current_inode = os.stat(self.log_path).st_ino
        current_size = self.log_path.stat().st_size

        # Detect log rotation (inode change) or truncation
        if current_inode != self._last_inode or current_size < self._last_position:
            logger.info("Log rotation detected — resetting position.")
            self._last_position = 0
            self._last_inode = current_inode

        if current_size == self._last_position:
            return  # nothing new

        with open(self.log_path, "r", errors="replace") as fh:
            fh.seek(self._last_position)
            new_data = fh.read()
            self._last_position = fh.tell()

        for raw_line in new_data.splitlines():
            self._line_counter += 1
            log_line = LogLine(
                text=raw_line,
                line_number=self._line_counter,
                timestamp=time.time(),
                source_file=str(self.log_path),
            )
            try:
                self._queue.put_nowait(log_line)
            except queue.Full:
                logger.warning("TailWatcher queue full — dropping line %d", self._line_counter)

    def _dispatcher_loop(self) -> None:
        """Drain the queue and invoke registered callbacks."""
        while not self._stop_event.is_set() or not self._queue.empty():
            try:
                item = self._queue.get(timeout=0.5)
            except queue.Empty:
                continue
            if item is None:
                break  # sentinel
            for cb in self._callbacks:
                try:
                    cb(item)
                except Exception:
                    logger.exception("Callback error for line %d", item.line_number)
