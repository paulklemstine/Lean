#!/usr/bin/env python3
"""
Mandelbrot Arithmetic: Numerical Demonstrations

Demonstrates the key theorems from the Lean formalization:
1. Orbit Shift Lemma
2. Period Divisibility Theorem
3. Exact Period Characterization
4. Dynatomic Structure
5. Orbit Congruence Modulo c²
"""

from typing import List, Tuple, Dict, Optional


def qiter(c: complex, n: int) -> complex:
    """Compute the n-th iterate of z -> z^2 + c starting from 0."""
    z = 0
    for _ in range(n):
        z = z**2 + c
    return z


def qiter_mod(c: int, n: int, p: int) -> int:
    """Compute qiter n c modulo p."""
    z = 0
    for _ in range(n):
        z = (z * z + c) % p
    return z


def find_period(c: complex, max_iter: int = 1000, tol: float = 1e-12) -> Optional[int]:
    """Find the period of the orbit of 0 under z -> z^2 + c."""
    for n in range(1, max_iter + 1):
        if abs(qiter(c, n)) < tol:
            return n
    return None


def find_period_mod(c: int, p: int) -> int:
    """Find the period of 0 under z -> z^2 + c in Z/pZ (or 0 if not periodic)."""
    seen = {}
    z = 0
    for n in range(p * p + 2):
        if z == 0 and n > 0:
            return n
        z = (z * z + c) % p
    return 0


def demo_orbit_shift():
    """Demonstrate the Orbit Shift Lemma: if qiter(d, c) = 0, then
    qiter(d + m, c) = qiter(m, c) for all m."""
    print("=" * 60)
    print("DEMO 1: Orbit Shift Lemma")
    print("=" * 60)
    print()
    
    # c = -1 has period 2: orbit is 0, -1, 0, -1, 0, ...
    c = -1
    d = 2  # qiter(2, -1) = 0
    print(f"c = {c}, d = {d} (period)")
    print(f"qiter({d}, {c}) = {qiter(c, d)}")
    print()
    
    for m in range(8):
        val_shifted = qiter(c, d + m)
        val_orig = qiter(c, m)
        print(f"  qiter({d}+{m}, {c}) = {val_shifted:6.1f}  ==  qiter({m}, {c}) = {val_orig:6.1f}")
    print()


def demo_period_divisibility():
    """Demonstrate: qiter(d, c) = 0 => qiter(d*k, c) = 0 for all k >= 1."""
    print("=" * 60)
    print("DEMO 2: Period Divisibility Theorem")
    print("=" * 60)
    print()
    
    c = -1
    d = 2
    print(f"c = {c}, period d = {d}")
    for k in range(1, 11):
        val = qiter(c, d * k)
        print(f"  qiter({d}*{k}={d*k}, {c}) = {val}")
    print()


def demo_exact_periods():
    """Demonstrate period characterization: period 1 <=> c=0, period 2 <=> c=-1."""
    print("=" * 60)
    print("DEMO 3: Exact Period Characterization")
    print("=" * 60)
    print()
    
    print("Period-1 set: {c | qiter(1,c) = 0}")
    for c in range(-5, 6):
        if qiter(c, 1) == 0:
            print(f"  c = {c}: qiter(1, {c}) = {qiter(c, 1)} ✓")
    
    print("\nPeriod-2 set: {c | qiter(2,c) = 0 and qiter(1,c) ≠ 0}")
    for c in range(-5, 6):
        if qiter(c, 2) == 0 and qiter(c, 1) != 0:
            print(f"  c = {c}: qiter(2, {c}) = {qiter(c, 2)}, qiter(1, {c}) = {qiter(c, 1)} ✓")
    print()


def demo_arithmetic_mandelbrot():
    """Compute the arithmetic Mandelbrot set over Z/pZ for small primes."""
    print("=" * 60)
    print("DEMO 4: Arithmetic Mandelbrot Set over Z/pZ")
    print("=" * 60)
    print()
    
    for p in [2, 3, 5, 7, 11, 13]:
        mandelbrot_set = []
        period_map = {}
        for c in range(p):
            per = find_period_mod(c, p)
            if per > 0:
                mandelbrot_set.append(c)
                period_map[c] = per
        
        print(f"  Z/{p}Z: M = {mandelbrot_set}")
        print(f"         Periods: {period_map}")
        print(f"         |M|/{p} = {len(mandelbrot_set)}/{p} = {len(mandelbrot_set)/p:.3f}")
        print()


def demo_dynatomic_counting():
    """Count parameters by exact period over Z/pZ — the dynamical Möbius function."""
    print("=" * 60)
    print("DEMO 5: Dynatomic Counting (Exact Periods over Z/pZ)")
    print("=" * 60)
    print()
    
    for p in [5, 7, 11, 13, 17, 19, 23]:
        counts: Dict[int, int] = {}
        for c in range(p):
            per = find_period_mod(c, p)
            if per > 0:
                counts[per] = counts.get(per, 0) + 1
        
        print(f"  Z/{p}Z: exact period counts = {dict(sorted(counts.items()))}")
    print()


