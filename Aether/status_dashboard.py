#!/usr/bin/env python3
"""Aether Status Dashboard — shows current state of the research pipeline."""
import asyncio
import json
import yaml
from pathlib import Path
from datetime import datetime

from aristotle_sdk_client import AristotleSDKClient


async def show_status():
    config = yaml.safe_load(Path("config.yaml").read_text())
    aristotle = AristotleSDKClient(config.get("aristotle", {}))

    # Load state
    workspace = Path("../workspace").resolve()
    state_path = workspace / "orchestrator_state.json"
    context_path = workspace / "research_context.json"

    # Load in-flight jobs
    inflight = []
    if state_path.exists():
        state = json.loads(state_path.read_text())
        inflight = state.get("inflight_jobs", [])
        cycle_count = state.get("cycle_count", 0)
        success_count = state.get("successful_proofs", 0)
    else:
        cycle_count = 0
        success_count = 0

    # Load research context
    discoveries = []
    open_problems = []
    if context_path.exists():
        ctx = json.loads(context_path.read_text())
        discoveries = ctx.get("discoveries", [])
        open_problems = ctx.get("global_open_problems", [])

    # Poll all projects
    print("=" * 70)
    print("  AETHER RESEARCH PIPELINE — STATUS DASHBOARD")
    print("=" * 70)
    print(f"  Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"  Cycles completed: {cycle_count}")
    print(f"  Successful proofs: {success_count}")
    print()

    # Known project IDs (from inflight + any we know about)
    known_pids = [j.get("project_id", "")[:36] for j in inflight if j.get("project_id")]
    
    print("  ARISTOTLE PROJECTS:")
    print("  " + "-" * 66)
    for j in inflight:
        pid = j.get("project_id", "")
        concept = j.get("concept", "?")[:40]
        domain = j.get("domain", "?")[:15]
        mode = j.get("research_mode", "?")[:12]
        dispatched = j.get("dispatch_time", 0)
        elapsed = (asyncio.get_event_loop().time() if dispatched else 0)
        
        # Poll
        status_str = "?"
        pct = 0
        if pid:
            try:
                result = await aristotle.poll_project(pid)
                status_str = result.get("status", "?")
                pct = result.get("percent_complete", 0)
            except Exception as e:
                status_str = f"ERR:{e}"[:15]
        
        elapsed_min = (datetime.now().timestamp() - dispatched) / 60 if dispatched else 0
        print(f"  {pid[:8]} | {status_str:15} | {pct:3}% | {elapsed_min:5.1f}m | {domain:12} | {mode:8} | {concept}")
    
    if not inflight:
        print("  (no projects in flight)")
    
    print()
    print("  DISCOVERIES:")
    print("  " + "-" * 66)
    for d in discoveries[-5:]:
        title = d.get("concept_title", "?")[:40]
        quality = d.get("quality", "?")
        score = d.get("quality_score", 0)
        theorems = d.get("key_theorems", [])[:3]
        print(f"  {title:40} | {quality:10} | {score:.2f} | {', '.join(theorems)}")
    
    if not discoveries:
        print("  (no discoveries yet)")
    
    print()
    print("  OPEN PROBLEMS:")
    print("  " + "-" * 66)
    for p in open_problems[:5]:
        print(f"  - {p[:65]}")
    
    if not open_problems:
        print("  (none listed)")
    
    print()
    print("=" * 70)


if __name__ == "__main__":
    asyncio.run(show_status())