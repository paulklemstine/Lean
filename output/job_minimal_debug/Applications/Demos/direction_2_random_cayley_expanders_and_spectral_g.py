#!/usr/bin/env python3
"""
applications.py — Real-world applications of Cayley graph spectral theory.

Demonstrates:
1. Random walk mixing on S_n — card shuffling convergence
2. Pseudorandom number generation via expander walks
3. Error amplification in randomized algorithms
4. Communication network design from group generators

Each application includes concrete numerical examples.
"""

import numpy as np
from math import factorial
from itertools import permutations
from typing import List, Tuple


# ──────────────────────────────────────────────────────────────
# Permutation utilities (self-contained)
# ──────────────────────────────────────────────────────────────

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def random_perm(n):
    p = list(range(n))
    np.random.shuffle(p)
    return tuple(p)


# ──────────────────────────────────────────────────────────────
# Application 1: Card Shuffling and Mixing Time
# ──────────────────────────────────────────────────────────────

def card_shuffling_demo(n: int = 5, num_steps: int = 50):
    """Simulate card shuffling using random Cayley graph generators.

    Demonstrates that the spectral gap controls how quickly a deck
    of cards becomes 'well shuffled'. A larger gap = faster mixing.

    The mixing time is approximately t_mix ≈ (1/gap) · ln(n!).
    """
    print(f"\n{'='*60}")
    print(f"  Application 1: Card Shuffling on a deck of {n} cards")
    print(f"  (Modeling S_{n} with |S_{n}| = {factorial(n)})")
    print(f"{'='*60}")

    # Build Cayley graph with standard generators
    tau = tuple((i + 1) % n for i in range(n))  # long cycle
    sigma_list = list(range(n))
    sigma_list[0], sigma_list[1] = sigma_list[1], sigma_list[0]
    sigma = tuple(sigma_list)

    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))

    elements = sorted(permutations(range(n)))
    idx = {p: i for i, p in enumerate(elements)}
    N = len(elements)

    # Build stochastic matrix
    A = np.zeros((N, N))
    d = len(gens)
    for i, g in enumerate(elements):
        for s in gens:
            j = idx[compose(s, g)]
            A[i, j] += 1.0 / d

    # Spectral gap
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    gap = 1.0 - eigs[1]

    # Simulate random walk from identity
    dist = np.zeros(N)
    dist[idx[identity(n)]] = 1.0  # Start at identity

    uniform = np.ones(N) / N

    print(f"  Spectral gap: {gap:.6f}")
    print(f"  Predicted mixing time: ≈ {1/gap * np.log(N):.1f} steps")
    print(f"\n  {'Step':>6} {'Total Variation Distance':>25} {'L² Distance':>15}")
    print(f"  {'─'*50}")

    for t in range(num_steps + 1):
        if t % max(1, num_steps // 15) == 0 or t <= 5:
            tv_dist = 0.5 * np.sum(np.abs(dist - uniform))
            l2_dist = np.sqrt(np.sum((dist - uniform) ** 2))
            bar = '█' * int(50 * min(1, tv_dist))
            print(f"  {t:6d} {tv_dist:25.8f} {l2_dist:15.8f}  {bar}")
        dist = A @ dist

    print(f"\n  The walk converges to uniform at rate ≈ (1-gap)^t = {1-gap:.4f}^t")
    return gap


def prg_expander_walk(n: int = 5, seed_bits: int = 10):
    """Pseudorandom generation via expander walks.

    Use a random walk on a Cayley expander to stretch a short
    random seed into a longer pseudorandom sequence. The spectral
    gap guarantees near-uniform marginals.
    """
    print(f"\n{'='*60}")
    print(f"  Application 2: Pseudorandom Generation via Expander Walk")
    print(f"{'='*60}")

    tau = tuple((i + 1) % n for i in range(n))
    sigma_list = list(range(n))
    sigma_list[0], sigma_list[1] = sigma_list[1], sigma_list[0]
    sigma = tuple(sigma_list)

    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))
    d = len(gens)

    # Random walk: start at random element, take random steps
    np.random.seed(42)
    current = random_perm(n)
    walk = [current]

    num_steps = 30
    for _ in range(num_steps):
        s = gens[np.random.randint(d)]
        current = compose(s, current)
        walk.append(current)

    print(f"  Starting permutation: {walk[0]}")
    print(f"  After {num_steps} steps: {walk[-1]}")
    print(f"\n  Walk trajectory (first 10 steps):")
    for i, p in enumerate(walk[:10]):
        print(f"    Step {i}: {p}")

    # Check pairwise independence
    print(f"\n  Testing near-independence of walk positions:")
    elements = sorted(permutations(range(n)))
    N = len(elements)

    # Build matrix
    idx = {p: i for i, p in enumerate(elements)}
    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in gens:
            j = idx[compose(s, g)]
            A[i, j] += 1.0 / d

    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    gap = 1.0 - eigs[1]

    print(f"  Spectral gap: {gap:.6f}")
    print(f"  After t steps, correlation ≤ (1-gap)^t = {1-gap:.4f}^t")
    for t in [5, 10, 20]:
        corr = (1 - gap) ** t
        print(f"    t={t}: correlation bound = {corr:.8f}")


