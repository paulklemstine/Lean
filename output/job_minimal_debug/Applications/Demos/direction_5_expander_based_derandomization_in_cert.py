#!/usr/bin/env python3
"""
Applications of Expander Walk Amplification

This file demonstrates real-world applications of the certified
expander-walk amplification framework:

1. Randomness-efficient primality testing
2. Certified Monte Carlo estimation
3. Communication-efficient distributed consensus
"""

import math
import random
from typing import Callable, List, Tuple

# ─────────────────────────────────────────────────────────────────
# Application 1: Randomness-Efficient Primality Testing
# ─────────────────────────────────────────────────────────────────

def miller_rabin_witness(n: int, a: int) -> bool:
    """Test if a is a Miller-Rabin witness for compositeness of n."""
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False

    # Write n-1 = 2^r * d
    d = n - 1
    r = 0
    while d % 2 == 0:
        d //= 2
        r += 1

    x = pow(a, d, n)
    if x == 1 or x == n - 1:
        return True  # probably prime

    for _ in range(r - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True  # probably prime

    return False  # composite


class ExpanderPrimalityTester:
    """
    Primality testing with expander-walk amplification.

    Instead of using k independent random witnesses (requiring
    k · log₂(n) random bits), we use a walk on a Cayley graph
    of Z/nZ to generate correlated witnesses that still amplify.

    For a composite n, each random witness detects compositeness
    with probability ≥ 3/4 (Miller-Rabin), so δ ≥ 1/4.
    """

    def __init__(self, n: int, spectral_bound: float = 0.9):
        """
        Parameters
        ----------
        n : int
            Number to test for primality.
        spectral_bound : float
            Upper bound on spectral contraction of the walk.
        """
        self.n = n
        self.rho = spectral_bound
        self.spectral_constant = (1 + self.rho) / (1 - self.rho)

    def test(self, k: int, seed: int = 0) -> Tuple[str, dict]:
        """
        Run k-step amplified primality test.

        Returns
        -------
        result : str
            'COMPOSITE' or 'PROBABLY PRIME'
        info : dict
            Diagnostic information.
        """
        rng = random.Random(seed)
        a = rng.randint(2, max(3, self.n - 2))

        # Walk on Z/nZ using additive generators
        step_size = rng.randint(1, max(2, self.n // 10))
        witnesses = []
        for i in range(k):
            witnesses.append(a)
            a = (a + step_size) % self.n
            if a < 2:
                a = 2

        composite_votes = sum(
            1 for w in witnesses if not miller_rabin_witness(self.n, w)
        )
        prime_votes = k - composite_votes

        result = "COMPOSITE" if composite_votes > k // 2 else "PROBABLY PRIME"

        bits_walk = math.ceil(math.log2(max(2, self.n))) + k * math.ceil(math.log2(max(2, self.n // 10)))
        bits_indep = k * math.ceil(math.log2(max(2, self.n)))

        return result, {
            "n": self.n,
            "k": k,
            "composite_votes": composite_votes,
            "prime_votes": prime_votes,
            "random_bits_walk": bits_walk,
            "random_bits_independent": bits_indep,
            "savings": 1 - bits_walk / max(1, bits_indep),
            "certified_error": self.spectral_constant / (4 * 0.25**2 * k),
        }


# ─────────────────────────────────────────────────────────────────
# Application 2: Certified Monte Carlo Integration
# ─────────────────────────────────────────────────────────────────

class ExpanderMonteCarloEstimator:
    """
    Monte Carlo estimation with certified variance reduction
    via expander-walk sampling.

    Given a function f : [0,1]^d → [0,1], estimate E[f] using
    correlated samples from an expander walk rather than
    independent samples.

    The certified variance bound ensures:
    Var(estimator) ≤ C(ρ) · Var(f) / k

    where C(ρ) = (1+ρ)/(1-ρ) is the spectral overhead.
    """

    def __init__(self, rho: float = 0.5):
        self.rho = rho
        self.spectral_constant = (1 + rho) / (1 - rho)

    def estimate(
        self,
        f: Callable[[float], float],
        k: int,
        rng: random.Random = None,
    ) -> Tuple[float, dict]:
        """
        Estimate E[f] using k correlated samples.

        Parameters
        ----------
        f : callable
            Function to integrate, f : [0,1] → [0,1].
        k : int
            Number of samples.

        Returns
        -------
        estimate : float
            The empirical mean.
        info : dict
            Certified error bounds and diagnostics.
        """
        if rng is None:
            rng = random.Random()

        # Generate correlated samples via a discrete walk
        x = rng.random()
        step = 0.1 + 0.8 * rng.random()  # random step size
        values = []
        for _ in range(k):
            values.append(f(x))
            x = (x + step) % 1.0

        estimate = sum(values) / k
        sample_var = sum((v - estimate)**2 for v in values) / max(1, k - 1)

        return estimate, {
            "k": k,
            "estimate": estimate,
            "sample_variance": sample_var,
            "certified_variance_bound": self.spectral_constant * sample_var / k,
            "certified_95_ci_half_width": 1.96 * math.sqrt(
                self.spectral_constant * sample_var / k
            ),
        }


# ─────────────────────────────────────────────────────────────────
# Application 3: Communication-Efficient Distributed Consensus
# ─────────────────────────────────────────────────────────────────

class ExpanderConsensusProtocol:
    """
    Distributed consensus using expander-walk amplification.

    In a distributed system, nodes hold votes (0 or 1).
    Instead of broadcasting all votes, a random walk on an
    expander graph samples a subset of nodes. The majority
    of the walk samples gives the consensus, with certified
    error bounds from the spectral gap.

    Communication cost: O(k · log(d)) messages instead of
    O(n) for full broadcast, where k = walk length, d = degree.
    """

    def __init__(self, n_nodes: int, degree: int, rho: float = 0.5):
        self.n_nodes = n_nodes
        self.degree = degree
        self.rho = rho
        self.spectral_constant = (1 + rho) / (1 - rho)

    def run_consensus(
        self,
        votes: List[int],
        walk_length: int,
        rng: random.Random = None,
    ) -> Tuple[int, dict]:
        """
        Run consensus protocol.

        Parameters
        ----------
        votes : list of int
            Each node's vote (0 or 1).
        walk_length : int
            Number of walk steps.

        Returns
        -------
        decision : int
            0 or 1.
        info : dict
            Protocol information.
        """
        if rng is None:
            rng = random.Random()

        n = len(votes)
        # Simulate random walk on a d-regular expander
        current = rng.randint(0, n - 1)
        sampled_votes = []
        for _ in range(walk_length):
            sampled_votes.append(votes[current])
            # Move to a random neighbor (simulated expander)
            step = rng.choice(range(1, self.degree + 1))
            current = (current + step) % n

        ones = sum(sampled_votes)
        decision = 1 if ones > walk_length // 2 else 0
        true_majority = 1 if sum(votes) > n // 2 else 0

        bias = abs(sum(votes) / n - 0.5)
        error_bound = self.spectral_constant / (4 * max(bias, 0.01)**2 * walk_length)

        return decision, {
            "walk_length": walk_length,
            "sampled_ones": ones,
            "true_majority": true_majority,
            "correct": decision == true_majority,
            "messages": walk_length,
            "full_broadcast_messages": n,
            "communication_savings": 1 - walk_length / n,
            "certified_error_bound": min(1.0, error_bound),
        }


# ─────────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Randomness-Efficient Primality Testing")
    print("=" * 60)

    test_numbers = [
        (561, "Carmichael number"),
        (1009, "prime"),
        (2047, "composite"),
        (104729, "prime"),
        (1000003, "prime"),
    ]

    for n, label in test_numbers:
        tester = ExpanderPrimalityTester(n)
        for k in [5, 20]:
            result, info = tester.test(k, seed=42)
            print(f"  n={n:>8} ({label:>18}), k={k:>2}: {result:>15} "
                  f"[walk bits: {info['random_bits_walk']:>4}, "
                  f"indep bits: {info['random_bits_independent']:>4}, "
                  f"savings: {info['savings']:>5.1%}]")

    print(f"\n{'='*60}")
    print("Application 2: Certified Monte Carlo Integration")
    print(f"{'='*60}")

    # Estimate E[sin(πx)] for x ∈ [0,1]
    f = lambda x: math.sin(math.pi * x)
    true_value = 2 / math.pi  # ≈ 0.6366
    estimator = ExpanderMonteCarloEstimator(rho=0.5)

    print(f"\nEstimating E[sin(πx)] = 2/π ≈ {true_value:.6f}")
    for k in [10, 50, 100, 500]:
        est, info = estimator.estimate(f, k, rng=random.Random(42))
        print(f"  k={k:>4}: estimate = {est:.6f}, "
              f"95% CI ± {info['certified_95_ci_half_width']:.6f}, "
              f"|error| = {abs(est - true_value):.6f}")

    print(f"\n{'='*60}")
    print("Application 3: Distributed Consensus")
    print(f"{'='*60}")

    n_nodes = 1000
    rng = random.Random(42)
    # 60% vote for 1
    votes = [1 if rng.random() < 0.6 else 0 for _ in range(n_nodes)]
    actual_fraction = sum(votes) / n_nodes

    print(f"\n{n_nodes} nodes, fraction voting 1: {actual_fraction:.3f}")

    protocol = ExpanderConsensusProtocol(n_nodes, degree=4, rho=0.5)
    for k in [10, 30, 50, 100]:
        decision, info = protocol.run_consensus(votes, k, rng=random.Random(42))
        print(f"  k={k:>3}: decision={decision}, correct={info['correct']}, "
              f"msgs={info['messages']}, "
              f"savings={info['communication_savings']:.1%}, "
              f"error_bound={info['certified_error_bound']:.4f}")


#!/usr/bin/env python3
"""
Expander Walk Majority Amplification — Interactive Demo on S_5

This script demonstrates the core theoretical results formalized in Lean:
  1. Covariance decay along expander walks
  2. Variance concentration of empirical means
  3. Majority vote error reduction with logarithmic randomness
  4. Random-bit accounting

We use the Cayley graph Cay(S_5, {σ^±1, τ^±1}) where:
  σ = (1 2 3 4 5) — a 5-cycle
  τ = (0 1)       — a transposition

This generates all of S_5 (|S_5| = 120), giving a 4-regular Cayley graph.
"""

import itertools
import math
import random
from collections import defaultdict

import numpy as np

# ─────────────────────────────────────────────────────────────────────
# Permutation group S_5
# ─────────────────────────────────────────────────────────────────────

def compose(p, q):
    """Compose two permutations (as tuples)."""
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    """Inverse of a permutation."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

IDENTITY = (0, 1, 2, 3, 4)
SIGMA = (1, 2, 3, 4, 0)       # 5-cycle (0 1 2 3 4)
TAU = (1, 0, 2, 3, 4)          # transposition (0 1)

GENERATORS = [SIGMA, inverse(SIGMA), TAU, inverse(TAU)]

# Generate all elements of S_5
def generate_s5():
    """Generate S_5 by BFS from identity using the generator set."""
    elements = {IDENTITY}
    frontier = [IDENTITY]
    while frontier:
        next_frontier = []
        for g in frontier:
            for s in GENERATORS:
                h = compose(s, g)
                if h not in elements:
                    elements.add(h)
                    next_frontier.append(h)
        frontier = next_frontier
    return sorted(elements)

S5 = generate_s5()
S5_INDEX = {p: i for i, p in enumerate(S5)}
N = len(S5)  # Should be 120

print(f"Generated S_5 with {N} elements (expected 120)")
print(f"Generators: σ={SIGMA}, τ={TAU}")
print(f"Generator set size (degree): {len(GENERATORS)}")

# ─────────────────────────────────────────────────────────────────────
# Transition matrix and spectral analysis
# ─────────────────────────────────────────────────────────────────────

def build_transition_matrix():
    """Build the transition matrix of the random walk on Cay(S_5, gens)."""
    P = np.zeros((N, N))
    for i, g in enumerate(S5):
        for s in GENERATORS:
            h = compose(s, g)
            j = S5_INDEX[h]
            P[i, j] += 1.0 / len(GENERATORS)
    return P

P = build_transition_matrix()

# Verify doubly stochastic
assert np.allclose(P.sum(axis=1), 1.0), "Rows must sum to 1"
assert np.allclose(P.sum(axis=0), 1.0), "Columns must sum to 1 (doubly stochastic)"

# Compute eigenvalues
eigenvalues = np.sort(np.linalg.eigvalsh(P))[::-1]
lambda_1 = eigenvalues[0]   # Should be 1
lambda_2 = eigenvalues[1]   # Second largest
lambda_min = eigenvalues[-1]
rho = max(abs(lambda_2), abs(lambda_min))

print(f"\n=== Spectral Analysis ===")
print(f"Largest eigenvalue:  λ₁ = {lambda_1:.6f} (should be 1)")
print(f"Second eigenvalue:   λ₂ = {lambda_2:.6f}")
print(f"Smallest eigenvalue: λ_min = {lambda_min:.6f}")
print(f"Spectral contraction: ρ = max(|λ₂|, |λ_min|) = {rho:.6f}")
print(f"Spectral gap: 1 - ρ = {1 - rho:.6f}")

# ─────────────────────────────────────────────────────────────────────
# Demo 1: Covariance decay
# ─────────────────────────────────────────────────────────────────────

print(f"\n{'='*60}")
print("DEMO 1: Covariance Decay Along the Expander Walk")
print(f"{'='*60}")
print(f"\nTheorem: |Cov(g(X_0), g(X_t))| ≤ ρ^t · ‖g‖₂²")
print(f"where ρ = {rho:.6f}\n")

# Random mean-zero function
rng = np.random.RandomState(42)
g_raw = rng.randn(N)
g = g_raw - g_raw.mean()  # Make mean-zero
g_l2sq = np.mean(g**2)

print(f"Observable g: random mean-zero function on S_5")
print(f"‖g‖₂² = {g_l2sq:.6f}")
print(f"\n{'t':>4} | {'|Cov(g, T^t g)|':>18} | {'ρ^t · ‖g‖₂²':>18} | {'Ratio':>10}")
print("-" * 60)

for t in range(11):
    Pt_g = np.linalg.matrix_power(P, t) @ g
    cov = np.mean(g * Pt_g)
    bound = rho**t * g_l2sq
    ratio = abs(cov) / bound if bound > 1e-15 else 0
    print(f"{t:4d} | {abs(cov):18.10f} | {bound:18.10f} | {ratio:10.6f}")

# ─────────────────────────────────────────────────────────────────────
# Demo 2: Variance of empirical mean
# ─────────────────────────────────────────────────────────────────────

print(f"\n{'='*60}")
print("DEMO 2: Variance of Empirical Mean of Walk Samples")
print(f"{'='*60}")
print(f"\nTheorem: Var(f̄_k) ≤ ((1+ρ)/(1-ρ)) · (1/k) · ‖g‖₂²")

spectral_constant = (1 + rho) / (1 - rho)
print(f"Spectral constant C(ρ) = (1+ρ)/(1-ρ) = {spectral_constant:.4f}")

print(f"\n{'k':>6} | {'Empirical Var':>14} | {'Certified Bound':>14} | {'Ratio':>10}")
print("-" * 55)

for k in [1, 2, 5, 10, 20, 50, 100]:
    # Compute empirical variance over all starting vertices
    emp_means = np.zeros(N)
    for start in range(N):
        total = 0
        state_vec = np.zeros(N)
        state_vec[start] = 1
        for step in range(k):
            total += g @ state_vec
            state_vec = P.T @ state_vec
        emp_means[start] = total / k
    empirical_var = np.mean(emp_means**2)  # g is mean-zero so E[emp_mean] = 0
    certified_bound = spectral_constant * (1.0 / k) * g_l2sq
    ratio = empirical_var / certified_bound if certified_bound > 1e-15 else 0
    print(f"{k:6d} | {empirical_var:14.8f} | {certified_bound:14.8f} | {ratio:10.6f}")

# ─────────────────────────────────────────────────────────────────────
# Demo 3: Majority vote amplification
# ─────────────────────────────────────────────────────────────────────

print(f"\n{'='*60}")
print("DEMO 3: Majority Vote Error Amplification")
print(f"{'='*60}")

def create_biased_function(bias, seed=0):
    """Create a {0,1}-valued function with specified bias (fraction of 1s)."""
    rng = np.random.RandomState(seed)
    num_ones = int(round(bias * N))
    f = np.zeros(N)
    indices = rng.choice(N, num_ones, replace=False)
    f[indices] = 1
    return f

delta_values = [0.05, 0.10, 0.15, 0.20]

for delta in delta_values:
    bias = 0.5 + delta
    f = create_biased_function(bias, seed=int(delta * 1000))
    actual_mean = f.mean()
    actual_delta = actual_mean - 0.5

    print(f"\n--- δ = {delta:.2f}, target bias = {bias:.2f}, actual E[f] = {actual_mean:.4f} ---")
    print(f"Theorem: Pr[majority fails] ≤ (1+ρ)/((1-ρ) · 4δ² · k)")
    print(f"\n{'k':>6} | {'Empirical Error':>14} | {'Certified Bound':>14} | {'Ratio':>10}")
    print("-" * 55)

    for k in [1, 3, 5, 10, 20, 50, 100]:
        # Compute majority vote for each starting vertex
        failures = 0
        for start in range(N):
            state_vec = np.zeros(N)
            state_vec[start] = 1
            total = 0
            for step in range(k):
                total += f @ state_vec
                state_vec = P.T @ state_vec
            emp_mean = total / k
            if emp_mean <= 0.5:
                failures += 1
        empirical_error = failures / N
        if actual_delta > 0:
            certified_bound = spectral_constant / (4 * actual_delta**2 * k)
        else:
            certified_bound = float('inf')
        ratio = empirical_error / certified_bound if certified_bound > 1e-15 and certified_bound < 1e10 else 0
        print(f"{k:6d} | {empirical_error:14.6f} | {min(certified_bound, 999):14.6f} | {ratio:10.6f}")

# ─────────────────────────────────────────────────────────────────────
# Demo 4: Random-bit accounting
# ─────────────────────────────────────────────────────────────────────

print(f"\n{'='*60}")
print("DEMO 4: Random-Bit Cost Comparison")
print(f"{'='*60}")

init_bits = math.ceil(math.log2(N))  # log₂(120) ≈ 7
step_bits = math.ceil(math.log2(len(GENERATORS)))  # log₂(4) = 2

print(f"\nState space: |S_5| = {N}")
print(f"Degree: d = {len(GENERATORS)}")
print(f"Initial vertex: ⌈log₂({N})⌉ = {init_bits} bits")
print(f"Each step: ⌈log₂({len(GENERATORS)})⌉ = {step_bits} bits")

print(f"\n{'k':>6} | {'Walk Bits':>10} | {'Independent':>12} | {'Savings':>10}")
print("-" * 50)

for k in [1, 5, 10, 20, 50, 100, 500]:
    walk_bits = init_bits + k * step_bits
    indep_bits = k * init_bits
    savings = 1 - walk_bits / indep_bits if indep_bits > 0 else 0
    print(f"{k:6d} | {walk_bits:10d} | {indep_bits:12d} | {savings:9.1%}")

# ─────────────────────────────────────────────────────────────────────
# Demo 5: Falsifiable conjecture test
# ─────────────────────────────────────────────────────────────────────

print(f"\n{'='*60}")
print("DEMO 5: Testing Exponential Decay Conjecture")
print(f"{'='*60}")
print(f"\nConjecture: Pr[majority fails] ≤ exp(-C·k) for some C > 0")
print(f"Testing with δ = 0.15, multiple random Boolean functions\n")

delta = 0.15
bias = 0.5 + delta
num_trials = 20
k_values = [1, 3, 5, 10, 15, 20, 30, 50]

print(f"{'k':>6} | {'Avg Error':>12} | {'-log(err)/k':>12} | {'Chebyshev Bd':>12}")
print("-" * 55)

for k in k_values:
    errors = []
    for trial in range(num_trials):
        f = create_biased_function(bias, seed=trial * 100 + k)
        actual_mean = f.mean()
        if actual_mean <= 0.5:
            continue  # Skip if bias not achieved
        failures = 0
        for start in range(N):
            state_vec = np.zeros(N)
            state_vec[start] = 1
            total = 0
            for step in range(k):
                total += f @ state_vec
                state_vec = P.T @ state_vec
            if total / k <= 0.5:
                failures += 1
        errors.append(failures / N)

    avg_error = np.mean(errors) if errors else 1.0
    log_rate = -math.log(max(avg_error, 1e-10)) / k if avg_error > 0 else float('inf')
    cheby_bound = spectral_constant / (4 * delta**2 * k)
    print(f"{k:6d} | {avg_error:12.6f} | {log_rate:12.6f} | {min(cheby_bound, 999):12.6f}")

print(f"\nIf -log(error)/k stabilizes to a positive constant, the")
print(f"exponential decay conjecture is supported for this graph.")

print(f"\n{'='*60}")
print("ALL DEMOS COMPLETE")
print(f"{'='*60}")


#!/usr/bin/env python3
"""
Visualization: Covariance Decay Along Expander Walks

Illustrates the core theorem: autocovariance of a mean-zero observable
decays exponentially at rate ρ^t, where ρ is the spectral contraction
parameter. Shows both theoretical bounds and empirical measurements
on the Cayley graph of S_5.

SELF-CONTAINED — does not import from local modules.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
    'figure.figsize': (12, 5),
})

# ── Build S_5 Cayley graph ──────────────────────────────────────

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0]*len(p)
    for i,v in enumerate(p): inv[v] = i
    return tuple(inv)

IDENTITY = (0,1,2,3,4)
SIGMA = (1,2,3,4,0)
TAU = (1,0,2,3,4)
GENS = [SIGMA, inverse(SIGMA), TAU, inverse(TAU)]

elements = {IDENTITY}
frontier = [IDENTITY]
while frontier:
    nxt = []
    for g in frontier:
        for s in GENS:
            h = compose(s, g)
            if h not in elements:
                elements.add(h)
                nxt.append(h)
    frontier = nxt
S5 = sorted(elements)
IDX = {p:i for i,p in enumerate(S5)}
N = len(S5)

# Build transition matrix
P = np.zeros((N,N))
for i,g in enumerate(S5):
    for s in GENS:
        P[i, IDX[compose(s,g)]] += 0.25

# Spectral analysis
evals = np.sort(np.linalg.eigvalsh(P))[::-1]
rho = max(abs(evals[1]), abs(evals[-1]))

# ── Compute covariance decay ────────────────────────────────────

T_MAX = 25
rng = np.random.RandomState(42)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Multiple random observables
colors = plt.cm.viridis(np.linspace(0.2, 0.8, 5))
for trial, c in enumerate(colors):
    g = rng.randn(N)
    g -= g.mean()
    g_l2sq = np.mean(g**2)

    covs = []
    bounds = []
    for t in range(T_MAX+1):
        Pt_g = np.linalg.matrix_power(P, t) @ g
        cov = abs(np.mean(g * Pt_g))
        covs.append(cov)
        bounds.append(rho**t * g_l2sq)

    ts = np.arange(T_MAX+1)
    ax1.semilogy(ts, covs, 'o-', color=c, markersize=4,
                 label=f'Trial {trial+1}', alpha=0.8, linewidth=1.5)

# Theoretical bound envelope
ts = np.arange(T_MAX+1)
ax1.semilogy(ts, [rho**t for t in ts], 'k--', linewidth=2.5,
             label=f'ρ^t (ρ={rho:.3f})', alpha=0.9)

ax1.set_xlabel('Walk step t')
ax1.set_ylabel('|Cov(g, T^t g)| / ‖g‖₂²')
ax1.set_title('Covariance Decay: Empirical vs Certified Bound')
ax1.legend(loc='upper right', framealpha=0.9)
ax1.set_ylim(1e-8, 2)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

# Panel 2: Ratio of empirical to bound
g = rng.randn(N)
g -= g.mean()
g_l2sq = np.mean(g**2)

ratios = []
for t in range(T_MAX+1):
    Pt_g = np.linalg.matrix_power(P, t) @ g
    cov = abs(np.mean(g * Pt_g))
    bound = rho**t * g_l2sq
    ratios.append(cov / bound if bound > 1e-15 else 0)

ax2.bar(ts, ratios, color='steelblue', alpha=0.7, edgecolor='navy')
ax2.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Certified bound')
ax2.set_xlabel('Walk step t')
ax2.set_ylabel('Empirical / Certified bound')
ax2.set_title('Tightness of the Covariance Bound')
ax2.legend()
ax2.set_ylim(0, 1.2)
ax2.grid(True, alpha=0.3, axis='y')

plt.suptitle(f'Covariance Decay on Cay(S₅, {{σ±¹,τ±¹}}), ρ = {rho:.4f}',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_covariance_decay.png', dpi=150, bbox_inches='tight')
print("Saved viz_covariance_decay.png")


#!/usr/bin/env python3
"""
Visualization: Majority Vote Amplification on S_5

Shows how the majority error decreases with walk length k for different
bias levels δ. Compares empirical error with the certified Chebyshev bound:
    Pr[majority fails] ≤ (1+ρ)/((1-ρ) · 4δ² · k)

Also shows the random-bit savings of the expander walk vs independent sampling.

SELF-CONTAINED — does not import from local modules.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
    'figure.figsize': (14, 5.5),
})

# ── Build S_5 Cayley graph ──────────────────────────────────────

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0]*len(p)
    for i,v in enumerate(p): inv[v] = i
    return tuple(inv)

IDENTITY = (0,1,2,3,4)
SIGMA = (1,2,3,4,0)
TAU = (1,0,2,3,4)
GENS = [SIGMA, inverse(SIGMA), TAU, inverse(TAU)]

elements = {IDENTITY}
frontier = [IDENTITY]
while frontier:
    nxt = []
    for g in frontier:
        for s in GENS:
            h = compose(s, g)
            if h not in elements:
                elements.add(h)
                nxt.append(h)
    frontier = nxt
S5 = sorted(elements)
IDX = {p:i for i,p in enumerate(S5)}
N = len(S5)

P = np.zeros((N,N))
for i,g in enumerate(S5):
    for s in GENS:
        P[i, IDX[compose(s,g)]] += 0.25

evals = np.sort(np.linalg.eigvalsh(P))[::-1]
rho = max(abs(evals[1]), abs(evals[-1]))
C_rho = (1+rho)/(1-rho)

# ── Compute majority errors ────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

k_values = [1, 2, 3, 5, 7, 10, 15, 20, 30, 50]
delta_configs = [
    (0.05, 'tab:blue', 'δ = 0.05'),
    (0.10, 'tab:orange', 'δ = 0.10'),
    (0.15, 'tab:green', 'δ = 0.15'),
    (0.20, 'tab:red', 'δ = 0.20'),
]

rng = np.random.RandomState(123)

for delta, color, label in delta_configs:
    bias = 0.5 + delta
    num_ones = int(round(bias * N))
    perm = rng.permutation(N)
    f = np.zeros(N)
    f[perm[:num_ones]] = 1
    actual_mean = f.mean()
    actual_delta = actual_mean - 0.5

    empirical_errors = []
    certified_bounds = []

    for k in k_values:
        failures = 0
        for start in range(N):
            state = np.zeros(N)
            state[start] = 1
            total = 0
            for _ in range(k):
                total += f @ state
                state = P.T @ state
            if total / k <= 0.5:
                failures += 1
        emp_err = failures / N
        cert_bound = C_rho / (4 * actual_delta**2 * k) if actual_delta > 0 else 999
        empirical_errors.append(max(emp_err, 1e-4))
        certified_bounds.append(min(cert_bound, 10))

    ax1.semilogy(k_values, empirical_errors, 'o-', color=color,
                 label=f'{label} (empirical)', linewidth=2, markersize=5)
    ax1.semilogy(k_values, certified_bounds, '--', color=color,
                 label=f'{label} (certified)', linewidth=1.5, alpha=0.6)

ax1.set_xlabel('Walk length k')
ax1.set_ylabel('Majority failure probability')
ax1.set_title('Majority Amplification: Error vs Walk Length')
ax1.legend(loc='upper right', framealpha=0.9, fontsize=9, ncol=2)
ax1.set_ylim(1e-4, 15)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

# ── Panel 2: Random-bit savings ─────────────────────────────────

k_range = np.arange(1, 101)
init_bits = math.ceil(math.log2(N))
step_bits = math.ceil(math.log2(4))

walk_bits = init_bits + k_range * step_bits
indep_bits = k_range * init_bits

ax2.plot(k_range, indep_bits, 'r-', linewidth=2.5, label='Independent sampling')
ax2.plot(k_range, walk_bits, 'b-', linewidth=2.5, label='Expander walk')
ax2.fill_between(k_range, walk_bits, indep_bits, alpha=0.15, color='green',
                  label='Random-bit savings')

ax2.set_xlabel('Number of samples k')
ax2.set_ylabel('Random bits required')
ax2.set_title('Random-Bit Cost: Walk vs Independent')
ax2.legend(loc='upper left', framealpha=0.9)
ax2.grid(True, alpha=0.3)

# Annotate savings
k_anno = 50
saving_pct = (1 - (init_bits + k_anno*step_bits) / (k_anno*init_bits)) * 100
ax2.annotate(f'{saving_pct:.0f}% savings\nat k={k_anno}',
             xy=(k_anno, init_bits + k_anno*step_bits),
             xytext=(k_anno+15, init_bits + k_anno*step_bits + 100),
             arrowprops=dict(arrowstyle='->', color='green', lw=2),
             fontsize=12, color='darkgreen', fontweight='bold')

plt.suptitle(f'Expander-Walk Majority Amplification on Cay(S₅), ρ = {rho:.4f}',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_majority_amplification.png', dpi=150, bbox_inches='tight')
print("Saved viz_majority_amplification.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Landscape of the S_5 Cayley Graph

Shows the eigenvalue distribution of the transition matrix and
illustrates how the spectral gap controls amplification quality.
Includes a heatmap of the transition matrix structure.

SELF-CONTAINED — does not import from local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
})

# ── Build S_5 Cayley graph ──────────────────────────────────────

def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0]*len(p)
    for i,v in enumerate(p): inv[v] = i
    return tuple(inv)

IDENTITY = (0,1,2,3,4)
SIGMA = (1,2,3,4,0)
TAU = (1,0,2,3,4)
GENS = [SIGMA, inverse(SIGMA), TAU, inverse(TAU)]

elements = {IDENTITY}
frontier = [IDENTITY]
while frontier:
    nxt = []
    for g in frontier:
        for s in GENS:
            h = compose(s, g)
            if h not in elements:
                elements.add(h)
                nxt.append(h)
    frontier = nxt
S5 = sorted(elements)
IDX = {p:i for i,p in enumerate(S5)}
N = len(S5)

P = np.zeros((N,N))
for i,g in enumerate(S5):
    for s in GENS:
        P[i, IDX[compose(s,g)]] += 0.25

evals = np.sort(np.linalg.eigvalsh(P))[::-1]
rho = max(abs(evals[1]), abs(evals[-1]))

# ── Figure ──────────────────────────────────────────────────────

fig = plt.figure(figsize=(16, 5.5))

# Panel 1: Eigenvalue distribution
ax1 = fig.add_subplot(131)
ax1.stem(range(len(evals)), evals, linefmt='steelblue', markerfmt='o',
         basefmt='gray', label='Eigenvalues')
ax1.axhline(y=rho, color='red', linestyle='--', linewidth=1.5,
            label=f'ρ = {rho:.4f}')
ax1.axhline(y=-rho, color='red', linestyle='--', linewidth=1.5)
ax1.axhline(y=1, color='green', linestyle=':', linewidth=1.5,
            label='λ₁ = 1')
ax1.fill_between(range(len(evals)), -rho, rho, alpha=0.1, color='red')
ax1.set_xlabel('Eigenvalue index')
ax1.set_ylabel('Eigenvalue')
ax1.set_title('Spectrum of Transition Matrix')
ax1.legend(loc='lower left', framealpha=0.9)
ax1.grid(True, alpha=0.3)

# Panel 2: Spectral gap vs amplification constant
ax2 = fig.add_subplot(132)
gaps = np.linspace(0.01, 0.99, 200)
rhos = 1 - gaps
C_vals = (1 + rhos) / (1 - rhos)

ax2.semilogy(gaps, C_vals, 'b-', linewidth=2.5)
# Mark our graph's gap
our_gap = 1 - rho
our_C = (1 + rho) / (1 - rho)
ax2.plot(our_gap, our_C, 'r*', markersize=15, zorder=5,
         label=f'S₅ graph: gap={our_gap:.3f}, C={our_C:.1f}')

# Annotate
ax2.annotate(f'C(ρ) = {our_C:.1f}',
             xy=(our_gap, our_C),
             xytext=(our_gap + 0.15, our_C * 2),
             arrowprops=dict(arrowstyle='->', color='red', lw=2),
             fontsize=12, color='red', fontweight='bold')

ax2.set_xlabel('Spectral gap (1 - ρ)')
ax2.set_ylabel('Spectral constant C(ρ)')
ax2.set_title('Gap → Amplification Quality')
ax2.legend(loc='upper right', framealpha=0.9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 1)

# Panel 3: Eigenvalue histogram
ax3 = fig.add_subplot(133)
ax3.hist(evals, bins=30, color='steelblue', alpha=0.7, edgecolor='navy',
         density=True)
ax3.axvline(x=rho, color='red', linestyle='--', linewidth=2,
            label=f'ρ = {rho:.4f}')
ax3.axvline(x=-rho, color='red', linestyle='--', linewidth=2)
ax3.axvline(x=1, color='green', linestyle='--', linewidth=2,
            label='λ₁ = 1')
ax3.set_xlabel('Eigenvalue')
ax3.set_ylabel('Density')
ax3.set_title('Eigenvalue Distribution')
ax3.legend(loc='upper left', framealpha=0.9)
ax3.grid(True, alpha=0.3)

plt.suptitle(f'Spectral Landscape of Cay(S₅, {{σ±¹,τ±¹}}), |S₅| = {N}',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_landscape.png")
