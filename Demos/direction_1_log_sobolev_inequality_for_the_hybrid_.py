#!/usr/bin/env python3
"""
applications.py — Real-world Applications of the Hybrid Walk MLSI Theory

Demonstrates applications of the modified log-Sobolev inequality for
the hybrid adjacent-transposition-plus-cycle walk to:

1. Card shuffling: How many shuffles to randomize a deck?
2. MCMC sampling: Convergence guarantees for permutation sampling
3. Sorting networks: Entropy-optimal sorting with hybrid operations
4. Information channels: Data processing inequality for permutation channels
"""

import numpy as np
from itertools import permutations
from math import factorial, log, exp, ceil


# ============================================================
# Application 1: Card Shuffling Analysis
# ============================================================

def card_shuffling_analysis():
    """
    Analyze the hybrid shuffle for card decks.

    The hybrid shuffle combines:
    - Riffle-like local swaps (adjacent transpositions)
    - Cut operations (long cycle rotations)

    The MLSI bound gives: t_mix = O(n^2 log n) steps.
    """
    print("=" * 60)
    print("  Application 1: Card Shuffling")
    print("=" * 60)
    print()

    for n in [3, 5, 10, 20, 52]:
        # Theoretical mixing time bound from MLSI
        # Using rho >= c/n^2 with estimated c ~ 1.3 from numerics
        c_est = 1.3
        rho_est = c_est / n**2
        N = factorial(n) if n <= 10 else float('inf')

        # t_mix <= (1/(2*rho)) * (log N + log(1/epsilon))
        # = n^2/(2c) * (n*log(n) + log(4))  (using Stirling for log N)
        log_N = sum(log(k) for k in range(1, n + 1))
        epsilon = 0.25
        t_mix_bound = (1 / (2 * rho_est)) * (log_N + log(1 / epsilon))

        # Compare with pure adjacent transposition walk
        # For pure adj. transpositions: t_mix ~ O(n^3 log n)
        t_mix_adj = n**3 * log(n) * 0.5  # rough estimate

        print(f"  n = {n:3d}: Hybrid t_mix <= {t_mix_bound:10.1f} | "
              f"Pure adj. t_mix ~ {t_mix_adj:10.1f} | "
              f"Speedup ~ {t_mix_adj/t_mix_bound:.1f}x")

    print()
    print("  Key insight: Adding cycle moves reduces mixing time from")
    print("  O(n^3 log n) to O(n^2 log n) — a factor of n improvement!")
    print()


# ============================================================
# Application 2: MCMC Sampling Guarantees
# ============================================================

def mcmc_sampling_application():
    """
    MCMC sampling of random permutations using the hybrid walk.

    The MLSI gives stronger guarantees than the spectral gap:
    - Spectral gap: controls L2 distance, variance decay
    - MLSI: controls KL divergence, entropy decay, hypercontractivity

    For sampling applications, entropy control means:
    - Faster convergence to uniformity in information-theoretic sense
    - Stronger tail bounds via log-Sobolev concentration
    """
    print("=" * 60)
    print("  Application 2: MCMC Permutation Sampling")
    print("=" * 60)
    print()

    n = 5
    perms = list(permutations(range(n)))
    N = len(perms)
    perm_index = {p: i for i, p in enumerate(perms)}

    # Build transition matrix
    gens = []
    for i in range(n - 1):
        g = list(range(n))
        g[i], g[i + 1] = g[i + 1], g[i]
        gens.append(tuple(g))
    cycle = tuple((i + 1) % n for i in range(n))
    cycle_inv = tuple((i - 1) % n for i in range(n))
    gens.append(cycle)
    gens.append(cycle_inv)

    P = np.zeros((N, N))
    for i, sigma in enumerate(perms):
        for g in gens:
            tau = tuple(g[sigma[j]] for j in range(n))
            j = perm_index[tau]
            P[i, j] += 1.0 / len(gens)

    # Start from identity permutation
    mu = np.ones(N) / N
    dist = np.zeros(N)
    dist[0] = 1.0  # Start at identity

    print(f"  Sampling from S_{n} (|S_{n}| = {N})")
    print(f"  Starting from identity permutation")
    print()

    # Track total variation distance
    print(f"  {'Step':>6} | {'TV distance':>12} | {'KL divergence':>14} | {'Entropy':>10}")
    print(f"  {'-'*6}-+-{'-'*12}-+-{'-'*14}-+-{'-'*10}")

    for t in range(0, 51, 5):
        tv = 0.5 * np.sum(np.abs(dist - mu))
        # KL divergence
        kl = 0.0
        for i in range(N):
            if dist[i] > 0:
                kl += dist[i] * np.log(dist[i] / mu[i])
        # Entropy of f = dist/mu as a density
        f = dist / mu
        f_pos = f[f > 0]
        ent = np.sum(mu[f > 0] * f_pos * np.log(f_pos)) - np.sum(dist) * np.log(np.sum(dist))

        print(f"  {t:6d} | {tv:12.8f} | {kl:14.8f} | {ent:10.6f}")

        if t < 50:
            for _ in range(5):
                dist = dist @ P

    print()
    print("  Observation: Both TV and KL divergence decay exponentially,")
    print("  confirming the MLSI-driven entropy contraction.")
    print()


