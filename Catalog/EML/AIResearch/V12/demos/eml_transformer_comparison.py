#!/usr/bin/env python3
"""
EML vs Standard Transformer Parameter Comparison — v12 Demo

Demonstrates the parameter savings of EML-based transformer architectures
compared to standard transformers across various model sizes.
"""

import math
import json

def transformer_ffn_params(d_model):
    """Standard transformer FFN: 2 dense layers with 4x expansion."""
    return 2 * d_model * (4 * d_model)

def eml_ffn_params(d_model):
    """EML FFN replacement: 4 EML coefficients × 4 expansion."""
    return 4 * d_model * 4

def std_layer_params(num_heads, d_model, d_k):
    """Standard transformer layer: attention + FFN + layernorm."""
    attn = num_heads * 4 * d_model * d_k  # Q, K, V, O projections
    ffn = transformer_ffn_params(d_model)
    ln = 2 * d_model
    return attn + ffn + ln

def eml_layer_params(num_heads, d_model, d_k):
    """EML transformer layer."""
    attn = num_heads * 8 * d_k  # EML attention
    ffn = eml_ffn_params(d_model)
    ln = 2 * d_model
    return attn + ffn + ln

def total_params(num_layers, num_heads, d_model, d_k, vocab_size, use_eml=False):
    """Total transformer parameters."""
    layer_fn = eml_layer_params if use_eml else std_layer_params
    layers = num_layers * layer_fn(num_heads, d_model, d_k)
    embeddings = vocab_size * d_model
    return layers + embeddings

# Standard model configurations
configs = {
    "GPT-2 Small":   {"layers": 12, "heads": 12, "d_model": 768,  "d_k": 64,  "vocab": 50257},
    "GPT-2 Medium":  {"layers": 24, "heads": 16, "d_model": 1024, "d_k": 64,  "vocab": 50257},
    "GPT-2 Large":   {"layers": 36, "heads": 20, "d_model": 1280, "d_k": 64,  "vocab": 50257},
    "GPT-2 XL":      {"layers": 48, "heads": 25, "d_model": 1600, "d_k": 64,  "vocab": 50257},
    "BERT Base":     {"layers": 12, "heads": 12, "d_model": 768,  "d_k": 64,  "vocab": 30522},
    "BERT Large":    {"layers": 24, "heads": 16, "d_model": 1024, "d_k": 64,  "vocab": 30522},
    "LLaMA 7B":      {"layers": 32, "heads": 32, "d_model": 4096, "d_k": 128, "vocab": 32000},
    "LLaMA 13B":     {"layers": 40, "heads": 40, "d_model": 5120, "d_k": 128, "vocab": 32000},
    "LLaMA 70B":     {"layers": 80, "heads": 64, "d_model": 8192, "d_k": 128, "vocab": 32000},
}

print("=" * 100)
print("EML vs Standard Transformer — Parameter Comparison")
print("=" * 100)
print()
print(f"{'Model':<18} {'Std Params':>14} {'EML Params':>14} {'Compression':>12} {'Savings %':>10}")
print("-" * 100)

results = {}
for name, cfg in configs.items():
    std = total_params(cfg["layers"], cfg["heads"], cfg["d_model"],
                       cfg["d_k"], cfg["vocab"], use_eml=False)
    eml = total_params(cfg["layers"], cfg["heads"], cfg["d_model"],
                       cfg["d_k"], cfg["vocab"], use_eml=True)
    ratio = std / eml if eml > 0 else float('inf')
    savings = (1 - eml / std) * 100 if std > 0 else 0

    def fmt(n):
        if n >= 1e9: return f"{n/1e9:.1f}B"
        if n >= 1e6: return f"{n/1e6:.1f}M"
        if n >= 1e3: return f"{n/1e3:.1f}K"
        return str(n)

    print(f"{name:<18} {fmt(std):>14} {fmt(eml):>14} {ratio:>11.1f}× {savings:>9.1f}%")
    results[name] = {"std": std, "eml": eml, "ratio": ratio, "savings": savings}

print()
print("=" * 100)
print()

# FFN-specific comparison
print("Feed-Forward Network Compression Ratios:")
print("-" * 60)
for d in [256, 512, 768, 1024, 2048, 4096, 8192]:
    std_ffn = transformer_ffn_params(d)
    eml_ffn = eml_ffn_params(d)
    ratio = std_ffn / eml_ffn
    print(f"  d_model = {d:>5}: Standard FFN = {fmt(std_ffn):>8}, EML FFN = {fmt(eml_ffn):>6}, Ratio = {ratio:.0f}×")

print()

# Training cost comparison (Chinchilla scaling)
print("Training Cost Comparison (6 × N × D FLOPs):")
print("-" * 80)
for name, cfg in configs.items():
    std = total_params(cfg["layers"], cfg["heads"], cfg["d_model"],
                       cfg["d_k"], cfg["vocab"], use_eml=False)
    eml = total_params(cfg["layers"], cfg["heads"], cfg["d_model"],
                       cfg["d_k"], cfg["vocab"], use_eml=True)
    # Chinchilla: 20N tokens for standard, 10N for EML
    std_flops = 6 * std * (20 * std)
    eml_flops = 6 * eml * (10 * eml)
    flop_ratio = std_flops / eml_flops if eml_flops > 0 else float('inf')
    print(f"  {name:<18}: Training FLOP ratio = {flop_ratio:.1f}× (EML cheaper)")

print()
print("Key Insight: EML transformers achieve dramatic parameter savings in")
print("the attention and FFN layers, while embedding layers remain the same.")
print("For large models (LLaMA 70B scale), layer savings dominate embeddings,")
print("yielding overall compression ratios exceeding 100×.")

# Save results
with open("eml_transformer_results.json", "w") as f:
    json.dump(results, f, indent=2)
print("\nResults saved to eml_transformer_results.json")
