#!/usr/bin/env python3
"""
Demo: Perturbed Fibonacci Sequences and the Anti-Fibonacci Algebra

Demonstrates the key results from the formalized theory:
1. The closed form for constant perturbations: P(n) = (1+c)*fib(n+1) - c
2. The superposition principle
3. The anti-Fibonacci sequence (c=1): always 2*fib - 1, always odd
4. The c=-1 fixed point: constant sequence of 1s
"""

def fib(n: int) -> int:
    """Standard Fibonacci: fib(0)=0, fib(1)=1, fib(2)=1, ..."""
    if n <= 0:
        return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

def fib_prime(n: int) -> int:
    """Shifted Fibonacci: fib'(n) = fib(n+1). Starts 1, 1, 2, 3, 5, 8, ..."""
    return fib(n + 1)

def pert_fib(f, n: int) -> int:
    """Perturbed Fibonacci: P(0)=P(1)=1, P(n+2) = P(n+1) + P(n) + f(n)."""
    if n == 0 or n == 1:
        return 1
    vals = [1, 1]
    for k in range(2, n + 1):
        vals.append(vals[-1] + vals[-2] + f(k - 2))
    return vals[n]

def fib_dev(f, n: int) -> int:
    """Deviation: dev(f, n) = pertFib(f, n) - fib'(n)."""
    return pert_fib(f, n) - fib_prime(n)

# ============================================================================
# Demo 1: Zero perturbation recovers Fibonacci
# ============================================================================
print("=" * 70)
print("DEMO 1: Zero perturbation recovers shifted Fibonacci")
print("=" * 70)
print(f"{'n':>4} | {'pertFib(0,n)':>14} | {'fib_prime(n)':>14} | {'match':>6}")
print("-" * 50)
for n in range(15):
    p = pert_fib(lambda _: 0, n)
    f = fib_prime(n)
    print(f"{n:>4} | {p:>14} | {f:>14} | {'✓' if p == f else '✗':>6}")

# ============================================================================
# Demo 2: Constant perturbation closed form
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 2: Constant perturbation closed form: P(n) = (1+c)*fib'(n) - c")
print("=" * 70)
for c in [-2, -1, 0, 1, 2, 5]:
    print(f"\n  c = {c}: P(n) = {1+c}*fib'(n) - {c}")
    for n in range(10):
        actual = pert_fib(lambda _, c=c: c, n)
        formula = (1 + c) * fib_prime(n) - c
        assert actual == formula, f"Mismatch at c={c}, n={n}: {actual} != {formula}"
    seq = [pert_fib(lambda _, c=c: c, n) for n in range(10)]
    print(f"  Sequence: {seq}")
print("\n  ✓ All closed forms verified!")

# ============================================================================
# Demo 3: The Anti-Fibonacci (c=1)
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 3: Anti-Fibonacci sequence: 2*fib'(n) - 1")
print("=" * 70)
print(f"{'n':>4} | {'antiFib(n)':>12} | {'2*fib-1':>12} | {'fib(n)':>10} | {'odd?':>6}")
print("-" * 55)
for n in range(15):
    af = pert_fib(lambda _: 1, n)
    formula = 2 * fib_prime(n) - 1
    fb = fib_prime(n)
    is_odd = af % 2 == 1
    print(f"{n:>4} | {af:>12} | {formula:>12} | {fb:>10} | {'✓' if is_odd else '✗':>6}")

print("\n  Key insight: Anti-Fibonacci is ALWAYS odd (proved in Lean!)")
print("  Key insight: For n ≥ 2, antiFib(n) ≠ fib'(n) (proved in Lean!)")

# ============================================================================
# Demo 4: The c=-1 fixed point
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 4: The c=-1 fixed point: constant sequence of 1s")
print("=" * 70)
seq_neg1 = [pert_fib(lambda _: -1, n) for n in range(20)]
print(f"  pertFib(c=-1): {seq_neg1}")
print(f"  All equal to 1: {'✓' if all(x == 1 for x in seq_neg1) else '✗'}")
print("  Remarkable: subtracting 1 at each step exactly cancels all growth!")

# ============================================================================
# Demo 5: Superposition principle
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 5: Superposition: pertFib(f+g) = pertFib(f) + pertFib(g) - fib'")
print("=" * 70)
f_func = lambda k: k + 1  # f(k) = k + 1
g_func = lambda k: (-1) ** k  # g(k) = (-1)^k
fg_func = lambda k: f_func(k) + g_func(k)

print(f"{'n':>4} | {'P(f+g,n)':>12} | {'P(f)+P(g)-fib':>14} | {'match':>6}")
print("-" * 50)
for n in range(12):
    lhs = pert_fib(fg_func, n)
    rhs = pert_fib(f_func, n) + pert_fib(g_func, n) - fib_prime(n)
    print(f"{n:>4} | {lhs:>12} | {rhs:>14} | {'✓' if lhs == rhs else '✗':>6}")

# ============================================================================
# Demo 6: Deviation linearity
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 6: Deviation linearity: dev(f+g) = dev(f) + dev(g)")
print("=" * 70)
print(f"{'n':>4} | {'dev(f+g)':>10} | {'dev(f)+dev(g)':>14} | {'dev(f)':>8} | {'dev(g)':>8}")
print("-" * 55)
for n in range(12):
    d_fg = fib_dev(fg_func, n)
    d_f = fib_dev(f_func, n)
    d_g = fib_dev(g_func, n)
    print(f"{n:>4} | {d_fg:>10} | {d_f + d_g:>14} | {d_f:>8} | {d_g:>8}")
    assert d_fg == d_f + d_g

