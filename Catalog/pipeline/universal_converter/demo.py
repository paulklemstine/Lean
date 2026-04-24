#!/usr/bin/env python3
"""
═══════════════════════════════════════════════════════════════════════════
Universal HuggingFace → Exotic Neural Framework Converter — Demo
═══════════════════════════════════════════════════════════════════════════

This demo shows how to:
  1. Take any model architecture and convert it to exotic neurons
     (tropical, LogSumExp, OISC, morphological)
  2. Apply the full compression pipeline:
     quantize → prune → crystallize → optimize
  3. Benchmark VRAM usage and inference speed
  4. Compare output quality

Run:
    python -m pipeline.universal_converter.demo

For HuggingFace models (requires transformers + torch):
    python -m pipeline.universal_converter.demo --model gpt2
    python -m pipeline.universal_converter.demo --model Qwen/Qwen2.5-0.5B

═══════════════════════════════════════════════════════════════════════════
"""

import torch
import torch.nn as nn
import time
import sys
import os
import argparse
import json
import math
from typing import Dict, Any, Optional, Tuple

# Add project root to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from pipeline.universal_converter.tropical_neurons import (
    TropicalNeuron, LogSumExpNeuron, DualTropicalNeuron,
    OISCNeuron, MorphologicalNeuron, ExoticNeuronFactory,
)
from pipeline.universal_converter.weight_converter import (
    UniversalWeightConverter, WeightAnalyzer, ConversionStats,
)
from pipeline.universal_converter.compression import (
    QuantConfig, PruneConfig, CrystalConfig, LowRankConfig,
    FullCompressionConfig, full_compression_pipeline,
    Quantizer, Pruner, Crystallizer,
)
from pipeline.universal_converter.attention import (
    TropicalAttention, TopKTropicalAttention, LinearAttention,
    HybridTropicalTransformerBlock,
)


# ─────────────────────────────────────────────────────────────
# Utility functions
# ─────────────────────────────────────────────────────────────

def count_parameters(model: nn.Module) -> int:
    return sum(p.numel() for p in model.parameters())


def model_size_mb(model: nn.Module) -> float:
    return sum(p.numel() * p.element_size() for p in model.parameters()) / (1024 ** 2)


def measure_inference_time(
    model: nn.Module, input_tensor: torch.Tensor, n_runs: int = 100
) -> Dict[str, float]:
    """Benchmark inference latency."""
    model.eval()
    device = next(model.parameters()).device

    # Warmup
    with torch.no_grad():
        for _ in range(10):
            _ = model(input_tensor)

    # Timed runs
    if device.type == "cuda":
        torch.cuda.synchronize()

    times = []
    with torch.no_grad():
        for _ in range(n_runs):
            start = time.perf_counter()
            _ = model(input_tensor)
            if device.type == "cuda":
                torch.cuda.synchronize()
            times.append(time.perf_counter() - start)

    times_ms = [t * 1000 for t in times]
    return {
        "mean_ms": sum(times_ms) / len(times_ms),
        "median_ms": sorted(times_ms)[len(times_ms) // 2],
        "min_ms": min(times_ms),
        "max_ms": max(times_ms),
        "p99_ms": sorted(times_ms)[int(0.99 * len(times_ms))],
    }


def compare_outputs(
    original: nn.Module,
    converted: nn.Module,
    input_tensor: torch.Tensor,
) -> Dict[str, float]:
    """Compare outputs between original and converted models."""
    original.eval()
    converted.eval()
    with torch.no_grad():
        out_orig = original(input_tensor)
        out_conv = converted(input_tensor)

    if isinstance(out_orig, tuple):
        out_orig = out_orig[0]
    if isinstance(out_conv, tuple):
        out_conv = out_conv[0]

    diff = (out_orig - out_conv).float()
    return {
        "max_abs_error": diff.abs().max().item(),
        "mean_abs_error": diff.abs().mean().item(),
        "rmse": diff.pow(2).mean().sqrt().item(),
        "cosine_similarity": float(
            nn.functional.cosine_similarity(
                out_orig.float().flatten().unsqueeze(0),
                out_conv.float().flatten().unsqueeze(0),
            )
        ),
    }


# ─────────────────────────────────────────────────────────────
# Demo Models
# ─────────────────────────────────────────────────────────────

class DemoMLP(nn.Module):
    """Simple MLP for demonstration."""

    def __init__(self, in_dim: int = 256, hidden: int = 512, out_dim: int = 10):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(in_dim, hidden),
            nn.ReLU(),
            nn.Linear(hidden, hidden),
            nn.ReLU(),
            nn.Linear(hidden, out_dim),
        )

    def forward(self, x):
        return self.net(x)