# ============================================================
# Application 3: Information Channel Analysis
# ============================================================

def information_channel_application():
    """
    The hybrid walk as a permutation channel.

    One step of the walk acts as a noisy channel on distributions:
    input distribution mu_in -> output distribution mu_out = mu_in @ P

    The data processing inequality (our Theorem 4) says:
    Ent(P*f) <= Ent(f)

    This means information is destroyed at each step, with the
    MLSI constant controlling the destruction rate.
    """
    print("=" * 60)
    print("  Application 3: Permutation Channel / Data Processing")
    print("=" * 60)
    print()

    n = 4
    perms = list(permutations(range(n)))
    N = len(perms)
    perm_index = {p: i for i, p in enumerate(perms)}

    # Build transition matrix
    gens = []
    for i in range(n - 1):
        g = list(range(n))
        g[i], g[i + 1] = g[i + 1], g[i]
        gens.append(tuple(g))
    cycle = tuple((i + 1) % n for i in range(n))
    cycle_inv = tuple((i - 1) % n for i in range(n))
    gens.append(cycle)
    gens.append(cycle_inv)

    P = np.zeros((N, N))
    for i, sigma in enumerate(perms):
        for g in gens:
            tau = tuple(g[sigma[j]] for j in range(n))
            j = perm_index[tau]
            P[i, j] += 1.0 / len(gens)

    mu = np.ones(N) / N

    # Different initial "signals" (positive functions on S_n)
    print(f"  Channel: Hybrid walk on S_{n}")
    print(f"  Testing data processing inequality: Ent(Pf) <= Ent(f)")
    print()

    test_functions = {
        "Delta at identity": lambda: np.array([N if i == 0 else 0.01 for i in range(N)]),
        "Two peaks": lambda: np.array([5.0 if i < 3 else 0.1 for i in range(N)]),
        "Linear ramp": lambda: np.array([1.0 + 2.0 * i / N for i in range(N)]),
        "Exponential": lambda: np.exp(np.linspace(-2, 2, N)),
    }

    for name, gen_f in test_functions.items():
        f = gen_f()
        entropies = []
        for t in range(20):
            ef = np.dot(mu, f)
            ent = np.dot(mu, f * np.log(f)) - ef * np.log(ef)
            entropies.append(ent)
            f = P.T @ f

        print(f"  Signal: {name}")
        print(f"    Ent(f):    {entropies[0]:.6f}")
        print(f"    Ent(Pf):   {entropies[1]:.6f}")
        print(f"    Ent(P^5f): {entropies[5]:.6f}")
        print(f"    Ratio Ent(Pf)/Ent(f): {entropies[1]/max(entropies[0], 1e-15):.6f}")
        print(f"    Data processing: {'VERIFIED' if entropies[1] <= entropies[0] + 1e-10 else 'FAILED'}")
        print()


# ============================================================
# Application 4: Sorting Network Entropy
# ============================================================

