#!/usr/bin/env python3
"""
Applications of Character Sum Bounds for Random Cayley Graphs

This module demonstrates real-world applications of the moment method
and excess moment theory:

1. Spectral gap estimation for random Cayley graphs
2. Mixing time bounds via moment decay
3. Expansion testing: distinguishing expander vs non-expander generators
4. Return probability prediction for random walks on groups
"""

import itertools
import math
import random
from fractions import Fraction
from typing import Tuple, List, Dict


# ============================================================
# Core permutation and moment functions (self-contained)
# ============================================================

Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p: Perm) -> Perm:
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n: int) -> Perm:
    return tuple(range(n))

def all_permutations(n: int) -> List[Perm]:
    return [tuple(p) for p in itertools.permutations(range(n))]

def eval_word(sigma: Perm, tau: Perm, word: Tuple[int, ...]) -> Perm:
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    result = identity(n)
    for letter in word:
        result = compose(gens[letter], result)
    return result

def closed_word_count_dp(sigma: Perm, tau: Perm, m: int) -> int:
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    e = identity(n)
    dist = {e: 1}
    for _ in range(m):
        new_dist: Dict[Perm, int] = {}
        for g, cnt in dist.items():
            for gen in gens:
                h = compose(gen, g)
                new_dist[h] = new_dist.get(h, 0) + cnt
        dist = new_dist
    return dist.get(e, 0)

def moment_kernel(sigma: Perm, tau: Perm, m: int) -> Fraction:
    return Fraction(closed_word_count_dp(sigma, tau, m), 4**m)

def excess_moment(sigma: Perm, tau: Perm, m: int) -> Fraction:
    baseline = Fraction(1) if m == 0 else Fraction(0)
    return moment_kernel(sigma, tau, m) - baseline


# ============================================================
# Application 1: Spectral gap estimation
# ============================================================

def estimate_spectral_gap(sigma: Perm, tau: Perm, max_m: int = 8) -> float:
    """
    Estimate the spectral gap of Cay(G, {σ, σ⁻¹, τ, τ⁻¹}) using
    the moment method.

    The spectral gap λ₁ satisfies:
        momentKernel(σ, τ, 2k) ≈ (1/|G|) + (1 - λ₁)^{2k} * dim(std)/(|G|·4^{2k})

    For a good expander, the moment kernel decays quickly to 1/|G|,
    indicating a large spectral gap.
    """
    n = len(sigma)
    card_G = math.factorial(n)
    uniform = Fraction(1, card_G)

    print(f"  Spectral gap estimation for generators in S_{n}:")
    print(f"  {'m':>4} | {'μ^(m)(e)':>15} | {'excess':>15} | {'ratio':>15}")
    print(f"  " + "-" * 60)

    prev_excess = None
    for m in range(2, max_m + 1, 2):
        mk = moment_kernel(sigma, tau, m)
        exc = mk - uniform
        ratio_str = ""
        if prev_excess and prev_excess > 0 and exc > 0:
            ratio = float(exc / prev_excess)
            ratio_str = f"{ratio:.6f}"
        print(f"  {m:>4} | {float(mk):>15.8f} | {float(exc):>15.8f} | {ratio_str:>15}")
        prev_excess = exc

    # Rough spectral gap estimate from ratio of consecutive even moments
    if prev_excess and prev_excess > 0:
        mk_last = moment_kernel(sigma, tau, max_m)
        mk_prev = moment_kernel(sigma, tau, max_m - 2)
        exc_last = mk_last - uniform
        exc_prev = mk_prev - uniform
        if exc_prev > 0 and exc_last > 0:
            ratio = float(exc_last / exc_prev)
            gap_estimate = 1 - math.sqrt(ratio)
            return gap_estimate
    return 0.0


# ============================================================
# Application 2: Mixing time bound
# ============================================================