class DemoTransformer(nn.Module):
    """Mini transformer for demonstration."""

    def __init__(
        self, vocab_size: int = 1000, embed_dim: int = 128,
        num_heads: int = 4, num_layers: int = 2, ff_dim: int = 256,
        max_seq_len: int = 64,
    ):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, embed_dim)
        self.pos_encoding = nn.Parameter(torch.randn(1, max_seq_len, embed_dim) * 0.02)

        self.layers = nn.ModuleList([
            nn.TransformerEncoderLayer(
                d_model=embed_dim, nhead=num_heads, dim_feedforward=ff_dim,
                batch_first=True, dropout=0.0,
            )
            for _ in range(num_layers)
        ])
        self.head = nn.Linear(embed_dim, vocab_size)

    def forward(self, x):
        h = self.embedding(x) + self.pos_encoding[:, :x.shape[1], :]
        for layer in self.layers:
            h = layer(h)
        return self.head(h)


class DemoTropicalTransformer(nn.Module):
    """Transformer built entirely from exotic neurons."""

    def __init__(
        self, vocab_size: int = 1000, embed_dim: int = 128,
        num_heads: int = 4, num_layers: int = 2, ff_dim: int = 256,
        max_seq_len: int = 64, top_k: int = 16,
    ):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, embed_dim)
        self.pos_encoding = nn.Parameter(torch.randn(1, max_seq_len, embed_dim) * 0.02)

        self.layers = nn.ModuleList([
            HybridTropicalTransformerBlock(
                embed_dim, num_heads, ff_dim,
                top_k=top_k, neuron_type="logsumexp",
            )
            for _ in range(num_layers)
        ])
        self.head = nn.Linear(embed_dim, vocab_size)

    def forward(self, x):
        h = self.embedding(x) + self.pos_encoding[:, :x.shape[1], :]
        for layer in self.layers:
            h = layer(h)
        return self.head(h)


# ─────────────────────────────────────────────────────────────
# Demo Scenarios
# ─────────────────────────────────────────────────────────────

def demo_exotic_neurons():
    """Demonstrate each exotic neuron type."""
    print("\n" + "═" * 70)
    print("  DEMO 1: Exotic Neuron Types")
    print("═" * 70)

    x = torch.randn(4, 64)  # batch=4, features=64

    for name in ExoticNeuronFactory.available():
        kwargs = {}
        if name == "logsumexp":
            kwargs["beta_init"] = 5.0
        elif name == "oisc":
            kwargs["n_ops"] = 4

        neuron = ExoticNeuronFactory.create(name, 64, 32, **kwargs)
        out = neuron(x)

        print(f"\n  {name:20s} | input: {tuple(x.shape)} → output: {tuple(out.shape)}")
        print(f"  {'':20s} | params: {count_parameters(neuron):,}")
        print(f"  {'':20s} | output range: [{out.min():.3f}, {out.max():.3f}]")

    # Compare classical vs tropical
    print("\n  --- Classical vs Tropical comparison ---")
    linear = nn.Linear(64, 32)
    tropical = TropicalNeuron(64, 32)
    tropical.weight.data.copy_(linear.weight.data)
    if tropical.bias is not None and linear.bias is not None:
        tropical.bias.data.copy_(linear.bias.data)

    out_linear = linear(x)
    out_tropical = tropical(x)
    print(f"  Linear output mean:   {out_linear.mean():.4f}")
    print(f"  Tropical output mean: {out_tropical.mean():.4f}")
    print(f"  Note: Tropical (max-plus) ≠ classical (dot-product)")
    print(f"  Tropical computes max_j(W_ij + x_j) vs Σ_j(W_ij * x_j)")


def demo_weight_conversion():
    """Demonstrate converting a classical model to exotic neurons."""
    print("\n" + "═" * 70)
    print("  DEMO 2: Universal Weight Conversion")
    print("═" * 70)

    model = DemoMLP(256, 512, 10)
    x = torch.randn(8, 256)

    print(f"\n  Original model: {count_parameters(model):,} params, "
          f"{model_size_mb(model):.2f} MB")

    for strategy in ["auto", "tropical", "logsumexp", "oisc"]:
        converter = UniversalWeightConverter(strategy=strategy)
        converted, stats = converter.convert(model)

        print(f"\n  Strategy: {strategy}")
        print(f"    Layers converted: {stats.layers_converted}")
        print(f"    Neuron types: {stats.neuron_type_counts}")
        print(f"    Params: {count_parameters(converted):,}")

        # Check output
        model.eval()
        converted.eval()
        with torch.no_grad():
            out_orig = model(x)
            out_conv = converted(x)
        print(f"    Output shape: {tuple(out_conv.shape)}")