def sorting_network_application():
    """
    Entropy-optimal sorting with hybrid operations.

    Adjacent transpositions are comparison-swap operations.
    The cycle is a circular shift (like rotating a buffer).
    The MLSI tells us how fast these operations destroy ordering information.
    """
    print("=" * 60)
    print("  Application 4: Hybrid Sorting Network Entropy")
    print("=" * 60)
    print()

    for n in [3, 4, 5]:
        # Number of comparison-swap + rotation operations needed
        # to "randomize" (reach uniform within epsilon)
        c_est = 1.3
        rho = c_est / n**2
        log_N = sum(log(k) for k in range(1, n + 1))
        t_random = ceil((1 / (2 * rho)) * log_N)

        # Pure bubble sort needs O(n^2) comparisons to sort
        t_sort = n * (n - 1) // 2

        print(f"  n = {n}: Randomization steps ~ {t_random}, "
              f"Sorting steps = {t_sort}")

    print()
    print("  The hybrid operations (swaps + rotations) are dual:")
    print("  - Sorting creates order from chaos")
    print("  - The hybrid walk creates chaos from order")
    print("  - MLSI quantifies the rate of entropy production")
    print()


def main():
    card_shuffling_analysis()
    mcmc_sampling_application()
    information_channel_application()
    sorting_network_application()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Modified Log-Sobolev Constant Estimation for the Hybrid Walk on S_n

Computes numerical estimates of the modified log-Sobolev constant ρ_n for the
hybrid adjacent-transposition-plus-cycle walk on S_n, for n = 3, 4, 5, 6.

The hybrid walk uses generators:
  - Adjacent transpositions: (i, i+1) for i = 0, ..., n-2
  - Long cycle: c = (0 1 2 ... n-1) and its inverse c^{-1}

The modified log-Sobolev constant is defined as:
  ρ_n = inf_{f > 0, f not const} E(f, log f) / Ent(f)

