"""
AutoHeal — A Self-Healing Program Library
==========================================

AutoHeal embeds a tail-watching AI companion into any Python application.
It monitors the parent app's log output in real-time, detects errors and
anomalies, generates source-code patches, recompiles the fixed modules,
and hot-swaps them into the live process — all without restarting.

Architecture
------------
    ┌─────────────┐        ┌──────────────┐
    │  Parent App  │──log──▶│  TailWatcher │
    │  (the head)  │        │  (the tail)  │
    └──────┬──────┘        └──────┬───────┘
           │                      │
           │  hot-swap            │ diagnose
           │◀─────────────────────┤
           │                      │
    ┌──────┴──────┐        ┌──────┴───────┐
    │  ModuleSlot  │◀──────│  CodeSurgeon │
    │  (live code) │ patch │  (AI fixer)  │
    └─────────────┘        └──────────────┘

Quick Start
-----------
    >>> import autoheal
    >>> healer = autoheal.AutoHealer("myapp.log", watch_dir="src/")
    >>> healer.start()          # begins tail-watching in background
    >>> healer.stop()           # graceful shutdown

Components
----------
- ``TailWatcher``   — async file-tail that streams new log lines
- ``Diagnostician`` — pattern-matching + AI classifier for log lines
- ``CodeSurgeon``   — generates minimal source-code patches
- ``Compiler``      — recompiles changed modules (py_compile / importlib)
- ``HotSwapper``    — atomically replaces live module objects in sys.modules
- ``Oracle``        — pluggable AI backend (local or API) for reasoning
- ``AutoHealer``    — top-level façade that wires everything together
"""

__version__ = "0.1.0"
__author__ = "AutoHeal Research Team"

from autoheal.core.tail_watcher import TailWatcher
from autoheal.core.diagnostician import Diagnostician, Severity
from autoheal.core.code_surgeon import CodeSurgeon
from autoheal.core.compiler import Compiler
from autoheal.core.hot_swapper import HotSwapper
from autoheal.core.oracle import Oracle, OracleTeam
from autoheal.core.auto_healer import AutoHealer

__all__ = [
    "TailWatcher",
    "Diagnostician",
    "Severity",
    "CodeSurgeon",
    "Compiler",
    "HotSwapper",
    "Oracle",
    "OracleTeam",
    "AutoHealer",
]
