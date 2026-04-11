#!/usr/bin/env python3
"""
App 1: Tropical Model Converter

Downloads a HuggingFace reasoning model, converts it to tropical architecture,
trains it via knowledge distillation to match the original model's performance,
and saves the result to disk.

Usage:
    python convert_model.py Qwen/Qwen2.5-0.5B
    python convert_model.py Qwen/Qwen2.5-0.5B --output ./my_tropical_model
    python convert_model.py Qwen/Qwen2.5-0.5B --epochs 5 --batch-size 8
    python convert_model.py --clear-cache  # Clear all cached work files

All intermediate work is cached in ~/.cache/tropicalize/ to speed up
subsequent runs. Set TROPICALIZE_CACHE to override the cache location.
"""

from __future__ import annotations

import argparse
import json
import logging
import sys
import time
from pathlib import Path

import torch

from tropicalize.converter import convert_model, extract_architecture_params
from tropicalize.distiller import DistillationConfig, distill
from tropicalize.cache import (
    cache_summary,
    clear_cache,
    get_finished_path,
    is_cached,
    mark_complete,
    CACHE_ROOT,
)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("tropicalize")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert a HuggingFace model to tropical architecture.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    parser.add_argument(
        "model_name",
        nargs="?",
        help="HuggingFace model identifier (e.g. 'Qwen/Qwen2.5-0.5B')",
    )

    parser.add_argument(
        "--output", "-o",
        type=str,
        default=None,
        help="Output directory for the tropical model (default: ./tropical_<model_name>)",
    )

    # Training
    parser.add_argument("--epochs", type=int, default=3, help="Number of distillation epochs (default: 3)")
    parser.add_argument("--batch-size", type=int, default=4, help="Training batch size (default: 4)")
    parser.add_argument("--lr", type=float, default=1e-4, help="Learning rate (default: 1e-4)")
    parser.add_argument("--seq-length", type=int, default=512, help="Training sequence length (default: 512)")
    parser.add_argument("--max-samples", type=int, default=10000, help="Max training samples (default: 10000)")

    # Tropical
    parser.add_argument(
        "--initial-temperature", type=float, default=1.0,
        help="Initial tropical temperature (1.0=smooth, default: 1.0)"
    )
    parser.add_argument(
        "--final-temperature", type=float, default=0.01,
        help="Final tropical temperature after annealing (default: 0.01)"
    )
    parser.add_argument(
        "--anneal-schedule", choices=["linear", "cosine", "exponential"],
        default="cosine", help="Temperature annealing schedule (default: cosine)"
    )

    # Distillation
    parser.add_argument("--distill-temp", type=float, default=2.0, help="Distillation temperature (default: 2.0)")
    parser.add_argument("--alpha-kl", type=float, default=0.7, help="KL divergence loss weight (default: 0.7)")
    parser.add_argument("--alpha-ce", type=float, default=0.2, help="Cross-entropy loss weight (default: 0.2)")
    parser.add_argument("--alpha-hidden", type=float, default=0.1, help="Hidden state loss weight (default: 0.1)")

    # Device
    parser.add_argument("--device", type=str, default="auto", help="Device: auto, cpu, cuda, mps (default: auto)")
    parser.add_argument("--dtype", choices=["float32", "float16", "bfloat16"], default="float32")

    # Cache management
    parser.add_argument("--clear-cache", action="store_true", help="Clear all cached files and exit")
    parser.add_argument("--cache-info", action="store_true", help="Show cache contents and exit")
    parser.add_argument("--skip-distill", action="store_true", help="Skip distillation (save converted model only)")

    # Model loading
    parser.add_argument("--no-trust-remote-code", action="store_true", help="Don't trust remote code")

    return parser.parse_args()


