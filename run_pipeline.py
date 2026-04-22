#!/usr/bin/env python3
"""
End-to-end Qwen optimization pipeline.

Runs the complete compression pipeline on a single command:
  1. Download / cache model
  2. Baseline benchmark
  3. Quantize (NF4)
  4. Prune (structured + unstructured)
  5. Distill (teacher → tropical student)
  6. Crystallize
  7. Final benchmark & telemetry

Usage:
    python run_pipeline.py \
        --model Qwen/Qwen2.5-3B-Instruct \
        --output_dir ./pipeline_results \
        --device cuda \
        --epochs 1 \
        --batch_size 2 \
        --num_samples 50
"""

import argparse
import json
import os
import time
from datetime import datetime

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

from qwen_optimizer import (
    BenchmarkSuite,
    ModelCache,
    TelemetryEntry,
    TelemetryLogger,
    TropicalModel,
    convert_to_tropical,
    prune_model,
)
from qwen_optimizer.distill import DistillationPipeline
from qwen_optimizer.telemetry import TelemetryLogger, TelemetryEntry
from qwen_optimizer.tropical import tropical_distillation_loss


def run_stage(name: str, fn, *args, **kwargs):
    """Run a pipeline stage with timing and error handling."""
    print("\n" + "=" * 60)
    print(f"Stage: {name}")
    print("=" * 60)
    t0 = time.time()
    try:
        result = fn(*args, **kwargs)
        elapsed = time.time() - t0
        print(f"Stage '{name}' completed in {elapsed:.1f}s")
        return result, elapsed, None
    except Exception as e:
        elapsed = time.time() - t0
        print(f"Stage '{name}' failed after {elapsed:.1f}s: {e}")
        return None, elapsed, str(e)


def stage_download(model_name: str, cache_dir: str):
    cache = ModelCache(cache_dir)
    path = cache.get_model_path(model_name)
    tokenizer = AutoTokenizer.from_pretrained(path, trust_remote_code=True)
    return path, tokenizer


def stage_baseline(model_path: str, tokenizer, device: str):
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float16 if device == "cuda" else torch.float32,
        device_map="auto" if device == "cuda" else "cpu",
        trust_remote_code=True,
    )
    bench = BenchmarkSuite(tokenizer, device=device)
    result = bench.run_inference_benchmark(model, "baseline", "fp16")
    return model, result


def stage_quantize(model_path: str, tokenizer, device: str):
    from transformers import BitsAndBytesConfig
    quant_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_use_double_quant=True,
        bnb_4bit_compute_dtype=torch.bfloat16,
    )
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        quantization_config=quant_config,
        device_map="auto",
        trust_remote_code=True,
    )
    bench = BenchmarkSuite(tokenizer, device=device)
    result = bench.run_inference_benchmark(model, "quantize_nf4", "nf4")
    return model, result


def stage_prune(model, prune_ratio: float = 0.3, unstructured: float = 0.2):
    stats = prune_model(
        model,
        ffn_prune_ratio=prune_ratio,
        unstructured_sparsity=unstructured,
        heads_to_prune=0,
    )
    return stats


def stage_distill(
    teacher,
    tokenizer,
    device: str,
    epochs: int = 1,
    batch_size: int = 2,
    num_samples: int = 50,
    temperature: float = 2.0,
    alpha: float = 0.5,
    output_dir: str = "./pipeline_results",
):
    """Distill teacher into a tropical student."""
    from qwen_optimizer.tropical_train import generate_synthetic_data, TextDataset, train_tropical_model

    # Create tropical student
    student_config = {
        "vocab_size": tokenizer.vocab_size,
        "d_model": 512,
        "num_layers": 6,
        "num_heads": 8,
        "d_ff": 1024,
        "max_seq_len": 2048,
        "dropout": 0.1,
        "hard_attention": False,
    }
    tropical_model = TropicalModel(**student_config)

    # Generate synthetic data
    texts = generate_synthetic_data(teacher, tokenizer, num_samples=num_samples)
    dataset = TextDataset(texts, tokenizer, max_length=256)

    # Train
    trained = train_tropical_model(
        teacher=teacher,
        tropical_model=tropical_model,
        tokenizer=tokenizer,
        dataset=dataset,
        epochs=epochs,
        batch_size=batch_size,
        device=device,
        output_dir=output_dir,
    )
    return trained


def stage_crystallize(model: TropicalModel):
    model.crystallize()
    return model


def stage_benchmark(model, tokenizer, device: str, stage_name: str, quant_label: str):
    bench = BenchmarkSuite(tokenizer, device=device)
    return bench.run_inference_benchmark(model, stage_name, quant_label)


