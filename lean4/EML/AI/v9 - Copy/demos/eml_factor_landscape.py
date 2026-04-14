#!/usr/bin/env python3
"""
EML Factor Landscape Explorer — v9 Demo

Demonstrates the gravitational factoring energy landscape and how EML-based
neural networks can navigate it to discover factors.

Key experiments:
1. Energy landscape visualization (mod-squared energy)
2. Trigonometric energy landscape (sin²-based)
3. EML factor detector (exp-based Gaussian peaks at divisors)
4. Gradient descent on the energy landscape
5. Channel amplification comparison
6. Neural sieve simulation
7. Parameter efficiency comparison (EML vs ReLU)
8. Multi-scale factor search
9. Convergence rate analysis
10. Adam-style adaptive learning rate demo
"""

import math
import random
from collections import defaultdict

def divisors(n):
    """Return sorted list of divisors of n."""
    divs = []
    for i in range(1, int(math.sqrt(n)) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)

def factoring_energy(N, k):
    """E(k) = (N mod k)²"""
    if k == 0:
        return float('inf')
    return (N % k) ** 2

def trig_energy(N, x):
    """E(x) = sin²(π·N/x)"""
    if x == 0:
        return 1.0
    return math.sin(math.pi * N / x) ** 2

def eml_detector(N, alpha, x):
    """F(x) = exp(-α · (N mod round(x))²)"""
    k = max(1, round(x))
    return math.exp(-alpha * (N % k) ** 2)

def gradient_descent_factor(N, x0, lr=0.01, steps=1000):
    """Gradient descent on trigonometric energy to find factors."""
    x = x0
    trajectory = [x]
    for _ in range(steps):
        if abs(x) < 1:
            break
        # Numerical gradient
        h = 0.001
        grad = (trig_energy(N, x + h) - trig_energy(N, x - h)) / (2 * h)
        x -= lr * grad
        x = max(1.5, x)  # Keep x > 1
        trajectory.append(x)
    return x, trajectory

# ==========================================
# Demo 1: Energy Landscape
# ==========================================
def demo_energy_landscape():
    print("=" * 60)
    print("Demo 1: Factoring Energy Landscape")
    print("=" * 60)
    N = 91  # = 7 × 13
    divs = divisors(N)
    print(f"N = {N}, divisors = {divs}")
    print(f"\n{'k':>4} | {'E(k)':>8} | {'Divisor?':>8}")
    print("-" * 30)
    for k in range(1, 20):
        e = factoring_energy(N, k)
        is_div = "✓" if k in divs else ""
        bar = "█" * min(e, 40)
        print(f"{k:>4} | {e:>8} | {is_div:>8} {bar}")
    print()

# ==========================================
# Demo 2: Trigonometric Energy
# ==========================================
def demo_trig_energy():
    print("=" * 60)
    print("Demo 2: Trigonometric Energy sin²(πN/x)")
    print("=" * 60)
    N = 77  # = 7 × 11
    divs = divisors(N)
    print(f"N = {N}, divisors = {divs}")
    print(f"\n{'x':>6} | {'E(x)':>10} | {'Near divisor?':>14}")
    print("-" * 40)
    for x_int in range(1, 20):
        x = float(x_int)
        e = trig_energy(N, x)
        near = "✓ ZERO" if e < 1e-10 else ""
        bar = "█" * int(e * 30)
        print(f"{x:>6.1f} | {e:>10.6f} | {near:>14} {bar}")
    print()

# ==========================================
# Demo 3: EML Factor Detector
# ==========================================
def demo_eml_detector():
    print("=" * 60)
    print("Demo 3: EML Factor Detector exp(-α·(N mod k)²)")
    print("=" * 60)
    N = 143  # = 11 × 13
    alpha = 5.0
    divs = divisors(N)
    print(f"N = {N}, α = {alpha}, divisors = {divs}")
    print(f"\n{'k':>4} | {'F(k)':>10} | {'Divisor?':>8}")
    print("-" * 35)
    for k in range(1, 20):
        f = eml_detector(N, alpha, k)
        is_div = "✓" if k in divs else ""
        bar = "█" * int(f * 30)
        print(f"{k:>4} | {f:>10.6f} | {is_div:>8} {bar}")
    print()

# ==========================================
# Demo 4: Gradient Descent Factor Search
# ==========================================
def demo_gradient_descent():
    print("=" * 60)
    print("Demo 4: Gradient Descent on Trigonometric Energy")
    print("=" * 60)
    N = 91  # = 7 × 13
    divs = divisors(N)
    print(f"N = {N}, divisors = {divs}")
    
    for x0 in [5.5, 8.0, 12.0, 15.0]:
        final_x, traj = gradient_descent_factor(N, x0, lr=0.1, steps=500)
        nearest_div = min(divs, key=lambda d: abs(d - final_x))
        print(f"  Start x₀={x0:>5.1f} → converged to x={final_x:>7.3f} "
              f"(nearest divisor: {nearest_div}, distance: {abs(final_x - nearest_div):.4f})")
    print()

