#!/usr/bin/env python3
"""Quick Aristotle API integration test for CI.

Submits a minimal Lean project, waits for completion, and downloads the result.
Verifies that the API key works and results can be retrieved.
Exits 0 on success, 1 on failure.
"""

import asyncio
import shutil
import sys
import tempfile
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from aristotle_sdk_client import AristotleSDKClient


LEAN_PROJECT = """import Mathlib.Tactic.Basic

theorem test_one_eq_one : 1 = 1 := rfl
"""


async def test_aristotle(api_key: str, timeout: int = 600) -> bool:
    """Submit a minimal project to Aristotle and try to download the result."""
    config = {
        "api_key": api_key,
        "api_base_url": "https://aristotle.harmonic.fun/api/v1",
        "timeout_seconds": timeout,
        "polling_interval_seconds": 15,
    }

    client = AristotleSDKClient(config=config)
    catalog_root = Path(__file__).parent.parent / "Catalog"

    # 1. Create a temp project dir with proper Lean setup
    with tempfile.TemporaryDirectory() as tmpdir:
        project_dir = Path(tmpdir) / "test_project"
        project_dir.mkdir()

        # Write the test Lean file
        (project_dir / "Test.lean").write_text(LEAN_PROJECT)

        # Copy lean-toolchain from Catalog if available
        toolchain_src = catalog_root / "lean-toolchain"
        if toolchain_src.exists():
            shutil.copy2(toolchain_src, project_dir / "lean-toolchain")
        else:
            (project_dir / "lean-toolchain").write_text("leanprover/lean4:v4.28.0\n")

        # Copy lakefile.toml from Catalog if available
        lakefile_src = catalog_root / "lakefile.toml"
        if lakefile_src.exists():
            shutil.copy2(lakefile_src, project_dir / "lakefile.toml")
        else:
            (project_dir / "lakefile.toml").write_text(
                'name = "Test"\n'
                'defaultTargets = ["Test"]\n\n'
                '[[require]]\n'
                'name = "mathlib"\n'
                'scope = "leanprover"\n\n'
            )

        print("[Test] Submitting minimal Lean project to Aristotle...")
        try:
            project_id = await client.submit_lean_project_only(
                prompt="Prove the theorem test_one_eq_one : 1 = 1",
                project_dir=project_dir,
            )
        except Exception as e:
            print(f"[Test] FAIL: Submit failed: {e}")
            return False

        if not project_id:
            print("[Test] FAIL: No project_id returned")
            return False

        print(f"[Test] Project submitted: {project_id}")

        # 2. Poll until complete (with short timeout for CI)
        start = time.time()
        max_wait = 300  # 5 minutes for CI
        while time.time() - start < max_wait:
            try:
                poll_result = await client.poll_project(project_id)
                status = poll_result.get("status", "unknown")
                pct = poll_result.get("percent_complete", 0)
                elapsed = int(time.time() - start)

                if status in ("COMPLETE", "COMPLETE_WITH_ERRORS"):
                    print(f"[Test] Project completed: status={status}, pct={pct}%, elapsed={elapsed}s")
                    break
                elif status in ("FAILED", "OUT_OF_BUDGET", "CANCELED"):
                    print(f"[Test] FAIL: Project failed: status={status}")
                    return False
                elif status == "error":
                    err = poll_result.get("error", "")
                    print(f"[Test] FAIL: Aristotle returned error status. Details: {err}")
                    # Try fetching more info via the SDK
                    try:
                        from aristotlelib import Project
                        proj = await Project.from_id(project_id)
                        await proj.refresh()
                        print(f"[Test] Project details: id={proj.project_id}, status={proj.status}, "
                              f"percent={proj.percent_complete}")
                        if hasattr(proj, 'error_message') and proj.error_message:
                            print(f"[Test] Error message: {proj.error_message}")
                        # Print all non-private attributes for debugging
                        for attr in dir(proj):
                            if not attr.startswith('_') and attr not in ('from_id', 'create_from_directory', 'create', 'refresh', 'wait_for_completion', 'get_solution'):
                                try:
                                    val = getattr(proj, attr)
                                    if not callable(val):
                                        print(f"[Test]   {attr} = {val}")
                                except Exception:
                                    pass
                    except Exception as e2:
                        print(f"[Test] Could not fetch project details: {e2}")
                    return False
                else:
                    print(f"[Test] Polling: status={status}, pct={pct}%, elapsed={elapsed}s")
            except Exception as e:
                print(f"[Test] Poll error (will retry): {e}")

            await asyncio.sleep(15)
        else:
            print(f"[Test] FAIL: Timed out after {max_wait}s")
            return False

        # 3. Try to download the result
        print("[Test] Attempting to download result...")
        try:
            with tempfile.TemporaryDirectory() as dl_dir:
                tar_path = await client.download_result(project_id, Path(dl_dir))
                if tar_path and tar_path.exists() and tar_path.name != "__AUTH_ERROR__":
                    print(f"[Test] SUCCESS: Downloaded result to {tar_path}")
                    import tarfile
                    with tarfile.open(tar_path, 'r:gz') as tar:
                        names = tar.getnames()
                        lean_files = [n for n in names if n.endswith('.lean')]
                        print(f"[Test] Archive contains {len(names)} files, {len(lean_files)} .lean files")
                    return True
                elif tar_path and tar_path.name == "__AUTH_ERROR__":
                    print("[Test] FAIL: Download returned auth error (403/401)")
                    print("[Test] The API key can submit but cannot download — likely a permissions issue")
                    return False
                else:
                    print("[Test] FAIL: download_result returned None")
                    return False
        except Exception as e:
            print(f"[Test] FAIL: Download error: {e}")
            return False


def main():
    import os
    api_key = os.environ.get("ARISTOTLE_API_KEY", "")
    if not api_key:
        print("[Test] FAIL: ARISTOTLE_API_KEY not set")
        sys.exit(1)

    success = asyncio.run(test_aristotle(api_key))
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()