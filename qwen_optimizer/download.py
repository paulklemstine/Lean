"""Model download and Google Drive caching utilities."""

import os
import shutil
from pathlib import Path
from typing import Optional

from huggingface_hub import snapshot_download


def check_disk_space(path: str, required_gb: float = 10.0) -> bool:
    """Check if the filesystem at path has at least required_gb free."""
    stat = shutil.disk_usage(path)
    free_gb = stat.free / (1024 ** 3)
    return free_gb >= required_gb


class ModelCache:
    """Downloads models from HuggingFace and caches them to a local directory.

    On Google Colab, set cache_dir to a Google Drive path for persistence.
    """

    def __init__(self, cache_dir: str = "./model_cache"):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def get_model_path(self, repo_id: str) -> Path:
        """Return the local path for a given HuggingFace repo_id.

        If the model is not yet cached, it is downloaded first.
        """
        local_name = repo_id.replace("/", "_")
        local_path = self.cache_dir / local_name

        if not (local_path / "config.json").exists():
            print(f"Downloading {repo_id}...")
            snapshot_download(
                repo_id=repo_id,
                local_dir=str(local_path),
                local_dir_use_symlinks=False,
                resume_download=True,
            )
            print(f"Cached to {local_path}")
        else:
            print(f"Using cached model at {local_path}")

        return local_path

    def cache_size_gb(self, repo_id: str) -> float:
        """Return the on-disk size of a cached model in GB."""
        local_path = self.cache_dir / repo_id.replace("/", "_")
        if not local_path.exists():
            return 0.0
        total = sum(
            f.stat().st_size for f in local_path.rglob("*") if f.is_file()
        )
        return total / (1024 ** 3)

    def drive_path(self, drive_mount: str = "/content/drive/MyDrive") -> Path:
        """Return a cache path inside Google Drive if mounted."""
        drive_cache = Path(drive_mount) / "CrystallineCache" / "models"
        drive_cache.mkdir(parents=True, exist_ok=True)
        return drive_cache