# ==========================================
# Demo 5: Channel Amplification
# ==========================================
def demo_channel_amplification():
    print("=" * 60)
    print("Demo 5: Channel Amplification Across Dimensions")
    print("=" * 60)
    dims = [
        (2, "ℂ (Gaussian)"),
        (3, "3-tuples"),
        (4, "ℍ (Quaternion)"),
        (8, "𝕆 (Octonion)"),
        (16, "𝕊 (Sedenion)"),
        (32, "32-ions"),
    ]
    print(f"\n{'Dim':>4} | {'Algebra':>16} | {'Channels':>8} | {'Bar'}")
    print("-" * 55)
    for k, name in dims:
        channels = k + k * (k - 1) // 2
        bar = "█" * (channels // 2)
        print(f"{k:>4} | {name:>16} | {channels:>8} | {bar}")
    print()

# ==========================================
# Demo 6: Neural Sieve Simulation
# ==========================================
def demo_neural_sieve():
    print("=" * 60)
    print("Demo 6: Neural Sieve Simulation")
    print("=" * 60)
    N = 2021  # = 43 × 47
    divs = set(divisors(N))
    alpha = 10.0
    threshold = 0.5
    
    print(f"N = {N}, divisors = {sorted(divs)}")
    print(f"Threshold = {threshold}, α = {alpha}")
    
    sieve_hits = []
    false_positives = 0
    for k in range(1, N + 1):
        score = eml_detector(N, alpha, k)
        if score >= threshold:
            sieve_hits.append(k)
            if k not in divs:
                false_positives += 1
    
    print(f"\nSieve hits: {sieve_hits}")
    print(f"True divisors found: {len([x for x in sieve_hits if x in divs])}/{len(divs)}")
    print(f"False positives: {false_positives}")
    print(f"Precision: {len([x for x in sieve_hits if x in divs]) / max(1, len(sieve_hits)):.2%}")
    print()

# ==========================================
# Demo 7: Parameter Efficiency
# ==========================================
def demo_param_efficiency():
    print("=" * 60)
    print("Demo 7: EML vs ReLU Parameter Efficiency")
    print("=" * 60)
    print(f"\n{'Width':>6} | {'Depth':>5} | {'EML Params':>12} | {'ReLU Params':>12} | {'Ratio':>8}")
    print("-" * 55)
    for width in [10, 50, 100, 500, 1000]:
        for depth in [3, 5]:
            eml = depth * 4 * width
            relu = depth * width * (width + 1)
            ratio = relu / eml
            print(f"{width:>6} | {depth:>5} | {eml:>12,} | {relu:>12,} | {ratio:>7.1f}×")
    print()

# ==========================================
# Demo 8: Multi-Scale Search
# ==========================================
def demo_multiscale():
    print("=" * 60)
    print("Demo 8: Multi-Scale Factor Search")
    print("=" * 60)
    N = 10403  # = 101 × 103
    sqrt_N = math.isqrt(N)
    divs = divisors(N)
    print(f"N = {N}, √N ≈ {sqrt_N}, divisors = {divs}")
    
    for scale in range(0, 6):
        window = 2 ** (scale + 1)
        lo = max(2, sqrt_N - window)
        hi = min(N, sqrt_N + window)
        found = [d for d in divs if lo <= d <= hi]
        print(f"  Scale {scale}: window [{lo}, {hi}] (size {window*2})"
              f" → found {found if found else 'none'}")
    print()

# ==========================================
# Demo 9: Convergence Rate
# ==========================================
def demo_convergence():
    print("=" * 60)
    print("Demo 9: Geometric Convergence Analysis")
    print("=" * 60)
    L0 = 1.0
    rates = [0.1, 0.3, 0.5, 0.7, 0.9]
    
    print(f"\n{'Step':>5}", end="")
    for r in rates:
        print(f" | {'r='+str(r):>10}", end="")
    print()
    print("-" * (6 + 13 * len(rates)))
    
    for t in [0, 1, 5, 10, 20, 50, 100]:
        print(f"{t:>5}", end="")
        for r in rates:
            loss = (1 - r) ** t * L0
            print(f" | {loss:>10.6f}", end="")
        print()
    print()

# ==========================================
# Demo 10: Adam LR Analysis
# ==========================================
def demo_adam_lr():
    print("=" * 60)
    print("Demo 10: Adam-Style Adaptive Learning Rate")
    print("=" * 60)
    eta = 0.001
    eps = 1e-8
    
    print(f"Base LR η = {eta}, ε = {eps}")
    print(f"\n{'Variance':>12} | {'Effective LR':>14} | {'Relative':>10}")
    print("-" * 45)
    
    for v in [0.0, 0.001, 0.01, 0.1, 1.0, 10.0, 100.0]:
        eff_lr = eta / (math.sqrt(v) + eps)
        relative = eff_lr / eta
        print(f"{v:>12.4f} | {eff_lr:>14.8f} | {relative:>9.4f}×")
    print()

# ==========================================
# Main
# ==========================================
if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  EML FACTOR LANDSCAPE EXPLORER — v9")
    print("  AI & Machine Learning Research Demo")
    print("█" * 60 + "\n")
    
    demo_energy_landscape()
    demo_trig_energy()
    demo_eml_detector()
    demo_gradient_descent()
    demo_channel_amplification()
    demo_neural_sieve()
    demo_param_efficiency()
    demo_multiscale()
    demo_convergence()
    demo_adam_lr()
    
    print("=" * 60)
    print("All 10 demos completed successfully!")
    print("=" * 60)
