"""
Persistent caching for model downloads, conversions, and training checkpoints.

Cache layout:
    ~/.cache/tropicalize/
    ├── models/           # Downloaded HuggingFace model snapshots
    ├── converted/        # Converted tropical model architectures
    ├── checkpoints/      # Distillation training checkpoints
    └── finished/         # Final trained tropical models
"""

from __future__ import annotations

import hashlib
import json
import os
import shutil
from pathlib import Path
from typing import Optional

CACHE_ROOT = Path(os.environ.get(
    "TROPICALIZE_CACHE",
    Path.home() / ".cache" / "tropicalize"
))


def get_cache_dir(subdir: str) -> Path:
    """Get or create a cache subdirectory."""
    path = CACHE_ROOT / subdir
    path.mkdir(parents=True, exist_ok=True)
    return path


def model_cache_key(model_name: str) -> str:
    """Deterministic cache key for a model name."""
    return hashlib.sha256(model_name.encode()).hexdigest()[:16]


def get_model_cache_path(model_name: str) -> Path:
    """Path where a downloaded model is cached."""
    return get_cache_dir("models") / model_cache_key(model_name)


def get_converted_cache_path(model_name: str) -> Path:
    """Path where a converted tropical model skeleton is cached."""
    return get_cache_dir("converted") / model_cache_key(model_name)


def get_checkpoint_dir(model_name: str) -> Path:
    """Path for distillation checkpoints."""
    return get_cache_dir("checkpoints") / model_cache_key(model_name)


def get_finished_path(model_name: str) -> Path:
    """Path for the final trained tropical model."""
    return get_cache_dir("finished") / model_cache_key(model_name)


def is_cached(path: Path) -> bool:
    """Check if a cache entry exists and has content."""
    if not path.exists():
        return False
    # Check for a completion marker
    marker = path / ".cache_complete"
    return marker.exists()


def mark_complete(path: Path, metadata: Optional[dict] = None):
    """Mark a cache entry as complete."""
    path.mkdir(parents=True, exist_ok=True)
    marker = path / ".cache_complete"
    info = {"status": "complete"}
    if metadata:
        info.update(metadata)
    marker.write_text(json.dumps(info, indent=2))


def read_cache_metadata(path: Path) -> Optional[dict]:
    """Read cache metadata if available."""
    marker = path / ".cache_complete"
    if marker.exists():
        return json.loads(marker.read_text())
    return None


def clear_cache(subdir: Optional[str] = None):
    """Clear all or part of the cache."""
    if subdir:
        path = CACHE_ROOT / subdir
        if path.exists():
            shutil.rmtree(path)
    else:
        if CACHE_ROOT.exists():
            shutil.rmtree(CACHE_ROOT)


def cache_summary() -> dict:
    """Return a summary of cached items."""
    summary = {}
    for subdir in ["models", "converted", "checkpoints", "finished"]:
        path = CACHE_ROOT / subdir
        if path.exists():
            items = [d.name for d in path.iterdir() if d.is_dir()]
            summary[subdir] = items
        else:
            summary[subdir] = []
    return summary