def demo_compression_pipeline():
    """Demonstrate the full compression pipeline."""
    print("\n" + "═" * 70)
    print("  DEMO 3: Compression Pipeline")
    print("═" * 70)

    model = DemoMLP(256, 1024, 10)
    x = torch.randn(8, 256)

    original_params = count_parameters(model)
    original_size = model_size_mb(model)
    print(f"\n  Original: {original_params:,} params, {original_size:.2f} MB")

    # Measure original inference time
    times_orig = measure_inference_time(model, x, n_runs=50)
    print(f"  Original latency: {times_orig['mean_ms']:.3f} ms (mean)")

    # Full pipeline
    config = FullCompressionConfig(
        quantize=True,
        quant_config=QuantConfig(bits=4, group_size=128),
        prune=True,
        prune_config=PruneConfig(sparsity=0.5),
        crystallize=True,
        crystal_config=CrystalConfig(target="integer"),
    )

    compressed, report = full_compression_pipeline(model, config)

    print(f"\n  Compressed:")
    print(f"    Total params:     {report['total_params']:,}")
    print(f"    Non-zero params:  {report['nonzero_params']:,}")
    print(f"    Effective sparsity: {report['effective_sparsity']:.1%}")
    print(f"    Crystal error:    {report.get('crystallization_error', 0):.6f}")

    # Measure compressed inference time
    times_comp = measure_inference_time(compressed, x, n_runs=50)
    print(f"    Latency: {times_comp['mean_ms']:.3f} ms (mean)")
    speedup = times_orig['mean_ms'] / max(times_comp['mean_ms'], 1e-6)
    print(f"    Speedup: {speedup:.2f}x")


def demo_tropical_attention():
    """Demonstrate tropical attention mechanisms."""
    print("\n" + "═" * 70)
    print("  DEMO 4: Tropical Attention")
    print("═" * 70)

    B, T, D = 4, 32, 128
    H = 4
    x = torch.randn(B, T, D)

    mechanisms = {
        "Standard Softmax": nn.MultiheadAttention(D, H, batch_first=True),
        "Tropical (hardmax)": TropicalAttention(D, H),
        "Top-k Tropical (k=8)": TopKTropicalAttention(D, H, top_k=8),
        "Linear (kernel)": LinearAttention(D, H),
    }

    for name, attn in mechanisms.items():
        start = time.perf_counter()
        with torch.no_grad():
            if isinstance(attn, nn.MultiheadAttention):
                out, _ = attn(x, x, x)
            else:
                out = attn(x, x, x)
        elapsed = (time.perf_counter() - start) * 1000

        print(f"\n  {name:30s}")
        print(f"    Output shape: {tuple(out.shape)}")
        print(f"    Params: {count_parameters(attn):,}")
        print(f"    Time: {elapsed:.2f} ms")


def demo_tropical_transformer():
    """Demonstrate the full tropical transformer."""
    print("\n" + "═" * 70)
    print("  DEMO 5: Tropical Transformer vs Classical")
    print("═" * 70)

    vocab, dim, heads, layers = 1000, 128, 4, 2
    B, T = 4, 32

    classical = DemoTransformer(vocab, dim, heads, layers, dim * 2, T)
    tropical = DemoTropicalTransformer(vocab, dim, heads, layers, dim * 2, T)

    tokens = torch.randint(0, vocab, (B, T))

    print(f"\n  Classical Transformer:")
    print(f"    Params: {count_parameters(classical):,}")
    print(f"    Size: {model_size_mb(classical):.2f} MB")
    times_c = measure_inference_time(classical, tokens, n_runs=20)
    print(f"    Latency: {times_c['mean_ms']:.3f} ms")

    print(f"\n  Tropical Transformer:")
    print(f"    Params: {count_parameters(tropical):,}")
    print(f"    Size: {model_size_mb(tropical):.2f} MB")
    times_t = measure_inference_time(tropical, tokens, n_runs=20)
    print(f"    Latency: {times_t['mean_ms']:.3f} ms")