def mixing_time_bound(sigma: Perm, tau: Perm, epsilon: float = 0.01) -> int:
    """
    Estimate mixing time using moment decay.

    The mixing time t_mix(ε) is the smallest t such that the random walk
    distribution is within total variation distance ε of uniform.

    Bound: t_mix(ε) ≤ t such that momentKernel(σ, τ, 2t) ≤ 1/|G| + ε/|G|.
    """
    n = len(sigma)
    card_G = math.factorial(n)
    threshold = Fraction(1, card_G) + Fraction.from_float(epsilon) / card_G

    for t in range(1, 100):
        mk = moment_kernel(sigma, tau, 2 * t)
        if mk <= threshold:
            return 2 * t
    return -1  # Did not converge


# ============================================================
# Application 3: Expansion testing
# ============================================================

def expansion_score(sigma: Perm, tau: Perm) -> float:
    """
    Score how 'expander-like' a pair of generators is.

    Uses the excess moment at length 4 as a proxy: smaller excess
    means the generators behave more like free-group generators
    (better expansion).

    Score ∈ [0, 1], where 0 = perfect expander (free-group behavior),
    1 = worst case (trivial generators).
    """
    return float(excess_moment(sigma, tau, 4))


def find_best_generators(n: int, num_samples: int = 100) -> Tuple[Perm, Perm, float]:
    """
    Find generators of S_n that produce the best expander
    (lowest expansion score).
    """
    perms = all_permutations(n)
    best_score = float('inf')
    best_pair = (identity(n), identity(n))

    for _ in range(num_samples):
        sigma = random.choice(perms)
        tau = random.choice(perms)
        score = expansion_score(sigma, tau)
        if score < best_score:
            best_score = score
            best_pair = (sigma, tau)

    return best_pair[0], best_pair[1], best_score


# ============================================================
# Application 4: Return probability prediction
# ============================================================

def return_probability_profile(sigma: Perm, tau: Perm, max_steps: int = 10) -> List[float]:
    """
    Compute the return probability profile: P(X_m = e) for m = 0, 1, ..., max_steps.

    This is directly the moment kernel and represents the probability
    that a random walk of length m returns to its starting point.
    """
    return [float(moment_kernel(sigma, tau, m)) for m in range(max_steps + 1)]


# ============================================================
# Main demonstration
# ============================================================

def main():
    print("=" * 70)
    print("Applications of Character Sum Bounds for Random Cayley Graphs")
    print("=" * 70)

    # Application 1: Spectral gap estimation
    print("\n--- Application 1: Spectral Gap Estimation ---\n")
    n = 5
    perms = all_permutations(n)
    # Use a transposition and a long cycle
    sigma = tuple((i + 1) % n for i in range(n))  # (0 1 2 3 4)
    tau = (1, 0) + tuple(range(2, n))               # (0 1)
    gap = estimate_spectral_gap(sigma, tau)
    print(f"\n  Estimated spectral gap: {gap:.4f}")

    # Application 2: Expansion testing
    print("\n--- Application 2: Expansion Testing ---\n")
    n = 4
    sigma_best, tau_best, score_best = find_best_generators(n, num_samples=50)
    print(f"  Best generators in S_{n}: σ = {sigma_best}, τ = {tau_best}")
    print(f"  Expansion score: {score_best:.6f} (lower is better)")

    sigma_worst = identity(n)
    tau_worst = identity(n)
    score_worst = expansion_score(sigma_worst, tau_worst)
    print(f"\n  Worst case (identity): score = {score_worst:.6f}")

    # Application 3: Return probability profile
    print("\n--- Application 3: Return Probability Profile ---\n")
    n = 4
    sigma = tuple((i + 1) % n for i in range(n))  # (0 1 2 3)
    tau = (1, 0) + tuple(range(2, n))               # (0 1)
    profile = return_probability_profile(sigma, tau, max_steps=8)
    print(f"  Generators: σ = {sigma}, τ = {tau}")
    for m, p in enumerate(profile):
        print(f"    P(X_{m} = e) = {p:.6f}")

    # Application 4: Mixing time estimation
    print("\n--- Application 4: Mixing Time Bound ---\n")
    t_mix = mixing_time_bound(sigma, tau, epsilon=0.1)
    if t_mix > 0:
        print(f"  Mixing time bound (ε=0.1): t_mix ≤ {t_mix}")
    else:
        print(f"  Mixing time bound: did not converge within 200 steps")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Average Excess Moment for Random Cayley Graphs on S_n

