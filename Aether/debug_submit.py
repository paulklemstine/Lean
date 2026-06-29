#!/usr/bin/env python3
"""Debug script to replicate daemon submission exactly."""
import asyncio
import json
import os
import shutil
import sys
import yaml
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from aristotle_sdk_client import AristotleSDKClient
from pi_agent_client import PiAgentClient
from prompt_engine import PromptEngine, ArtifactRequests


def load_config():
    p = Path("config.yaml")
    if p.exists():
        with open(p, "r", encoding="utf-8") as f:
            cfg = yaml.safe_load(f)
        # Substitute env vars
        def sub(obj):
            if isinstance(obj, dict):
                for k, v in obj.items():
                    if isinstance(v, str) and v.startswith("${") and v.endswith("}"):
                        var_name = v[2:-1]
                        obj[k] = os.environ.get(var_name, v)
                    else:
                        sub(v)
            elif isinstance(obj, list):
                for item in obj:
                    sub(item)
        sub(cfg)
        return cfg
    return {}


async def main():
    config = load_config()
    print(f"Config aristotle section: {json.dumps(config.get('aristotle', {}), indent=2)}")

    pi_cfg = config.get("pi_agent", {})
    pi = PiAgentClient(
        model=pi_cfg.get("model", "fingpt-7b:latest"),
    )
    concept = pi.generate_breakthrough_concept("compression", ["Tropical geometry", "Kolmogorov complexity"], "theorem")
    print(f"Concept: {concept.title}")
    print(f"lean_guess: {concept.lean_guess}")

    engine = PromptEngine(config.get("prompts", {}))
    prompt = engine.build_prompt(
        title=concept.title,
        domain="compression",
        concept_description=concept.concept_description,
        mathematical_framing=concept.mathematical_framing,
        lean_guess=concept.lean_guess,
        difficulty="phd",
        artifacts=ArtifactRequests(lean_proof=True, research_report=True, python_demo=True, svg_demo=True, sciam_discussion=True)
    )
    print(f"Prompt length: {len(prompt.prompt_text)}")

    client = AristotleSDKClient(config.get("aristotle", {}))
    print(f"Client api_key present: {bool(client.api_key)}")
    print(f"Client timeout: {client.timeout}")
    print(f"Client polling_interval: {client.polling_interval}")

    catalog_root = Path(config.get("catalog", {}).get("root_dir", "../Catalog")).resolve()
    if not catalog_root.exists() or catalog_root.name != "Catalog":
        if (catalog_root / "Catalog").exists():
            catalog_root = catalog_root / "Catalog"
        else:
            catalog_root = (Path(__file__).parent.parent / "Catalog").resolve()
    project_dir = Path("output/job_debug_test")
    if project_dir.exists():
        shutil.rmtree(project_dir)
    project_dir.mkdir(parents=True, exist_ok=True)

    print(f"Catalog root: {catalog_root}")
    print(f"Project dir: {project_dir}")

    print("Dispatching...")
    result = await client.submit_with_catalog_context(
        lean_source="""import Mathlib\n\ntheorem tropical_kolmogorov_bound {X : Type*} [Inhabited X] :\n    True := by\n  sorry""",
        catalog_root=catalog_root,
        project_dir=project_dir,
        prompt=prompt.prompt_text,
    )
    print(f"Status: {result.status}")
    print(f"Error: {result.error_message}")
    print(f"Project ID: {result.project_id}")
    print(f"Latency: {result.latency_seconds}")


if __name__ == "__main__":
    asyncio.run(main())
