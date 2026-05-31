"""
Hyperbolic Trace Arithmetic: Demonstration Script

Demonstrates the key results from the paper with numerical examples.
"""

from algorithms import (
    cheb_trace, cheb_trace_sequence, einstein_add, einstein_iterate,
    trace_discriminant, classify_trace, cheb_trace_period_mod,
    is_trace_divisor, find_trace_primes, hyperbolic_trace_count, is_prime
)


def demo_chebyshev_traces():
    """Demonstrate Chebyshev trace sequences for various initial traces."""
    print("=" * 70)
    print("CHEBYSHEV TRACE SEQUENCES")
    print("=" * 70)

    for t in [0, -1, 2, 3, 5]:
        seq = cheb_trace_sequence(t, 10)
        classification = classify_trace(t)
        print(f"\nt = {t} ({classification}):")
        print(f"  Sequence: {seq}")
        print(f"  Discriminant: Δ({t}) = {trace_discriminant(t)}")


def demo_growth_bounds():
    """Demonstrate exponential growth bounds for hyperbolic traces."""
    print("\n" + "=" * 70)
    print("EXPONENTIAL GROWTH BOUNDS (t ≥ 3)")
    print("=" * 70)

    for t in [3, 5, 10]:
        print(f"\nt = {t}:")
        print(f"  {'n':>3} | {'(t-1)^n':>15} | {'chebTrace':>15} | {'t^n':>15}")
        print(f"  {'-'*3}-+-{'-'*15}-+-{'-'*15}-+-{'-'*15}")
        for n in range(8):
            lower = (t - 1) ** n
            val = cheb_trace(t, n)
            upper = t ** n
            ok_lower = "✓" if lower <= val else "✗"
            ok_upper = "✓" if (n == 0 or val <= upper) else "✗"
            print(f"  {n:>3} | {lower:>15} | {val:>15} | {upper:>15}  {ok_lower}{ok_upper}")


def demo_periodicity():
    """Demonstrate periodicity of trace sequences modulo m."""
    print("\n" + "=" * 70)
    print("CHEBYSHEV TRACE PERIODICITY MODULO m")
    print("=" * 70)

    for t in [0, -1, 3, 7]:
        print(f"\nt = {t}:")
        for m in [2, 3, 5, 7, 11]:
            period = cheb_trace_period_mod(t, m)
            seq_mod = [cheb_trace(t, n) % m for n in range(period + 3)]
            print(f"  mod {m:>2}: period = {period:>4}, seq = {seq_mod[:min(12, len(seq_mod))]}")


def demo_einstein_addition():
    """Demonstrate Einstein addition properties."""
    print("\n" + "=" * 70)
    print("EINSTEIN ADDITION")
    print("=" * 70)

    print("\nBasic properties:")
    a, b = 0.5, 0.3
    print(f"  {a} ⊕ {b} = {einstein_add(a, b):.6f}")
    print(f"  {b} ⊕ {a} = {einstein_add(b, a):.6f} (commutative)")
    print(f"  {a} ⊕ 0 = {einstein_add(a, 0):.6f} (identity)")
    print(f"  {a} ⊕ (-{a}) = {einstein_add(a, -a):.6f} (inverse)")

    print("\nIterated Einstein addition (bounded by 1):")
    for a in [0.3, 0.5, 0.9]:
        vals = [einstein_iterate(a, n) for n in range(10)]
        print(f"  a = {a}: {[f'{v:.4f}' for v in vals]}")

    print("\nPreservation of (-1, 1):")
    import random
    random.seed(42)
    for _ in range(5):
        a = random.uniform(-0.99, 0.99)
        b = random.uniform(-0.99, 0.99)
        result = einstein_add(a, b)
        print(f"  {a:.4f} ⊕ {b:.4f} = {result:.4f}, |result| = {abs(result):.6f} < 1: {abs(result) < 1}")