Computes the average excess moment A_{n,k} = avgExcessMoment(n, 2k)
for symmetric groups S_n, n = 3..8, and small k values.

The excess moment measures how far the return probability of a random
walk on Cay(S_n, {σ, σ⁻¹, τ, τ⁻¹}) deviates from the free-group baseline.

Key prediction: A_{n,k} ~ C_k / n for large n.
"""

import itertools
import math
from fractions import Fraction
from collections import defaultdict


def compose_perms(p, q, n):
    """Compose permutations p ∘ q on {0, ..., n-1}."""
    return tuple(p[q[i]] for i in range(n))


def inverse_perm(p, n):
    """Inverse of permutation p."""
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)


def identity_perm(n):
    """Identity permutation on {0, ..., n-1}."""
    return tuple(range(n))


def all_perms(n):
    """All permutations of {0, ..., n-1}."""
    return [tuple(p) for p in itertools.permutations(range(n))]


def eval_word(sigma, tau, word, n):
    """Evaluate a word over {0: σ, 1: σ⁻¹, 2: τ, 3: τ⁻¹} in S_n."""
    sigma_inv = inverse_perm(sigma, n)
    tau_inv = inverse_perm(tau, n)
    generators = [sigma, sigma_inv, tau, tau_inv]
    result = identity_perm(n)
    for letter in word:
        result = compose_perms(generators[letter], result, n)
    return result


def closed_word_count(sigma, tau, m, n):
    """Count words of length m over the 4-letter alphabet evaluating to identity."""
    e = identity_perm(n)
    count = 0
    for word in itertools.product(range(4), repeat=m):
        if eval_word(sigma, tau, word, n) == e:
            count += 1
    return count


def moment_kernel(sigma, tau, m, n):
    """The moment kernel: closed word count / 4^m."""
    return Fraction(closed_word_count(sigma, tau, m, n), 4**m)


def free_group_return_moment(m):
    """Free-group return moment (simplified: 1 at m=0, 0 otherwise)."""
    return Fraction(1) if m == 0 else Fraction(0)


def excess_moment(sigma, tau, m, n):
    """Excess moment: moment kernel minus free-group baseline."""
    return moment_kernel(sigma, tau, m, n) - free_group_return_moment(m)


def avg_excess_moment(n, m):
    """Average excess moment over all pairs (σ, τ) in S_n."""
    perms = all_perms(n)
    total = Fraction(0)
    for sigma in perms:
        for tau in perms:
            total += excess_moment(sigma, tau, m, n)
    return total / Fraction(len(perms)**2)


def avg_excess_moment_sampled(n, m, num_samples=500):
    """Estimate average excess moment by random sampling."""
    import random
    perms = all_perms(n)
    total = Fraction(0)
    for _ in range(num_samples):
        sigma = random.choice(perms)
        tau = random.choice(perms)
        total += excess_moment(sigma, tau, m, n)
    return total / Fraction(num_samples)


def main():
    print("=" * 70)
    print("Average Excess Moment for Random Cayley Graphs on S_n")
    print("=" * 70)
    print()

    # Compute for small n (exhaustive)
    max_n_exact = 5
    max_n_sampled = 7

    for k in [1, 2]:
        m = 2 * k
        print(f"\n--- k = {k}, word length m = {m} ---")
        print(f"{'n':>4} | {'A_{n,k}':>20} | {'n * A_{n,k}':>20} | {'Method':>10}")
        print("-" * 65)

        for n in range(3, max_n_sampled + 1):
            if n <= max_n_exact:
                a_nk = avg_excess_moment(n, m)
                method = "exact"
            else:
                a_nk = avg_excess_moment_sampled(n, m, num_samples=200)
                method = "sampled"

            n_times_a = a_nk * n
            print(f"{n:>4} | {float(a_nk):>20.8f} | {float(n_times_a):>20.8f} | {method:>10}")

    print()
    print("=" * 70)
    print("Prediction: A_{n,k} ~ C_k / n  <==>  n * A_{n,k} → constant")
    print("=" * 70)

    # Verify conjugation invariance computationally
    print("\n--- Conjugation Invariance Check ---")
    n = 4
    perms = all_perms(n)
    sigma, tau = perms[5], perms[10]
    h = perms[3]
    sigma_conj = compose_perms(compose_perms(h, sigma, n), inverse_perm(h, n), n)
    tau_conj = compose_perms(compose_perms(h, tau, n), inverse_perm(h, n), n)

    for m in [2, 4]:
        mk_orig = moment_kernel(sigma, tau, m, n)
        mk_conj = moment_kernel(sigma_conj, tau_conj, m, n)
        print(f"  n={n}, m={m}: momentKernel(σ,τ) = {mk_orig}, "
              f"momentKernel(hσh⁻¹,hτh⁻¹) = {mk_conj}, "
              f"equal = {mk_orig == mk_conj}")

    # Verify partition function bound
    print("\n--- Truncated Partition Function Check ---")
    n = 3
    K = 3
    perms = all_perms(n)
    total_Z = Fraction(0)
    for sigma in perms:
        for tau in perms:
            Z = sum(
                Fraction(1, math.factorial(kk)) * excess_moment(sigma, tau, kk, n)
                for kk in range(K + 1)
            )
            total_Z += Z
    bound = Fraction(len(perms)**2) * sum(
        Fraction(1, math.factorial(kk)) for kk in range(K + 1)
    )
    print(f"  n={n}, K={K}: total Z = {float(total_Z):.6f}, "
          f"bound = {float(bound):.6f}, "
          f"satisfies bound = {total_Z <= bound}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Average Excess Moment Scaling Law

Plots the average excess moment A_{n,k} vs 1/n for symmetric groups S_n,
demonstrating the predicted O(1/n) decay law. Also plots n * A_{n,k}
to show convergence to the standard-representation constant.

This visualizes the central prediction: the deviation from free-group
universality scales as 1/n, where n is the degree of the symmetric group.
"""

