#!/usr/bin/env python3
"""
Side-by-side benchmark comparing standard, tropical, quantized,
and crystallized Qwen models.

Usage:
    python compare_benchmark.py \
        --teacher Qwen/Qwen2.5-3B-Instruct \
        --device cuda \
        --output_dir ./benchmark_results
"""

import argparse
import json
import os
import time
from datetime import datetime
from typing import List, Optional

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

from qwen_optimizer import (
    BenchmarkSuite,
    ModelCache,
    TelemetryEntry,
    TelemetryLogger,
    TropicalModel,
    convert_to_tropical,
)
from qwen_optimizer.telemetry import TelemetryLogger, TelemetryEntry


# ---------------------------------------------------------------------------
# Synthetic prompts for consistent benchmarking
# ---------------------------------------------------------------------------
DEFAULT_PROMPTS = [
    "Explain the Pythagorean theorem in one sentence:",
    "The capital of France is",
    "Solve for x: 2x + 3 = 7",
    "In quantum mechanics, the uncertainty principle states",
    "The theory of relativity states that",
    "To calculate the area of a circle, use",
    "In machine learning, overfitting occurs when",
    "The main advantage of tropical geometry is",
]


def print_banner(title: str):
    print("\n" + "=" * 60)
    print(title)
    print("=" * 60)


def run_standard_benchmark(
    model_name: str,
    device: str,
    output_dir: str,
    prompts: List[str] = None,
) -> dict:
    """Benchmark the standard (teacher) model."""
    print_banner("Standard Model Benchmark")

    cache = ModelCache(os.path.join(output_dir, "model_cache"))
    model_path = cache.get_model_path(model_name)

    tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
    bench = BenchmarkSuite(tokenizer, device=device)

    t0 = time.time()
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float16 if device == "cuda" else torch.float32,
        device_map="auto" if device == "cuda" else "cpu",
        trust_remote_code=True,
    )
    load_time = time.time() - t0
    print(f"Loaded in {load_time:.1f}s")

    result = bench.run_inference_benchmark(
        model,
        stage_name="standard",
        quantization_label="fp16" if device == "cuda" else "fp32",
        load_time=load_time,
        notes=f"teacher={model_name}",
    )

    # Text quality benchmark on multiple prompts
    if prompts:
        print("Running generation quality check...")
        for prompt in prompts[:3]:
            inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
            with torch.no_grad():
                outputs = model.generate(**inputs, max_new_tokens=30, do_sample=False)
            text = tokenizer.decode(outputs[0], skip_special_tokens=True)
            print(f"  Prompt: {prompt[:40]}... | Output: {text[:60]}...")

    del model
    torch.cuda.empty_cache()
    return {
        "stage": result.stage,
        "quantization": result.quantization,
        "vram_mb": result.vram_mb,
        "tokens_per_sec_prefill": result.tokens_per_sec_prefill,
        "tokens_per_sec_decode": result.tokens_per_sec_decode,
        "latency_ttft_ms": result.latency_ttft_ms,
        "latency_tpot_ms": result.latency_tpot_ms,
        "load_time_s": result.load_time_s,
        "notes": result.notes,
    }