def main():
    parser = argparse.ArgumentParser(description="End-to-end Qwen optimization pipeline")
    parser.add_argument("--model", type=str, default="Qwen/Qwen2.5-3B-Instruct")
    parser.add_argument("--output_dir", type=str, default="./pipeline_results")
    parser.add_argument("--device", type=str, default="cuda" if torch.cuda.is_available() else "cpu")
    parser.add_argument("--skip_quantize", action="store_true")
    parser.add_argument("--skip_prune", action="store_true")
    parser.add_argument("--skip_distill", action="store_true")
    parser.add_argument("--skip_crystallize", action="store_true")
    parser.add_argument("--epochs", type=int, default=1)
    parser.add_argument("--batch_size", type=int, default=2)
    parser.add_argument("--num_samples", type=int, default=50)
    parser.add_argument("--prune_ratio", type=float, default=0.3)
    parser.add_argument("--unstructured", type=float, default=0.2)
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)
    logger = TelemetryLogger(os.path.join(args.output_dir, "telemetry.json"))
    timestamp = datetime.utcnow().isoformat()

    results = []

    # Stage 1: Download
    (model_path, tokenizer), t, err = run_stage(
        "Download", stage_download, args.model, os.path.join(args.output_dir, "model_cache")
    )
    if err:
        return

    # Stage 2: Baseline
    (baseline_model, baseline_result), t, err = run_stage(
        "Baseline", stage_baseline, model_path, tokenizer, args.device
    )
    if err:
        return
    results.append(baseline_result)
    logger.log(TelemetryEntry(
        timestamp=timestamp, stage=baseline_result.stage, model_name=args.model,
        quantization=baseline_result.quantization, vram_mb=baseline_result.vram_mb,
        tokens_per_sec_prefill=baseline_result.tokens_per_sec_prefill,
        tokens_per_sec_decode=baseline_result.tokens_per_sec_decode,
        perplexity=None, latency_ttft_ms=baseline_result.latency_ttft_ms,
        latency_tpot_ms=baseline_result.latency_tpot_ms, notes=baseline_result.notes,
    ))

    teacher = baseline_model

    # Stage 3: Quantize
    if not args.skip_quantize:
        (quant_model, quant_result), t, err = run_stage(
            "Quantize", stage_quantize, model_path, tokenizer, args.device
        )
        if not err:
            results.append(quant_result)
            logger.log(TelemetryEntry(
                timestamp=timestamp, stage=quant_result.stage, model_name=args.model,
                quantization=quant_result.quantization, vram_mb=quant_result.vram_mb,
                tokens_per_sec_prefill=quant_result.tokens_per_sec_prefill,
                tokens_per_sec_decode=quant_result.tokens_per_sec_decode,
                perplexity=None, latency_ttft_ms=quant_result.latency_ttft_ms,
                latency_tpot_ms=quant_result.latency_tpot_ms, notes=quant_result.notes,
            ))
            del quant_model
            torch.cuda.empty_cache()

    # Stage 4: Prune
    if not args.skip_prune:
        prune_stats, t, err = run_stage(
            "Prune", stage_prune, teacher, args.prune_ratio, args.unstructured
        )
        if not err:
            print(f"Pruning stats: {json.dumps({k: str(v) for k, v in prune_stats.items()}, indent=2)}")

    # Stage 5: Distill
    tropical_model = None
    if not args.skip_distill:
        tropical_model, t, err = run_stage(
            "Distill", stage_distill, teacher, tokenizer, args.device,
            args.epochs, args.batch_size, args.num_samples,
            output_dir=args.output_dir,
        )
        if not err:
            bench = BenchmarkSuite(tokenizer, device=args.device)
            dist_result = bench.run_inference_benchmark(
                tropical_model, "distilled", "tropical_fp16",
                notes=f"epochs={args.epochs}",
            )
            results.append(dist_result)
            logger.log(TelemetryEntry(
                timestamp=timestamp, stage=dist_result.stage, model_name="TropicalStudent",
                quantization=dist_result.quantization, vram_mb=dist_result.vram_mb,
                tokens_per_sec_prefill=dist_result.tokens_per_sec_prefill,
                tokens_per_sec_decode=dist_result.tokens_per_sec_decode,
                perplexity=None, latency_ttft_ms=dist_result.latency_ttft_ms,
                latency_tpot_ms=dist_result.latency_tpot_ms, notes=dist_result.notes,
            ))

    # Stage 6: Crystallize
    if not args.skip_crystallize and tropical_model is not None:
        _, t, err = run_stage("Crystallize", stage_crystallize, tropical_model)
        if not err:
            bench = BenchmarkSuite(tokenizer, device=args.device)
            cryst_result = bench.run_inference_benchmark(
                tropical_model, "crystallized", "ternary",
                notes="hard_attention=True",
            )
            results.append(cryst_result)
            logger.log(TelemetryEntry(
                timestamp=timestamp, stage=cryst_result.stage, model_name="CrystallizedStudent",
                quantization=cryst_result.quantization, vram_mb=cryst_result.vram_mb,
                tokens_per_sec_prefill=cryst_result.tokens_per_sec_prefill,
                tokens_per_sec_decode=cryst_result.tokens_per_sec_decode,
                perplexity=None, latency_ttft_ms=cryst_result.latency_ttft_ms,
                latency_tpot_ms=cryst_result.latency_tpot_ms, notes=cryst_result.notes,
            ))

    # Summary
    print("\n" + "=" * 80)
    print("Pipeline Summary")
    print("=" * 80)
    for r in results:
        print(
            f"{r.stage:<15} {r.quantization:<12} VRAM={r.vram_mb:<10.1f}MB "
            f"Decode={r.tokens_per_sec_decode:<8.1f}tok/s TPOT={r.latency_tpot_ms:<8.1f}ms"
        )
    print("=" * 80)
    print(f"Telemetry saved to: {os.path.join(args.output_dir, 'telemetry.json')}")


if __name__ == "__main__":
    main()