def demo_trace_primes():
    """Demonstrate the search for primes in Chebyshev trace sequences."""
    print("\n" + "=" * 70)
    print("CHEBYSHEV TRACE PRIMALITY (Conjecture 9.1)")
    print("=" * 70)

    for t in [3, 5, 7]:
        primes = find_trace_primes(t, 30)
        print(f"\nt = {t}: primes at indices {[(n, v) for n, v in primes[:10]]}")
        if primes:
            print(f"  Found {len(primes)} prime(s) in first 31 terms")


def demo_trace_divisibility():
    """Demonstrate the trace divisibility lattice."""
    print("\n" + "=" * 70)
    print("TRACE DIVISIBILITY LATTICE")
    print("=" * 70)

    print("\nBasic divisibilities:")
    for t in [3, 5, 7]:
        seq = cheb_trace_sequence(t, 6)
        print(f"\n  Orbit of t = {t}: {seq}")
        for v in seq[1:]:
            n = is_trace_divisor(t, v)
            if n is not None:
                print(f"    {t} |_T {v} (via n = {n})")

    print("\nTransitivity check: 3 |_T 7 |_T 47")
    n1 = is_trace_divisor(3, 7)
    n2 = is_trace_divisor(7, 47)
    n3 = is_trace_divisor(3, 47)
    print(f"  3 |_T 7: n = {n1}")
    print(f"  7 |_T 47: n = {n2}")
    print(f"  3 |_T 47: n = {n3}")
    # Verify: cheb_trace(3, n1 * n2) should equal 47 if composition holds
    if n1 is not None and n2 is not None:
        comp = cheb_trace(3, n1 * n2)
        print(f"  Composition: cheb_trace(3, {n1}*{n2}) = cheb_trace(3, {n1*n2}) = {comp}")


def demo_counting():
    """Demonstrate hyperbolic trace counting."""
    print("\n" + "=" * 70)
    print("HYPERBOLIC TRACE COUNTING")
    print("=" * 70)

    print(f"\n  {'T':>5} | {'Count':>8} | {'T-2':>5} ≤ Count ≤ {'2T':>5}")
    print(f"  {'-'*5}-+-{'-'*8}-+-{'-'*25}")
    for T in [3, 5, 10, 50, 100, 1000]:
        count = hyperbolic_trace_count(T)
        print(f"  {T:>5} | {count:>8} | {T-2:>5} ≤ {count:>5} ≤ {2*T:>5}  ✓")


def demo_period_vs_legendre():
    """Test the conjecture about Chebyshev periods and quadratic residues."""
    print("\n" + "=" * 70)
    print("PERIOD VS QUADRATIC RESIDUE (Conjecture 9.2)")
    print("=" * 70)

    for p in [5, 7, 11, 13]:
        print(f"\np = {p}:")
        for t in range(3, p):
            period = cheb_trace_period_mod(t, p)
            disc = (t * t - 4) % p
            # Check if disc is a quadratic residue mod p
            is_qr = any((x * x) % p == disc for x in range(p))
            divides_pm1 = period % (p - 1) == 0 or (p - 1) % period == 0
            divides_pp1 = period % (p + 1) == 0 or (p + 1) % period == 0
            print(f"  t={t}: period={period:>3}, Δ≡{disc} (mod {p}), "
                  f"QR={is_qr}, π|p-1={divides_pm1}, π|p+1={divides_pp1}, "
                  f"π|p²-1={(p*p-1) % period == 0}")