def run_tropical_benchmark(
    teacher_name: str,
    device: str,
    output_dir: str,
    student_config: Optional[dict] = None,
    prompts: List[str] = None,
) -> dict:
    """Benchmark a tropical student model."""
    print_banner("Tropical Model Benchmark")

    cache = ModelCache(os.path.join(output_dir, "model_cache"))
    model_path = cache.get_model_path(teacher_name)

    tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
    bench = BenchmarkSuite(tokenizer, device=device)

    # Load teacher to extract config
    teacher = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float16 if device == "cuda" else torch.float32,
        device_map="auto" if device == "cuda" else "cpu",
        trust_remote_code=True,
    )

    if student_config is None:
        # Default small tropical config for fast benchmarking
        student_config = {
            "vocab_size": teacher.config.vocab_size,
            "d_model": 512,
            "num_layers": 6,
            "num_heads": 8,
            "d_ff": 1024,
            "max_seq_len": 2048,
            "dropout": 0.0,
            "hard_attention": False,
        }

    tropical_model = TropicalModel(**student_config)
    tropical_model.to(device)
    tropical_model.eval()

    t0 = time.time()
    result = bench.run_inference_benchmark(
        tropical_model,
        stage_name="tropical",
        quantization_label="tropical_fp16",
        load_time=0.0,
        notes=f"student_d={student_config['d_model']}_l={student_config['num_layers']}",
    )
    result.load_time_s = time.time() - t0

    print(f"Tropical params: {sum(p.numel() for p in tropical_model.parameters()) / 1e6:.1f}M")
    print(f"Tropical VRAM: {result.vram_mb:.1f} MB")

    # Quick sanity generation
    if prompts:
        print("Running tropical generation sanity check...")
        for prompt in prompts[:2]:
            inputs = tokenizer(prompt, return_tensors="pt").to(device)
            with torch.no_grad():
                logits = tropical_model(inputs.input_ids, is_causal=True)
                next_token = torch.argmax(logits[:, -1, :], dim=-1)
            text = tokenizer.decode(next_token, skip_special_tokens=True)
            print(f"  Prompt: {prompt[:40]}... | Next token: {text}")

    del teacher, tropical_model
    torch.cuda.empty_cache()
    return {
        "stage": result.stage,
        "quantization": result.quantization,
        "vram_mb": result.vram_mb,
        "tokens_per_sec_prefill": result.tokens_per_sec_prefill,
        "tokens_per_sec_decode": result.tokens_per_sec_decode,
        "latency_ttft_ms": result.latency_ttft_ms,
        "latency_tpot_ms": result.latency_tpot_ms,
        "load_time_s": result.load_time_s,
        "notes": result.notes,
    }


def run_crystallized_benchmark(
    teacher_name: str,
    device: str,
    output_dir: str,
    student_config: Optional[dict] = None,
    prompts: List[str] = None,
) -> dict:
    """Benchmark a crystallized tropical model."""
    print_banner("Crystallized Model Benchmark")

    cache = ModelCache(os.path.join(output_dir, "model_cache"))
    model_path = cache.get_model_path(teacher_name)

    tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
    bench = BenchmarkSuite(tokenizer, device=device)

    if student_config is None:
        student_config = {
            "vocab_size": getattr(
                AutoTokenizer.from_pretrained(model_path, trust_remote_code=True),
                "vocab_size",
                151936,
            ),
            "d_model": 512,
            "num_layers": 6,
            "num_heads": 8,
            "d_ff": 1024,
            "max_seq_len": 2048,
            "dropout": 0.0,
            "hard_attention": True,
        }

    tropical_model = TropicalModel(**student_config)
    tropical_model.to(device)

    # Crystallize weights
    print("Crystallizing weights to {-1, 0, 1}...")
    tropical_model.crystallize()

    tropical_model.eval()

    t0 = time.time()
    result = bench.run_inference_benchmark(
        tropical_model,
        stage_name="crystallized",
        quantization_label="ternary",
        load_time=0.0,
        notes=f"hard_attention=True_crystallized",
    )
    result.load_time_s = time.time() - t0

    print(f"Crystallized params: {sum(p.numel() for p in tropical_model.parameters()) / 1e6:.1f}M")
    print(f"Crystallized VRAM: {result.vram_mb:.1f} MB")

    del tropical_model
    torch.cuda.empty_cache()
    return {
        "stage": result.stage,
        "quantization": result.quantization,
        "vram_mb": result.vram_mb,
        "tokens_per_sec_prefill": result.tokens_per_sec_prefill,
        "tokens_per_sec_decode": result.tokens_per_sec_decode,
        "latency_ttft_ms": result.latency_ttft_ms,
        "latency_tpot_ms": result.latency_tpot_ms,
        "load_time_s": result.load_time_s,
        "notes": result.notes,
    }


def print_comparison_table(results: List[dict]):
    """Pretty-print a comparison table."""
    print("\n" + "=" * 100)
    print(f"{'Stage':<15} {'Quant':<12} {'VRAM (MB)':<12} {'Prefill (t/s)':<15} {'Decode (t/s)':<15} {'TTFT (ms)':<12} {'TPOT (ms)':<12}")
    print("-" * 100)
    for r in results:
        print(
            f"{r['stage']:<15} {r['quantization']:<12} {r['vram_mb']:<12.1f} "
            f"{r['tokens_per_sec_prefill']:<15.1f} {r['tokens_per_sec_decode']:<15.1f} "
            f"{r['latency_ttft_ms']:<12.1f} {r['latency_tpot_ms']:<12.1f}"
        )
    print("=" * 100)