import itertools
import math
from fractions import Fraction
from typing import Tuple, Dict, List
import matplotlib.pyplot as plt
import numpy as np


# Self-contained permutation and moment computation
Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p: Perm) -> Perm:
    n = len(p)
    inv = [0] * n
    for i in range(n): inv[p[i]] = i
    return tuple(inv)

def identity(n: int) -> Perm:
    return tuple(range(n))

def all_permutations(n: int) -> List[Perm]:
    return [tuple(p) for p in itertools.permutations(range(n))]

def closed_word_count_dp(sigma: Perm, tau: Perm, m: int) -> int:
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    e = identity(n)
    dist = {e: 1}
    for _ in range(m):
        new_dist: Dict[Perm, int] = {}
        for g, cnt in dist.items():
            for gen in gens:
                h = compose(gen, g)
                new_dist[h] = new_dist.get(h, 0) + cnt
        dist = new_dist
    return dist.get(e, 0)

def moment_kernel(sigma: Perm, tau: Perm, m: int) -> Fraction:
    return Fraction(closed_word_count_dp(sigma, tau, m), 4**m)

def excess_moment(sigma: Perm, tau: Perm, m: int) -> Fraction:
    baseline = Fraction(1) if m == 0 else Fraction(0)
    return moment_kernel(sigma, tau, m) - baseline

