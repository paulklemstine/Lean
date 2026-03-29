#!/usr/bin/env python3
"""
Unit tests for AutoHeal core components.

Run::

    python -m pytest autoheal/tests/test_core.py -v
"""

import ast
import os
import sys
import time
import tempfile
import threading
from pathlib import Path
from unittest import TestCase, main as unittest_main

# Ensure project root is on path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from autoheal.core.tail_watcher import TailWatcher, LogLine
from autoheal.core.diagnostician import Diagnostician, Severity
from autoheal.core.code_surgeon import CodeSurgeon, Patch
from autoheal.core.compiler import Compiler
from autoheal.core.hot_swapper import HotSwapper
from autoheal.core.oracle import Oracle, OracleTeam


class TestTailWatcher(TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.log_file = Path(self.tmpdir) / "test.log"
        self.log_file.touch()
        self.received = []

    def tearDown(self):
        import shutil
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    def test_detects_new_lines(self):
        watcher = TailWatcher(self.log_file, poll_interval=0.1)
        watcher.on_line(lambda ll: self.received.append(ll.text))
        watcher.start()

        time.sleep(0.3)
        with open(self.log_file, "a") as f:
            f.write("Hello World\n")
            f.write("Second Line\n")

        time.sleep(0.5)
        watcher.stop()

        self.assertIn("Hello World", self.received)
        self.assertIn("Second Line", self.received)

    def test_handles_missing_file(self):
        missing = Path(self.tmpdir) / "nonexistent.log"
        watcher = TailWatcher(missing, poll_interval=0.1)
        watcher.start()
        time.sleep(0.3)
        watcher.stop()
        # Should not crash


class TestDiagnostician(TestCase):
    def _make_line(self, text):
        return LogLine(text=text, line_number=1, timestamp=time.time(), source_file="test.log")

    def test_classifies_python_exception(self):
        diag = Diagnostician()
        result = diag.classify(self._make_line("ValueError: invalid literal"))
        self.assertIsNotNone(result)
        self.assertEqual(result.severity, Severity.ERROR)
        self.assertEqual(result.category, "ValueError")

    def test_classifies_warning(self):
        diag = Diagnostician()
        result = diag.classify(self._make_line("WARNING: deprecated function"))
        self.assertIsNotNone(result)
        self.assertEqual(result.severity, Severity.WARNING)

    def test_ignores_info(self):
        diag = Diagnostician()
        result = diag.classify(self._make_line("Processing item 42..."))
        self.assertIsNone(result)

    def test_classifies_segfault(self):
        diag = Diagnostician()
        result = diag.classify(self._make_line("Segmentation fault (core dumped)"))
        self.assertIsNotNone(result)
        self.assertEqual(result.severity, Severity.CRITICAL)


class TestCodeSurgeon(TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.watch_dir = Path(self.tmpdir)

    def tearDown(self):
        import shutil
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    def test_heuristic_fixes_missing_colon(self):
        src = "def foo()\n    pass\n"
        src_file = self.watch_dir / "broken.py"
        src_file.write_text(src)

        from autoheal.core.diagnostician import Diagnosis
        diag = Diagnosis(
            severity=Severity.ERROR,
            category="SyntaxError",
            message="expected ':'",
            source_file=str(src_file),
            source_line=1,
            raw_log="SyntaxError: expected ':'",
        )

        surgeon = CodeSurgeon(watch_dir=self.watch_dir)
        patch = surgeon.propose_patch(diag)

        self.assertIsNotNone(patch)
        self.assertTrue(patch.is_valid)
        self.assertIn("def foo():", patch.patched_source)

    def test_validate_syntax(self):
        self.assertTrue(CodeSurgeon._validate_syntax("x = 1\n"))
        self.assertFalse(CodeSurgeon._validate_syntax("def (:\n"))


class TestCompiler(TestCase):
    def test_compile_valid_module(self):
        tmpdir = tempfile.mkdtemp()
        mod_file = Path(tmpdir) / "good.py"
        mod_file.write_text("def hello():\n    return 'hi'\n")

        compiler = Compiler(tmpdir)
        result = compiler.compile_and_load(mod_file)

        self.assertTrue(result.success)
        self.assertIsNotNone(result.module)
        self.assertEqual(result.module.hello(), "hi")

        import shutil
        shutil.rmtree(tmpdir, ignore_errors=True)

    def test_compile_invalid_module(self):
        tmpdir = tempfile.mkdtemp()
        mod_file = Path(tmpdir) / "bad.py"
        mod_file.write_text("def bad(\n")

        compiler = Compiler(tmpdir)
        result = compiler.compile_and_load(mod_file)

        self.assertFalse(result.success)
        self.assertIsNotNone(result.error)

        import shutil
        shutil.rmtree(tmpdir, ignore_errors=True)


class TestHotSwapper(TestCase):
    def test_swap_function(self):
        import types

        # Create old module
        old_mod = types.ModuleType("test_swap_mod")
        old_mod.greet = lambda: "v1"
        sys.modules["test_swap_mod"] = old_mod

        # Hold a reference
        old_ref = old_mod.greet

        # Create new module
        new_mod = types.ModuleType("test_swap_mod")
        exec("def greet():\n    return 'v2'\n", new_mod.__dict__)

        swapper = HotSwapper()
        n = swapper.swap_module("test_swap_mod", new_mod)

        self.assertGreater(n, 0)
        # The module-level attribute should return v2
        self.assertEqual(sys.modules["test_swap_mod"].greet(), "v2")

        # Cleanup
        del sys.modules["test_swap_mod"]


class TestOracle(TestCase):
    def test_query(self):
        oracle = Oracle(backend=lambda p: f"Echo: {p}", name="test")
        result = oracle.query("Hello")
        self.assertIn("Hello", result)
        self.assertEqual(len(oracle.conversation_log), 2)

    def test_oracle_team(self):
        team = OracleTeam(
            backend=lambda p: "CONVERGED — looks good",
            max_rounds=2,
        )
        result = team.run_repair_cycle("test error", "x = 1\n")
        self.assertIsNotNone(result)
        self.assertGreater(len(team.notes), 0)


if __name__ == "__main__":
    unittest_main()