def demo_end_to_end():
    """Full pipeline: model → convert → compress → benchmark."""
    print("\n" + "═" * 70)
    print("  DEMO 6: End-to-End Pipeline")
    print("═" * 70)

    # 1. Create a model (simulating a HuggingFace download)
    print("\n  Step 1: Create model (simulating HuggingFace download)")
    model = DemoTransformer(vocab_size=5000, embed_dim=256, num_heads=8,
                            num_layers=4, ff_dim=512, max_seq_len=128)
    print(f"    Params: {count_parameters(model):,}")
    print(f"    Size: {model_size_mb(model):.2f} MB")

    tokens = torch.randint(0, 5000, (2, 64))

    # 2. Convert to exotic neurons
    print("\n  Step 2: Convert to exotic neurons (auto strategy)")
    converter = UniversalWeightConverter(strategy="auto", preserve_attention=True)
    exotic_model, conv_stats = converter.convert(model)
    print(f"    Converted layers: {conv_stats.layers_converted}")
    print(f"    Neuron types: {conv_stats.neuron_type_counts}")

    # 3. Compress
    print("\n  Step 3: Compress (quantize + prune + crystallize)")
    config = FullCompressionConfig(
        quantize=True,
        quant_config=QuantConfig(bits=4),
        prune=True,
        prune_config=PruneConfig(sparsity=0.5),
        crystallize=True,
        crystal_config=CrystalConfig(target="integer"),
    )
    compressed, report = full_compression_pipeline(exotic_model, config)
    print(f"    Non-zero params: {report['nonzero_params']:,}")
    print(f"    Sparsity: {report['effective_sparsity']:.1%}")

    # 4. Benchmark
    print("\n  Step 4: Benchmark")
    times_orig = measure_inference_time(model, tokens, n_runs=20)
    times_comp = measure_inference_time(compressed, tokens, n_runs=20)
    print(f"    Original latency:   {times_orig['mean_ms']:.3f} ms")
    print(f"    Compressed latency: {times_comp['mean_ms']:.3f} ms")
    speedup = times_orig['mean_ms'] / max(times_comp['mean_ms'], 1e-6)
    print(f"    Speedup: {speedup:.2f}x")

    # 5. Summary
    print("\n  ┌─────────────────────────────────────────────┐")
    print("  │           Pipeline Summary                  │")
    print("  ├─────────────────────────────────────────────┤")
    print(f"  │ Original params:      {count_parameters(model):>15,} │")
    print(f"  │ Compressed non-zero:  {report['nonzero_params']:>15,} │")
    print(f"  │ Effective reduction:  {report['effective_sparsity']:>14.1%} │")
    print(f"  │ Latency (original):   {times_orig['mean_ms']:>11.3f} ms │")
    print(f"  │ Latency (compressed): {times_comp['mean_ms']:>11.3f} ms │")
    print(f"  │ Speedup:              {speedup:>14.2f}x │")
    print("  └─────────────────────────────────────────────┘")


def demo_crystallization_theory():
    """Demonstrate crystallization with formal guarantees."""
    print("\n" + "═" * 70)
    print("  DEMO 7: Crystallization Theory (Formally Verified)")
    print("═" * 70)

    print("\n  The crystallization penalty sin²(πw) = 0 iff w ∈ ℤ")
    print("  (Proven in Lean: crystal_penalty_zero_at_int)")
    print()

    # Show penalty at various points
    import numpy as np
    test_points = [0.0, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0, 1.5, 2.0, 3.14]
    for w in test_points:
        penalty = math.sin(math.pi * w) ** 2
        is_int = "✓ integer" if abs(w - round(w)) < 1e-10 else ""
        print(f"    w = {w:6.2f}  →  sin²(πw) = {penalty:.6f}  {is_int}")

    # Demonstrate weight crystallization
    print("\n  Weight crystallization demo:")
    W = torch.randn(4, 4) * 3  # random weights
    print(f"    Original weights:\n{W.numpy()}")
    W_crystal = Crystallizer.crystallize_weights(W, target="integer")
    print(f"    Crystallized (integer):\n{W_crystal.numpy()}")
    error = (W - W_crystal).abs()
    print(f"    Per-element error ≤ 0.5: {(error <= 0.5 + 1e-6).all().item()}")
    print(f"    (Proven in Lean: crystal_error_bound)")

    # Ternary crystallization
    W_ternary = Crystallizer.crystallize_weights(W, target="ternary")
    print(f"\n    Crystallized (ternary ∈ {{-1,0,+1}}):\n{W_ternary.numpy()}")


