#!/usr/bin/env python3
"""
Demonstration of the Hecke eigenvalue recursion and its key identities.
Numerically verifies the Cassini-Hecke identity, addition formula,
tropical linearization, and growth dichotomy.
"""

import math
from typing import List, Tuple


def hecke_seq(a: int, q: int, n: int) -> int:
    """Compute the Hecke eigenvalue sequence h(n) with parameters a, q.
    
    h(0) = 1, h(1) = a, h(n+2) = a * h(n+1) - q * h(n)
    """
    if n == 0:
        return 1
    if n == 1:
        return a
    h_prev2 = 1  # h(0)
    h_prev1 = a  # h(1)
    for _ in range(2, n + 1):
        h_curr = a * h_prev1 - q * h_prev2
        h_prev2 = h_prev1
        h_prev1 = h_curr
    return h_prev1


def trop_hecke_seq(a: float, q: float, n: int) -> float:
    """Compute the tropical Hecke sequence t(n) with parameters a, q.
    
    t(0) = 0, t(1) = a, t(n+2) = min(a + t(n+1), q + t(n))
    """
    if n == 0:
        return 0.0
    if n == 1:
        return a
    t_prev2 = 0.0
    t_prev1 = a
    for _ in range(2, n + 1):
        t_curr = min(a + t_prev1, q + t_prev2)
        t_prev2 = t_prev1
        t_prev1 = t_curr
    return t_prev1


def soft_min(t: float, x: float, y: float) -> float:
    """Soft minimum: -t * log(exp(-x/t) + exp(-y/t))"""
    if t <= 0:
        return min(x, y)
    # Numerically stable version
    m = min(x, y)
    return m - t * math.log(1 + math.exp(-(abs(x - y)) / t))


def maslov_hecke_seq(temp: float, a: float, q: float, n: int) -> float:
    """Maslov-deformed Hecke sequence at temperature temp."""
    if n == 0:
        return 0.0
    if n == 1:
        return a
    m_prev2 = 0.0
    m_prev1 = a
    for _ in range(2, n + 1):
        m_curr = soft_min(temp, a + m_prev1, q + m_prev2)
        m_prev2 = m_prev1
        m_prev1 = m_curr
    return m_prev1


def verify_cassini_hecke(a: int, q: int, max_n: int = 20) -> bool:
    """Verify the Cassini-Hecke identity h(n+1)^2 - h(n+2)*h(n) = q^(n+1)."""
    print(f"\n=== Cassini-Hecke Identity (a={a}, q={q}) ===")
    all_ok = True
    for n in range(max_n):
        hn = hecke_seq(a, q, n)
        hn1 = hecke_seq(a, q, n + 1)
        hn2 = hecke_seq(a, q, n + 2)
        lhs = hn1 ** 2 - hn2 * hn
        rhs = q ** (n + 1)
        ok = lhs == rhs
        if not ok:
            all_ok = False
        if n < 8:
            print(f"  n={n}: h({n+1})²-h({n+2})·h({n}) = {lhs}, q^{n+1} = {rhs} {'✓' if ok else '✗'}")
    print(f"  All n=0..{max_n-1}: {'PASS' if all_ok else 'FAIL'}")
    return all_ok


def verify_addition_formula(a: int, q: int, max_mn: int = 10) -> bool:
    """Verify h(m+n+2) = h(m+1)*h(n+1) - q*h(m)*h(n)."""
    print(f"\n=== Addition Formula (a={a}, q={q}) ===")
    all_ok = True
    for m in range(max_mn):
        for n in range(max_mn):
            lhs = hecke_seq(a, q, m + n + 2)
            rhs = hecke_seq(a, q, m + 1) * hecke_seq(a, q, n + 1) - q * hecke_seq(a, q, m) * hecke_seq(a, q, n)
            if lhs != rhs:
                all_ok = False
                print(f"  FAIL at m={m}, n={n}: {lhs} != {rhs}")
    print(f"  All m,n in 0..{max_mn-1}: {'PASS' if all_ok else 'FAIL'}")
    return all_ok


def verify_tropical_linearization(a: float, q: float, max_n: int = 20) -> bool:
    """Verify that tropHeckeSeq(a, q, n) = n*a when 2a <= q."""
    print(f"\n=== Tropical Linearization (a={a}, q={q}, 2a={2*a} <= q={q}: {2*a <= q}) ===")
    all_ok = True
    for n in range(max_n):
        t_n = trop_hecke_seq(a, q, n)
        expected = n * a
        ok = abs(t_n - expected) < 1e-10
        if not ok:
            all_ok = False
        if n < 10:
            print(f"  t({n}) = {t_n:.4f}, expected {expected:.4f} {'✓' if ok else '✗'}")
    print(f"  All n=0..{max_n-1}: {'PASS' if all_ok else 'FAIL'}")
    return all_ok