def error_amplification_demo(n: int = 5):
    """Error amplification for randomized algorithms.

    A function f: S_n → {0,1} represents a randomized decision.
    The spectral gap allows amplifying correctness probability
    using correlated samples from an expander walk, saving random bits.
    """
    print(f"\n{'='*60}")
    print(f"  Application 3: Error Amplification via Expander Walk")
    print(f"{'='*60}")

    tau = tuple((i + 1) % n for i in range(n))
    sigma_list = list(range(n))
    sigma_list[0], sigma_list[1] = sigma_list[1], sigma_list[0]
    sigma = tuple(sigma_list)

    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))
    d = len(gens)

    elements = sorted(permutations(range(n)))
    N = len(elements)

    # Simulate a "correct on 70% of inputs" function
    np.random.seed(123)
    f_values = np.zeros(N)
    correct_fraction = 0.7
    correct_count = int(N * correct_fraction)
    correct_indices = np.random.choice(N, correct_count, replace=False)
    f_values[correct_indices] = 1.0

    actual_fraction = np.mean(f_values)
    print(f"  Decision function: correct on {actual_fraction*100:.1f}% of inputs")

    # Independent sampling baseline
    print(f"\n  Independent sampling (majority of k trials):")
    for k in [3, 5, 7, 11]:
        # Probability of majority correct with p = actual_fraction
        from scipy.stats import binom
        prob_correct = sum(binom.pmf(j, k, actual_fraction) for j in range(k//2 + 1, k + 1))
        print(f"    k={k:2d}: P(majority correct) = {prob_correct:.6f}")

    # Expander walk sampling
    print(f"\n  Expander walk sampling (majority of walk positions):")
    idx = {p: i for i, p in enumerate(elements)}
    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in gens:
            j = idx[compose(s, g)]
            A[i, j] += 1.0 / d

    num_trials = 5000
    for k in [3, 5, 7, 11]:
        correct = 0
        for _ in range(num_trials):
            start = elements[np.random.randint(N)]
            votes = [f_values[idx[start]]]
            current = start
            for _ in range(k - 1):
                s = gens[np.random.randint(d)]
                current = compose(s, current)
                votes.append(f_values[idx[current]])
            if sum(votes) > k / 2:
                correct += 1
        print(f"    k={k:2d}: P(majority correct) ≈ {correct/num_trials:.6f}")


def network_design_demo(n: int = 5):
    """Communication network design using Cayley expanders.

    A Cayley graph gives a network where:
    - Each node (processor) is a permutation
    - Each edge (link) corresponds to a generator
    - The spectral gap guarantees fast information dissemination
    """
    print(f"\n{'='*60}")
    print(f"  Application 4: Communication Network from Cayley Graph")
    print(f"{'='*60}")

    N = factorial(n)
    print(f"  Network size: {N} nodes (elements of S_{n})")
    print(f"  Node degree: 4 (from 2 generators + inverses)")

    tau = tuple((i + 1) % n for i in range(n))
    sigma_list = list(range(n))
    sigma_list[0], sigma_list[1] = sigma_list[1], sigma_list[0]
    sigma = tuple(sigma_list)

    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))

    # Compute diameter via BFS
    elements = sorted(permutations(range(n)))
    idx = {p: i for i, p in enumerate(elements)}
    e = identity(n)

    # BFS from identity to find distances
    from collections import deque
    dist_from_e = {e: 0}
    queue = deque([e])
    while queue:
        g = queue.popleft()
        for s in gens:
            h = compose(s, g)
            if h not in dist_from_e:
                dist_from_e[h] = dist_from_e[g] + 1
                queue.append(h)

    distances = list(dist_from_e.values())
    diameter = max(distances)
    avg_dist = np.mean(distances)

    print(f"  Diameter: {diameter}")
    print(f"  Average distance from identity: {avg_dist:.2f}")
    print(f"  log₂(N) = {np.log2(N):.2f}")
    print(f"  Diameter/log₂(N) = {diameter/np.log2(N):.2f}")
    print(f"\n  Distance distribution from identity:")
    for d in range(diameter + 1):
        count = distances.count(d)
        bar = '█' * (count * 40 // max(max(np.bincount(distances)), 1))
        print(f"    d={d:3d}: {count:5d} nodes  {bar}")

    # Spectral gap
    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in gens:
            j = idx[compose(s, g)]
            A[i, j] += 0.25

    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    gap = 1.0 - eigs[1]

    print(f"\n  Spectral gap: {gap:.6f}")
    print(f"  Mixing time bound: ≈ {1/gap * np.log(N):.0f} steps")
    print(f"  Edge expansion ≥ gap/2 = {gap/2:.6f}")


if __name__ == '__main__':
    try:
        from scipy.stats import binom
        has_scipy = True
    except ImportError:
        has_scipy = False

    card_shuffling_demo(5, 30)
    prg_expander_walk(5)
    if has_scipy:
        error_amplification_demo(5)
    else:
        print("\n  [Skipping error amplification demo: scipy not available]")
    network_design_demo(5)


#!/usr/bin/env python3
"""
demo.py — Interactive Demo: Random Cayley Expanders for S_n

Explores the spectral properties of random Cayley graphs of the symmetric group.
For n in {5, 6, 7, 8}, generates random pairs (σ, τ) of permutations,
checks if they generate S_n, constructs the Cayley graph, and computes
spectral gaps and eigenvalue distributions.

Usage:
    python demo.py [--n N] [--samples K] [--plot]
"""

import numpy as np
from itertools import permutations
from math import factorial
import argparse
import sys

# ──────────────────────────────────────────────────────────────
# Core permutation utilities
# ──────────────────────────────────────────────────────────────

def compose(p, q):
    """Compose permutations p and q: (p∘q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    """Inverse of permutation p."""
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    """Identity permutation of size n."""
    return tuple(range(n))

def random_perm(n):
    """Generate a uniformly random permutation of {0,...,n-1}."""
    p = list(range(n))
    np.random.shuffle(p)
    return tuple(p)

def closure(generators, n):
    """Compute the subgroup generated by a set of permutations via BFS."""
    e = identity(n)
    visited = {e}
    frontier = [e]
    while frontier:
        next_frontier = []
        for g in frontier:
            for s in generators:
                h = compose(s, g)
                if h not in visited:
                    visited.add(h)
                    next_frontier.append(h)
                h = compose(inverse(s), g)
                if h not in visited:
                    visited.add(h)
                    next_frontier.append(h)
        frontier = next_frontier
    return visited

def generates_sn(sigma, tau, n):
    """Check whether σ and τ generate S_n."""
    return len(closure([sigma, tau], n)) == factorial(n)

# ──────────────────────────────────────────────────────────────
# Cayley graph construction
# ──────────────────────────────────────────────────────────────

def build_cayley_adjacency(sigma, tau, n):
    """Build the normalized adjacency matrix of Cay(S_n, {σ, σ⁻¹, τ, τ⁻¹}).

    Returns: (A, elements) where A is the |S_n|×|S_n| normalized adjacency
    matrix and elements is the list of group elements (permutations).
    """
    gens = [sigma, inverse(sigma), tau, inverse(tau)]
    # Remove duplicates (e.g., if σ is an involution, σ = σ⁻¹)
    gen_set = list(set(gens))
    d = len(gen_set)

    # Enumerate all elements of S_n
    elements = list(permutations(range(n)))
    idx = {p: i for i, p in enumerate(elements)}
    N = len(elements)

    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in gen_set:
            j = idx[compose(s, g)]
            A[i, j] += 1.0
    A /= d
    return A, elements

def spectral_gap(A):
    """Compute the spectral gap of a stochastic matrix A.

    The spectral gap is 1 - λ₂, where λ₂ is the second largest eigenvalue.
    """
    eigenvalues = np.linalg.eigvalsh(A)
    eigenvalues = np.sort(eigenvalues)[::-1]
    # The largest eigenvalue should be 1 (for a stochastic matrix)
    return 1.0 - eigenvalues[1]

def all_eigenvalues(A):
    """Return all eigenvalues of A sorted in decreasing order."""
    eigenvalues = np.linalg.eigvalsh(A)
    return np.sort(eigenvalues)[::-1]

# ──────────────────────────────────────────────────────────────
# Dirichlet energy computation
# ──────────────────────────────────────────────────────────────

def dirichlet_energy(f_values, sigma, tau, n):
    """Compute Dirichlet energy E_S(f) = Σ_x Σ_{s∈S} (f(sx) - f(x))²."""
    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))
    elements = list(permutations(range(n)))
    idx = {p: i for i, p in enumerate(elements)}
    energy = 0.0
    for i, x in enumerate(elements):
        for s in gens:
            j = idx[compose(s, x)]
            energy += (f_values[j] - f_values[i]) ** 2
    return energy

# ──────────────────────────────────────────────────────────────
# Trace method: closed walk counts
# ──────────────────────────────────────────────────────────────

def closed_walk_count(A, k):
    """Compute tr(A^(2k)), the normalized count of closed walks of length 2k."""
    Ak = np.linalg.matrix_power(A, 2 * k)
    return np.trace(Ak)

# ──────────────────────────────────────────────────────────────
# Main demo
# ──────────────────────────────────────────────────────────────

def run_demo(n=5, num_samples=20, show_plot=False):
    """Run the spectral gap demo for S_n."""
    print(f"\n{'='*60}")
    print(f"  Random Cayley Expanders for S_{n}")
    print(f"  |S_{n}| = {factorial(n)}")
    print(f"  Sampling {num_samples} random generating pairs...")
    print(f"{'='*60}\n")

    gaps = []
    traces_k2 = []
    traces_k3 = []
    attempts = 0
    generated_count = 0

    while generated_count < num_samples:
        sigma = random_perm(n)
        tau = random_perm(n)
        attempts += 1

        if not generates_sn(sigma, tau, n):
            continue

        generated_count += 1
        A, elems = build_cayley_adjacency(sigma, tau, n)
        gap = spectral_gap(A)
        gaps.append(gap)

        # Trace method
        tr4 = closed_walk_count(A, 2) / len(elems)
        tr6 = closed_walk_count(A, 3) / len(elems)
        traces_k2.append(tr4)
        traces_k3.append(tr6)

        if generated_count <= 5:
            eigs = all_eigenvalues(A)
            print(f"  Sample {generated_count}:")
            print(f"    σ = {sigma}")
            print(f"    τ = {tau}")
            print(f"    Spectral gap = {gap:.6f}")
            print(f"    Top 5 eigenvalues: {eigs[:5].round(4)}")
            print(f"    tr(A⁴)/|G| - 1 = {tr4 - 1:.6f}")
            print()

    # Summary statistics
    gaps = np.array(gaps)
    print(f"\n{'─'*60}")
    print(f"  Summary ({generated_count} generating pairs from {attempts} attempts)")
    print(f"  Generation probability ≈ {generated_count/attempts:.4f}")
    print(f"{'─'*60}")
    print(f"  Spectral gap statistics:")
    print(f"    Min gap:    {gaps.min():.6f}")
    print(f"    Max gap:    {gaps.max():.6f}")
    print(f"    Mean gap:   {gaps.mean():.6f}")
    print(f"    Std gap:    {gaps.std():.6f}")
    print(f"    Median gap: {np.median(gaps):.6f}")
    print()

    # Conjecture test
    threshold = 0.01
    below = np.sum(gaps < threshold)
    print(f"  Conjecture test (gap > {threshold}):")
    print(f"    Samples with gap < {threshold}: {below}/{generated_count}")
    if below == 0:
        print(f"    ✓ Conjecture supported: all gaps > {threshold}")
    else:
        print(f"    ✗ Conjecture challenged: {below} samples have gap < {threshold}")

    # Alon-Boppana heuristic
    d = 4  # degree of generators (counting inverses)
    alon_boppana = 2 * np.sqrt(d - 1) / d
    print(f"\n  Alon–Boppana bound: λ₂ ≥ {alon_boppana:.4f} (gap ≤ {1 - alon_boppana:.4f})")
    print(f"  Observed max gap:  {gaps.max():.4f}")
    print(f"  Observed min gap:  {gaps.min():.4f}")

    # Trace method statistics
    traces_k2 = np.array(traces_k2)
    traces_k3 = np.array(traces_k3)
    print(f"\n  Trace method (closed walk excess):")
    print(f"    tr(A⁴)/|G| - 1: mean={np.mean(traces_k2 - 1):.6f}, max={np.max(traces_k2 - 1):.6f}")
    print(f"    tr(A⁶)/|G| - 1: mean={np.mean(traces_k3 - 1):.6f}, max={np.max(traces_k3 - 1):.6f}")

    if show_plot:
        try:
            import matplotlib
            matplotlib.use('Agg')
            import matplotlib.pyplot as plt

            fig, axes = plt.subplots(1, 2, figsize=(14, 5))

            # Histogram of spectral gaps
            axes[0].hist(gaps, bins=20, edgecolor='black', alpha=0.7, color='steelblue')
            axes[0].axvline(x=threshold, color='red', linestyle='--',
                          label=f'Threshold = {threshold}')
            axes[0].set_xlabel('Spectral Gap')
            axes[0].set_ylabel('Count')
            axes[0].set_title(f'Spectral Gaps of Random Cayley Graphs of S_{n}')
            axes[0].legend()

            # Full eigenvalue spectrum for last sample
            eigs = all_eigenvalues(A)
            axes[1].plot(range(len(eigs)), eigs, 'o-', markersize=2, color='darkblue')
            axes[1].axhline(y=1 - threshold, color='red', linestyle='--', alpha=0.5)
            axes[1].set_xlabel('Eigenvalue Index')
            axes[1].set_ylabel('Eigenvalue')
            axes[1].set_title(f'Eigenvalue Spectrum (last sample)')

            plt.tight_layout()
            plt.savefig(f'cayley_expander_S{n}.png', dpi=150)
            print(f"\n  Plot saved to cayley_expander_S{n}.png")
        except ImportError:
            print("\n  matplotlib not available for plotting")

    return gaps

# ──────────────────────────────────────────────────────────────
# Classical generators test
# ──────────────────────────────────────────────────────────────

def test_classical_generators(n=5):
    """Test the classical generators: adjacent transposition + long cycle."""
    print(f"\n{'='*60}")
    print(f"  Classical Generators for S_{n}")
    print(f"{'='*60}")

    # Long cycle: (0 1 2 ... n-1)
    tau = tuple((i + 1) % n for i in range(n))
    # Adjacent transposition: (0 1)
    sigma = list(range(n))
    sigma[0], sigma[1] = sigma[1], sigma[0]
    sigma = tuple(sigma)

    print(f"  σ (adjacent transposition) = {sigma}")
    print(f"  τ (long cycle) = {tau}")
    print(f"  Generates S_{n}: {generates_sn(sigma, tau, n)}")

    A, elems = build_cayley_adjacency(sigma, tau, n)
    gap = spectral_gap(A)
    eigs = all_eigenvalues(A)

    print(f"  Spectral gap = {gap:.6f}")
    print(f"  All eigenvalues: {eigs.round(4)[:20]}{'...' if len(eigs) > 20 else ''}")

    # Dirichlet energy test with random function
    f = np.random.randn(len(elems))
    E = dirichlet_energy(f, sigma, tau, n)
    print(f"  Dirichlet energy of random f: {E:.4f}")

    # Constant function test
    f_const = np.ones(len(elems)) * 3.14
    E_const = dirichlet_energy(f_const, sigma, tau, n)
    print(f"  Dirichlet energy of constant f: {E_const:.10f}")
    print(f"  ✓ Constant functions have zero energy: {E_const < 1e-10}")

    return gap, eigs


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Random Cayley Expander Demo')
    parser.add_argument('--n', type=int, default=5, choices=[5, 6, 7, 8],
                       help='Size of symmetric group S_n')
    parser.add_argument('--samples', type=int, default=20,
                       help='Number of random generating pairs')
    parser.add_argument('--plot', action='store_true',
                       help='Generate plots')
    parser.add_argument('--all', action='store_true',
                       help='Run for all n in {5,6,7,8}')
    args = parser.parse_args()

    # Classical generators test
    test_classical_generators(5)

    if args.all:
        for n in [5, 6, 7]:
            run_demo(n=n, num_samples=args.samples, show_plot=args.plot)
    else:
        run_demo(n=args.n, num_samples=args.samples, show_plot=args.plot)


#!/usr/bin/env python3
"""
Visualization 3: Eigenvalue Spectrum Comparison

Compares the full eigenvalue spectrum of Cayley graphs generated by
different generator pairs for S_5. Shows that:
1. The top eigenvalue is always 1 (connected graph).
2. There is a visible spectral gap.
3. Random generators tend to produce 'better' gaps than the standard pair.

Output: Eigenvalue spectrum heatmap and individual spectrum plots.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def random_perm(n):
    p = list(range(n))
    np.random.shuffle(p)
    return tuple(p)

def closure(generators, n):
    e = identity(n)
    all_gens = list(generators) + [inverse(s) for s in generators]
    visited = {e}
    frontier = [e]
    while frontier:
        nf = []
        for g in frontier:
            for s in all_gens:
                h = compose(s, g)
                if h not in visited:
                    visited.add(h)
                    nf.append(h)
        frontier = nf
    return visited

def build_matrix_and_spectrum(sigma, tau, n):
    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))
    d = len(gens)
    elements = sorted(permutations(range(n)))
    idx = {p: i for i, p in enumerate(elements)}
    N = len(elements)
    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in gens:
            j = idx[compose(s, g)]
            A[i, j] += 1.0 / d
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    return eigs


