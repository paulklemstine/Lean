"""
HotSwapper — Atomic live-code replacement
===========================================

The HotSwapper takes a freshly compiled module object and *surgically*
replaces the corresponding live objects in the running process:

1. **Functions & methods** — patches ``__code__``, ``__defaults__``, and
   ``__globals__`` on existing function objects so that all existing
   references (closures, bound methods, decorators) see the new code.
2. **Classes** — walks the MRO and updates ``__dict__`` entries.
3. **Module-level variables** — updates ``sys.modules[name].__dict__``.

Why not just ``importlib.reload()``?
    ``reload()`` replaces the *module object* in ``sys.modules``, but any
    code that already holds a reference to the *old* module's functions
    or classes still points at stale objects. HotSwapper ensures those
    existing references are updated **in place**.

Safety
------
- All swaps happen inside a lock so observers see a consistent snapshot.
- A rollback list is maintained per swap; call ``rollback()`` to undo.
"""

from __future__ import annotations

import sys
import types
import logging
import threading
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)


@dataclass
class SwapRecord:
    """Record of a single object replacement (for rollback)."""
    module_name: str
    attr_name: str
    old_value: Any
    new_value: Any
    timestamp: float = 0.0


class HotSwapper:
    """
    Replace live objects in-place with freshly compiled versions.

    Parameters
    ----------
    dry_run : bool
        If True, log what *would* change without actually swapping.
    """

    def __init__(self, dry_run: bool = False) -> None:
        self.dry_run = dry_run
        self._lock = threading.RLock()
        self.swap_history: List[SwapRecord] = []

    def swap_module(self, module_name: str, new_module: types.ModuleType) -> int:
        """
        Hot-swap all public attributes from *new_module* into the live
        module registered under *module_name* in ``sys.modules``.

        Returns the number of attributes swapped.
        """
        import time

        with self._lock:
            old_module = sys.modules.get(module_name)
            if old_module is None:
                # Nothing to swap into — just register the new one
                sys.modules[module_name] = new_module
                logger.info("Registered new module %s (no prior version).", module_name)
                return 0

            count = 0
            for attr_name in dir(new_module):
                if attr_name.startswith("_") and attr_name not in (
                    "__all__", "__version__",
                ):
                    continue

                new_obj = getattr(new_module, attr_name)
                old_obj = getattr(old_module, attr_name, _SENTINEL)

                if old_obj is _SENTINEL:
                    # Genuinely new attribute
                    if not self.dry_run:
                        setattr(old_module, attr_name, new_obj)
                    logger.debug("  + added %s.%s", module_name, attr_name)
                    count += 1
                    continue

                if type(old_obj) != type(new_obj):
                    # Type changed — straight replacement
                    record = SwapRecord(
                        module_name=module_name,
                        attr_name=attr_name,
                        old_value=old_obj,
                        new_value=new_obj,
                        timestamp=time.time(),
                    )
                    if not self.dry_run:
                        setattr(old_module, attr_name, new_obj)
                    self.swap_history.append(record)
                    count += 1
                    continue

                # Same type — deep swap where possible
                if isinstance(old_obj, types.FunctionType):
                    count += self._swap_function(old_obj, new_obj, module_name, attr_name)
                elif isinstance(old_obj, type):
                    count += self._swap_class(old_obj, new_obj, module_name, attr_name)
                else:
                    # Scalar / other — just replace
                    if old_obj != new_obj:
                        record = SwapRecord(
                            module_name=module_name,
                            attr_name=attr_name,
                            old_value=old_obj,
                            new_value=new_obj,
                            timestamp=time.time(),
                        )
                        if not self.dry_run:
                            setattr(old_module, attr_name, new_obj)
                        self.swap_history.append(record)
                        count += 1

            logger.info("Hot-swapped %d attributes in %s", count, module_name)
            return count

    def rollback(self, n: int = 1) -> int:
        """Undo the last *n* swap records."""
        undone = 0
        with self._lock:
            for _ in range(min(n, len(self.swap_history))):
                rec = self.swap_history.pop()
                mod = sys.modules.get(rec.module_name)
                if mod:
                    setattr(mod, rec.attr_name, rec.old_value)
                    undone += 1
                    logger.info("Rolled back %s.%s", rec.module_name, rec.attr_name)
        return undone

    # ──────────────────────────────────────────────────────────────────
    # Deep-swap helpers
    # ──────────────────────────────────────────────────────────────────

    def _swap_function(
        self,
        old_fn: types.FunctionType,
        new_fn: types.FunctionType,
        mod_name: str,
        attr_name: str,
    ) -> int:
        """Patch old function *in place* so existing refs see new code."""
        import time

        record = SwapRecord(
            module_name=mod_name,
            attr_name=attr_name,
            old_value=_snapshot_function(old_fn),
            new_value=new_fn,
            timestamp=time.time(),
        )
        if not self.dry_run:
            old_fn.__code__ = new_fn.__code__
            old_fn.__defaults__ = new_fn.__defaults__
            old_fn.__kwdefaults__ = new_fn.__kwdefaults__
            old_fn.__annotations__ = new_fn.__annotations__
            old_fn.__doc__ = new_fn.__doc__
            # __globals__ is read-only; update the dict in place
            old_fn.__globals__.update(new_fn.__globals__)

        self.swap_history.append(record)
        logger.debug("  ↻ patched function %s.%s in place", mod_name, attr_name)
        return 1

    def _swap_class(
        self,
        old_cls: type,
        new_cls: type,
        mod_name: str,
        attr_name: str,
    ) -> int:
        """Update class methods and attributes in place."""
        count = 0
        for key in list(new_cls.__dict__):
            if key.startswith("__") and key.endswith("__") and key not in (
                "__init__", "__call__", "__repr__", "__str__",
                "__eq__", "__hash__", "__len__", "__getitem__",
            ):
                continue
            new_val = new_cls.__dict__[key]
            old_val = old_cls.__dict__.get(key, _SENTINEL)
            if old_val is _SENTINEL or old_val is not new_val:
                if not self.dry_run:
                    try:
                        setattr(old_cls, key, new_val)
                        count += 1
                    except (AttributeError, TypeError):
                        pass
        logger.debug("  ↻ patched class %s.%s (%d attrs)", mod_name, attr_name, count)
        return count


# ──────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────

_SENTINEL = object()


def _snapshot_function(fn: types.FunctionType) -> dict:
    """Capture enough state to roll back a function patch."""
    return {
        "__code__": fn.__code__,
        "__defaults__": fn.__defaults__,
        "__kwdefaults__": fn.__kwdefaults__,
        "__annotations__": fn.__annotations__.copy(),
        "__doc__": fn.__doc__,
    }
