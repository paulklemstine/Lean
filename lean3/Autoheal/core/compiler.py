"""
Compiler — Module recompilation engine
========================================

After the CodeSurgeon writes a patched source file, the Compiler:

1. **Syntax-checks** the patched ``.py`` file via ``py_compile``.
2. **Byte-compiles** it to ``.pyc`` in the ``__pycache__`` directory.
3. **Reloads** the module object via ``importlib.reload()`` — or, if
   the module was never imported, uses ``importlib.import_module()``.

The Compiler deliberately avoids ``exec()`` on raw strings. Every
recompilation goes through Python's standard import machinery, which
means the module gets a proper ``__spec__``, ``__file__``, etc.

Thread Safety
-------------
All public methods are guarded by a reentrant lock so that concurrent
patches to different files do not corrupt the import system.
"""

from __future__ import annotations

import py_compile
import importlib
import importlib.util
import sys
import types
import logging
import threading
from pathlib import Path
from dataclasses import dataclass
from typing import Optional

logger = logging.getLogger(__name__)


@dataclass
class CompileResult:
    module_name: str
    source_file: str
    success: bool
    error: Optional[str] = None
    module: Optional[types.ModuleType] = None


class Compiler:
    """
    Recompile and reload Python modules from patched source files.

    Parameters
    ----------
    watch_dir : str | Path
        Root of the source tree — used to derive module names from file paths.
    """

    def __init__(self, watch_dir: str | Path) -> None:
        self.watch_dir = Path(watch_dir).resolve()
        self._lock = threading.RLock()

    def compile_and_load(self, source_path: str | Path) -> CompileResult:
        """
        Compile a ``.py`` file and reload (or import) its module.

        Returns a CompileResult with ``success=True`` if the module was
        successfully loaded into ``sys.modules``.
        """
        source_path = Path(source_path).resolve()
        module_name = self._path_to_module(source_path)

        with self._lock:
            # Step 1: py_compile check
            try:
                py_compile.compile(str(source_path), doraise=True)
            except py_compile.PyCompileError as exc:
                logger.error("Compile failed for %s: %s", source_path, exc)
                return CompileResult(
                    module_name=module_name,
                    source_file=str(source_path),
                    success=False,
                    error=str(exc),
                )

            # Step 2: reload or import
            try:
                if module_name in sys.modules:
                    old_module = sys.modules[module_name]
                    # Try reload first; fall back to fresh load if spec is missing
                    try:
                        old_module.__file__ = str(source_path)
                        module = importlib.reload(old_module)
                    except (ModuleNotFoundError, AttributeError):
                        # Module was loaded dynamically — do a fresh spec-based load
                        spec = importlib.util.spec_from_file_location(
                            module_name, str(source_path)
                        )
                        if spec is None or spec.loader is None:
                            raise ImportError(f"Cannot create spec for {source_path}")
                        module = importlib.util.module_from_spec(spec)
                        sys.modules[module_name] = module
                        spec.loader.exec_module(module)
                    logger.info("Reloaded module %s", module_name)
                else:
                    spec = importlib.util.spec_from_file_location(
                        module_name, str(source_path)
                    )
                    if spec is None or spec.loader is None:
                        raise ImportError(f"Cannot create spec for {source_path}")
                    module = importlib.util.module_from_spec(spec)
                    sys.modules[module_name] = module
                    spec.loader.exec_module(module)
                    logger.info("Imported new module %s", module_name)

                return CompileResult(
                    module_name=module_name,
                    source_file=str(source_path),
                    success=True,
                    module=module,
                )

            except Exception as exc:
                logger.exception("Load failed for %s", module_name)
                return CompileResult(
                    module_name=module_name,
                    source_file=str(source_path),
                    success=False,
                    error=str(exc),
                )

    def invalidate_caches(self) -> None:
        """Clear import-system caches (call after large batch patches)."""
        importlib.invalidate_caches()
        logger.debug("Import caches invalidated.")

    # ──────────────────────────────────────────────────────────────────
    # Internals
    # ──────────────────────────────────────────────────────────────────

    def _path_to_module(self, path: Path) -> str:
        """
        Derive a dotted module name from a file path relative to watch_dir.

        Example: watch_dir/foo/bar/baz.py  →  foo.bar.baz
        """
        try:
            rel = path.relative_to(self.watch_dir)
        except ValueError:
            # Fallback: use stem
            return path.stem

        parts = list(rel.parts)
        if parts[-1] == "__init__.py":
            parts = parts[:-1]
        else:
            parts[-1] = Path(parts[-1]).stem  # strip .py

        return ".".join(parts)