np.random.seed(2025)
n = 5
N = factorial(n)

# Collect spectra
spectra = []
gaps = []
labels = []

# Standard generators
tau = tuple((i + 1) % n for i in range(n))
sl = list(range(n)); sl[0], sl[1] = sl[1], sl[0]
sigma = tuple(sl)
eigs = build_matrix_and_spectrum(sigma, tau, n)
spectra.append(eigs)
gaps.append(1.0 - eigs[1])
labels.append('Standard (swap+cycle)')

# Random generators
num_random = 25
while len(spectra) - 1 < num_random:
    s = random_perm(n)
    t = random_perm(n)
    if len(closure([s, t], n)) == N:
        eigs = build_matrix_and_spectrum(s, t, n)
        spectra.append(eigs)
        gaps.append(1.0 - eigs[1])
        labels.append(f'Random #{len(spectra)-1}')

fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# Top left: Heatmap of all spectra
ax = axes[0, 0]
spectrum_matrix = np.array(spectra)
im = ax.imshow(spectrum_matrix, aspect='auto', cmap='RdYlBu_r',
               vmin=-1, vmax=1, interpolation='nearest')
ax.set_xlabel('Eigenvalue Index', fontsize=12)
ax.set_ylabel('Generator Pair', fontsize=12)
ax.set_title('Eigenvalue Spectra (all pairs)', fontsize=13, fontweight='bold')
fig.colorbar(im, ax=ax, label='Eigenvalue')
ax.axhline(y=0.5, color='yellow', linewidth=2, linestyle='--', alpha=0.7)
ax.set_yticks([0])
ax.set_yticklabels(['Standard'])