def demo_huggingface_model(model_name: str):
    """Convert a real HuggingFace model (requires transformers)."""
    print("\n" + "═" * 70)
    print(f"  DEMO HF: Converting {model_name}")
    print("═" * 70)

    try:
        from transformers import AutoModel, AutoTokenizer
    except ImportError:
        print("  [!] Install transformers: pip install transformers")
        print("  Falling back to demo models...")
        demo_end_to_end()
        return

    print(f"\n  Loading {model_name} from HuggingFace...")
    try:
        model = AutoModel.from_pretrained(model_name, trust_remote_code=True)
        tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
    except Exception as e:
        print(f"  [!] Failed to load model: {e}")
        print("  Falling back to demo models...")
        demo_end_to_end()
        return

    original_params = count_parameters(model)
    original_size = model_size_mb(model)
    print(f"  Loaded: {original_params:,} params, {original_size:.2f} MB")

    # Analyze weights
    print("\n  Analyzing weight structure...")
    analyzer = WeightAnalyzer()
    for name, param in list(model.named_parameters())[:5]:
        if param.dim() >= 2:
            fitness = analyzer.compute_tropical_fitness(param.data)
            rank = analyzer.compute_effective_rank(param.data)
            sparsity = analyzer.compute_sparsity(param.data)
            recommended = analyzer.recommend_neuron_type(param.data)
            print(f"    {name[:50]:50s} | tropical={fitness:.2f} rank={rank} "
                  f"sparse={sparsity:.2f} → {recommended}")

    # Convert
    print("\n  Converting to exotic neurons...")
    converter = UniversalWeightConverter(strategy="auto", preserve_attention=True)
    exotic, stats = converter.convert(model)
    print(f"  Converted: {stats.layers_converted} layers")
    print(f"  Types: {stats.neuron_type_counts}")

    # Compress
    print("\n  Compressing...")
    config = FullCompressionConfig(
        quantize=True,
        quant_config=QuantConfig(bits=4),
        prune=True,
        prune_config=PruneConfig(sparsity=0.5),
        crystallize=True,
        crystal_config=CrystalConfig(target="integer"),
    )
    compressed, report = full_compression_pipeline(exotic, config)

    print(f"\n  ┌─────────────────────────────────────────────┐")
    print(f"  │  {model_name:^41s}  │")
    print(f"  ├─────────────────────────────────────────────┤")
    print(f"  │ Original params:      {original_params:>15,} │")
    print(f"  │ Original size:        {original_size:>11.2f} MB │")
    print(f"  │ Non-zero after comp:  {report['nonzero_params']:>15,} │")
    print(f"  │ Effective sparsity:   {report['effective_sparsity']:>14.1%} │")
    print(f"  └─────────────────────────────────────────────┘")


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Universal HuggingFace → Exotic Neural Framework Demo"
    )
    parser.add_argument(
        "--model", type=str, default=None,
        help="HuggingFace model name (e.g., gpt2, bert-base-uncased)"
    )
    parser.add_argument(
        "--demo", type=str, default="all",
        choices=["all", "neurons", "convert", "compress", "attention",
                 "transformer", "e2e", "crystal", "hf"],
        help="Which demo to run"
    )
    args = parser.parse_args()

    print("╔═══════════════════════════════════════════════════════════════════╗")
    print("║   Universal HuggingFace → Exotic Neural Framework Converter     ║")
    print("║   Tropical · OISC · Morphological · Crystallization             ║")
    print("║   Formally verified compression bounds (Lean 4 + Mathlib)       ║")
    print("╚═══════════════════════════════════════════════════════════════════╝")

    demos = {
        "neurons": demo_exotic_neurons,
        "convert": demo_weight_conversion,
        "compress": demo_compression_pipeline,
        "attention": demo_tropical_attention,
        "transformer": demo_tropical_transformer,
        "e2e": demo_end_to_end,
        "crystal": demo_crystallization_theory,
    }

    if args.model:
        demo_huggingface_model(args.model)
    elif args.demo == "all":
        for name, fn in demos.items():
            fn()
    elif args.demo == "hf":
        demo_huggingface_model(args.model or "gpt2")
    else:
        demos[args.demo]()

    print("\n" + "═" * 70)
    print("  All demos complete.")
    print("  See Lean formalizations in MachineLearning/Neural/UniversalConverter/")
    print("  See research paper in UNIVERSAL_CONVERTER_PAPER.md")
    print("═" * 70)


if __name__ == "__main__":
    main()
