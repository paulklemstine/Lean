#!/usr/bin/env python3
"""
Demo script for qwen_optimizer.
Runs a lightweight end-to-end pipeline on CPU (or GPU if available).
"""

import os
import torch
from datetime import datetime

from qwen_optimizer import (
    ModelCache,
    BenchmarkSuite,
    TelemetryLogger,
    TelemetryEntry,
)
from transformers import AutoModelForCausalLM, AutoTokenizer

CACHE_DIR = "./model_cache"
TELEMETRY_FILE = "./telemetry_demo.json"
MODEL_NAME = "Qwen/Qwen2.5-0.5B-Instruct"  # Small model for CPU demo


def main():
    print("=" * 60)
    print("Qwen Optimizer Demo")
    print("=" * 60)

    cache = ModelCache(CACHE_DIR)
    model_path = cache.get_model_path(MODEL_NAME)

    print(f"\nLoading {MODEL_NAME}...")
    tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
        device_map="auto" if torch.cuda.is_available() else "cpu",
        trust_remote_code=True,
    )
    print("Model loaded.")

    bench = BenchmarkSuite(tokenizer, device=model.device.type)
    logger = TelemetryLogger(TELEMETRY_FILE)

    result = bench.run_inference_benchmark(
        model,
        stage_name="demo_baseline",
        quantization_label="fp16" if torch.cuda.is_available() else "fp32",
    )

    logger.log(TelemetryEntry(
        timestamp=datetime.utcnow().isoformat(),
        stage=result.stage,
        model_name=MODEL_NAME,
        quantization=result.quantization,
        vram_mb=result.vram_mb,
        tokens_per_sec_prefill=result.tokens_per_sec_prefill,
        tokens_per_sec_decode=result.tokens_per_sec_decode,
        perplexity=result.perplexity,
        latency_ttft_ms=result.latency_ttft_ms,
        latency_tpot_ms=result.latency_tpot_ms,
        notes=result.notes,
    ))

    logger.summary()
    print(f"\nTelemetry saved to: {TELEMETRY_FILE}")


if __name__ == "__main__":
    main()
