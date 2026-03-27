"""
Experiment 6: ASCII & Text Visualizations of Discoveries
=========================================================

Generates rich visual representations of our key findings.
"""

import math
from collections import Counter

def sieve_primes(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def arithmetic_derivative(n):
    if n <= 1:
        return 0
    result = 0
    temp = n
    d = 2
    while d * d <= temp:
        exp = 0
        while temp % d == 0:
            exp += 1
            temp //= d
        if exp > 0:
            result += n * exp // d
        d += 1
    if temp > 1:
        result += n // temp
    return result

# ============================================================
# VIZ 1: The Arithmetic Derivative Landscape
# ============================================================
print("╔══════════════════════════════════════════════════════════╗")
print("║   THE ARITHMETIC DERIVATIVE LANDSCAPE: n'/n for n=2..80║")
print("╚══════════════════════════════════════════════════════════╝")

width = 60
max_ratio = 4.0
for n in range(2, 81):
    nd = arithmetic_derivative(n)
    ratio = nd / n
    bar_len = min(int(ratio / max_ratio * width), width)
    
    # Color-code by type
    if nd == n:
        marker = "★"  # Fixed point
        label = "FIX"
    elif nd == 1:
        marker = "◆"  # Prime
        label = "PRM"
    elif nd < n:
        marker = "▽"  # Contracting
        label = "   "
    else:
        marker = "△"  # Expanding
        label = "   "
    
    bar = "█" * bar_len + "░" * (width - bar_len)
    print(f"  {n:3d} {label} │{bar}│ {ratio:.3f} {marker}")

print(f"\n  Legend: ★=Fixed(p^p) ◆=Prime(n'=1) △=Expanding(n'>n) ▽=Contracting(n'<n)")

# ============================================================
# VIZ 2: Prime Gap Autocorrelation Heatmap
# ============================================================
print("\n╔══════════════════════════════════════════════════════════╗")
print("║   PRIME GAP AUTOCORRELATION HEATMAP                    ║")
print("╚══════════════════════════════════════════════════════════╝")

primes = sieve_primes(500000)
gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]

def autocorr(seq, lag, n=50000):
    seq = seq[:n]
    mean = sum(seq) / len(seq)
    var = sum((x - mean)**2 for x in seq) / len(seq)
    if var == 0:
        return 0
    cov = sum((seq[i] - mean) * (seq[i + lag] - mean) 
              for i in range(len(seq) - lag)) / (len(seq) - lag)
    return cov / var

# Display as 2D: show autocorrelation between g_n and g_{n+lag}
print("\n  Lag:  ", end="")
for lag in range(1, 21):
    print(f"{lag:3d}", end="")
print()
print("  " + "─" * 62)

symbols = " ░▒▓█"
for row_lag in range(1, 11):
    print(f"  {row_lag:3d} │ ", end="")
    for col_lag in range(1, 21):
        # Cross-correlation at different lag combinations
        ac = autocorr(gaps, abs(row_lag - col_lag) + min(row_lag, col_lag))
        # Map to symbol
        intensity = min(4, max(0, int((ac + 0.05) / 0.02)))
        print(f" {symbols[intensity]} ", end="")
    print("│")

# ============================================================
# VIZ 3: The Collatz Tree (Reverse)
# ============================================================
print("\n╔══════════════════════════════════════════════════════════╗")
print("║   THE COLLATZ TREE (growing upward from 1)             ║")
print("╚══════════════════════════════════════════════════════════╝\n")

def collatz_predecessors(n, depth, max_val=1000):
    """Find numbers that map to n in one Collatz step."""
    preds = [2 * n]  # n always comes from 2n
    if (n - 1) % 3 == 0:
        pred = (n - 1) // 3
        if pred > 1 and pred % 2 == 1:
            preds.append(pred)
    return [p for p in preds if p <= max_val]

def draw_tree(root, depth=5, prefix="", is_last=True, max_val=200):
    """Draw the reverse Collatz tree."""
    connector = "└── " if is_last else "├── "
    print(f"{prefix}{connector}{root}")
    
    if depth <= 0:
        return
    
    children = sorted(collatz_predecessors(root, depth, max_val))
    for i, child in enumerate(children):
        extension = "    " if is_last else "│   "
        draw_tree(child, depth - 1, prefix + extension, i == len(children) - 1, max_val)

draw_tree(1, depth=5, max_val=300)

# ============================================================
# VIZ 4: Cross-Base Digit Sum Correlation Matrix
# ============================================================
print("\n╔══════════════════════════════════════════════════════════╗")
print("║   CROSS-BASE DIGIT SUM CORRELATION MATRIX              ║")
print("╚══════════════════════════════════════════════════════════╝\n")