def main():
    parser = argparse.ArgumentParser(description="Compare standard, tropical, and crystallized models")
    parser.add_argument("--teacher", type=str, default="Qwen/Qwen2.5-3B-Instruct")
    parser.add_argument("--device", type=str, default="cuda" if torch.cuda.is_available() else "cpu")
    parser.add_argument("--output_dir", type=str, default="./benchmark_results")
    parser.add_argument("--skip_standard", action="store_true", help="Skip standard model benchmark")
    parser.add_argument("--skip_tropical", action="store_true", help="Skip tropical model benchmark")
    parser.add_argument("--skip_crystallized", action="store_true", help="Skip crystallized model benchmark")
    parser.add_argument("--student_config", type=str, default=None, help="JSON file with student config")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)
    logger = TelemetryLogger(os.path.join(args.output_dir, "telemetry.json"))

    student_config = None
    if args.student_config:
        with open(args.student_config, "r") as f:
            student_config = json.load(f)

    results = []
    timestamp = datetime.utcnow().isoformat()

    if not args.skip_standard:
        try:
            res = run_standard_benchmark(
                args.teacher, args.device, args.output_dir, prompts=DEFAULT_PROMPTS
            )
            results.append(res)
            logger.log(TelemetryEntry(
                timestamp=timestamp,
                stage=res["stage"],
                model_name=args.teacher,
                quantization=res["quantization"],
                vram_mb=res["vram_mb"],
                tokens_per_sec_prefill=res["tokens_per_sec_prefill"],
                tokens_per_sec_decode=res["tokens_per_sec_decode"],
                perplexity=None,
                latency_ttft_ms=res["latency_ttft_ms"],
                latency_tpot_ms=res["latency_tpot_ms"],
                notes=res["notes"],
            ))
        except Exception as e:
            print(f"Standard benchmark failed: {e}")

    if not args.skip_tropical:
        try:
            res = run_tropical_benchmark(
                args.teacher, args.device, args.output_dir, student_config=student_config, prompts=DEFAULT_PROMPTS
            )
            results.append(res)
            logger.log(TelemetryEntry(
                timestamp=timestamp,
                stage=res["stage"],
                model_name="TropicalStudent",
                quantization=res["quantization"],
                vram_mb=res["vram_mb"],
                tokens_per_sec_prefill=res["tokens_per_sec_prefill"],
                tokens_per_sec_decode=res["tokens_per_sec_decode"],
                perplexity=None,
                latency_ttft_ms=res["latency_ttft_ms"],
                latency_tpot_ms=res["latency_tpot_ms"],
                notes=res["notes"],
            ))
        except Exception as e:
            print(f"Tropical benchmark failed: {e}")

    if not args.skip_crystallized:
        try:
            res = run_crystallized_benchmark(
                args.teacher, args.device, args.output_dir, student_config=student_config, prompts=DEFAULT_PROMPTS
            )
            results.append(res)
            logger.log(TelemetryEntry(
                timestamp=timestamp,
                stage=res["stage"],
                model_name="CrystallizedStudent",
                quantization=res["quantization"],
                vram_mb=res["vram_mb"],
                tokens_per_sec_prefill=res["tokens_per_sec_prefill"],
                tokens_per_sec_decode=res["tokens_per_sec_decode"],
                perplexity=None,
                latency_ttft_ms=res["latency_ttft_ms"],
                latency_tpot_ms=res["latency_tpot_ms"],
                notes=res["notes"],
            ))
        except Exception as e:
            print(f"Crystallized benchmark failed: {e}")

    print_comparison_table(results)

    summary_path = os.path.join(args.output_dir, "summary.json")
    with open(summary_path, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\nSummary saved to {summary_path}")
    print(f"Telemetry saved to {os.path.join(args.output_dir, 'telemetry.json')}")


if __name__ == "__main__":
    main()
