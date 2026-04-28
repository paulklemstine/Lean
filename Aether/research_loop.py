#!/usr/bin/env python3
"""Aether Continuous Research Loop

Monitors in-flight Aristotle projects and dispatches new research cycles
as slots become available. This is the production loop that runs Aether.

Usage:
    python3 research_loop.py [--max-inflight 3] [--poll-interval 60]
"""
import asyncio
import json
import time
import argparse
import yaml
from pathlib import Path

from pi_orchestrator import PiAgentOrchestrator
from aristotle_sdk_client import AristotleSDKClient


async def research_loop(max_inflight: int = 3, poll_interval: int = 60, max_cycles: int = 20):
    """Main continuous research loop."""
    config = yaml.safe_load(Path("config.yaml").read_text())
    domains_config = json.loads(Path("research_domains.json").read_text())
    workspace = Path("../workspace").resolve()

    orch = PiAgentOrchestrator(
        config=config,
        domains_config=domains_config,
        workspace=workspace,
    )

    aristotle = AristotleSDKClient(config.get("aristotle", {}))

    # In-flight jobs: {project_id: job_dict}
    inflight = {}

    # Load any existing in-flight jobs from state
    state_path = workspace / "orchestrator_state.json"
    if state_path.exists():
        try:
            state = json.loads(state_path.read_text())
            for j in state.get("inflight_jobs", []):
                inflight[j["project_id"]] = j
        except Exception:
            pass

    # Domains to cycle through (ensures diversity)
    domain_cycle = [
        None,           # Let Aristotle Loop choose (UCB)
        "tropical",     # Tropical geometry
        "emachinelearning",  # EML / Machine Learning
        "ealgebra",     # Algebra
        "ephysics",     # Physics
        "epythagorean", # Number theory
    ]
    domain_idx = 0

    cycle_count = 0
    total_dispatched = 0
    total_completed = 0
    total_failed = 0

    print(f"[ResearchLoop] Starting: max_inflight={max_inflight}, poll={poll_interval}s, max_cycles={max_cycles}")
    print(f"[ResearchLoop] {len(inflight)} existing in-flight jobs")

    try:
        while cycle_count < max_cycles:
            # 1. Poll all in-flight jobs
            completed_ids = []
            for pid, job_info in list(inflight.items()):
                try:
                    result = await aristotle.poll_project(pid)
                    status = result.get("status", "unknown")
                    pct = result.get("percent_complete", 0)

                    if status in ("COMPLETE", "COMPLETE_WITH_ERRORS"):
                        print(f"[Poll] {pid[:8]} COMPLETED ({status})")
                        completed_ids.append(pid)
                        total_completed += 1
                        # Process the result
                        if hasattr(orch, '_process_completed_job'):
                            try:
                                from orchestrator_state import JobInfo
                                job = JobInfo(
                                    exp_id=job_info.get("exp_id", ""),
                                    concept=job_info.get("concept", ""),
                                    domain=job_info.get("domain", ""),
                                    research_mode=job_info.get("research_mode", "prove"),
                                    references=[],
                                    prompt="",
                                    project_id=pid,
                                    status="complete",
                                    dispatch_time=job_info.get("dispatch_time", time.time()),
                                    result_data=result,
                                )
                                await orch._process_completed_job(job)
                            except Exception as e:
                                print(f"[Poll] Error processing result: {e}")
                    elif status == "error":
                        print(f"[Poll] {pid[:8]} ERROR: {result.get('error', 'unknown')[:100]}")
                        completed_ids.append(pid)
                        total_failed += 1
                    elif status == "IN_PROGRESS":
                        if pct > 1:
                            print(f"[Poll] {pid[:8]} IN_PROGRESS ({pct}%)")
                except Exception as e:
                    print(f"[Poll] {pid[:8]} poll error: {e}")

            # Remove completed jobs
            for pid in completed_ids:
                del inflight[pid]

            # 2. Fill the queue up to max_inflight
            while len(inflight) < max_inflight and cycle_count < max_cycles:
                domain = domain_cycle[domain_idx % len(domain_cycle)]
                domain_idx += 1
                cycle_count += 1

                print(f"\n[Dispatch] Cycle {cycle_count}/{max_cycles}, domain={domain or 'UCB'}, inflight={len(inflight)}/{max_inflight}")

                try:
                    job = await orch._prepare_job(forced_domain=domain)
                    if job:
                        await orch._dispatch_job(job)

                        if job.project_id:
                            inflight[job.project_id] = {
                                "exp_id": job.exp_id,
                                "concept": job.concept.title,
                                "domain": job.concept.domain,
                                "research_mode": job.concept.research_mode,
                                "project_id": job.project_id,
                                "dispatch_time": time.time(),
                            }
                            total_dispatched += 1
                            print(f"[Dispatch] {job.project_id[:8]} dispatched ({job.concept.title[:40]})")
                        else:
                            # Rate-limited or other dispatch error
                            print(f"[Dispatch] No project_id (rate-limited or error). Pausing...")
                            cycle_count -= 1  # Don't count this cycle
                            domain_idx -= 1   # Retry same domain later
                            await asyncio.sleep(30)
                            break  # Stop dispatching, wait for a slot
                    else:
                        print(f"[Dispatch] Could not prepare job")
                except Exception as e:
                    print(f"[Dispatch] Error: {e}")

                # Save state with inflight tracking
                orch._save_state()

            # 3. Save inflight jobs to state
            try:
                state = json.loads(state_path.read_text())
                state["inflight_jobs"] = list(inflight.values())
                state_path.write_text(json.dumps(state, indent=2))
            except Exception:
                pass

            # 4. Print status
            print(f"\n[Status] Cycle {cycle_count}/{max_cycles} | "
                  f"Inflight: {len(inflight)}/{max_inflight} | "
                  f"Dispatched: {total_dispatched} | "
                  f"Completed: {total_completed} | "
                  f"Failed: {total_failed}")

            if len(inflight) >= max_inflight:
                print(f"[Wait] All slots full, polling in {poll_interval}s...")
                await asyncio.sleep(poll_interval)
            elif cycle_count >= max_cycles:
                break
            else:
                # Brief pause between dispatches
                await asyncio.sleep(5)

    except KeyboardInterrupt:
        print(f"\n[Interrupt] Saving state...")

    # Save final state
    try:
        state = json.loads(state_path.read_text())
        state["inflight_jobs"] = list(inflight.values())
        state_path.write_text(json.dumps(state, indent=2))
    except Exception:
        pass

    orch._save_state()
    print(f"\n[Done] Dispatched: {total_dispatched}, Completed: {total_completed}, Failed: {total_failed}")
    if inflight:
        print(f"[Done] {len(inflight)} jobs still in-flight:")
        for pid, j in inflight.items():
            print(f"  {pid[:8]}: {j['concept'][:50]} ({j['domain']})")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Aether Continuous Research Loop")
    parser.add_argument("--max-inflight", type=int, default=3, help="Max concurrent Aristotle jobs")
    parser.add_argument("--poll-interval", type=int, default=60, help="Seconds between polls")
    parser.add_argument("--max-cycles", type=int, default=20, help="Total dispatch cycles to run")
    args = parser.parse_args()

    asyncio.run(research_loop(
        max_inflight=args.max_inflight,
        poll_interval=args.poll_interval,
        max_cycles=args.max_cycles,
    ))