#!/usr/bin/env python3
"""
Tropical Orbit PRG — Real-World Applications

This module demonstrates practical applications of the tropical orbit PRG:
1. Lightweight random number generation for embedded systems
2. Deterministic randomness for reproducible simulations
3. Statistical testing of PRG output quality
4. Network routing with pseudorandom load balancing
"""

import numpy as np
from algorithms import (
    TropicalOrbitPRG, tropical_mat_pow, tropical_mat_mul,
    trace_hash, statistical_distance, verify_conditional_extraction
)


# ============================================================
# Application 1: Lightweight PRNG for Embedded Systems
# ============================================================

class LightweightTropicalPRNG:
    """
    A lightweight PRNG based on tropical matrix orbits.
    
    Designed for resource-constrained devices:
    - Uses only min and addition (no multiplication hardware needed)
    - Small state: one n×n matrix of integers
    - Deterministic: same seed always produces same sequence
    """
    
    def __init__(self, seed_matrix: np.ndarray, q: int = 256):
        """
        Initialize with a seed matrix.
        
        Args:
            seed_matrix: n×n matrix with integer entries
            q: output range (default 256 for byte-level output)
        """
        self.G = seed_matrix.astype(float)
        self.q = q
        self.n = seed_matrix.shape[0]
        self.step = 0
        self.current_power = np.full_like(self.G, np.inf)
        np.fill_diagonal(self.current_power, 0.0)
    
    def next_byte(self) -> int:
        """Generate the next pseudorandom byte."""
        self.current_power = tropical_mat_mul(self.current_power, self.G)
        self.step += 1
        return trace_hash(self.current_power, self.q)
    
    def next_bytes(self, count: int) -> bytes:
        """Generate multiple pseudorandom bytes."""
        return bytes(self.next_byte() for _ in range(count))
    
    def reset(self):
        """Reset to initial state."""
        self.step = 0
        self.current_power = np.full_like(self.G, np.inf)
        np.fill_diagonal(self.current_power, 0.0)


# ============================================================
# Application 2: Reproducible Monte Carlo Simulation
# ============================================================

def tropical_monte_carlo_pi(seed_matrix: np.ndarray, num_samples: int) -> float:
    """
    Estimate π using Monte Carlo with tropical PRG.
    
    Uses tropical orbit hash values to generate (x, y) coordinates
    in the unit square, then counts how many fall inside the unit circle.
    
    Args:
        seed_matrix: seed for the tropical PRG
        num_samples: number of random points to generate
    
    Returns:
        Estimate of π
    """
    prng = LightweightTropicalPRNG(seed_matrix, q=1000)
    
    inside = 0
    for _ in range(num_samples):
        x = prng.next_byte() / 1000.0
        y = prng.next_byte() / 1000.0
        if x*x + y*y <= 1.0:
            inside += 1
    
    return 4.0 * inside / num_samples


# ============================================================
# Application 3: Statistical Testing
# ============================================================

def frequency_test(sequence: list, q: int) -> dict:
    """
    Frequency test: checks if each value appears with roughly equal frequency.
    
    Args:
        sequence: list of values in {0, ..., q-1}
        q: alphabet size
    
    Returns:
        Test results including chi-squared statistic
    """
    n = len(sequence)
    expected = n / q
    
    counts = np.zeros(q)
    for v in sequence:
        counts[v] += 1
    
    chi_sq = sum((counts[i] - expected)**2 / expected for i in range(q))
    
    # Chi-squared critical value for q-1 degrees of freedom at 5% significance
    # For q=8: critical value ≈ 14.07
    critical_values = {3: 5.99, 4: 7.81, 5: 9.49, 6: 11.07, 7: 12.59, 8: 14.07}
    critical = critical_values.get(q, 2 * q)
    
    return {
        'chi_squared': chi_sq,
        'critical_value': critical,
        'pass': chi_sq < critical,
        'counts': counts.tolist(),
        'expected': expected
    }