# ============================================================================
# Demo 7: Recovery formula
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 7: Recovery: f(n) = dev(n+2) - dev(n+1) - dev(n)")
print("=" * 70)
test_f = lambda k: 3 * k - 2
print(f"{'n':>4} | {'f(n)':>8} | {'recovered':>10} | {'match':>6}")
print("-" * 40)
for n in range(10):
    fn = test_f(n)
    recovered = fib_dev(test_f, n + 2) - fib_dev(test_f, n + 1) - fib_dev(test_f, n)
    print(f"{n:>4} | {fn:>8} | {recovered:>10} | {'✓' if fn == recovered else '✗':>6}")

# ============================================================================
# Demo 8: Growth comparison
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 8: Growth rates — Fibonacci vs Anti-Fibonacci vs c=-1")
print("=" * 70)
print(f"{'n':>4} | {'fib(n)':>12} | {'antiFib':>12} | {'c=-1':>6} | {'ratio':>10}")
print("-" * 55)
for n in range(20):
    fb = fib_prime(n)
    af = pert_fib(lambda _: 1, n)
    cm = pert_fib(lambda _: -1, n)
    ratio = af / fb if fb > 0 else float('inf')
    print(f"{n:>4} | {fb:>12} | {af:>12} | {cm:>6} | {ratio:>10.4f}")

print("\n  Ratio antiFib/fib → 2.0 (since antiFib = 2*fib - 1)")
print("  All growth rates are exponential ~ φ^n, just with different coefficients!")

print("\n" + "=" * 70)
print("All demos completed successfully! ✓")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Perturbed Fibonacci Sequences — Growth Comparison

Shows the standard Fibonacci, anti-Fibonacci (c=1), and c=-1 fixed point
on a log scale, demonstrating that constant perturbations only change
the coefficient of exponential growth, not the base.
"""
import matplotlib.pyplot as plt
import numpy as np

def fibonacci_shifted(n):
    if n <= 0:
        return 1
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return b

def perturbed_fib_seq(c, length):
    if length == 0:
        return []
    if length == 1:
        return [1]
    vals = [1, 1]
    for k in range(2, length):
        vals.append(vals[-1] + vals[-2] + c)
    return vals

N = 25
ns = list(range(N))

fib_seq = [fibonacci_shifted(n) for n in ns]
anti_fib = perturbed_fib_seq(1, N)
neg1_seq = perturbed_fib_seq(-1, N)
c2_seq = perturbed_fib_seq(2, N)
c_neg2 = perturbed_fib_seq(-2, N)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Perturbed Fibonacci Algebra — Key Results', fontsize=16, fontweight='bold')

# Plot 1: Log-scale growth comparison
ax1 = axes[0, 0]
ax1.semilogy(ns, fib_seq, 'b-o', label='Fibonacci (c=0)', markersize=4)
ax1.semilogy(ns, anti_fib, 'r-s', label='Anti-Fibonacci (c=1)', markersize=4)
ax1.semilogy(ns, c2_seq, 'g-^', label='c=2', markersize=4)
ax1.semilogy(ns, [max(abs(x), 0.1) for x in c_neg2], 'm-v', label='c=-2', markersize=4)
ax1.axhline(y=1, color='orange', linestyle='--', alpha=0.7, label='c=-1 (constant 1)')
ax1.set_xlabel('n')
ax1.set_ylabel('P(n) [log scale]')
ax1.set_title('Growth: All scale by φⁿ')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Plot 2: Ratio antiFib/fib approaching 2
ax2 = axes[0, 1]
ratios = [anti_fib[n] / fib_seq[n] if fib_seq[n] > 0 else 0 for n in ns]
ax2.plot(ns[1:], ratios[1:], 'r-o', markersize=5)
ax2.axhline(y=2.0, color='k', linestyle='--', alpha=0.5, label='Limit = 2')
ax2.set_xlabel('n')
ax2.set_ylabel('antiFib(n) / fib\'(n)')
ax2.set_title('Ratio → 2 (since antiFib = 2·fib - 1)')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.8, 2.5)

# Plot 3: Deviation for various constant perturbations
ax3 = axes[1, 0]
for c in [-3, -2, -1, 0, 1, 2, 3]:
    devs = [perturbed_fib_seq(c, N)[n] - fib_seq[n] for n in range(min(N, 20))]
    label = f'c={c}'
    if c == -1:
        label += ' (fixed pt)'
    elif c == 0:
        label += ' (zero dev)'
    ax3.plot(range(len(devs)), devs, '-o', label=label, markersize=3)
ax3.set_xlabel('n')
ax3.set_ylabel('dev(n) = P(n) - fib\'(n)')
ax3.set_title('Deviation: c · (fib\'(n) - 1)')
ax3.legend(fontsize=7)
ax3.grid(True, alpha=0.3)

# Plot 4: Superposition principle
ax4 = axes[1, 1]
f_pert = lambda k: k + 1
g_pert = lambda k: (-1) ** k

pf = [1, 1]
pg = [1, 1]
pfg = [1, 1]
M = 15
for k in range(2, M):
    pf.append(pf[-1] + pf[-2] + f_pert(k-2))
    pg.append(pg[-1] + pg[-2] + g_pert(k-2))
    pfg.append(pfg[-1] + pfg[-2] + f_pert(k-2) + g_pert(k-2))

superposed = [pf[n] + pg[n] - fib_seq[n] for n in range(M)]

ax4.plot(range(M), pfg, 'b-o', label='P(f+g)', markersize=5)
ax4.plot(range(M), superposed, 'r--x', label='P(f) + P(g) - fib\'', markersize=5)
ax4.set_xlabel('n')
ax4.set_ylabel('Value')
ax4.set_title('Superposition: P(f+g) = P(f)+P(g)-fib\'')
ax4.legend()
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('pertfib_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved pertfib_visualization.png")