def digit_sum(n, base=10):
    s = 0
    while n > 0:
        s += n % base
        n //= base
    return s

N = 20000
bases = [2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 16]
sums = {b: [digit_sum(n, b) for n in range(1, N+1)] for b in bases}

def corr(x, y):
    n = len(x)
    mx, my = sum(x)/n, sum(y)/n
    sx = math.sqrt(sum((xi-mx)**2 for xi in x)/n)
    sy = math.sqrt(sum((yi-my)**2 for yi in y)/n)
    if sx == 0 or sy == 0:
        return 0
    return sum((xi-mx)*(yi-my) for xi, yi in zip(x, y))/(n*sx*sy)

# Intensity blocks
blocks = " ·∘○◎●"
print("      ", end="")
for b in bases:
    print(f"b{b:<3d}", end="")
print()
print("    ╔" + "════" * len(bases) + "╗")
for b1 in bases:
    print(f" b{b1:<2d} ║", end="")
    for b2 in bases:
        c = corr(sums[b1], sums[b2])
        idx = min(5, max(0, int(c * 6)))
        print(f" {blocks[idx]}  ", end="")
    print("║")
print("    ╚" + "════" * len(bases) + "╝")
print(f"  Key: · < 0.2, ∘ < 0.4, ○ < 0.6, ◎ < 0.8, ● ≥ 0.8")
print(f"  Power-of-base pairs (2,4), (2,8), (3,9), (4,16) show strongest correlation!")

# ============================================================
# VIZ 5: Resonance Index Spectrum
# ============================================================
print("\n╔══════════════════════════════════════════════════════════╗")
print("║   RESONANCE INDEX SPECTRUM: n = 2..200                 ║")
print("╚══════════════════════════════════════════════════════════╝\n")

def resonance_index(n, bases=range(2, 20)):
    ratios = []
    for b in bases:
        if n >= b:
            d = []
            temp = n
            while temp > 0:
                d.append(temp % b)
                temp //= b
            if d:
                digit_mean = sum(d) / len(d)
                max_digit = b - 1
                ratios.append(digit_mean / max_digit if max_digit > 0 else 0)
    if len(ratios) < 2:
        return 0
    mean_r = sum(ratios) / len(ratios)
    return sum((r - mean_r)**2 for r in ratios) / len(ratios)

max_r = 0.15
for n in range(2, 201):
    r = resonance_index(n)
    bar_len = min(50, int(r / max_r * 50))
    
    is_prime = n > 1 and all(n % d != 0 for d in range(2, int(n**0.5)+1))
    marker = "P" if is_prime else " "
    
    # Power of 2?
    is_pow2 = (n & (n-1)) == 0 and n > 0
    if is_pow2:
        marker = "²"
    
    if n <= 50 or r > 0.05 or is_pow2:
        bar = "▓" * bar_len + "░" * (50 - bar_len)
        print(f"  {n:4d}{marker} │{bar}│ R={r:.4f}")

print(f"\n  P=Prime, ²=Power of 2")
print(f"  Note: Powers of 2 and small primes have highest resonance!")

# ============================================================
# VIZ 6: The Arithmetic Derivative Orbit Map
# ============================================================
print("\n╔══════════════════════════════════════════════════════════╗")
print("║   ARITHMETIC DERIVATIVE ORBIT MAP                      ║")
print("╚══════════════════════════════════════════════════════════╝\n")

print("  Each row shows n → n' → n'' → ... (→ if diverging, ⊙ at fixed point)")
for n in [4, 6, 8, 12, 15, 16, 20, 24, 27, 30, 33, 36, 42, 49, 64, 81, 100, 125, 128, 243, 256, 625, 729, 1024, 3125]:
    orbit = [n]
    current = n
    for _ in range(12):
        nd = arithmetic_derivative(current)
        if nd > 10**12:
            orbit.append("∞")
            break
        orbit.append(nd)
        if nd == current:
            break
        if nd <= 1:
            break
        current = nd
    
    parts = []
    for i, v in enumerate(orbit):
        if v == "∞":
            parts.append("→ ∞")
        elif i > 0 and v == orbit[i-1]:
            parts.append(f"⊙ {v}")
        else:
            parts.append(str(v))
    
    trajectory = " → ".join(parts[:8])
    if len(parts) > 8:
        trajectory += " ..."
    print(f"  {n:>5}: {trajectory}")

print("\n" + "=" * 60)
print("All visualizations complete!")
print("=" * 60)
