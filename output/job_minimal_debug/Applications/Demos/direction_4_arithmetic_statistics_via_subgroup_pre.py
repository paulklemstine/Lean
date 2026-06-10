#!/usr/bin/env python3
"""
Applications of Parabolic Pressure Theory

Demonstrates cross-domain connections between:
- Finite group theory (subgroup counting)
- Arithmetic statistics (flag varieties)
- Information theory (Tsallis entropy)
- Statistical mechanics (free energy)
"""

import math
from typing import List, Tuple


def q_int(q: int, k: int) -> int:
    return sum(q**i for i in range(k)) if k > 0 else 0

def q_factorial(q: int, k: int) -> int:
    r = 1
    for i in range(1, k+1): r *= q_int(q, i)
    return r

def q_binomial(q: int, n: int, k: int) -> int:
    if k < 0 or k > n: return 0
    return q_factorial(q, n) // (q_factorial(q, k) * q_factorial(q, n-k))

def q_multinomial(q: int, c: list) -> int:
    if len(c) <= 1: return 1
    n = sum(c)
    r = q_factorial(q, n)
    for ci in c: r //= q_factorial(q, ci)
    return r

def compositions(n: int) -> list:
    if n == 0: return [[]]
    result = []
    for k in range(1, n+1):
        for rest in compositions(n-k):
            result.append([k] + rest)
    return result

def cross_term(c: list) -> int:
    t, s = 0, sum(c)
    for ci in c: s -= ci; t += ci * s
    return t


# Application 1: Flag Variety Point Counting
def flag_variety_points(q: int, n: int, comp: list) -> int:
    """Count F_q-rational points of the partial flag variety of type comp.

    The number of partial flags of type (n_1, ..., n_k) in F_q^n
    equals the q-multinomial coefficient [n; n_1, ..., n_k]_q.
    This is the index [GL_n(F_q) : P_comp].
    """
    return q_multinomial(q, comp)