def main():
    args = parse_args()

    # Cache management commands
    if args.clear_cache:
        clear_cache()
        print(f"✓ Cache cleared: {CACHE_ROOT}")
        return

    if args.cache_info:
        summary = cache_summary()
        print(f"Cache directory: {CACHE_ROOT}")
        for section, items in summary.items():
            print(f"\n  {section}/ ({len(items)} items)")
            for item in items:
                print(f"    - {item}")
        return

    if not args.model_name:
        print("Error: model_name is required. Example: python convert_model.py Qwen/Qwen2.5-0.5B")
        sys.exit(1)

    # Determine output path
    if args.output:
        output_path = Path(args.output)
    else:
        safe_name = args.model_name.replace("/", "_").replace("\\", "_")
        output_path = Path(f"./tropical_{safe_name}")

    # Dtype
    dtype_map = {
        "float32": torch.float32,
        "float16": torch.float16,
        "bfloat16": torch.bfloat16,
    }
    dtype = dtype_map[args.dtype]

    print("=" * 60)
    print("  🌴 Tropical Model Converter")
    print("=" * 60)
    print(f"  Source model : {args.model_name}")
    print(f"  Output       : {output_path}")
    print(f"  Device       : {args.device}")
    print(f"  Dtype        : {args.dtype}")
    print(f"  Epochs       : {args.epochs}")
    print(f"  Batch size   : {args.batch_size}")
    print(f"  Temperature  : {args.initial_temperature} → {args.final_temperature}")
    print(f"  Cache        : {CACHE_ROOT}")
    print("=" * 60)

    start_time = time.time()

    # ── Step 1: Convert model ──────────────────────────────────
    print("\n📥 Step 1/3: Downloading and converting model...")
    tropical_model, tokenizer, arch_params, source_model = convert_model(
        model_name=args.model_name,
        initial_temperature=args.initial_temperature,
        dtype=dtype,
        trust_remote_code=not args.no_trust_remote_code,
    )

    param_count = sum(p.numel() for p in tropical_model.parameters())
    print(f"  ✓ Tropical model built: {param_count:,} parameters")
    print(f"  ✓ Architecture: {arch_params['num_layers']} layers, "
          f"{arch_params['hidden_size']} hidden, "
          f"{arch_params['num_heads']} heads")

    # ── Step 2: Distillation ───────────────────────────────────
    if not args.skip_distill:
        print("\n🎓 Step 2/3: Knowledge distillation...")

        distill_config = DistillationConfig(
            num_epochs=args.epochs,
            batch_size=args.batch_size,
            learning_rate=args.lr,
            seq_length=args.seq_length,
            max_train_samples=args.max_samples,
            distill_temperature=args.distill_temp,
            alpha_logit=args.alpha_kl,
            alpha_ce=args.alpha_ce,
            alpha_hidden=args.alpha_hidden,
            anneal_tropical_temp=True,
            final_tropical_temp=args.final_temperature,
            anneal_schedule=args.anneal_schedule,
            device=args.device,
        )

        tropical_model = distill(
            teacher=source_model,
            student=tropical_model,
            tokenizer=tokenizer,
            config=distill_config,
            model_name=args.model_name,
        )
        print("  ✓ Distillation complete")
    else:
        print("\n⏭️  Step 2/3: Skipping distillation (--skip-distill)")

    # ── Step 3: Save ───────────────────────────────────────────
    print(f"\n💾 Step 3/3: Saving tropical model to {output_path}...")
    output_path.mkdir(parents=True, exist_ok=True)

    # Save model weights
    torch.save(tropical_model.state_dict(), output_path / "tropical_model.pt")

    # Save architecture params
    (output_path / "arch_params.json").write_text(json.dumps(arch_params, indent=2))

    # Save tokenizer
    tokenizer.save_pretrained(output_path)

    # Save metadata
    metadata = {
        "source_model": args.model_name,
        "architecture": "TropicalCausalLM",
        "parameters": param_count,
        "initial_temperature": args.initial_temperature,
        "final_temperature": args.final_temperature,
        "distilled": not args.skip_distill,
        "epochs": args.epochs if not args.skip_distill else 0,
        "dtype": args.dtype,
    }
    (output_path / "metadata.json").write_text(json.dumps(metadata, indent=2))

    # Also cache as finished
    finished_path = get_finished_path(args.model_name)
    finished_path.mkdir(parents=True, exist_ok=True)
    torch.save(tropical_model.state_dict(), finished_path / "tropical_model.pt")
    (finished_path / "arch_params.json").write_text(json.dumps(arch_params, indent=2))
    tokenizer.save_pretrained(finished_path)
    (finished_path / "metadata.json").write_text(json.dumps(metadata, indent=2))
    mark_complete(finished_path, metadata)

    elapsed = time.time() - start_time
    print(f"\n{'=' * 60}")
    print(f"  ✅ Conversion complete in {elapsed:.1f}s")
    print(f"  📁 Model saved to: {output_path}")
    print(f"  📁 Also cached at: {finished_path}")
    print(f"{'=' * 60}")

    # Free memory
    del source_model, tropical_model
    torch.cuda.empty_cache() if torch.cuda.is_available() else None


if __name__ == "__main__":
    main()