# Top right: Overlay of spectra
ax = axes[0, 1]
for i in range(min(8, len(spectra))):
    alpha = 1.0 if i == 0 else 0.3
    lw = 2.5 if i == 0 else 1
    color = 'red' if i == 0 else 'steelblue'
    ax.plot(spectra[i], 'o-', markersize=2, alpha=alpha, linewidth=lw,
           color=color, label=labels[i] if i <= 1 else None)

ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('Eigenvalue Index', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title('Eigenvalue Spectra Overlay', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2)

# Bottom left: Gap distribution
ax = axes[1, 0]
ax.hist(gaps[1:], bins=12, edgecolor='white', color='#4CAF50', alpha=0.8)
ax.axvline(x=gaps[0], color='red', linewidth=2, linestyle='--',
          label=f'Standard: {gaps[0]:.4f}')
ax.axvline(x=0.01, color='orange', linewidth=2, linestyle=':',
          label='Threshold 0.01')
ax.set_xlabel('Spectral Gap', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Gap Distribution', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)

# Bottom right: Eigenvalue density (histogram of all eigenvalues)
ax = axes[1, 1]
all_eigs = np.concatenate(spectra[1:])  # Exclude standard
ax.hist(all_eigs, bins=50, edgecolor='white', color='#9C27B0', alpha=0.7,
       density=True, label='Random generators')
ax.hist(spectra[0], bins=30, edgecolor='white', color='red', alpha=0.5,
       density=True, label='Standard generators')
ax.set_xlabel('Eigenvalue', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Eigenvalue Density Distribution', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.axvline(x=1, color='gray', linestyle=':', alpha=0.5)

fig.suptitle(f'Spectral Analysis of Cayley Graphs of S_{n} ({N} vertices)',
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_eigenvalue_spectrum.png")


#!/usr/bin/env python3
"""
Visualization 2: L² Mixing Contraction on Cayley Graphs

Shows how the L² norm of a mean-zero function decays under repeated
application of the Cayley averaging operator. The decay rate is
controlled by the spectral gap: ‖A^k f‖₂² ≤ (1-gap)^(2k) · ‖f‖₂².

This demonstrates the proven theorem that the averaging operator
is an L² contraction, and visualizes the exponential convergence
to equilibrium.

Output: Plot showing L² decay curves for different generator pairs.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def random_perm(n):
    p = list(range(n))
    np.random.shuffle(p)
    return tuple(p)

def closure(generators, n):
    e = identity(n)
    all_gens = list(generators) + [inverse(s) for s in generators]
    visited = {e}
    frontier = [e]
    while frontier:
        nf = []
        for g in frontier:
            for s in all_gens:
                h = compose(s, g)
                if h not in visited:
                    visited.add(h)
                    nf.append(h)
        frontier = nf
    return visited

def build_matrix(sigma, tau, n):
    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))
    d = len(gens)
    elements = sorted(permutations(range(n)))
    idx = {p: i for i, p in enumerate(elements)}
    N = len(elements)
    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in gens:
            j = idx[compose(s, g)]
            A[i, j] += 1.0 / d
    return A

def spectral_gap(A):
    eigs = np.sort(np.linalg.eigvalsh(A))[::-1]
    return 1.0 - eigs[1]


np.random.seed(42)
n = 5
N = factorial(n)
num_steps = 40

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

# Collect several generating pairs
pairs = []
while len(pairs) < 5:
    s = random_perm(n)
    t = random_perm(n)
    if len(closure([s, t], n)) == N:
        pairs.append((s, t))

# Also include standard generators
tau = tuple((i + 1) % n for i in range(n))
sigma_list = list(range(n))
sigma_list[0], sigma_list[1] = sigma_list[1], sigma_list[0]
sigma = tuple(sigma_list)
pairs.insert(0, (sigma, tau))

colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(pairs)))

# Left plot: L² decay
for idx_p, (s, t) in enumerate(pairs):
    A = build_matrix(s, t, n)
    gap = spectral_gap(A)

    # Random mean-zero function
    f = np.random.randn(N)
    f -= np.mean(f)

    norms = [np.sum(f ** 2)]
    current = f.copy()
    for _ in range(num_steps):
        current = A @ current
        norms.append(np.sum(current ** 2))

    norms = np.array(norms) / norms[0]  # Normalize

    label = f'gap={gap:.4f}' + (' (standard)' if idx_p == 0 else '')
    ax1.semilogy(range(num_steps + 1), norms, 'o-', color=colors[idx_p],
                markersize=3, linewidth=1.5, label=label)

    # Theoretical bound
    bound = [(1 - gap) ** (2 * k) for k in range(num_steps + 1)]
    ax1.semilogy(range(num_steps + 1), bound, '--', color=colors[idx_p],
                alpha=0.4, linewidth=1)

ax1.set_xlabel('Step k', fontsize=13)
ax1.set_ylabel('‖A^k f‖₂² / ‖f‖₂²  (log scale)', fontsize=13)
ax1.set_title('L² Contraction Under Averaging', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-16, 2)

# Right plot: Total variation distance from uniform
ax2_colors = ['#E91E63', '#2196F3', '#4CAF50']

for idx_p, (s, t) in enumerate(pairs[:3]):
    A = build_matrix(s, t, n)
    gap = spectral_gap(A)

    # Start from delta at identity
    dist = np.zeros(N)
    dist[0] = 1.0  # Identity is first element
    uniform = np.ones(N) / N

    tv_dists = []
    for k in range(num_steps + 1):
        tv = 0.5 * np.sum(np.abs(dist - uniform))
        tv_dists.append(tv)
        dist = A @ dist

    label = f'gap={gap:.4f}' + (' (standard)' if idx_p == 0 else '')
    ax2.semilogy(range(num_steps + 1), tv_dists, 'o-', color=ax2_colors[idx_p],
                markersize=3, linewidth=2, label=label)

ax2.set_xlabel('Step k', fontsize=13)
ax2.set_ylabel('Total Variation Distance (log scale)', fontsize=13)
ax2.set_title('Mixing: Convergence to Uniform', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0.01, color='gray', linestyle=':', alpha=0.5, label='TV = 0.01')

fig.suptitle(f'Spectral Gap Controls Mixing Speed (S_{n}, |S_{n}| = {N})',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mixing.png', dpi=150, bbox_inches='tight')
print("Saved viz_mixing.png")


#!/usr/bin/env python3
"""
Visualization 1: Spectral Gap Distribution of Random Cayley Graphs of S_n

Visualizes the distribution of spectral gaps across random generating pairs
for S_5, S_6, and S_7, demonstrating the Random Cayley Expander Conjecture:
random generators typically produce Cayley graphs with a uniform spectral gap
bounded away from zero.

Output: Histogram subplots comparing gap distributions across group sizes.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def random_perm(n):
    p = list(range(n))
    np.random.shuffle(p)
    return tuple(p)

def closure(generators, n):
    e = identity(n)
    all_gens = list(generators) + [inverse(s) for s in generators]
    visited = {e}
    frontier = [e]
    while frontier:
        next_frontier = []
        for g in frontier:
            for s in all_gens:
                h = compose(s, g)
                if h not in visited:
                    visited.add(h)
                    next_frontier.append(h)
        frontier = next_frontier
    return visited

def spectral_gap_for_pair(sigma, tau, n):
    gens = list(set([sigma, inverse(sigma), tau, inverse(tau)]))
    d = len(gens)
    elements = sorted(permutations(range(n)))
    idx = {p: i for i, p in enumerate(elements)}
    N = len(elements)
    A = np.zeros((N, N))
    for i, g in enumerate(elements):
        for s in gens:
            j = idx[compose(s, g)]
            A[i, j] += 1.0 / d
    eigs = np.linalg.eigvalsh(A)
    eigs = np.sort(eigs)[::-1]
    return 1.0 - eigs[1]

def collect_gaps(n, num_samples=50):
    gaps = []
    while len(gaps) < num_samples:
        s = random_perm(n)
        t = random_perm(n)
        if len(closure([s, t], n)) == factorial(n):
            gaps.append(spectral_gap_for_pair(s, t, n))
    return np.array(gaps)


np.random.seed(2025)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

colors = ['#2196F3', '#FF9800', '#4CAF50']
ns = [5, 6, 7]
samples = [60, 30, 10]

all_gaps = {}
for i, (n, num) in enumerate(zip(ns, samples)):
    gaps = collect_gaps(n, num)
    all_gaps[n] = gaps

    ax = axes[i]
    ax.hist(gaps, bins=15, edgecolor='white', alpha=0.85, color=colors[i],
            linewidth=1.2)
    ax.axvline(x=0.01, color='red', linestyle='--', linewidth=2,
              label='Threshold c₀ = 0.01')
    ax.set_xlabel('Spectral Gap', fontsize=13)
    ax.set_ylabel('Count', fontsize=13)
    ax.set_title(f'S_{n}  (|S_{n}| = {factorial(n)})', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(0, max(gaps) * 1.15)

    # Add statistics
    stats_text = (f'min = {gaps.min():.4f}\n'
                  f'mean = {gaps.mean():.4f}\n'
                  f'n = {num}')
    ax.text(0.97, 0.97, stats_text, transform=ax.transAxes,
            fontsize=9, verticalalignment='top', horizontalalignment='right',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.7))

fig.suptitle('Spectral Gaps of Random Cayley Graphs of Symmetric Groups',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_gaps.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_gaps.png")
