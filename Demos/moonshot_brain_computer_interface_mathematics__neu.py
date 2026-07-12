"""
Neural Coding Theorems --- numerical demonstrations.

Self-contained demonstrations of the core results:

  1. Capacity theorem:            |{0,1}^N| = 2^N   and the doubling law.
  2. Dense energy law:            E[weight] = N/2 over uniform codes.
  3. Sparse counting & efficiency: |weight-k codes| = C(N,k);
                                   info/spike rho(N,k) = log2 C(N,k)/k,
                                   rho(N,1) = log2 N  (Theta(log N) advantage).
  4. Population precision:        Var(mean of N iid) = v/N  (1/sqrt(N) error).
  5. Neural manifold bound:       rank of activity from d behaviors <= d.

Run:  python demo.py
Only the standard library is required for 1-3 and 5; NumPy is used, if
available, for the Monte Carlo checks in 4 (a pure-Python fallback is
provided).
"""

from __future__ import annotations

from itertools import product
from math import comb, log2, sqrt
from typing import Iterator


# --------------------------------------------------------------------------
# 1. Capacity and the doubling law
# --------------------------------------------------------------------------

def all_codes(n: int) -> Iterator[tuple[int, ...]]:
    """Enumerate every neural code in {0,1}^n."""
    return product((0, 1), repeat=n)


def capacity(n: int) -> int:
    """Representational capacity of n binary neurons: 2^n."""
    return 2 ** n


def demo_capacity(max_n: int = 8) -> None:
    print("=" * 68)
    print("1. CAPACITY THEOREM  |{0,1}^N| = 2^N   and the doubling law")
    print("=" * 68)
    for n in range(1, max_n + 1):
        enumerated = sum(1 for _ in all_codes(n))  # brute-force count
        formula = capacity(n)
        doubling = capacity(n) == 2 * capacity(n - 1) if n >= 1 else True
        assert enumerated == formula
        print(f"  N={n:2d}:  enumerated={enumerated:5d}  2^N={formula:5d}"
              f"  doubling(2^N = 2*2^(N-1)): {doubling}")
    print(f"  ...just N=300 binary neurons give 2^300 = {2**300:.3e} codes,")
    print("     more than the number of atoms in the observable universe.\n")


# --------------------------------------------------------------------------
# 2. Dense energy law: E[weight] = N/2
# --------------------------------------------------------------------------

def mean_weight_bruteforce(n: int) -> float:
    """Average number of active neurons over all 2^n codes."""
    total = sum(sum(code) for code in all_codes(n))
    return total / capacity(n)


def demo_dense_energy(max_n: int = 12) -> None:
    print("=" * 68)
    print("2. DENSE ENERGY LAW   E[active neurons] = N/2")
    print("=" * 68)
    for n in range(1, max_n + 1):
        mean = mean_weight_bruteforce(n)
        # total weight identity: sum_c w(c) = N * 2^(N-1)
        total = mean * capacity(n)
        assert total == n * 2 ** (n - 1)
        print(f"  N={n:2d}:  mean weight = {mean:6.3f}   N/2 = {n/2:6.3f}"
              f"   total = N*2^(N-1) = {int(total)}")
    print("  => using all codes democratically fires HALF the population.\n")


# --------------------------------------------------------------------------
# 3. Sparse counting and information per spike
# --------------------------------------------------------------------------

def sparse_count(n: int, k: int) -> int:
    """Number of weight-k neural codes: C(n, k)."""
    return comb(n, k)


def info_per_spike(n: int, k: int) -> float:
    """rho(N,k) = log2 C(N,k) / k  (bits carried per active neuron)."""
    if k == 0:
        return 0.0
    return log2(comb(n, k)) / k