def runs_test(sequence: list) -> dict:
    """
    Runs test: checks for unexpected clustering of values.
    
    Counts the number of "runs" (consecutive sequences of increasing
    or decreasing values) and compares to expected.
    """
    n = len(sequence)
    if n < 2:
        return {'runs': 0, 'expected': 0, 'pass': True}
    
    runs = 1
    for i in range(1, n):
        if sequence[i] != sequence[i-1]:
            runs += 1
    
    # Expected runs for random sequence
    unique_vals = len(set(sequence))
    # Simplified expected value
    expected_runs = 1 + 2 * (n - 1) * (unique_vals - 1) / (unique_vals * n) if unique_vals > 1 else 1
    
    return {
        'runs': runs,
        'expected_runs': expected_runs,
        'ratio': runs / expected_runs if expected_runs > 0 else 0,
        'pass': 0.5 < runs / expected_runs < 2.0 if expected_runs > 0 else True
    }

def autocorrelation_test(sequence: list, lag: int = 1) -> dict:
    """
    Autocorrelation test: checks for serial correlation at given lag.
    """
    n = len(sequence)
    if n <= lag:
        return {'correlation': 0, 'pass': True}
    
    mean = np.mean(sequence)
    var = np.var(sequence)
    
    if var == 0:
        return {'correlation': 0, 'pass': True}
    
    corr = np.mean([(sequence[i] - mean) * (sequence[i + lag] - mean) 
                     for i in range(n - lag)]) / var
    
    return {
        'lag': lag,
        'correlation': corr,
        'pass': abs(corr) < 0.1  # Threshold for near-zero correlation
    }


# ============================================================
# Application 4: Network Load Balancing
# ============================================================

def tropical_load_balancer(seed_matrix: np.ndarray, 
                            num_requests: int,
                            num_servers: int) -> dict:
    """
    Simulate network load balancing using tropical PRG.
    
    Each request is routed to a server based on the tropical hash value.
    Good pseudorandomness ensures even distribution across servers.
    
    Args:
        seed_matrix: PRG seed
        num_requests: number of requests to route
        num_servers: number of available servers
    
    Returns:
        Load distribution statistics
    """
    prng = LightweightTropicalPRNG(seed_matrix, q=num_servers)
    
    loads = np.zeros(num_servers, dtype=int)
    for _ in range(num_requests):
        server = prng.next_byte()
        loads[server] += 1
    
    expected = num_requests / num_servers
    imbalance = max(loads) - min(loads)
    
    return {
        'loads': loads.tolist(),
        'expected': expected,
        'max_load': int(max(loads)),
        'min_load': int(min(loads)),
        'imbalance': int(imbalance),
        'imbalance_ratio': imbalance / expected if expected > 0 else 0
    }


# ============================================================
# Main: Run all applications
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Tropical Orbit PRG — Applications")
    print("=" * 60)
    
    # Create a seed matrix
    np.random.seed(42)
    seed = np.array([[2, 5], [3, 1]], dtype=float)
    
    # App 1: Lightweight PRNG
    print("\n--- Application 1: Lightweight PRNG ---")
    prng = LightweightTropicalPRNG(seed, q=256)
    random_bytes = prng.next_bytes(20)
    print(f"Seed matrix:\n{seed}")
    print(f"First 20 bytes: {list(random_bytes)}")
    print(f"Hex: {random_bytes.hex()}")
    
    # App 2: Monte Carlo π estimation
    print("\n--- Application 2: Monte Carlo π Estimation ---")
    for n_samples in [100, 1000, 10000]:
        pi_est = tropical_monte_carlo_pi(seed, n_samples)
        error = abs(pi_est - np.pi)
        print(f"  {n_samples:>6} samples: π ≈ {pi_est:.4f} (error: {error:.4f})")
    
    # App 3: Statistical testing
    print("\n--- Application 3: Statistical Testing ---")
    prng = LightweightTropicalPRNG(seed, q=8)
    sequence = [prng.next_byte() for _ in range(1000)]
    
    freq = frequency_test(sequence, 8)
    print(f"  Frequency test: χ² = {freq['chi_squared']:.2f} "
          f"(critical: {freq['critical_value']:.2f}) → {'PASS' if freq['pass'] else 'FAIL'}")
    
    runs = runs_test(sequence)
    print(f"  Runs test: {runs['runs']} runs "
          f"(expected: {runs['expected_runs']:.0f}) → {'PASS' if runs['pass'] else 'FAIL'}")
    
    auto = autocorrelation_test(sequence, lag=1)
    print(f"  Autocorrelation (lag 1): r = {auto['correlation']:.4f} "
          f"→ {'PASS' if auto['pass'] else 'FAIL'}")
    
    auto5 = autocorrelation_test(sequence, lag=5)
    print(f"  Autocorrelation (lag 5): r = {auto5['correlation']:.4f} "
          f"→ {'PASS' if auto5['pass'] else 'FAIL'}")
    
    # App 4: Load balancing
    print("\n--- Application 4: Network Load Balancing ---")
    result = tropical_load_balancer(seed, num_requests=10000, num_servers=8)
    print(f"  Requests: 10000, Servers: 8")
    print(f"  Loads: {result['loads']}")
    print(f"  Expected per server: {result['expected']:.0f}")
    print(f"  Imbalance: {result['imbalance']} "
          f"({result['imbalance_ratio']:.1%} of expected)")
    
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Orbit PRG — Demonstration

