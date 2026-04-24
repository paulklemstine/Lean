#!/usr/bin/env python3
"""Automated hyperparameter sweep runner for Crystalline experiments.

Usage:
    python run_sweep.py --config experiments/sweep_config.yaml
"""

import argparse
import itertools
import json
import os
import time
from datetime import datetime

import torch
import yaml
from transformers import AutoModelForCausalLM, AutoTokenizer

from crystalline import CrystallineModel, CrystallineConfig
from crystalline.train import (
    generate_synthetic_data,
    TextDataset,
    train_crystalline_model,
)
from qwen_optimizer.benchmark import BenchmarkSuite
from qwen_optimizer.telemetry import TelemetryLogger, TelemetryEntry
from qwen_optimizer.download import ModelCache


def load_config(path: str) -> dict:
    with open(path, "r") as f:
        return yaml.safe_load(f)


def run_single_experiment(
    teacher,
    tokenizer,
    config: dict,
    student_cfg: dict,
    temperature: float,
    alpha: float,
    epochs: int,
    batch_size: int,
    crystallization_weight: float,
    device: str,
) -> dict:
    """Run one training experiment and return metrics."""
    student_config = CrystallineConfig(
        vocab_size=teacher.config.vocab_size,
        d_model=student_cfg["d_model"],
        num_layers=student_cfg["num_layers"],
        num_heads=student_cfg["num_heads"],
        d_ff=student_cfg["d_ff"],
        max_seq_len=512,
        dropout=0.1,
        use_delta_net=False,
        num_experts=1,
    )
    student = CrystallineModel(student_config).to(device)

    # Generate synthetic data
    texts = generate_synthetic_data(
        teacher, tokenizer,
        num_samples=config["dataset"]["num_samples"],
        max_length=config["dataset"]["max_length"],
        device=device,
    )
    dataset = TextDataset(texts, tokenizer, max_length=config["dataset"]["max_length"])

    # Train
    t0 = time.time()
    trained = train_crystalline_model(
        teacher=teacher,
        student=student,
        tokenizer=tokenizer,
        dataset=dataset,
        epochs=epochs,
        batch_size=batch_size,
        lr=config["training"]["lr"],
        device=device,
        temperature=temperature,
        alpha=alpha,
        crystallization_weight=crystallization_weight,
        output_dir=os.path.join(config["output_dir"], "checkpoints"),
        max_length=config["dataset"]["max_length"],
    )
    train_time = time.time() - t0

    # Benchmark
    bench = BenchmarkSuite(tokenizer, device=device)
    result = bench.run_inference_benchmark(
        trained,
        stage_name=f\"sweep_{student_cfg['name']}_T{temperature}_a{alpha}\",
        quantization_label="crystalline_fp16",
        notes=f\"epochs={epochs},bs={batch_size},lambda={crystallization_weight}\",
    )

    return {
        "stage": result.stage,
        "student": student_cfg["name"],
        "temperature": temperature,
        "alpha": alpha,
        "epochs": epochs,
        "batch_size": batch_size,
        "crystallization_weight": crystallization_weight,
        "vram_mb": result.vram_mb,
        "tokens_per_sec_prefill": result.tokens_per_sec_prefill,
        "tokens_per_sec_decode": result.tokens_per_sec_decode,
        "latency_ttft_ms": result.latency_ttft_ms,
        "latency_tpot_ms": result.latency_tpot_ms,
        "train_time_s": train_time,
    }


def main():
    parser = argparse.ArgumentParser(description="Run Crystalline hyperparameter sweep")
    parser.add_argument("--config", type=str, default="experiments/sweep_config.yaml")
    parser.add_argument("--device", type=str, default=None)
    args = parser.parse_args()

    config = load_config(args.config)
    device = args.device or config.get("device", "cuda" if torch.cuda.is_available() else "cpu")
    os.makedirs(config["output_dir"], exist_ok=True)

    # Load teacher
    cache = ModelCache(os.path.join(config["output_dir"], "model_cache"))
    model_path = cache.get_model_path(config["model"])
    tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
    teacher = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float16 if device == "cuda" else torch.float32,
        device_map="auto" if device == "cuda" else "cpu",
        trust_remote_code=True,
    )

    # Setup telemetry
    logger = TelemetryLogger(config["telemetry_file"])
    bench = BenchmarkSuite(tokenizer, device=device)
    baseline = bench.run_inference_benchmark(teacher, "baseline_fp16", "fp16")
    logger.log(TelemetryEntry(
        timestamp=datetime.utcnow().isoformat(),
        stage=baseline.stage,
        model_name=config["model"],
        quantization=baseline.quantization,
        vram_mb=baseline.vram_mb,
        tokens_per_sec_prefill=baseline.tokens_per_sec_prefill,
        tokens_per_sec_decode=baseline.tokens_per_sec_decode,
        perplexity=None,
        latency_ttft_ms=baseline.latency_ttft_ms,
        latency_tpot_ms=baseline.latency_tpot_ms,
        notes="sweep baseline",
    ))

    # Build sweep grid
    grid = list(itertools.product(
        config["student_configs"],
        config["distillation"]["temperatures"],
        config["distillation"]["alphas"],
        config["distillation"]["epochs"],
        config["distillation"]["batch_sizes"],
        config["crystallization"]["weights"],
    ))

    print(f"Running {len(grid)} experiments...")
    results = []

    for student_cfg, temp, alpha, epochs, bs, cryst_w in grid:
        print(f"\n--- Running: {student_cfg['name']} | T={temp} | alpha={alpha} | epochs={epochs} | bs={bs} | lambda={cryst_w} ---")
        try:
            metrics = run_single_experiment(
                teacher, tokenizer, config, student_cfg,
                temp, alpha, epochs, bs, cryst_w, device,
            )
            results.append(metrics)
            logger.log(TelemetryEntry(
                timestamp=datetime.utcnow().isoformat(),
                stage=metrics["stage"],
                model_name=f"Crystalline-{student_cfg['name']}",
                quantization="crystalline_fp16",
                vram_mb=metrics["vram_mb"],
                tokens_per_sec_prefill=metrics["tokens_per_sec_prefill"],
                tokens_per_sec_decode=metrics["tokens_per_sec_decode"],
                perplexity=None,
                latency_ttft_ms=metrics["latency_ttft_ms"],
                latency_tpot_ms=metrics["latency_tpot_ms"],
                notes=f"T={temp},alpha={alpha},epochs={epochs},bs={bs},lambda={cryst_w}",
            ))
            print(f"  VRAM: {metrics['vram_mb']:.1f}MB | Decode: {metrics['tokens_per_sec_decode']:.1f} tok/s")
        except Exception as e:
            print(f"  FAILED: {e}")
            results.append({"error": str(e), "student": student_cfg["name"]})

    # Save results
    results_path = os.path.join(config["output_dir"], "sweep_results.json")
    with open(results_path, "w") as f:
        json.dump(results, f, indent=2)

    logger.summary()
    print(f"\nResults saved to: {results_path}")
    print(f"Telemetry saved to: {config['telemetry_file']}")


if __name__ == "__main__":
    main()