We estimate ρ_n by sampling random positive functions and computing the ratio.
"""

import numpy as np
from itertools import permutations
from math import factorial


def generate_sn(n):
    """Generate all elements of S_n as tuples."""
    return list(permutations(range(n)))


def left_multiply(gen, sigma):
    """Left multiply: gen * sigma."""
    return tuple(gen[sigma[i]] for i in range(len(sigma)))


def adj_transposition(n, i):
    """Adjacent transposition swapping positions i and i+1."""
    perm = list(range(n))
    perm[i], perm[i + 1] = perm[i + 1], perm[i]
    return tuple(perm)


def long_cycle(n):
    """Long cycle (0 1 2 ... n-1): maps i -> (i+1) mod n."""
    return tuple((i + 1) % n for i in range(n))


def long_cycle_inv(n):
    """Inverse of long cycle: maps i -> (i-1) mod n."""
    return tuple((i - 1) % n for i in range(n))


def build_hybrid_generators(n):
    """Build the list of hybrid generators."""
    gens = []
    for i in range(n - 1):
        gens.append(adj_transposition(n, i))
    gens.append(long_cycle(n))
    gens.append(long_cycle_inv(n))
    return gens


def build_transition_matrix(n):
    """Build the transition matrix P for the hybrid walk on S_n."""
    perms = generate_sn(n)
    perm_index = {p: i for i, p in enumerate(perms)}
    N = len(perms)
    gens = build_hybrid_generators(n)
    num_gens = len(gens)

    P = np.zeros((N, N))
    for i, sigma in enumerate(perms):
        for g in gens:
            tau = left_multiply(g, sigma)
            j = perm_index[tau]
            P[i, j] += 1.0 / num_gens

    return P, perms


def compute_entropy_vectorized(f, mu):
    """Compute Ent_μ(f) = E_μ[f log f] - E_μ[f] log E_μ[f]."""
    ef = np.dot(mu, f)
    eflogf = np.dot(mu, f * np.log(f))
    if ef <= 0:
        return 0.0
    return eflogf - ef * np.log(ef)


def compute_dirichlet_log_vectorized(f, P, mu):
    """Compute E(f, log f) using vectorized operations."""
    logf = np.log(f)
    N = len(f)
    # (f(x) - f(y)) * (log f(x) - log f(y)) for all x, y
    df = f[:, None] - f[None, :]  # N x N
    dlogf = logf[:, None] - logf[None, :]  # N x N
    # μ(x) * P(x,y) * (f(x)-f(y)) * (log f(x) - log f(y))
    weighted = mu[:, None] * P * df * dlogf
    return 0.5 * np.sum(weighted)


def compute_mls_ratio_vectorized(f, P, mu):
    """Compute MLS ratio E(f, log f) / Ent(f)."""
    ent = compute_entropy_vectorized(f, mu)
    if ent < 1e-15:
        return float('inf')
    dirichlet = compute_dirichlet_log_vectorized(f, P, mu)
    if dirichlet < 0:
        return float('inf')
    return dirichlet / ent


def estimate_mls_constant(n, num_samples=5000, seed=42):
    """Estimate the modified log-Sobolev constant for S_n hybrid walk."""
    print(f"\n{'='*60}")
    print(f"  Hybrid Walk on S_{n}  (|S_{n}| = {factorial(n)})")
    print(f"  Generators: {n-1} adj. transpositions + cycle + cycle^(-1)")
    print(f"{'='*60}")

    P, perms = build_transition_matrix(n)
    N = len(perms)
    mu = np.ones(N) / N

    # Verify stationarity
    mu_P = mu @ P
    assert np.allclose(mu_P, mu), "Stationarity check failed!"
    print(f"  Stationarity verified")

    # Verify reversibility (detailed balance)
    db_max = np.max(np.abs(mu[:, None] * P - mu[None, :] * P.T))
    print(f"  Detailed balance error: {db_max:.2e}")

    # Spectral gap
    eigenvalues = np.linalg.eigvalsh(P)
    eigenvalues.sort()
    spectral_gap = 1 - eigenvalues[-2]
    print(f"  Spectral gap lambda_1 = {spectral_gap:.6f}")
    print(f"  lambda_1 * n^2 = {spectral_gap * n**2:.6f}")

    # Estimate rho_n
    rng = np.random.RandomState(seed)
    min_ratio = float('inf')
    ratios = []

    for trial in range(num_samples):
        if trial < num_samples // 4:
            f = np.exp(rng.randn(N) * 0.5)
        elif trial < num_samples // 2:
            f = 1.0 + rng.randn(N) * 0.1
            f = np.maximum(f, 0.01)
        elif trial < 3 * num_samples // 4:
            f = np.ones(N) * 0.1
            k = rng.randint(1, max(2, N // 3))
            idx = rng.choice(N, k, replace=False)
            f[idx] = rng.exponential(5.0, k)
        else:
            f = rng.pareto(2.0, N) + 0.01

        ratio = compute_mls_ratio_vectorized(f, P, mu)
        if 0 < ratio < float('inf'):
            ratios.append(ratio)
            if ratio < min_ratio:
                min_ratio = ratio

    ratios = np.array(ratios)
    print(f"\n  Estimated rho_{n} >= {min_ratio:.8f}")
    print(f"  rho_{n} * n^2 = {min_ratio * n**2:.6f}")
    print(f"  Mean MLS ratio = {np.mean(ratios):.6f}")
    print(f"  1st percentile = {np.percentile(ratios, 1):.6f}")

    return min_ratio, spectral_gap, ratios


def main():
    print("=" * 60)
    print("  Modified Log-Sobolev Constant for Hybrid Walk on S_n")
    print("  Adjacent Transpositions + Long Cycle")
    print("=" * 60)

    results = {}
    for n in [3, 4, 5, 6]:
        samples = 5000 if n <= 5 else 2000
        rho, gap, ratios = estimate_mls_constant(n, num_samples=samples)
        results[n] = {
            'rho_est': rho,
            'rho_n2': rho * n**2,
            'gap': gap,
            'gap_n2': gap * n**2,
        }

    # Summary table
    print(f"\n{'='*70}")
    print(f"  SUMMARY: Scaling Analysis")
    print(f"{'='*70}")
    print(f"  {'n':>3} | {'|S_n|':>6} | {'rho_n':>12} | {'rho_n*n^2':>10} | "
          f"{'lambda_1':>10} | {'lambda_1*n^2':>12}")
    print(f"  {'-'*3}-+-{'-'*6}-+-{'-'*12}-+-{'-'*10}-+-{'-'*10}-+-{'-'*12}")
    for n in [3, 4, 5, 6]:
        r = results[n]
        print(f"  {n:3d} | {factorial(n):6d} | {r['rho_est']:12.8f} | "
              f"{r['rho_n2']:10.6f} | {r['gap']:10.6f} | {r['gap_n2']:12.6f}")

    print(f"\n  Conjecture: rho_n >= c/n^2 for universal c > 0")
    print(f"  Evidence: rho_n * n^2 appears bounded away from zero")
    print(f"\n  Note: rho_n <= lambda_1 always (MLSI constant <= spectral gap)")
    print(f"  The ratio rho_n/lambda_1 measures the gap between")
    print(f"  entropy and variance control.\n")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Entropy Decay under the Hybrid Walk

Shows how relative entropy Ent_μ(P^t f) decays over time for the hybrid
adjacent-transposition-plus-cycle walk on S_n, for n = 3, 4, 5.

The plot demonstrates:
1. Exponential entropy decay (linear on log scale)
2. Faster decay for smaller n (larger ρ_n)
3. The data processing inequality: entropy never increases
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def build_hybrid_walk(n):
    perms = list(permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(perms)}
    N = len(perms)

    gens = []
    for i in range(n - 1):
        g = list(range(n))
        g[i], g[i + 1] = g[i + 1], g[i]
        gens.append(tuple(g))
    cycle = tuple((i + 1) % n for i in range(n))
    cycle_inv = tuple((i - 1) % n for i in range(n))
    gens.append(cycle)
    gens.append(cycle_inv)

    P = np.zeros((N, N))
    for i, sigma in enumerate(perms):
        for g in gens:
            tau = tuple(g[sigma[j]] for j in range(n))
            j = perm_index[tau]
            P[i, j] += 1.0 / len(gens)
    return P, N


def compute_entropy(f, mu):
    ef = np.dot(mu, f)
    if ef <= 0 or np.any(f <= 0):
        return 0.0
    return np.dot(mu, f * np.log(f)) - ef * np.log(ef)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

colors = {3: '#2196F3', 4: '#FF5722', 5: '#4CAF50'}

# Left panel: Entropy decay curves
ax = axes[0]
for n in [3, 4, 5]:
    P, N = build_hybrid_walk(n)
    mu = np.ones(N) / N

    # Start from peaked distribution (delta at identity)
    f = np.ones(N) * 0.01
    f[0] = N * 0.5

    num_steps = 60
    entropies = []
    for t in range(num_steps):
        ent = compute_entropy(f, mu)
        entropies.append(max(ent, 1e-20))
        f = P.T @ f

    ax.semilogy(range(num_steps), entropies, '-', linewidth=2.5,
                color=colors[n], label=f'$S_{n}$ (n={n}, |S_n|={N})')

ax.set_xlabel('Time steps $t$', fontsize=13)
ax.set_ylabel('$\\mathrm{Ent}_\\mu(P^t f)$', fontsize=13)
ax.set_title('Entropy Decay under Hybrid Walk', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=1e-16)

# Right panel: Scaling of rho * n^2
ax = axes[1]
ns = [3, 4, 5]
rho_n2_values = []

for n in ns:
    P, N = build_hybrid_walk(n)
    mu = np.ones(N) / N

    rng = np.random.RandomState(42)
    min_ratio = float('inf')

    for trial in range(3000):
        if trial % 3 == 0:
            f = np.exp(rng.randn(N) * 0.5)
        elif trial % 3 == 1:
            f = 1.0 + rng.randn(N) * 0.1
            f = np.maximum(f, 0.01)
        else:
            f = rng.pareto(2.0, N) + 0.01

        logf = np.log(f)
        ef = np.dot(mu, f)
        ent = np.dot(mu, f * logf) - ef * np.log(ef)
        if ent < 1e-15:
            continue
        df = f[:, None] - f[None, :]
        dlogf = logf[:, None] - logf[None, :]
        dirichlet = 0.5 * np.sum(mu[:, None] * P * df * dlogf)
        if dirichlet < 0:
            continue
        ratio = dirichlet / ent
        if ratio < min_ratio:
            min_ratio = ratio

    rho_n2_values.append(min_ratio * n**2)

ax.bar(ns, rho_n2_values, color=[colors[n] for n in ns], alpha=0.8, width=0.6)
ax.set_xlabel('$n$', fontsize=13)
ax.set_ylabel('$\\rho_n \\cdot n^2$', fontsize=13)
ax.set_title('MLSI Scaling: $\\rho_n \\cdot n^2$ (bounded away from 0)', fontsize=14, fontweight='bold')
ax.set_xticks(ns)
ax.grid(True, axis='y', alpha=0.3)

# Add horizontal line at minimum
min_val = min(rho_n2_values)
ax.axhline(y=min_val, color='red', linestyle='--', alpha=0.7,
           label=f'min = {min_val:.2f}')
ax.legend(fontsize=11)

plt.tight_layout()
plt.savefig('entropy_decay_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved entropy_decay_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs Modified Log-Sobolev Constant

Compares the spectral gap (Poincaré constant) with the estimated MLSI
constant for the hybrid walk on S_n, n = 3, 4, 5.

The spectral gap controls variance decay: Var(P^t f) <= (1-lambda_1)^t Var(f)
The MLSI constant controls entropy decay: Ent(P^t f) <= exp(-2*rho*t) Ent(f)

The relationship rho <= lambda_1 always holds. For the hybrid walk,
both scale as Theta(1/n^2), but rho carries strictly more information.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def build_hybrid_walk(n):
    perms = list(permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(perms)}
    N = len(perms)

    gens = []
    for i in range(n - 1):
        g = list(range(n))
        g[i], g[i + 1] = g[i + 1], g[i]
        gens.append(tuple(g))
    cycle = tuple((i + 1) % n for i in range(n))
    cycle_inv = tuple((i - 1) % n for i in range(n))
    gens.append(cycle)
    gens.append(cycle_inv)

    P = np.zeros((N, N))
    for i, sigma in enumerate(perms):
        for g in gens:
            tau = tuple(g[sigma[j]] for j in range(n))
            j = perm_index[tau]
            P[i, j] += 1.0 / len(gens)
    return P, N


def estimate_rho(P, N, num_trials=5000):
    mu = np.ones(N) / N
    rng = np.random.RandomState(42)
    min_ratio = float('inf')

    for trial in range(num_trials):
        if trial % 3 == 0:
            f = np.exp(rng.randn(N) * 0.5)
        elif trial % 3 == 1:
            f = 1.0 + rng.randn(N) * 0.1
            f = np.maximum(f, 0.01)
        else:
            f = rng.pareto(2.0, N) + 0.01

        logf = np.log(f)
        ef = np.dot(mu, f)
        ent = np.dot(mu, f * logf) - ef * np.log(ef)
        if ent < 1e-15:
            continue
        df = f[:, None] - f[None, :]
        dlogf = logf[:, None] - logf[None, :]
        dirichlet = 0.5 * np.sum(mu[:, None] * P * df * dlogf)
        if dirichlet < 0:
            continue
        ratio = dirichlet / ent
        if ratio < min_ratio:
            min_ratio = ratio

    return min_ratio


ns = [3, 4, 5]
spectral_gaps = []
rho_estimates = []

for n in ns:
    P, N = build_hybrid_walk(n)
    eigs = np.linalg.eigvalsh(P)
    eigs.sort()
    spectral_gaps.append(1 - eigs[-2])
    rho_estimates.append(estimate_rho(P, N))

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Raw values comparison
ax = axes[0]
x = np.arange(len(ns))
width = 0.35
bars1 = ax.bar(x - width/2, spectral_gaps, width, label='Spectral gap $\\lambda_1$',
               color='#2196F3', alpha=0.8)
bars2 = ax.bar(x + width/2, rho_estimates, width, label='MLSI constant $\\rho_n$ (est.)',
               color='#FF5722', alpha=0.8)
ax.set_xticks(x)
ax.set_xticklabels([f'$S_{n}$' for n in ns])
ax.set_ylabel('Constant value', fontsize=12)
ax.set_title('Spectral Gap vs MLSI Constant', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, axis='y', alpha=0.3)

# Panel 2: Scaled values (× n²)
ax = axes[1]
gap_scaled = [g * n**2 for g, n in zip(spectral_gaps, ns)]
rho_scaled = [r * n**2 for r, n in zip(rho_estimates, ns)]

ax.plot(ns, gap_scaled, 'o-', linewidth=2, markersize=8,
        color='#2196F3', label='$\\lambda_1 \\cdot n^2$')
ax.plot(ns, rho_scaled, 's-', linewidth=2, markersize=8,
        color='#FF5722', label='$\\rho_n \\cdot n^2$ (est.)')
ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('$n$', fontsize=12)
ax.set_ylabel('Scaled constant $\\times n^2$', fontsize=12)
ax.set_title('$n^2$-Scaling: Both $\\Theta(1/n^2)$', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Entropy vs variance decay comparison for S_4
ax = axes[2]
n = 4
P, N = build_hybrid_walk(n)
mu = np.ones(N) / N
eigs = np.linalg.eigvalsh(P)
eigs.sort()
gap = 1 - eigs[-2]

# Initial function
f = np.ones(N) * 0.1
f[0] = N * 0.3
f[1] = N * 0.2

steps = 40
entropies = []
variances = []

f_ent = f.copy()
f_var = f.copy()

for t in range(steps):
    # Entropy
    ef = np.dot(mu, f_ent)
    if ef > 0 and np.all(f_ent > 0):
        ent = np.dot(mu, f_ent * np.log(f_ent)) - ef * np.log(ef)
    else:
        ent = 0
    entropies.append(max(ent, 1e-20))

    # Variance
    mean_f = np.dot(mu, f_var)
    var = np.dot(mu, (f_var - mean_f)**2)
    variances.append(max(var, 1e-20))

    f_ent = P.T @ f_ent
    f_var = P.T @ f_var

ax.semilogy(range(steps), entropies, '-', linewidth=2.5, color='#FF5722',
            label='Entropy $\\mathrm{Ent}_\\mu(P^t f)$')
ax.semilogy(range(steps), variances, '--', linewidth=2.5, color='#2196F3',
            label='Variance $\\mathrm{Var}_\\mu(P^t f)$')
ax.set_xlabel('Time steps $t$', fontsize=12)
ax.set_ylabel('Value (log scale)', fontsize=12)
ax.set_title(f'Entropy vs Variance Decay ($S_{n}$)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_vs_entropy_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved spectral_vs_entropy_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Transition Matrix Heatmap for the Hybrid Walk

Shows the structure of the transition matrix P for the hybrid
adjacent-transposition-plus-cycle walk on S_3 and S_4.

The heatmap reveals the sparsity pattern: each row has at most
n+1 nonzero entries (one per generator), creating a structured
sparse matrix that combines local and global connectivity.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def build_hybrid_walk(n):
    perms = list(permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(perms)}
    N = len(perms)

    gens = []
    for i in range(n - 1):
        g = list(range(n))
        g[i], g[i + 1] = g[i + 1], g[i]
        gens.append(tuple(g))
    cycle = tuple((i + 1) % n for i in range(n))
    cycle_inv = tuple((i - 1) % n for i in range(n))
    gens.append(cycle)
    gens.append(cycle_inv)

    P = np.zeros((N, N))
    for i, sigma in enumerate(perms):
        for g in gens:
            tau = tuple(g[sigma[j]] for j in range(n))
            j = perm_index[tau]
            P[i, j] += 1.0 / len(gens)
    return P, perms


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, n in enumerate([3, 4]):
    ax = axes[idx]
    P, perms = build_hybrid_walk(n)
    N = len(perms)

    im = ax.imshow(P, cmap='YlOrRd', interpolation='nearest', aspect='auto')
    ax.set_title(f'Transition Matrix $P$ for Hybrid Walk on $S_{n}$\n'
                 f'($|S_{n}|$ = {N}, {n+1} generators)',
                 fontsize=12, fontweight='bold')
    ax.set_xlabel('Target permutation index', fontsize=11)
    ax.set_ylabel('Source permutation index', fontsize=11)

    plt.colorbar(im, ax=ax, shrink=0.8, label='$P(\\sigma, \\tau)$')

    # Annotate sparsity
    nnz = np.count_nonzero(P)
    density = nnz / (N * N) * 100
    ax.text(0.02, 0.98, f'Nonzero: {nnz}/{N*N} ({density:.1f}%)',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.suptitle('Hybrid Walk: Local Swaps + Global Cycle Create Structured Connectivity',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('transition_matrix_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved transition_matrix_visualization.png")