def demo_sparse(n: int = 10000) -> None:
    print("=" * 68)
    print("3. SPARSE COUNTING & EFFICIENCY  (info per spike)")
    print("=" * 68)
    # verify sum_k C(N,k) = 2^N on a small N
    small = 12
    assert sum(sparse_count(small, k) for k in range(small + 1)) == 2 ** small
    print(f"  Check: sum_k C({small},k) = 2^{small} = {2**small}  (recovers capacity)")

    print(f"\n  With N = {n} neurons and a 1% code (k = {n//100}):")
    c = sparse_count(n, n // 100)
    print(f"    number of patterns C(N,k) has {len(str(c))} digits.")

    print("\n  Information per spike rho(N,k) = log2 C(N,k)/k :")
    for k in (1, 2, 5, 10, 100, n // 100, n // 2):
        print(f"    k={k:6d}:  rho = {info_per_spike(n, k):8.3f} bits/spike")
    rho1 = info_per_spike(n, 1)
    print(f"\n  One-hot (k=1): rho = log2 N = {rho1:.3f} bits/spike (Theta(log N)).")
    print(f"  Dense: N bits at N/2 spikes => 2 bits/spike (constant).")
    print(f"  Sparse advantage factor = (log2 N)/2 = {rho1/2:.2f}x .\n")


def optimal_sparsity(n: int) -> tuple[int, float]:
    """Return (k*, rho*) maximizing info per spike over k=1..n."""
    best_k, best_rho = 1, info_per_spike(n, 1)
    for k in range(1, n + 1):
        r = info_per_spike(n, k)
        if r > best_rho:
            best_k, best_rho = k, r
    return best_k, best_rho


# --------------------------------------------------------------------------
# 4. Population precision: Var(mean) = v/N,  error ~ 1/sqrt(N)
# --------------------------------------------------------------------------

def demo_population(v: float = 1.0, trials: int = 20000) -> None:
    print("=" * 68)
    print("4. POPULATION PRECISION   Var(mean of N iid) = v/N")
    print("=" * 68)
    try:
        import numpy as np  # optional
        rng = np.random.default_rng(0)
        for n in (1, 4, 16, 64, 256):
            samples = rng.normal(0.0, sqrt(v), size=(trials, n))
            means = samples.mean(axis=1)
            emp_var = float(means.var())
            print(f"  N={n:4d}:  empirical Var(mean) = {emp_var:8.5f}"
                  f"   theory v/N = {v/n:8.5f}"
                  f"   sd ~ 1/sqrt(N) = {sqrt(v/n):7.4f}")
    except ImportError:
        import random
        random.seed(0)
        for n in (1, 4, 16, 64, 256):
            means = []
            for _ in range(trials):
                s = sum(random.gauss(0.0, sqrt(v)) for _ in range(n)) / n
                means.append(s)
            mu = sum(means) / trials
            emp_var = sum((m - mu) ** 2 for m in means) / trials
            print(f"  N={n:4d}:  empirical Var(mean) = {emp_var:8.5f}"
                  f"   theory v/N = {v/n:8.5f}")
    print("  => pooling N noisy neurons sharpens precision as sqrt(N).\n")


# --------------------------------------------------------------------------
# 5. Neural manifold dimension bound: rank(activity) <= d
# --------------------------------------------------------------------------

def demo_manifold(n_neurons: int = 200, d_behaviors: int = 3,
                  n_time: int = 500) -> None:
    print("=" * 68)
    print("5. NEURAL MANIFOLD BOUND   dim(activity) <= behavioral DOF")
    print("=" * 68)
    try:
        import numpy as np
        rng = np.random.default_rng(1)
        # d behavioral latents drive N neurons through a linear encoding map F
        behavior = rng.normal(size=(n_time, d_behaviors))
        F = rng.normal(size=(d_behaviors, n_neurons))
        activity = behavior @ F  # (time x neurons), generated from d latents
        sv = np.linalg.svd(activity, compute_uv=False)
        tol = sv.max() * max(activity.shape) * 1e-12
        numerical_rank = int((sv > tol).sum())
        print(f"  ambient neuron count N = {n_neurons}")
        print(f"  behavioral DOF        d = {d_behaviors}")
        print(f"  numerical rank of activity = {numerical_rank}  (<= d)")
        print(f"  top singular values: {np.round(sv[:d_behaviors+2], 3)}")
        assert numerical_rank <= d_behaviors
        print("  => activity of 200 neurons lives on a d-dimensional manifold.\n")
    except ImportError:
        print("  (NumPy not available; skipping the SVD demonstration.)\n")


def main() -> None:
    demo_capacity()
    demo_dense_energy()
    demo_sparse()
    k_star, rho_star = optimal_sparsity(1000)
    print(f"  Optimal sparsity for N=1000: k* = {k_star}, "
          f"rho* = {rho_star:.3f} bits/spike (one-hot regime).\n")
    demo_population()
    demo_manifold()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