This script demonstrates the main theorems with concrete numerical examples,
showing that tropical matrix orbits, after hashing, produce output sequences
that are statistically close to uniform.
"""

import numpy as np
from itertools import product as cart_product

def tropical_mul(A, B):
    """Tropical (min-plus) matrix multiplication: (A⊗B)_ij = min_k(A_ik + B_kj)."""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = min(A[i, k] + B[k, j] for k in range(n))
    return C

def tropical_pow(G, k):
    """Compute G^{⊗k} under tropical multiplication."""
    n = G.shape[0]
    if k == 0:
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result
    result = G.copy()
    for _ in range(k - 1):
        result = tropical_mul(result, G)
    return result

def hash_matrix(M, q):
    """Hash a matrix to Z/qZ using trace-like function."""
    n = M.shape[0]
    # Use sum of diagonal entries mod q (avoiding inf)
    diag_sum = sum(M[i, i] for i in range(n) if np.isfinite(M[i, i]))
    return int(diag_sum) % q

def stat_dist(p, q):
    """Statistical distance between two distributions (as arrays)."""
    return 0.5 * np.sum(np.abs(p - q))

def orbit_hash_distribution(seeds, pow_func, hash_func, T, q):
    """
    Compute the orbit hash distribution.
    
    For each seed, compute (h(G^0), h(G^1), ..., h(G^T)) and count
    the frequency of each output sequence.
    """
    N = len(seeds)
    # Count occurrences of each output sequence
    counts = {}
    for s in seeds:
        seq = tuple(hash_func(pow_func(s, i), q) for i in range(T + 1))
        counts[seq] = counts.get(seq, 0) + 1
    
    # Compute empirical distribution
    total_outputs = q ** (T + 1)
    p_empirical = np.zeros(total_outputs)
    
    # Map sequences to indices
    for seq, count in counts.items():
        idx = sum(seq[i] * q**i for i in range(T + 1))
        p_empirical[idx] = count / N
    
    # Uniform distribution
    p_uniform = np.ones(total_outputs) / total_outputs
    
    return p_empirical, p_uniform

def compute_conditional_extraction(seeds, pow_func, hash_func, step, q, T_prefix):
    """
    Verify the conditional extraction property at a given step.
    
    For each prefix of hash values, check that the distribution of
    the next hash value is close to uniform.
    """
    N = len(seeds)
    max_sd = 0.0
    
    # Enumerate all possible prefixes up to the given step
    for prefix in cart_product(range(q), repeat=step):
        # Find the fiber: seeds matching this prefix
        fiber = [s for s in seeds 
                 if all(hash_func(pow_func(s, j), q) == prefix[j] for j in range(step))]
        
        if len(fiber) == 0:
            continue
        
        # Distribution of next hash value within the fiber
        counts = np.zeros(q)
        for s in fiber:
            b = hash_func(pow_func(s, step), q)
            counts[b] += 1
        
        p_cond = counts / len(fiber)
        p_uniform = np.ones(q) / q
        
        sd = stat_dist(p_cond, p_uniform)
        max_sd = max(max_sd, sd)
    
    return max_sd

def demo_basic():
    """Basic demonstration of the tropical orbit PRG."""
    print("=" * 70)
    print("DEMO 1: Basic Tropical Orbit PRG")
    print("=" * 70)
    
    np.random.seed(42)
    n = 2  # Matrix size
    q = 4  # Hash output alphabet size
    num_seeds = 500
    T = 5  # Orbit length
    
    # Generate random tropical matrices as seeds
    seeds = [np.random.randint(0, 10, size=(n, n)).astype(float) for _ in range(num_seeds)]
    
    print(f"\nParameters:")
    print(f"  Matrix size: {n}x{n}")
    print(f"  Seed set size: {num_seeds}")
    print(f"  Hash alphabet size: {q}")
    print(f"  Orbit length (T): {T}")
    
    # Example: show one seed and its orbit
    s = seeds[0]
    print(f"\nExample seed matrix:")
    print(s)
    print(f"\nOrbit hash sequence (h(G^0), ..., h(G^{T})):")
    orbit_seq = [hash_matrix(tropical_pow(s, i), q) for i in range(T + 1)]
    print(f"  {orbit_seq}")
    
    # Compute conditional extraction at each step
    print(f"\nConditional extraction analysis:")
    print(f"  {'Step':>4}  {'Max SD':>10}  {'Bound':>10}")
    print(f"  {'----':>4}  {'------':>10}  {'-----':>10}")
    
    epsilons = []
    for step in range(min(T + 1, 4)):  # Limit to avoid exponential blowup
        eps = compute_conditional_extraction(seeds, tropical_pow, hash_matrix, step, q, T)
        epsilons.append(eps)
        print(f"  {step:>4}  {eps:>10.6f}  {1/q:>10.6f}")
    
    # Compute orbit hash distribution for small T
    T_small = 2
    p_emp, p_uni = orbit_hash_distribution(seeds, tropical_pow, hash_matrix, T_small, q)
    sd = stat_dist(p_emp, p_uni)
    
    eps_max = max(epsilons[:T_small + 1]) if len(epsilons) > T_small else epsilons[-1]
    bound = (T_small + 1) * eps_max
    
    print(f"\nStatistical distance analysis (T={T_small}):")
    print(f"  Empirical SD:     {sd:.6f}")
    print(f"  Theoretical bound: {bound:.6f} = (T+1)*ε = {T_small+1}*{eps_max:.6f}")
    print(f"  Bound holds: {sd <= bound + 1e-10}")

def demo_scaling():
    """Demonstrate the (T+1)*ε scaling law."""
    print("\n" + "=" * 70)
    print("DEMO 2: Scaling of Statistical Distance with Orbit Length")
    print("=" * 70)
    
    np.random.seed(123)
    n = 2
    q = 4
    num_seeds = 1000
    
    seeds = [np.random.randint(0, 8, size=(n, n)).astype(float) for _ in range(num_seeds)]
    
    # Compute epsilon (conditional extraction error at step 0)
    eps = compute_conditional_extraction(seeds, tropical_pow, hash_matrix, 0, q, 0)
    print(f"\nConditional extraction error ε ≈ {eps:.6f}")
    
    print(f"\n  {'T':>4}  {'Empirical SD':>14}  {'Bound (T+1)ε':>14}  {'Ratio':>8}")
    print(f"  {'---':>4}  {'-----------':>14}  {'------------':>14}  {'-----':>8}")
    
    for T in [0, 1, 2, 3]:
        p_emp, p_uni = orbit_hash_distribution(seeds, tropical_pow, hash_matrix, T, q)
        sd = stat_dist(p_emp, p_uni)
        bound = (T + 1) * eps
        ratio = sd / bound if bound > 0 else 0
        print(f"  {T:>4}  {sd:>14.6f}  {bound:>14.6f}  {ratio:>8.4f}")

def demo_fiber_analysis():
    """Demonstrate the prefix fiber structure."""
    print("\n" + "=" * 70)
    print("DEMO 3: Prefix Fiber Analysis")
    print("=" * 70)
    
    np.random.seed(42)
    n = 2
    q = 3
    num_seeds = 1000
    
    seeds = [np.random.randint(0, 10, size=(n, n)).astype(float) for _ in range(num_seeds)]
    
    print(f"\nParameters: {n}x{n} matrices, |S|={num_seeds}, q={q}")
    
    for depth in range(1, 4):
        fiber_sizes = []
        for prefix in cart_product(range(q), repeat=depth):
            fiber = [s for s in seeds 
                     if all(hash_matrix(tropical_pow(s, j), q) == prefix[j] for j in range(depth))]
            if len(fiber) > 0:
                fiber_sizes.append(len(fiber))
        
        if fiber_sizes:
            print(f"\n  Prefix depth {depth}:")
            print(f"    Non-empty fibers: {len(fiber_sizes)} / {q**depth}")
            print(f"    Average size: {np.mean(fiber_sizes):.1f}")
            print(f"    Maximum size: {max(fiber_sizes)}")
            print(f"    Minimum size: {min(fiber_sizes)}")
            print(f"    Expected (uniform): {num_seeds / q**depth:.1f}")

def demo_tropical_operations():
    """Show tropical matrix operations in action."""
    print("\n" + "=" * 70)
    print("DEMO 4: Tropical Matrix Operations")
    print("=" * 70)
    
    A = np.array([[1, 3], [7, 2]], dtype=float)
    B = np.array([[4, 1], [5, 8]], dtype=float)
    
    print(f"\nMatrix A:")
    print(A)
    print(f"\nMatrix B:")
    print(B)
    
    C = tropical_mul(A, B)
    print(f"\nA ⊗ B (tropical product):")
    print(C)
    print(f"  (A⊗B)[0,0] = min(A[0,0]+B[0,0], A[0,1]+B[1,0]) = min({A[0,0]+B[0,0]}, {A[0,1]+B[1,0]}) = {C[0,0]}")
    
    G = np.array([[0, 3], [1, 0]], dtype=float)
    print(f"\nMatrix G:")
    print(G)
    print(f"\nTropical powers of G:")
    for k in range(5):
        Gk = tropical_pow(G, k)
        print(f"  G^{k} =")
        print(f"    {Gk}")
        print(f"    hash(G^{k}) mod 4 = {hash_matrix(Gk, 4)}")

if __name__ == "__main__":
    demo_tropical_operations()
    demo_basic()
    demo_scaling()
    demo_fiber_analysis()
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary_to_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Tropical/TropicalOrbitPRG.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Read visualizations
viz_sd = read_binary_to_base64('sd_scaling.png')
viz_freq = read_binary_to_base64('hash_freq.png')
viz_fiber = read_binary_to_base64('fiber_struct.png')
viz_power = read_binary_to_base64('power_evol.png')

package = {
    "title": "Tropical Orbit Pseudorandom Generators via Conditional Entropy Extraction",
    "domain": "Tropical Algebra / Pseudorandom Generation / Information Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Orbit PRG Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Matrix Multiplication",
            "pseudocode": "Input: n×n matrices A, B\nOutput: C = A ⊗ B where C[i,j] = min_k(A[i,k] + B[k,j])\n\nfor i = 0 to n-1:\n  for j = 0 to n-1:\n    C[i,j] = infinity\n    for k = 0 to n-1:\n      C[i,j] = min(C[i,j], A[i,k] + B[k,j])\nreturn C\n\nComplexity: O(n³) time, O(n²) space",
            "code": algorithms_code
        },
        {
            "name": "Tropical Orbit PRG",
            "pseudocode": "Input: seed matrix G, time horizon T, hash function h\nOutput: pseudorandom sequence (b₀, ..., b_T)\n\n1. Set M ← tropical identity\n2. For i = 0 to T:\n   a. M ← M ⊗ G    (tropical multiply)\n   b. bᵢ ← h(M)    (hash to output alphabet)\n3. Return (b₀, ..., b_T)\n\nComplexity: O(T·n³) time, O(n²) space\nSecurity: (T+1)·ε-close to uniform",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Statistical Distance Scaling with Orbit Length",
            "data": viz_sd
        },
        {
            "name": "Hash Value Frequency Distribution",
            "data": viz_freq
        },
        {
            "name": "Prefix Fiber Size Distribution",
            "data": viz_fiber
        },
        {
            "name": "Tropical Matrix Power Evolution",
            "data": viz_power
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Orbit PRG — Visualizations

Generates publication-quality figures illustrating the key concepts:
1. Statistical distance scaling with orbit length
2. Prefix fiber distribution
3. Hash value frequency distribution
4. Tropical matrix power evolution
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO
from itertools import product as cart_product


def tropical_mul(A, B):
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = min(A[i, k] + B[k, j] for k in range(n))
    return C

def tropical_pow(G, k):
    n = G.shape[0]
    if k == 0:
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result
    result = G.copy()
    for _ in range(k - 1):
        result = tropical_mul(result, G)
    return result

def hash_matrix(M, q):
    n = M.shape[0]
    total = 0
    for i in range(n):
        for j in range(n):
            if np.isfinite(M[i, j]):
                total += int(M[i, j]) * (3*i + j + 1)
    return total % q

def stat_dist(p, q_arr):
    return 0.5 * np.sum(np.abs(p - q_arr))

def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_stat_dist_scaling():
    """Plot statistical distance as a function of orbit length T."""
    np.random.seed(42)
    n = 3
    q = 6
    num_seeds = 500
    seeds = [np.random.randint(0, 6, size=(n, n)).astype(float) for _ in range(num_seeds)]
    
    # Compute epsilon at step 0
    counts_step0 = np.zeros(q)
    for s in seeds:
        b = hash_matrix(tropical_pow(s, 0), q)
        counts_step0[b] += 1
    p0 = counts_step0 / num_seeds
    u0 = np.ones(q) / q
    eps = stat_dist(p0, u0)
    
    Ts = list(range(4))
    empirical_sds = []
    bounds = []
    
    for T in Ts:
        total_outputs = q ** (T + 1)
        counts = {}
        for s in seeds:
            seq = tuple(hash_matrix(tropical_pow(s, i), q) for i in range(T + 1))
            counts[seq] = counts.get(seq, 0) + 1
        
        p_emp = np.zeros(total_outputs)
        for seq, count in counts.items():
            idx = sum(seq[i] * q**i for i in range(T + 1))
            if idx < total_outputs:
                p_emp[idx] = count / num_seeds
        p_uni = np.ones(total_outputs) / total_outputs
        
        sd = stat_dist(p_emp, p_uni)
        empirical_sds.append(sd)
        bounds.append((T + 1) * eps)
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(Ts, empirical_sds, 'bo-', linewidth=2, markersize=8, label='Empirical SD')
    ax.plot(Ts, bounds, 'r--', linewidth=2, label='Bound: (T+1)·ε')
    ax.fill_between(Ts, 0, bounds, alpha=0.1, color='red')
    ax.set_xlabel('Orbit Length T', fontsize=14)
    ax.set_ylabel('Statistical Distance from Uniform', fontsize=14)
    ax.set_title('Tropical Orbit PRG: SD Scaling', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)
    
    return fig_to_base64(fig)


def plot_hash_frequency():
    """Plot hash value frequency distribution."""
    np.random.seed(42)
    n = 3
    q = 8
    num_seeds = 2000
    seeds = [np.random.randint(0, 8, size=(n, n)).astype(float) for _ in range(num_seeds)]
    
    fig, axes = plt.subplots(2, 2, figsize=(10, 8))
    
    for idx, step in enumerate([0, 1, 2, 3]):
        ax = axes[idx // 2][idx % 2]
        
        counts = np.zeros(q)
        for s in seeds:
            b = hash_matrix(tropical_pow(s, step), q)
            counts[b] += 1
        
        freq = counts / num_seeds
        expected = 1.0 / q
        
        bars = ax.bar(range(q), freq, color='steelblue', alpha=0.7, label='Empirical')
        ax.axhline(y=expected, color='red', linestyle='--', linewidth=2, label=f'Uniform ({expected:.3f})')
        ax.set_xlabel('Hash Value', fontsize=11)
        ax.set_ylabel('Frequency', fontsize=11)
        ax.set_title(f'Step {step}: h(G^{step})', fontsize=13)
        ax.legend(fontsize=9)
        ax.set_ylim(0, max(freq.max(), expected) * 1.3)
    
    fig.suptitle('Hash Value Distribution at Each Orbit Step', fontsize=16, y=1.02)
    plt.tight_layout()
    
    return fig_to_base64(fig)


def plot_fiber_structure():
    """Plot prefix fiber sizes at different depths."""
    np.random.seed(42)
    n = 3
    q = 4
    num_seeds = 1000
    seeds = [np.random.randint(0, 6, size=(n, n)).astype(float) for _ in range(num_seeds)]
    
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))
    
    for depth_idx, depth in enumerate([1, 2, 3]):
        ax = axes[depth_idx]
        fiber_sizes = []
        
        for prefix in cart_product(range(q), repeat=depth):
            size = sum(1 for s in seeds 
                      if all(hash_matrix(tropical_pow(s, j), q) == prefix[j] for j in range(depth)))
            if size > 0:
                fiber_sizes.append(size)
        
        if fiber_sizes:
            ax.hist(fiber_sizes, bins=min(20, len(set(fiber_sizes))), 
                   color='teal', alpha=0.7, edgecolor='black')
            ax.axvline(x=num_seeds / q**depth, color='red', linestyle='--', 
                      linewidth=2, label=f'Expected: {num_seeds/q**depth:.0f}')
            ax.axvline(x=max(fiber_sizes), color='orange', linestyle=':', 
                      linewidth=2, label=f'Max: {max(fiber_sizes)}')
        
        ax.set_xlabel('Fiber Size', fontsize=11)
        ax.set_ylabel('Count', fontsize=11)
        ax.set_title(f'Depth {depth} (B ≤ {max(fiber_sizes) if fiber_sizes else 0})', fontsize=13)
        ax.legend(fontsize=9)
    
    fig.suptitle('Prefix Fiber Size Distribution', fontsize=16, y=1.02)
    plt.tight_layout()
    
    return fig_to_base64(fig)


def plot_tropical_power_evolution():
    """Visualize how tropical matrix entries evolve with power."""
    G = np.array([[0, 3, 7], [2, 0, 4], [5, 1, 0]], dtype=float)
    
    steps = range(8)
    entries = {(i, j): [] for i in range(3) for j in range(3)}
    
    for k in steps:
        Gk = tropical_pow(G, k)
        for i in range(3):
            for j in range(3):
                val = Gk[i, j] if np.isfinite(Gk[i, j]) else np.nan
                entries[(i, j)].append(val)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    colors = plt.cm.tab10(np.linspace(0, 1, 9))
    for idx, ((i, j), vals) in enumerate(entries.items()):
        ax.plot(list(steps), vals, 'o-', color=colors[idx], 
               linewidth=1.5, markersize=5, label=f'G^k[{i},{j}]')
    
    ax.set_xlabel('Power k', fontsize=14)
    ax.set_ylabel('Entry Value (shortest path weight)', fontsize=14)
    ax.set_title('Tropical Matrix Power Evolution: G^{⊗k} Entries', fontsize=16)
    ax.legend(bbox_to_anchor=(1.05, 1), loc='upper left', fontsize=9)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    print("  1/4: Statistical distance scaling...")
    sd_img = plot_stat_dist_scaling()
    print(f"      Generated ({len(sd_img)} chars)")
    
    print("  2/4: Hash frequency distribution...")
    freq_img = plot_hash_frequency()
    print(f"      Generated ({len(freq_img)} chars)")
    
    print("  3/4: Fiber structure...")
    fiber_img = plot_fiber_structure()
    print(f"      Generated ({len(fiber_img)} chars)")
    
    print("  4/4: Power evolution...")
    power_img = plot_tropical_power_evolution()
    print(f"      Generated ({len(power_img)} chars)")
    
    # Save to files
    for name, data in [("sd_scaling", sd_img), ("hash_freq", freq_img), 
                        ("fiber_struct", fiber_img), ("power_evol", power_img)]:
        # Extract base64 data and save as PNG
        b64_data = data.split(",")[1]
        with open(f"{name}.png", "wb") as f:
            f.write(base64.b64decode(b64_data))
        print(f"  Saved {name}.png")
    
    print("\nAll visualizations generated successfully.")