# Application 2: Cohen-Lenstra Style Weights
def cohen_lenstra_weight(q: int, n: int) -> float:
    """Compute the Cohen-Lenstra weight for GL_n(F_q).

    The weight 1/|Aut(V)| for V = F_q^n is 1/|GL_n(F_q)|.
    |GL_n(F_q)| = q^{n(n-1)/2} * prod_{i=1}^{n} (q^i - 1).
    """
    gl_order = 1
    for i in range(1, n+1):
        gl_order *= (q**i - 1)
    gl_order *= q**(n*(n-1)//2)
    return 1.0 / gl_order


# Application 3: Random Matrix Subspace Statistics
def subspace_distribution(q: int, n: int) -> dict:
    """Compute the distribution of k-dimensional subspaces in F_q^n.

    The number of k-dimensional subspaces is [n choose k]_q.
    The total number of subspaces is sum_{k=0}^{n} [n choose k]_q.
    """
    dist = {}
    total = 0
    for k in range(n + 1):
        count = q_binomial(q, n, k)
        dist[k] = count
        total += count
    return {k: (v, v/total) for k, v in dist.items()}


# Application 4: Thermodynamic Phase Diagram
def phase_diagram_data(q_values: list, beta_values: list, n: int) -> dict:
    """Compute free energy landscape for different (q, beta) parameters."""
    data = {}
    for q in q_values:
        for beta in beta_values:
            total = 0.0
            for c in compositions(n):
                qm = q_multinomial(q, c)
                if qm > 0:
                    total += qm ** (-beta)
            fe = math.log(total) / n if n > 0 else 0
            data[(q, beta)] = fe
    return data


if __name__ == '__main__':
    print("=" * 70)
    print("APPLICATIONS OF PARABOLIC PRESSURE THEORY")
    print("=" * 70)

    # App 1: Flag Varieties
    print("\n--- Application 1: Flag Variety Point Counting ---")
    print("Number of partial flags of type c in F_q^n = q-multinomial [n; c]_q")
    for q in [2, 3]:
        print(f"\n  q = {q}:")
        for c in [[2, 2], [1, 1, 2], [1, 1, 1, 1]]:
            n = sum(c)
            pts = flag_variety_points(q, n, c)
            print(f"    Flag type {c} in F_{q}^{n}: {pts} points")

    # App 2: Cohen-Lenstra Weights
    print("\n--- Application 2: Cohen-Lenstra Weights ---")
    for q in [2, 3, 5]:
        print(f"  q = {q}:")
        for n in range(1, 5):
            w = cohen_lenstra_weight(q, n)
            print(f"    1/|GL_{n}(F_{q})| = {w:.2e}")

    # App 3: Subspace Distribution
    print("\n--- Application 3: Subspace Distribution in F_2^6 ---")
    dist = subspace_distribution(2, 6)
    for k, (count, prob) in dist.items():
        print(f"  dim {k}: {count:>6d} subspaces ({prob:.4f})")

    # App 4: Phase Diagram
    print("\n--- Application 4: Free Energy Landscape F(n=5, q, beta) ---")
    q_vals = [2, 3, 5, 7]
    beta_vals = [0.0, 0.5, 1.0, 2.0]
    data = phase_diagram_data(q_vals, beta_vals, 5)
    print(f"{'q':>4} {'beta':>6} {'F(5,q,beta)':>14}")
    for q in q_vals:
        for beta in beta_vals:
            fe = data[(q, beta)]
            print(f"{q:>4} {beta:>6.1f} {fe:>14.6f}")

    # App 5: Tsallis Entropy Connection
    print("\n--- Application 5: Tsallis-2 Entropy Approximation ---")
    q = 2
    for n in range(3, 8):
        print(f"  n = {n}, q = {q}:")
        for c in compositions(n)[:3]:
            qm = q_multinomial(q, c)
            w = math.log(qm) if qm > 0 else 0
            p = [ci / n for ci in c]
            h2 = 1 - sum(x**2 for x in p)
            approx = (math.log(q) / 2) * h2
            actual = w / n**2
            err = abs(actual - approx)
            print(f"    c={str(c):>12}: w/n² = {actual:.4f}, "
                  f"(log q/2)H₂ = {approx:.4f}, error = {err:.4f}")


#!/usr/bin/env python3
"""
Parabolic Pressure for GL_n(F_q): Computational Exploration

This script computes parabolic pressure, q-multinomial coefficients,
and related quantities for finite linear groups, demonstrating the
theorems proved in the formal development.

Usage:
    python demo.py [--q Q] [--beta BETA] [--nmax NMAX]
"""

import math
from itertools import product as cartesian_product
from functools import lru_cache
import argparse


def q_int(q: int, k: int) -> int:
    """q-integer [k]_q = 1 + q + ... + q^{k-1}"""
    return sum(q**i for i in range(k))


def q_factorial(q: int, k: int) -> int:
    """q-factorial [k]_q! = [1]_q * [2]_q * ... * [k]_q"""
    result = 1
    for i in range(1, k + 1):
        result *= q_int(q, i)
    return result


def q_binomial(q: int, n: int, k: int) -> int:
    """Gaussian binomial coefficient [n choose k]_q via recurrence"""
    if k < 0 or k > n:
        return 0
    if k == 0:
        return 1
    # Use the factorial formula for efficiency
    num = q_factorial(q, n)
    den = q_factorial(q, k) * q_factorial(q, n - k)
    return num // den


def q_multinomial(q: int, c: list) -> int:
    """q-multinomial coefficient [n; c_1, ..., c_k]_q"""
    if len(c) <= 1:
        return 1
    n = sum(c)
    result = q_factorial(q, n)
    for ci in c:
        result //= q_factorial(q, ci)
    return result


def compositions(n: int) -> list:
    """Generate all compositions of n (ordered partitions into positive parts)"""
    if n == 0:
        return [[]]
    result = []
    for k in range(1, n + 1):
        for rest in compositions(n - k):
            result.append([k] + rest)
    return result


def cross_term(c: list) -> int:
    """Composition cross-term sum_{i<j} c_i * c_j"""
    total = 0
    for i in range(len(c)):
        for j in range(i + 1, len(c)):
            total += c[i] * c[j]
    return total


def parabolic_pressure(q: int, beta: float, n: int) -> float:
    """Parabolic pressure Pi^par_{n,q}(beta) = sum_{c |= n} exp(-beta * log(qMultinomial(q, c)))"""
    total = 0.0
    for c in compositions(n):
        qm = q_multinomial(q, c)
        if qm > 0:
            total += math.exp(-beta * math.log(qm))
    return total


def normalized_free_energy(q: int, beta: float, n: int) -> float:
    """F^par_{n,q}(beta) = (1/n) * log(Pi^par_{n,q}(beta))"""
    if n == 0:
        return 0.0
    pi = parabolic_pressure(q, beta, n)
    return math.log(pi) / n


def tsallis2(p: list) -> float:
    """Tsallis-2 entropy H_2(p) = 1 - sum p_i^2"""
    return 1.0 - sum(x**2 for x in p)


def main():
    parser = argparse.ArgumentParser(description='Parabolic Pressure Explorer')
    parser.add_argument('--q', type=int, default=2, help='Field size parameter (default: 2)')
    parser.add_argument('--beta', type=float, default=1.0, help='Inverse temperature (default: 1.0)')
    parser.add_argument('--nmax', type=int, default=8, help='Maximum n (default: 8)')
    args = parser.parse_args()

    q = args.q
    beta = args.beta
    nmax = args.nmax

    print(f"=" * 70)
    print(f"PARABOLIC PRESSURE FOR GL_n(F_{q})")
    print(f"beta = {beta}, q = {q}")
    print(f"=" * 70)

    # 1. Verify cross-term identity
    print(f"\n--- Theorem: 2 * crossTerm(c) = sum(c)^2 - sumOfSquares(c) ---")
    for n in range(1, min(nmax, 5) + 1):
        for c in compositions(n)[:3]:
            ct = cross_term(c)
            sos = sum(x**2 for x in c)
            lhs = 2 * ct
            rhs = sum(c)**2 - sos
            print(f"  c = {c}: 2*crossTerm = {lhs}, sum^2 - sumSq = {rhs}, match = {lhs == rhs}")

    # 2. Verify q-multinomial bounds
    print(f"\n--- Theorem: q^crossTerm <= qMultinomial <= q^(crossTerm + sum) ---")
    for n in range(1, min(nmax, 5) + 1):
        for c in compositions(n)[:3]:
            qm = q_multinomial(q, c)
            ct = cross_term(c)
            s = sum(c)
            lb = q**ct
            ub = q**(ct + s)
            print(f"  c = {c}: {lb} <= {qm} <= {ub}  "
                  f"[{lb <= qm and qm <= ub}]")

    # 3. Parabolic pressure table
    print(f"\n--- Parabolic Pressure Pi^par_{{n,{q}}}({beta}) ---")
    print(f"{'n':>4} {'Pi(n)':>14} {'log Pi(n)':>12} {'F(n)=log Pi/n':>14}")
    print(f"{'---':>4} {'---':>14} {'---':>12} {'---':>14}")
    for n in range(1, nmax + 1):
        pi = parabolic_pressure(q, beta, n)
        log_pi = math.log(pi)
        fn = log_pi / n
        print(f"{n:>4} {pi:>14.6f} {log_pi:>12.6f} {fn:>14.6f}")

    # 4. Near-supermultiplicativity check
    print(f"\n--- Near-Supermultiplicativity: log Pi(m+n) >= log Pi(m) + log Pi(n) - beta*log(B) ---")
    for m in range(1, min(nmax // 2, 4) + 1):
        for n_val in range(1, min(nmax - m, 4) + 1):
            pi_mn = parabolic_pressure(q, beta, m + n_val)
            pi_m = parabolic_pressure(q, beta, m)
            pi_n = parabolic_pressure(q, beta, n_val)
            B = q_binomial(q, m + n_val, m)
            lhs = math.log(pi_mn)
            rhs = math.log(pi_m) + math.log(pi_n) - beta * math.log(B)
            print(f"  m={m}, n={n_val}: log Pi({m+n_val}) = {lhs:.4f} >= "
                  f"{rhs:.4f} = log Pi({m}) + log Pi({n_val}) - beta*log B  [{lhs >= rhs - 1e-10}]")

    # 5. Tsallis-2 entropy approximation
    print(f"\n--- Tsallis-2 Approximation: w/(n^2) ~ (log q / 2) * H_2(p) ---")
    for n in range(2, min(nmax, 6) + 1):
        for c in compositions(n)[:2]:
            qm = q_multinomial(q, c)
            w = math.log(qm) if qm > 0 else 0
            p = [ci / n for ci in c]
            h2 = tsallis2(p)
            approx = (math.log(q) / 2) * h2
            actual = w / n**2
            error = abs(actual - approx)
            print(f"  n={n}, c={c}: w/n^2 = {actual:.6f}, (log q/2)*H2 = {approx:.6f}, "
                  f"|error| = {error:.6f}, C/n bound = {error * n:.6f}")

    # 6. Convergence of free energy
    print(f"\n--- Free Energy Convergence F^par_{{n,q}}(beta) = (1/n)*log Pi(n) ---")
    for q_val in [2, 3, 5]:
        print(f"  q = {q_val}:")
        prev = None
        for n in range(1, nmax + 1):
            fn = normalized_free_energy(q_val, beta, n)
            diff_str = f"  diff = {fn - prev:.6f}" if prev is not None else ""
            print(f"    n={n}: F(n) = {fn:.6f}{diff_str}")
            prev = fn

    print(f"\n{'=' * 70}")
    print("All computations complete.")


if __name__ == '__main__':
    main()


"""
Visualization: Energy Landscape of Compositions

Shows the parabolic index weight w_q(c) for all compositions of n,
colored by the number of parts, demonstrating the quadratic energy bounds.
"""
import math
import matplotlib.pyplot as plt
import numpy as np

def q_int(q, k):
    return sum(q**i for i in range(k)) if k > 0 else 0

def q_factorial(q, k):
    r = 1
    for i in range(1, k+1): r *= q_int(q, i)
    return r

def q_multinomial(q, c):
    if len(c) <= 1: return 1
    n = sum(c)
    r = q_factorial(q, n)
    for ci in c: r //= q_factorial(q, ci)
    return r

def cross_term(c):
    t, s = 0, sum(c)
    for ci in c: s -= ci; t += ci * s
    return t

def compositions(n):
    if n == 0: return [[]]
    result = []
    for k in range(1, n+1):
        for rest in compositions(n-k):
            result.append([k] + rest)
    return result

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
q = 2

# Left: Energy vs cross-term for different n
ax = axes[0]
for n in [4, 5, 6, 7]:
    comps = compositions(n)
    cts = [cross_term(c) for c in comps]
    ws = [math.log(q_multinomial(q, c)) for c in comps]
    ax.scatter(cts, ws, s=20, alpha=0.6, label=f'n={n}')

# Plot bounds
ct_range = np.linspace(0, 15, 100)
ax.plot(ct_range, ct_range * math.log(q), 'k-', linewidth=2, label='Lower: ct·log q')
ax.fill_between(ct_range, ct_range * math.log(q),
                ct_range * math.log(q) + 8 * math.log(q),
                alpha=0.1, color='gray', label='Upper gap: n·log q')

ax.set_xlabel('Cross-term Σᵢ<ⱼ nᵢnⱼ', fontsize=13)
ax.set_ylabel('Weight w_q(c) = log[n; c]_q', fontsize=13)
ax.set_title('Energy vs Cross-Term (q=2)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Histogram of energies for n=7
ax = axes[1]
n = 7
comps = compositions(n)
ws = [math.log(q_multinomial(q, c)) for c in comps]
parts = [len(c) for c in comps]

for k in sorted(set(parts)):
    w_k = [w for w, p in zip(ws, parts) if p == k]
    ax.hist(w_k, bins=15, alpha=0.6, label=f'{k} parts')

ax.set_xlabel('Weight w_q(c)', fontsize=13)
ax.set_ylabel('Count', fontsize=13)
ax.set_title(f'Energy Distribution (n={n}, q={q})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved energy_landscape.png")


"""
Visualization: Normalized Free Energy Convergence

Plots the normalized parabolic free energy F^par_{n,q}(beta) = (1/n) * log(Pi)
as a function of n for different values of q, showing convergence behavior.
"""
import math
import matplotlib.pyplot as plt
import numpy as np

def q_int(q, k):
    return sum(q**i for i in range(k)) if k > 0 else 0

def q_factorial(q, k):
    r = 1
    for i in range(1, k+1): r *= q_int(q, i)
    return r

def q_multinomial(q, c):
    if len(c) <= 1: return 1
    n = sum(c)
    r = q_factorial(q, n)
    for ci in c: r //= q_factorial(q, ci)
    return r

def compositions(n):
    if n == 0: return [[]]
    result = []
    for k in range(1, n+1):
        for rest in compositions(n-k):
            result.append([k] + rest)
    return result

def parabolic_pressure(q, beta, n):
    return sum(q_multinomial(q, c)**(-beta) for c in compositions(n))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Free energy vs n for different q
ax = axes[0]
nmax = 8
for q in [2, 3, 5, 7]:
    ns = list(range(1, nmax+1))
    Fs = [math.log(parabolic_pressure(q, 1.0, n)) / n for n in ns]
    ax.plot(ns, Fs, 'o-', label=f'q = {q}', markersize=6)

ax.set_xlabel('n', fontsize=13)
ax.set_ylabel('F(n, q, β=1)', fontsize=13)
ax.set_title('Normalized Free Energy vs n', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Right: Free energy vs beta for fixed q=2, different n
ax = axes[1]
betas = np.linspace(0.01, 3.0, 30)
for n in [2, 4, 6, 8]:
    Fs = [math.log(parabolic_pressure(2, b, n)) / n for b in betas]
    ax.plot(betas, Fs, '-', label=f'n = {n}', linewidth=2)

ax.set_xlabel('β', fontsize=13)
ax.set_ylabel('F(n, q=2, β)', fontsize=13)
ax.set_title('Free Energy vs β (q=2)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('free_energy_convergence.png', dpi=150, bbox_inches='tight')
print("Saved free_energy_convergence.png")


"""
Visualization: Tsallis-2 Entropy Approximation

Shows how the normalized parabolic weight w_q(c)/n^2 converges to
(log q / 2) * H_2(p) as n grows, where H_2(p) = 1 - sum(p_i^2)
is the Tsallis-2 entropy.
"""
import math
import matplotlib.pyplot as plt
import numpy as np

def q_int(q, k):
    return sum(q**i for i in range(k)) if k > 0 else 0

def q_factorial(q, k):
    r = 1
    for i in range(1, k+1): r *= q_int(q, i)
    return r

def q_multinomial(q, c):
    if len(c) <= 1: return 1
    n = sum(c)
    r = q_factorial(q, n)
    for ci in c: r //= q_factorial(q, ci)
    return r

def cross_term(c):
    t, s = 0, sum(c)
    for ci in c: s -= ci; t += ci * s
    return t

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
q = 2

# Left: Scatter plot of w/n^2 vs (log q / 2) * H2(p)
ax = axes[0]
for n in range(2, 8):
    from itertools import combinations_with_replacement
    # Generate some compositions of n
    comps = []
    def gen_comp(n, prefix=[]):
        if n == 0:
            if prefix: comps.append(prefix[:])
            return
        for k in range(1, n+1):
            prefix.append(k)
            gen_comp(n-k, prefix)
            prefix.pop()
    gen_comp(n)

    actuals, approxs = [], []
    for c in comps:
        qm = q_multinomial(q, c)
        if qm <= 0: continue
        w = math.log(qm)
        p = [ci/n for ci in c]
        h2 = 1 - sum(x**2 for x in p)
        actuals.append(w / n**2)
        approxs.append((math.log(q) / 2) * h2)

    ax.scatter(approxs, actuals, s=15, alpha=0.7, label=f'n={n}')

mn, mx = 0, max(max(a for a in [0.01]), 0.5)
ax.plot([0, 0.4], [0, 0.4], 'k--', alpha=0.5, label='y = x')
ax.set_xlabel('(log q / 2) · H₂(p)', fontsize=13)
ax.set_ylabel('w_q(c) / n²', fontsize=13)
ax.set_title('Tsallis-2 Approximation (q=2)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Error decay as function of n
ax = axes[1]
ns_plot = list(range(2, 9))
max_errors = []
mean_errors = []

for n in ns_plot:
    comps = []
    def gen_comp2(n, prefix=[]):
        if n == 0:
            if prefix: comps.append(prefix[:])
            return
        for k in range(1, n+1):
            prefix.append(k)
            gen_comp2(n-k, prefix)
            prefix.pop()
    gen_comp2(n)

    errors = []
    for c in comps:
        qm = q_multinomial(q, c)
        if qm <= 0: continue
        w = math.log(qm)
        p = [ci/n for ci in c]
        h2 = 1 - sum(x**2 for x in p)
        actual = w / n**2
        approx = (math.log(q) / 2) * h2
        errors.append(abs(actual - approx))

    max_errors.append(max(errors))
    mean_errors.append(sum(errors)/len(errors))

ax.plot(ns_plot, max_errors, 'ro-', label='Max error', markersize=6)
ax.plot(ns_plot, mean_errors, 'bs-', label='Mean error', markersize=6)
ax.plot(ns_plot, [math.log(q)/n for n in ns_plot], 'g--', label='log(q)/n', linewidth=2)
ax.set_xlabel('n', fontsize=13)
ax.set_ylabel('|w/n² - (log q/2)·H₂|', fontsize=13)
ax.set_title('Approximation Error Decay (q=2)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tsallis_approximation.png', dpi=150, bbox_inches='tight')
print("Saved tsallis_approximation.png")
