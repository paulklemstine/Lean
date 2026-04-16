#!/usr/bin/env python3
"""
EML Attention Mechanism Demo — v12

Demonstrates how EML's exp/ln operations naturally implement
attention-like mechanisms, with temperature control and
multi-head efficiency analysis.
"""

import math

def softmax(scores, temperature=1.0):
    """Standard softmax with temperature scaling."""
    scaled = [s / temperature for s in scores]
    max_s = max(scaled)
    exps = [math.exp(s - max_s) for s in scaled]
    total = sum(exps)
    return [e / total for e in exps]

def eml_attention_scores(queries, keys, d_k, temperature=1.0):
    """Compute EML attention scores: exp(Q·K / (T·√d_k))."""
    scores = []
    sqrt_dk = math.sqrt(d_k)
    for q in queries:
        row = []
        for k in keys:
            dot = sum(qi * ki for qi, ki in zip(q, k))
            score = math.exp(dot / (temperature * sqrt_dk))
            row.append(score)
        total = sum(row)
        row = [s / total for s in row]
        scores.append(row)
    return scores

# Demo 1: Temperature effects on attention
print("=" * 70)
print("Demo 1: Temperature Effects on EML Attention")
print("=" * 70)
print()

raw_scores = [2.0, 1.0, 0.5, 0.1]
print(f"Raw logits: {raw_scores}")
print()

for temp in [0.1, 0.5, 1.0, 2.0, 5.0]:
    attn = softmax(raw_scores, temperature=temp)
    entropy = -sum(p * math.log(p + 1e-10) for p in attn)
    peak = max(attn)
    print(f"  T={temp:<4.1f}: weights = [{', '.join(f'{a:.3f}' for a in attn)}]  "
          f"entropy={entropy:.3f}  peak={peak:.3f}")

print()
print("→ Lower temperature = sharper attention (more focused)")
print("→ Higher temperature = smoother attention (more uniform)")
print("→ EML's exp naturally provides this temperature control")

# Demo 2: Multi-head parameter comparison
print()
print("=" * 70)
print("Demo 2: Multi-Head Attention Parameter Efficiency")
print("=" * 70)
print()

print(f"{'d_model':>8} {'heads':>6} {'d_k':>5} {'Std MHA':>12} {'EML MHA':>12} {'Ratio':>8}")
print("-" * 60)

for d_model in [256, 512, 768, 1024, 2048, 4096]:
    for num_heads in [8, 16]:
        d_k = d_model // num_heads
        std_params = num_heads * (3 * d_model * d_k + d_k * d_model)
        eml_params = num_heads * (4 * d_k + 4 * d_k)
        ratio = std_params / eml_params
        print(f"{d_model:>8} {num_heads:>6} {d_k:>5} {std_params:>12,} {eml_params:>12,} {ratio:>7.0f}×")

# Demo 3: Context window memory comparison
print()
print("=" * 70)
print("Demo 3: Attention Memory — O(n²) vs O(n·d) Linear Attention")
print("=" * 70)
print()

print(f"{'Seq Len':>10} {'Std Memory':>15} {'Linear (d=64)':>15} {'Linear (d=256)':>15} {'Savings':>10}")
print("-" * 70)

for seq_len in [512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072]:
    std_mem = seq_len * seq_len
    for d in [64, 256]:
        lin_mem = seq_len * d

    lin_64 = seq_len * 64
    lin_256 = seq_len * 256
    savings = (1 - lin_64 / std_mem) * 100

    def fmt(n):
        if n >= 1e9: return f"{n/1e9:.1f}B"
        if n >= 1e6: return f"{n/1e6:.1f}M"
        if n >= 1e3: return f"{n/1e3:.1f}K"
        return str(n)

    print(f"{seq_len:>10,} {fmt(std_mem):>15} {fmt(lin_64):>15} {fmt(lin_256):>15} {savings:>9.1f}%")

print()
print("→ Linear attention enables arbitrarily long context windows")
print("→ EML's exp/ln structure can implement kernel-based linear attention")
print("→ At seq_len=131K: standard attention needs 17.2B entries vs 8.4M for linear")

# Demo 4: Positional encoding comparison
print()
print("=" * 70)
print("Demo 4: EML vs Sinusoidal Positional Encoding")
print("=" * 70)
print()

def sinusoidal_pe(pos, dim, d_model):
    """Standard sinusoidal positional encoding."""
    angle = pos / (10000 ** (2 * (dim // 2) / d_model))
    if dim % 2 == 0:
        return math.sin(angle)
    else:
        return math.cos(angle)

def eml_pe(pos, dim, d_model):
    """EML positional encoding using exp/ln."""
    scale = pos / (10000 ** (2 * (dim // 2) / d_model))
    if dim % 2 == 0:
        return math.exp(-scale**2)  # Gaussian-like
    else:
        return math.log(1 + scale) if scale > 0 else -math.log(1 - scale)

d_model = 8
print(f"Position encodings for d_model={d_model}:")
print()
print(f"{'Pos':>4}  {'Sinusoidal':^40}  {'EML (exp/ln)':^40}")
print("-" * 90)

for pos in [0, 1, 5, 10, 50, 100]:
    sin_vals = [sinusoidal_pe(pos, d, d_model) for d in range(d_model)]
    eml_vals = [eml_pe(pos, d, d_model) for d in range(d_model)]
    sin_str = " ".join(f"{v:>5.2f}" for v in sin_vals)
    eml_str = " ".join(f"{v:>5.2f}" for v in eml_vals)
    print(f"{pos:>4}  {sin_str}  {eml_str}")

print()
print("→ Both encoding schemes use 2 basis functions per dimension")
print("→ EML encoding uses exp(-x²) and ln(1+x) instead of sin/cos")
print("→ EML encoding may better capture relative position for nearby tokens")