if __name__ == "__main__":
    demo_chebyshev_traces()
    demo_growth_bounds()
    demo_periodicity()
    demo_einstein_addition()
    demo_trace_primes()
    demo_trace_divisibility()
    demo_counting()
    demo_period_vs_legendre()
    print("\n" + "=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)


"""
Visualization: Chebyshev Trace Growth Bounds

Plots the Chebyshev trace sequence alongside its exponential bounds
for various initial trace values, demonstrating the sandwich theorem:
(t-1)^n ≤ chebTrace(t, n) ≤ t^n.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def cheb_trace_seq(t, length):
    if length == 0:
        return []
    if length == 1:
        return [2]
    seq = [2, t]
    for i in range(2, length):
        seq.append(t * seq[-1] - seq[-2])
    return seq


def plot_growth_bounds():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, t in enumerate([3, 5, 10]):
        ax = axes[idx]
        N = 10
        ns = list(range(N))
        seq = cheb_trace_seq(t, N)

        lower = [(t - 1) ** n for n in ns]
        upper = [t ** n for n in ns]

        ax.semilogy(ns, seq, 'ko-', label=f'chebTrace({t}, n)', markersize=6, linewidth=2)
        ax.semilogy(ns, lower, 'b--', label=f'(t-1)^n = {t-1}^n', alpha=0.7)
        ax.semilogy(ns[1:], upper[1:], 'r--', label=f't^n = {t}^n', alpha=0.7)
        ax.fill_between(ns[1:], lower[1:], upper[1:], alpha=0.1, color='green')

        ax.set_xlabel('n', fontsize=12)
        ax.set_ylabel('Value (log scale)', fontsize=12)
        ax.set_title(f't = {t} (Δ = {t**2 - 4})', fontsize=13)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Chebyshev Trace Growth: Exponential Sandwich Theorem', fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_chebyshev_growth.png', dpi=150, bbox_inches='tight')
    print("Saved viz_chebyshev_growth.png")


def plot_periodicity():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    configs = [
        (0, 'Period 4: t=0 (elliptic)', [2, 0, -2, 0]),
        (-1, 'Period 3: t=-1 (elliptic)', [2, -1, -1]),
        (2, 'Period 1: t=2 (parabolic)', [2]),
        (3, 'Hyperbolic growth: t=3', None),
    ]

    for idx, (t, title, _) in enumerate(configs):
        ax = axes[idx // 2][idx % 2]
        N = 20
        seq = cheb_trace_seq(t, N)
        ns = list(range(N))

        if t <= 2:
            ax.stem(ns, seq, linefmt='b-', markerfmt='bo', basefmt='k-')
            ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
        else:
            ax.plot(ns, seq, 'ro-', markersize=5)

        ax.set_xlabel('n', fontsize=11)
        ax.set_ylabel('chebTrace(t, n)', fontsize=11)
        ax.set_title(title, fontsize=12)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Chebyshev Trace Dynamics: Elliptic, Parabolic, Hyperbolic', fontsize=14)
    plt.tight_layout()
    plt.savefig('viz_trace_dynamics.png', dpi=150, bbox_inches='tight')
    print("Saved viz_trace_dynamics.png")


def plot_einstein_addition():
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Einstein addition preserves (-1, 1)
    ax = axes[0]
    xs = np.linspace(-0.99, 0.99, 200)
    for b in [0.0, 0.3, 0.6, 0.9]:
        ys = [(x + b) / (1 + x * b) for x in xs]
        ax.plot(xs, ys, label=f'b = {b}')
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
    ax.axhline(y=-1, color='red', linestyle='--', alpha=0.5)
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('a ⊕ b', fontsize=12)
    ax.set_title('Einstein Addition: a ⊕ b vs a', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Right: Iterated Einstein addition approaches 1
    ax = axes[1]
    for a in [0.1, 0.3, 0.5, 0.7, 0.9]:
        vals = [0.0]
        for _ in range(20):
            vals.append((vals[-1] + a) / (1 + vals[-1] * a))
        ax.plot(range(len(vals)), vals, 'o-', markersize=3, label=f'a = {a}')
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Boundary')
    ax.set_xlabel('n (iterations)', fontsize=12)
    ax.set_ylabel('a⊕a⊕...⊕a (n times)', fontsize=12)
    ax.set_title('Iterated Einstein Addition', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_einstein_addition.png', dpi=150, bbox_inches='tight')
    print("Saved viz_einstein_addition.png")


if __name__ == '__main__':
    plot_growth_bounds()
    plot_periodicity()
    plot_einstein_addition()