def avg_excess_moment(n: int, m: int) -> Fraction:
    perms = all_permutations(n)
    total = Fraction(0)
    for sigma in perms:
        for tau in perms:
            total += excess_moment(sigma, tau, m)
    return total / Fraction(len(perms)**2)


# Compute data
ns = [3, 4, 5]
ks = [1, 2]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

for idx, k in enumerate(ks):
    m = 2 * k
    a_values = []
    na_values = []
    inv_n_values = []

    for n in ns:
        a = float(avg_excess_moment(n, m))
        a_values.append(a)
        na_values.append(n * a)
        inv_n_values.append(1.0 / n)

    # Left plot: A_{n,k} vs 1/n
    axes[0].plot(inv_n_values, a_values, 'o-', color=colors[idx],
                 label=f'k={k} (m={m})', markersize=8, linewidth=2)

    # Right plot: n * A_{n,k}
    axes[1].plot(ns, na_values, 's-', color=colors[idx],
                 label=f'k={k} (m={m})', markersize=8, linewidth=2)

# Left plot formatting
axes[0].set_xlabel('1/n', fontsize=14)
axes[0].set_ylabel('$A_{n,k}$ = avgExcessMoment(n, 2k)', fontsize=14)
axes[0].set_title('Excess Moment vs 1/n\n(Predicted: linear relationship)', fontsize=14)
axes[0].legend(fontsize=12)
axes[0].grid(True, alpha=0.3)

# Add regression line
for idx, k in enumerate(ks):
    m = 2 * k
    x_data = [1.0/n for n in ns]
    y_data = [float(avg_excess_moment(n, m)) for n in ns]
    if len(x_data) >= 2:
        coeffs = np.polyfit(x_data, y_data, 1)
        x_line = np.linspace(0, max(x_data) * 1.1, 100)
        y_line = np.polyval(coeffs, x_line)
        axes[0].plot(x_line, y_line, '--', color=colors[idx], alpha=0.5,
                     label=f'fit: {coeffs[0]:.3f}/n + {coeffs[1]:.3f}')

axes[0].legend(fontsize=10)

# Right plot formatting
axes[1].set_xlabel('n', fontsize=14)
axes[1].set_ylabel('$n \\cdot A_{n,k}$', fontsize=14)
axes[1].set_title('Scaled Excess Moment\n(Predicted: converges to constant $C_k$)',
                   fontsize=14)
axes[1].legend(fontsize=12)
axes[1].grid(True, alpha=0.3)
axes[1].set_xticks(ns)

plt.tight_layout()
plt.savefig('excess_moment_scaling.png', dpi=150, bbox_inches='tight')
print("Saved: excess_moment_scaling.png")


#!/usr/bin/env python3
"""
Visualization: Moment Kernel Heatmap by Conjugacy Class

Displays the moment kernel as a function of conjugacy class pairs
in S_n, demonstrating the conjugation invariance theorem.
The heatmap shows that the moment kernel is constant on conjugacy
classes — the fundamental compression property.
"""

import itertools
import math
from fractions import Fraction
from typing import Tuple, Dict, List
import matplotlib.pyplot as plt
import numpy as np


Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p: Perm) -> Perm:
    n = len(p)
    inv = [0] * n
    for i in range(n): inv[p[i]] = i
    return tuple(inv)

def identity(n: int) -> Perm:
    return tuple(range(n))

def all_permutations(n: int) -> List[Perm]:
    return [tuple(p) for p in itertools.permutations(range(n))]

def cycle_type(p: Perm) -> Tuple[int, ...]:
    n = len(p)
    visited = [False] * n
    cycles = []
    for i in range(n):
        if not visited[i]:
            length = 0
            j = i
            while not visited[j]:
                visited[j] = True
                j = p[j]
                length += 1
            cycles.append(length)
    return tuple(sorted(cycles, reverse=True))