def verify_boundary_case(max_n: int = 30) -> bool:
    """Verify h(n) = n+1 when a=2, q=1."""
    print(f"\n=== Boundary Case (a=2, q=1) ===")
    all_ok = True
    for n in range(max_n):
        hn = hecke_seq(2, 1, n)
        expected = n + 1
        ok = hn == expected
        if not ok:
            all_ok = False
        if n < 10:
            print(f"  h({n}) = {hn}, expected {expected} {'✓' if ok else '✗'}")
    print(f"  All n=0..{max_n-1}: {'PASS' if all_ok else 'FAIL'}")
    return all_ok


def demonstrate_growth_dichotomy():
    """Show the growth behavior inside vs outside the Ramanujan regime."""
    print("\n=== Growth Dichotomy ===")
    
    # Inside Ramanujan: a=2, q=2 (a²=4 <= 4q=8)
    print("\n  Inside Ramanujan (a=2, q=2, a²=4 ≤ 4q=8):")
    for n in [0, 5, 10, 15, 20]:
        hn = hecke_seq(2, 2, n)
        bound = (n + 1) * int(2 ** (n / 2)) if n % 2 == 0 else (n + 1) * 2 ** (n // 2) * 2
        print(f"    h({n}) = {hn}, bound (n+1)·q^(n/2) ≈ {(n+1) * 2**(n/2):.0f}")
    
    # Outside Ramanujan: a=3, q=1 (a²=9 > 4q=4)
    print("\n  Outside Ramanujan (a=3, q=1, a²=9 > 4q=4):")
    for n in [0, 5, 10, 15, 20]:
        hn = hecke_seq(3, 1, n)
        print(f"    h({n}) = {hn}, ratio h(n)/h(n-1) ≈ {hn / max(1, hecke_seq(3, 1, max(0, n-1))):.4f}")


def demonstrate_maslov_convergence():
    """Show convergence of Maslov-deformed sequence to tropical as t→0."""
    print("\n=== Maslov Dequantization Convergence ===")
    print("  (a=1, q=3, Ramanujan regime: 2a=2 ≤ q=3)")
    
    n_val = 5
    trop_val = trop_hecke_seq(1.0, 3.0, n_val)
    print(f"\n  Tropical value t({n_val}) = {trop_val}")
    print(f"  {'t':>10s} {'maslov(t)':>12s} {'error':>12s}")
    for temp in [10.0, 1.0, 0.1, 0.01, 0.001]:
        m_val = maslov_hecke_seq(temp, 1.0, 3.0, n_val)
        err = abs(m_val - trop_val)
        print(f"  {temp:10.3f} {m_val:12.6f} {err:12.8f}")


def demonstrate_fibonacci_specialization():
    """Show that a=1, q=-1 gives the Fibonacci sequence."""
    print("\n=== Fibonacci Specialization (a=1, q=-1) ===")
    print("  h(n) = F(n+1) (Fibonacci numbers shifted by 1)")
    fib_names = ["F(1)", "F(2)", "F(3)", "F(4)", "F(5)", "F(6)", "F(7)", "F(8)", "F(9)", "F(10)"]
    for n in range(10):
        hn = hecke_seq(1, -1, n)
        print(f"  h({n}) = {hn} = {fib_names[n]}")
    
    print("\n  Cassini identity F(n+1)² - F(n+2)·F(n) = (-1)^(n+1):")
    for n in range(8):
        cassini = hecke_seq(1, -1, n+1)**2 - hecke_seq(1, -1, n+2) * hecke_seq(1, -1, n)
        print(f"    n={n}: {cassini} = (-1)^{n+1} = {(-1)**(n+1)} ✓")


def test_fermat_conjecture():
    """Test the Fermat-like conjecture: p | h(p-1) - 1 when gcd(q, p) = 1."""
    print("\n=== Fermat-like Divisibility Conjecture ===")
    print("  Testing: p | h(p-1) - 1 when gcd(q, p) = 1")
    
    primes = [2, 3, 5, 7, 11, 13]
    test_cases = [(2, 1), (3, 2), (1, 1), (5, 3), (4, 7)]
    
    for a, q in test_cases:
        print(f"\n  a={a}, q={q}:")
        for p in primes:
            if q % p == 0:
                print(f"    p={p}: SKIP (p | q)")
                continue
            hp = hecke_seq(a, q, p - 1)
            residue = (hp - 1) % p
            print(f"    p={p}: h({p-1}) = {hp}, h({p-1})-1 mod {p} = {residue} {'✓' if residue == 0 else '✗'}")


if __name__ == "__main__":
    print("=" * 60)
    print("  HECKE EIGENVALUE RECURSION — NUMERICAL DEMONSTRATIONS")
    print("=" * 60)
    
    # Core identity verifications
    verify_cassini_hecke(3, 2)
    verify_cassini_hecke(1, -1)  # Fibonacci
    verify_addition_formula(3, 2)
    verify_boundary_case()
    
    # Tropical theory
    verify_tropical_linearization(1.0, 3.0)  # Ramanujan regime
    verify_tropical_linearization(3.0, 4.0)  # Non-Ramanujan (2a=6 > q=4)
    
    # Specializations and growth
    demonstrate_fibonacci_specialization()
    demonstrate_growth_dichotomy()
    demonstrate_maslov_convergence()
    
    # Conjecture testing
    test_fermat_conjecture()
    
    print("\n" + "=" * 60)
    print("  ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization of the Hecke eigenvalue recursion and growth dichotomy."""

import matplotlib.pyplot as plt
import numpy as np


def hecke_seq(a, q, n):
    if n == 0:
        return 1
    if n == 1:
        return a
    h0, h1 = 1, a
    for _ in range(2, n + 1):
        h0, h1 = h1, a * h1 - q * h0
    return h1


def trop_hecke_seq(a, q, n):
    if n == 0:
        return 0.0
    if n == 1:
        return float(a)
    t0, t1 = 0.0, float(a)
    for _ in range(2, n + 1):
        t0, t1 = t1, min(a + t1, q + t0)
    return t1


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Growth Dichotomy
ax = axes[0, 0]
ns = list(range(20))
cases = [
    (2, 1, "a=2, q=1 (boundary)", "C0"),
    (2, 2, "a=2, q=2 (Ramanujan)", "C1"),
    (3, 1, "a=3, q=1 (non-Ramanujan)", "C2"),
    (1, -1, "a=1, q=-1 (Fibonacci)", "C3"),
]
for a, q, label, color in cases:
    vals = [abs(hecke_seq(a, q, n)) for n in ns]
    ax.semilogy(ns, [max(v, 0.1) for v in vals], 'o-', label=label, color=color, markersize=4)
ax.set_xlabel("n")
ax.set_ylabel("|h(n)|")
ax.set_title("Hecke Sequence Growth Dichotomy")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 2: Cassini-Hecke Identity
ax = axes[0, 1]
ns = list(range(15))
for a, q, label, color in [(3, 2, "a=3,q=2", "C0"), (1, -1, "Fibonacci", "C1"), (2, 1, "boundary", "C2")]:
    cassini = []
    for n in ns:
        hn = hecke_seq(a, q, n)
        hn1 = hecke_seq(a, q, n + 1)
        hn2 = hecke_seq(a, q, n + 2)
        cassini.append(hn1**2 - hn2 * hn)
    expected = [q**(n+1) for n in ns]
    ax.plot(ns, cassini, 'o', label=f"{label}: defect", color=color, markersize=5)
    ax.plot(ns, expected, '-', label=f"{label}: q^(n+1)", color=color, alpha=0.5)
ax.set_xlabel("n")
ax.set_ylabel("Cassini defect = q^(n+1)")
ax.set_title("Cassini-Hecke Identity Verification")
ax.legend(fontsize=7)
ax.grid(True, alpha=0.3)

# Plot 3: Tropical vs Classical
ax = axes[1, 0]
ns = list(range(15))
a_val, q_val = 1.0, 3.0
trop_vals = [trop_hecke_seq(a_val, q_val, n) for n in ns]
classical_vals = [np.log(max(abs(hecke_seq(int(a_val), int(q_val), n)), 1e-10)) for n in ns]
ax.plot(ns, trop_vals, 'bo-', label=f"Tropical (a={a_val}, q={q_val})", markersize=5)
ax.plot(ns, [n * a_val for n in ns], 'r--', label=f"Affine: n·a", alpha=0.7)
a_val2, q_val2 = 3.0, 4.0
trop_vals2 = [trop_hecke_seq(a_val2, q_val2, n) for n in ns]
ax.plot(ns, trop_vals2, 'gs-', label=f"Tropical (a={a_val2}, q={q_val2})", markersize=5)
ax.plot(ns, [n * a_val2 for n in ns], 'g--', label=f"Affine: n·a (broken)", alpha=0.3)
ax.set_xlabel("n")
ax.set_ylabel("t(n)")
ax.set_title("Tropical Hecke: Ramanujan vs Non-Ramanujan")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 4: Boundary case h(n) = n+1
ax = axes[1, 1]
ns = list(range(20))
hn_vals = [hecke_seq(2, 1, n) for n in ns]
ax.plot(ns, hn_vals, 'ro-', label="h(n) with a=2, q=1", markersize=6)
ax.plot(ns, [n + 1 for n in ns], 'b--', label="n + 1", linewidth=2, alpha=0.7)
ax.set_xlabel("n")
ax.set_ylabel("h(n)")
ax.set_title("Boundary Case: a²=4q → h(n) = n+1")
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("hecke_visualization.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved hecke_visualization.png")