def demo_orbit_congruence():
    """Demonstrate: qiter(n, c) ≡ c (mod c²) for all n >= 1."""
    print("=" * 60)
    print("DEMO 6: Orbit Congruence (qiter(n,c) = c + c²·q)")
    print("=" * 60)
    print()
    
    for c_val in [2, 3, -1, -2, 5]:
        print(f"  c = {c_val}:")
        for n in range(1, 7):
            val = qiter(c_val, n)
            if c_val != 0:
                q = (val - c_val) / (c_val ** 2)
                print(f"    qiter({n}, {c_val}) = {val:>12} = {c_val} + {c_val}²·{q}")
            else:
                print(f"    qiter({n}, {c_val}) = {val}")
        print()


def demo_neg_two_fixed():
    """Demonstrate: c = -2 gives orbit 0 → -2 → 2 → 2 → 2 → ..."""
    print("=" * 60)
    print("DEMO 7: The c = -2 Fixed Point (Tip of Mandelbrot Set)")
    print("=" * 60)
    print()
    
    c = -2
    print(f"Orbit of 0 under z → z² + ({c}):")
    for n in range(10):
        print(f"  z_{n} = qiter({n}, {c}) = {qiter(c, n)}")
    print()
    print("After step 2, the orbit is fixed at 2.")
    print("This corresponds to the leftmost point c = -2 of the Mandelbrot set.")
    print()


def demo_polynomial_tower():
    """Display the Mandelbrot polynomials M_n(c)."""
    print("=" * 60)
    print("DEMO 8: Mandelbrot Polynomial Tower")
    print("=" * 60)
    print()
    
    # Compute symbolically using coefficient lists
    polys = {
        0: "0",
        1: "c",
        2: "c² + c",
        3: "c⁴ + 2c³ + c² + c",
        4: "c⁸ + 4c⁷ + 6c⁶ + 6c⁵ + 5c⁴ + 2c³ + c² + c",
    }
    
    for n, poly in polys.items():
        deg = 0 if n == 0 else 2**(n-1)
        print(f"  M_{n}(c) = {poly}")
        print(f"    degree = {deg}")
    
    print()
    print("Degree pattern: deg(M_n) = 2^(n-1) for n ≥ 1")
    print("This exponential degree growth is the polynomial analogue of")
    print("the 'sensitivity to initial conditions' in chaos theory.")
    print()


if __name__ == "__main__":
    demo_orbit_shift()
    demo_period_divisibility()
    demo_exact_periods()
    demo_arithmetic_mandelbrot()
    demo_dynatomic_counting()
    demo_orbit_congruence()
    demo_neg_two_fixed()
    demo_polynomial_tower()


#!/usr/bin/env python3
"""
Visualization: The Arithmetic Mandelbrot Set over Finite Fields

Creates a grid visualization showing the arithmetic Mandelbrot set
for small primes, color-coded by period.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def qiter_mod(c: int, n: int, p: int) -> int:
    z = 0
    for _ in range(n):
        z = (z * z + c) % p
    return z


def find_period_mod(c: int, p: int) -> int:
    z = 0
    for n in range(1, p * p + 2):
        z = (z * z + c) % p
        if z == 0:
            return n
    return 0


def main():
    primes = [2, 3, 5, 7, 11, 13, 17, 19]
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    fig.suptitle("Arithmetic Mandelbrot Set over Z/pZ\nColor = Exact Period of Orbit",
                 fontsize=14, fontweight='bold')
    
    cmap = plt.cm.Set1
    max_period = 10
    
    for idx, p in enumerate(primes):
        ax = axes[idx // 4][idx % 4]
        
        periods = []
        for c in range(p):
            per = find_period_mod(c, p)
            periods.append(per)
        
        colors = []
        for per in periods:
            if per == 0:
                colors.append('lightgray')
            else:
                colors.append(cmap(per / max_period))
        
        bars = ax.bar(range(p), [1] * p, color=colors, edgecolor='black', linewidth=0.5)
        
        for i, per in enumerate(periods):
            if per > 0:
                ax.text(i, 0.5, str(per), ha='center', va='center', fontsize=8, fontweight='bold')
        
        ax.set_title(f"Z/{p}Z  |M| = {sum(1 for x in periods if x > 0)}/{p}")
        ax.set_xlabel("c")
        ax.set_yticks([])
        ax.set_xlim(-0.5, p - 0.5)
    
    patches = [mpatches.Patch(color=cmap(i / max_period), label=f'Period {i}')
               for i in range(1, 6)]
    patches.append(mpatches.Patch(color='lightgray', label='Not periodic'))
    fig.legend(handles=patches, loc='lower center', ncol=6, fontsize=9)
    
    plt.tight_layout(rect=[0, 0.06, 1, 0.95])
    plt.savefig("arithmetic_mandelbrot.png", dpi=150, bbox_inches='tight')
    print("Saved arithmetic_mandelbrot.png")


if __name__ == "__main__":
    main()