def closed_word_count_dp(sigma: Perm, tau: Perm, m: int) -> int:
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    e = identity(n)
    dist = {e: 1}
    for _ in range(m):
        new_dist: Dict[Perm, int] = {}
        for g, cnt in dist.items():
            for gen in gens:
                h = compose(gen, g)
                new_dist[h] = new_dist.get(h, 0) + cnt
        dist = new_dist
    return dist.get(e, 0)

def moment_kernel(sigma: Perm, tau: Perm, m: int) -> Fraction:
    return Fraction(closed_word_count_dp(sigma, tau, m), 4**m)


# Parameters
n = 4
m = 4

perms = all_permutations(n)

# Get conjugacy class representatives
class_reps: Dict[Tuple[int, ...], Perm] = {}
class_sizes: Dict[Tuple[int, ...], int] = {}
for p in perms:
    ct = cycle_type(p)
    if ct not in class_reps:
        class_reps[ct] = p
    class_sizes[ct] = class_sizes.get(ct, 0) + 1

classes = sorted(class_reps.keys())
num_classes = len(classes)

# Compute moment kernel for each class pair
mk_matrix = np.zeros((num_classes, num_classes))
for i, ct1 in enumerate(classes):
    for j, ct2 in enumerate(classes):
        rep1 = class_reps[ct1]
        rep2 = class_reps[ct2]
        mk_matrix[i, j] = float(moment_kernel(rep1, rep2, m))

# Create heatmap
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Left: Heatmap by conjugacy class
class_labels = [str(ct) for ct in classes]
im = axes[0].imshow(mk_matrix, cmap='YlOrRd', aspect='equal')
axes[0].set_xticks(range(num_classes))
axes[0].set_yticks(range(num_classes))
axes[0].set_xticklabels(class_labels, rotation=45, ha='right', fontsize=9)
axes[0].set_yticklabels(class_labels, fontsize=9)
axes[0].set_xlabel('Cycle type of τ', fontsize=12)
axes[0].set_ylabel('Cycle type of σ', fontsize=12)
axes[0].set_title(f'Moment Kernel by Conjugacy Class\n$S_{n}$, m={m}',
                   fontsize=14)
plt.colorbar(im, ax=axes[0], label='momentKernel(σ, τ, m)')

# Add values
for i in range(num_classes):
    for j in range(num_classes):
        axes[0].text(j, i, f'{mk_matrix[i,j]:.3f}',
                     ha='center', va='center', fontsize=8,
                     color='white' if mk_matrix[i,j] > 0.5 else 'black')

# Right: Verify conjugation invariance
# Pick a specific pair and compute for all conjugates
sigma = class_reps[classes[1]]  # a non-trivial class
tau = class_reps[classes[2]]     # another non-trivial class
mk_orig = float(moment_kernel(sigma, tau, m))

mk_conjugated = []
for h in perms[:24]:  # sample some conjugating elements
    sigma_c = compose(compose(h, sigma, ), inverse(h))
    tau_c = compose(compose(h, tau), inverse(h))
    mk_conjugated.append(float(moment_kernel(sigma_c, tau_c, m)))

axes[1].plot(mk_conjugated, 'o', color='#2196F3', markersize=6, alpha=0.7,
             label='Conjugated values')
axes[1].axhline(y=mk_orig, color='#FF5722', linewidth=2, linestyle='--',
                label=f'Original = {mk_orig:.4f}')
axes[1].set_xlabel('Conjugating element index', fontsize=12)
axes[1].set_ylabel('momentKernel value', fontsize=12)
axes[1].set_title(f'Conjugation Invariance Verification\n'
                   f'σ type={cycle_type(sigma)}, τ type={cycle_type(tau)}',
                   fontsize=14)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('moment_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: moment_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Truncated Excess Partition Function

Shows the truncated excess partition function Z_K(β) as a function of β
for different truncation levels K, demonstrating the cross-domain bridge
between moment bounds and statistical mechanics observables.
"""

import itertools
import math
from fractions import Fraction
from typing import Tuple, Dict, List
import matplotlib.pyplot as plt
import numpy as np


Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p: Perm) -> Perm:
    n = len(p)
    inv = [0] * n
    for i in range(n): inv[p[i]] = i
    return tuple(inv)

def identity(n: int) -> Perm:
    return tuple(range(n))

def all_permutations(n: int) -> List[Perm]:
    return [tuple(p) for p in itertools.permutations(range(n))]

def closed_word_count_dp(sigma: Perm, tau: Perm, m: int) -> int:
    n = len(sigma)
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    e = identity(n)
    dist = {e: 1}
    for _ in range(m):
        new_dist: Dict[Perm, int] = {}
        for g, cnt in dist.items():
            for gen in gens:
                h = compose(gen, g)
                new_dist[h] = new_dist.get(h, 0) + cnt
        dist = new_dist
    return dist.get(e, 0)

def moment_kernel_float(sigma: Perm, tau: Perm, m: int) -> float:
    return closed_word_count_dp(sigma, tau, m) / 4**m

def excess_moment_float(sigma: Perm, tau: Perm, m: int) -> float:
    baseline = 1.0 if m == 0 else 0.0
    return moment_kernel_float(sigma, tau, m) - baseline


# Parameters
n = 4
perms = all_permutations(n)
card = len(perms)

# Pick representative generators
sigma = tuple((i + 1) % n for i in range(n))  # (0 1 2 3)
tau = (1, 0) + tuple(range(2, n))               # (0 1)

# Compute truncated partition function for varying β and K
betas = np.linspace(0, 3, 50)
K_values = [2, 4, 6, 8]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']

# Left: Z_K(β) for a single pair (σ, τ)
for idx, K in enumerate(K_values):
    Z_values = []
    for beta in betas:
        Z = sum(
            beta**k / math.factorial(k) * excess_moment_float(sigma, tau, k)
            for k in range(K + 1)
        )
        Z_values.append(Z)
    axes[0].plot(betas, Z_values, '-', color=colors[idx % len(colors)],
                 linewidth=2, label=f'K={K}')

axes[0].set_xlabel('β (inverse temperature)', fontsize=13)
axes[0].set_ylabel('$Z_K(\\beta; \\sigma, \\tau)$', fontsize=13)
axes[0].set_title(f'Truncated Excess Partition Function\n'
                   f'Generators: σ={(0,1,2,3)}, τ=(0,1) in $S_{n}$',
                   fontsize=13)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)
axes[0].axhline(y=0, color='gray', linewidth=0.5)

# Right: Average Z_K(1) across all pairs, compared to bound
avg_Z_values = []
bound_values = []
K_range = range(1, 8)

for K in K_range:
    # Average over a sample of pairs
    np.random.seed(42)
    sample_size = min(50, card)
    total_Z = 0.0
    for _ in range(sample_size):
        s = perms[np.random.randint(card)]
        t = perms[np.random.randint(card)]
        Z = sum(
            1.0 / math.factorial(k) * excess_moment_float(s, t, k)
            for k in range(K + 1)
        )
        total_Z += Z
    avg_Z = total_Z / sample_size
    avg_Z_values.append(avg_Z)

    # Bound: sum of 1/k!
    bound = sum(1.0 / math.factorial(k) for k in range(K + 1))
    bound_values.append(bound)

axes[1].bar(list(K_range), avg_Z_values, alpha=0.7, color='#2196F3',
            label='Average $Z_K(1)$')
axes[1].plot(list(K_range), bound_values, 'rs-', markersize=8, linewidth=2,
             label='Bound: $\\sum 1/k!$')
axes[1].set_xlabel('Truncation level K', fontsize=13)
axes[1].set_ylabel('Value', fontsize=13)
axes[1].set_title(f'Average Partition Function vs Bound\n$S_{n}$, β=1',
                   fontsize=13)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('partition_function.png', dpi=150, bbox_inches='tight')
print("Saved: partition_function.png")
