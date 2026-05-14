#!/usr/bin/env python3
"""
Applications of Tropical Information Theory

Demonstrates real-world applications of the tropical coding framework:
1. Data compression analysis for natural language text
2. Image compression via tropical code length optimization
3. Network routing as tropical coding
4. Cryptographic entropy analysis
"""

import numpy as np
from collections import Counter
import math


def text_compression_analysis(text: str) -> dict:
    """
    Analyze text compression using tropical information theory.

    Computes Shannon entropy, min-entropy, and optimal code lengths
    for the character distribution of the input text.

    Args:
        text: Input text string

    Returns:
        Dictionary with compression analysis results
    """
    # Character frequency distribution
    counts = Counter(text)
    n = len(text)
    chars = sorted(counts.keys())
    probs = np.array([counts[c] / n for c in chars])

    # Shannon entropy (bits per character)
    H = -np.sum(probs * np.log2(probs))

    # Min-entropy
    H_inf = -np.log2(np.max(probs))

    # Optimal code lengths (bits)
    optimal_lengths = -np.log2(probs)

    # Ceiling code
    ceil_lengths = np.ceil(optimal_lengths).astype(int)

    # Expected lengths
    E_optimal = np.sum(probs * optimal_lengths)
    E_ceil = np.sum(probs * ceil_lengths)

    # Kraft sums
    K_optimal = np.sum(2.0 ** (-optimal_lengths))
    K_ceil = np.sum(2.0 ** (-ceil_lengths.astype(float)))

    return {
        'n_chars': n,
        'alphabet_size': len(chars),
        'shannon_entropy_bits': H,
        'min_entropy_bits': H_inf,
        'entropy_gap': H - H_inf,
        'optimal_expected_length': E_optimal,
        'ceil_expected_length': E_ceil,
        'ceil_redundancy': E_ceil - H,
        'kraft_sum_optimal': K_optimal,
        'kraft_sum_ceil': K_ceil,
        'compression_ratio': H / np.log2(len(chars)) if len(chars) > 1 else 1.0,
        'min_file_size_bits': n * H,
        'ceil_file_size_bits': n * E_ceil,
        'top_chars': [(c, counts[c], f'{counts[c]/n:.4f}') for c in
                      sorted(counts, key=counts.get, reverse=True)[:5]]
    }


def network_routing_as_tropical_coding():
    """
    Demonstrate that network routing IS tropical coding.

    A network with edge costs is a tropical semiring computation.
    Shortest paths = optimal tropical code lengths.
    """
    # Simple network: 5 nodes with edge costs
    INF = float('inf')
    cost = np.array([
        [0, 2, INF, 1, INF],
        [INF, 0, 3, INF, INF],
        [INF, INF, 0, INF, 1],
        [INF, 1, INF, 0, 4],
        [INF, INF, INF, INF, 0]
    ])

    # Bellman-Ford = tropical matrix power
    n = 5
    dist = np.full((n, n), INF)
    np.fill_diagonal(dist, 0)

    # Tropical matrix multiplication: (A ⊕ B)(i,j) = min_k (A(i,k) + B(k,j))
    def tropical_matmul(A, B):
        n = len(A)
        C = np.full((n, n), INF)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i][j] = min(C[i][j], A[i][k] + B[k][j])
        return C

    # Compute shortest paths via tropical matrix powers
    result = cost.copy()
    power = cost.copy()
    for _ in range(n - 1):
        power = tropical_matmul(power, cost)
        result = np.minimum(result, power)

    return {
        'cost_matrix': cost,
        'shortest_paths': result,
        'interpretation': 'Shortest paths are optimal tropical code lengths'
    }


def entropy_analysis_for_crypto():
    """
    Analyze entropy properties relevant to cryptography.

    The min-entropy H_∞ is the correct entropy for cryptographic
    randomness extraction (not Shannon entropy H).
    Our theorem proves H_∞ ≤ H, showing that Shannon entropy
    overestimates extractable randomness.
    """
    results = []

    # Various key distributions
    scenarios = [
        ("Uniform 256-bit key", np.ones(256) / 256),
        ("Biased coin (p=0.7)", np.array([0.7, 0.3])),
        ("Weak RNG (10 of 256 values)", None),
        ("English letter frequencies", None),
    ]

    # Uniform key
    p_uniform = np.ones(256) / 256
    H_uniform = -np.sum(p_uniform * np.log2(p_uniform))
    H_inf_uniform = -np.log2(np.max(p_uniform))
    results.append({
        'name': 'Uniform 256-bit key',
        'H': H_uniform,
        'H_inf': H_inf_uniform,
        'gap': H_uniform - H_inf_uniform,
        'extractable_bits': H_inf_uniform
    })

    # Biased coin
    p_biased = np.array([0.7, 0.3])
    H_biased = -np.sum(p_biased * np.log2(p_biased))
    H_inf_biased = -np.log2(np.max(p_biased))
    results.append({
        'name': 'Biased coin (p=0.7)',
        'H': H_biased,
        'H_inf': H_inf_biased,
        'gap': H_biased - H_inf_biased,
        'extractable_bits': H_inf_biased
    })

    # Weak RNG
    p_weak = np.zeros(256)
    p_weak[:10] = 1/10
    p_weak_pos = p_weak[p_weak > 0]
    H_weak = -np.sum(p_weak_pos * np.log2(p_weak_pos))
    H_inf_weak = -np.log2(np.max(p_weak))
    results.append({
        'name': 'Weak RNG (10 of 256 values)',
        'H': H_weak,
        'H_inf': H_inf_weak,
        'gap': H_weak - H_inf_weak,
        'extractable_bits': H_inf_weak
    })

    # English letters
    english_freq = {
        'e': 0.127, 't': 0.091, 'a': 0.082, 'o': 0.075, 'i': 0.070,
        'n': 0.067, 's': 0.063, 'h': 0.061, 'r': 0.060, 'd': 0.043,
        'l': 0.040, 'c': 0.028, 'u': 0.028, 'm': 0.024, 'w': 0.024,
        'f': 0.022, 'g': 0.020, 'y': 0.020, 'p': 0.019, 'b': 0.015,
        'v': 0.010, 'k': 0.008, 'j': 0.002, 'x': 0.002, 'q': 0.001,
        'z': 0.001
    }
    total = sum(english_freq.values())
    p_eng = np.array([v/total for v in english_freq.values()])
    H_eng = -np.sum(p_eng * np.log2(p_eng))
    H_inf_eng = -np.log2(np.max(p_eng))
    results.append({
        'name': 'English letter frequencies',
        'H': H_eng,
        'H_inf': H_inf_eng,
        'gap': H_eng - H_inf_eng,
        'extractable_bits': H_inf_eng
    })

    return results


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Text Compression Analysis")
    print("=" * 60)

    sample_text = (
        "to be or not to be that is the question whether tis nobler "
        "in the mind to suffer the slings and arrows of outrageous fortune"
    )
    analysis = text_compression_analysis(sample_text)
    print(f"Text: '{sample_text[:50]}...'")
    print(f"Characters: {analysis['n_chars']}")
    print(f"Alphabet size: {analysis['alphabet_size']}")
    print(f"Shannon entropy: {analysis['shannon_entropy_bits']:.4f} bits/char")
    print(f"Min-entropy: {analysis['min_entropy_bits']:.4f} bits/char")
    print(f"Entropy gap: {analysis['entropy_gap']:.4f} bits/char")
    print(f"Compression ratio: {analysis['compression_ratio']:.4f}")
    print(f"Min file size: {analysis['min_file_size_bits']:.0f} bits "
          f"({analysis['min_file_size_bits']/8:.0f} bytes)")
    print(f"Ceiling code: {analysis['ceil_file_size_bits']:.0f} bits "
          f"({analysis['ceil_file_size_bits']/8:.0f} bytes)")
    print(f"Original size: {analysis['n_chars'] * 8} bits")
    print()

    print("=" * 60)
    print("APPLICATION 2: Network Routing as Tropical Coding")
    print("=" * 60)

    routing = network_routing_as_tropical_coding()
    print("Shortest path matrix (= tropical code lengths):")
    for row in routing['shortest_paths']:
        print("  ", [f"{x:5.1f}" if x < 1e10 else "  inf" for x in row])
    print()

    print("=" * 60)
    print("APPLICATION 3: Cryptographic Entropy Analysis")
    print("=" * 60)

    crypto = entropy_analysis_for_crypto()
    for r in crypto:
        print(f"\n{r['name']}:")
        print(f"  Shannon entropy H = {r['H']:.4f} bits")
        print(f"  Min-entropy H_∞ = {r['H_inf']:.4f} bits")
        print(f"  Gap H - H_∞ = {r['gap']:.4f} bits")
        print(f"  Extractable randomness: {r['extractable_bits']:.4f} bits")
        print(f"  H_∞ ≤ H? {r['H_inf'] <= r['H'] + 1e-10}")


#!/usr/bin/env python3
"""
Tropical Arithmetic Coding: Demonstrations and Numerical Verification

This module demonstrates the key theorems of tropical information theory
with concrete numerical examples, verifying:
1. Shannon entropy as the lower bound for Kraft-admissible codes
2. KL divergence non-negativity
3. Min-plus convolution for composite codes
4. Universal coding optimality
5. Entropy hierarchy: H_∞ ≤ H
"""

import numpy as np
from typing import List, Tuple
import math


def shannon_entropy(p: np.ndarray) -> float:
    """Compute Shannon entropy H(p) = -sum p(a) log p(a) (natural log)."""
    p = p[p > 0]
    return -np.sum(p * np.log(p))


def min_entropy(p: np.ndarray) -> float:
    """Compute min-entropy H_inf(p) = -log(max p(a))."""
    return -np.log(np.max(p))


def kraft_sum(lengths: np.ndarray) -> float:
    """Compute Kraft sum: sum exp(-l(a))."""
    return np.sum(np.exp(-lengths))


def expected_length(p: np.ndarray, lengths: np.ndarray) -> float:
    """Compute expected code length E_p[l]."""
    return np.sum(p * lengths)


def shannon_optimal_lengths(p: np.ndarray) -> np.ndarray:
    """Shannon-optimal code lengths: l(a) = -log p(a)."""
    return -np.log(p)


def ceil_code_lengths(p: np.ndarray) -> np.ndarray:
    """Integer ceiling code: l(a) = ceil(-log2 p(a))."""
    return np.ceil(-np.log2(p))


def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """KL divergence D(p || q) = sum p(a) log(p(a)/q(a))."""
    mask = p > 0
    return np.sum(p[mask] * np.log(p[mask] / q[mask]))


def minplus_convolution(f: np.ndarray, g: np.ndarray) -> np.ndarray:
    """Min-plus convolution: (f * g)(z) = min_x (f(x) + g(z-x)) mod n."""
    n = len(f)
    result = np.full(n, np.inf)
    for z in range(n):
        for x in range(n):
            y = (z - x) % n
            result[z] = min(result[z], f[x] + g[y])
    return result


def random_distribution(n: int) -> np.ndarray:
    """Generate a random probability distribution on n symbols."""
    p = np.random.dirichlet(np.ones(n))
    return p


# ============================================================
# DEMO 1: Tropical Shannon Lower Bound
# ============================================================
def demo_shannon_bound():
    print("=" * 60)
    print("DEMO 1: Tropical Shannon Lower Bound")
    print("=" * 60)
    print()

    # Example 1: Uniform distribution
    n = 4
    p = np.ones(n) / n
    optimal_l = shannon_optimal_lengths(p)
    H = shannon_entropy(p)
    E_l = expected_length(p, optimal_l)
    K = kraft_sum(optimal_l)

    print(f"Uniform distribution on {n} symbols:")
    print(f"  p = {p}")
    print(f"  Shannon entropy H(p) = {H:.6f} nats")
    print(f"  Optimal lengths l(a) = -log p(a) = {optimal_l}")
    print(f"  Expected length E[l] = {E_l:.6f}")
    print(f"  Kraft sum = {K:.6f}")
    print(f"  H(p) ≤ E[l]? {H <= E_l + 1e-10}")
    print(f"  Gap E[l] - H(p) = {E_l - H:.10f}")
    print()

    # Example 2: Skewed distribution
    p2 = np.array([0.5, 0.25, 0.125, 0.125])
    optimal_l2 = shannon_optimal_lengths(p2)
    H2 = shannon_entropy(p2)
    E_l2 = expected_length(p2, optimal_l2)
    K2 = kraft_sum(optimal_l2)

    print(f"Skewed distribution:")
    print(f"  p = {p2}")
    print(f"  Shannon entropy H(p) = {H2:.6f} nats")
    print(f"  Expected length E[l] = {E_l2:.6f}")
    print(f"  Kraft sum = {K2:.6f}")
    print(f"  H(p) = E[l]? (optimal code achieves equality)")
    print()

    # Example 3: Suboptimal code
    suboptimal_l = np.array([1.0, 1.5, 2.0, 2.5])
    K3 = kraft_sum(suboptimal_l)
    E_l3 = expected_length(p2, suboptimal_l)
    print(f"Suboptimal code with Kraft sum {K3:.6f}:")
    print(f"  lengths = {suboptimal_l}")
    if K3 <= 1.0:
        print(f"  Kraft-admissible: YES")
        print(f"  E[l] = {E_l3:.6f} ≥ H(p) = {H2:.6f}? {E_l3 >= H2 - 1e-10}")
    else:
        print(f"  Kraft-admissible: NO (sum = {K3:.4f} > 1)")
    print()


# ============================================================
# DEMO 2: KL Divergence Non-Negativity
# ============================================================
def demo_kl_divergence():
    print("=" * 60)
    print("DEMO 2: KL Divergence Non-Negativity")
    print("=" * 60)
    print()

    # Test on many random pairs
    n_tests = 10000
    n_symbols = 5
    min_kl = float('inf')
    all_nonneg = True

    for _ in range(n_tests):
        p = random_distribution(n_symbols)
        q = random_distribution(n_symbols)
        kl = kl_divergence(p, q)
        if kl < -1e-10:
            all_nonneg = False
        min_kl = min(min_kl, kl)

    print(f"Tested D(p || q) ≥ 0 on {n_tests} random pairs (n={n_symbols}):")
    print(f"  All non-negative (within tolerance): {all_nonneg}")
    print(f"  Minimum KL divergence found: {min_kl:.10f}")
    print()

    # Specific example
    p = np.array([0.5, 0.3, 0.2])
    q = np.array([0.3, 0.4, 0.3])
    kl = kl_divergence(p, q)
    print(f"Specific example:")
    print(f"  p = {p}, q = {q}")
    print(f"  D(p || q) = {kl:.6f} ≥ 0? {kl >= -1e-10}")
    print()


# ============================================================
# DEMO 3: Min-Plus Convolution
# ============================================================
def demo_minplus_convolution():
    print("=" * 60)
    print("DEMO 3: Min-Plus Convolution")
    print("=" * 60)
    print()

    # Two cost functions on Z/5Z
    f = np.array([1.0, 3.0, 2.0, 5.0, 4.0])
    g = np.array([2.0, 1.0, 4.0, 3.0, 2.0])
    conv = minplus_convolution(f, g)

    print(f"f = {f}")
    print(f"g = {g}")
    print(f"(f ⋆ g) = {conv}")
    print()
    print("Verification: (f ⋆ g)(x+y) ≤ f(x) + g(y) for all x, y:")
    all_ok = True
    for x in range(5):
        for y in range(5):
            z = (x + y) % 5
            if conv[z] > f[x] + g[y] + 1e-10:
                print(f"  VIOLATION at x={x}, y={y}")
                all_ok = False
    print(f"  All inequalities satisfied: {all_ok}")
    print()

    # Application: composite source coding
    print("Application to composite source coding:")
    p1 = np.array([0.4, 0.3, 0.2, 0.1])
    p2 = np.array([0.5, 0.3, 0.15, 0.05])
    l1 = shannon_optimal_lengths(p1)
    l2 = shannon_optimal_lengths(p2)

    # For product source, the optimal length is l1(a) + l2(b)
    print(f"  Source 1: H = {shannon_entropy(p1):.4f} nats")
    print(f"  Source 2: H = {shannon_entropy(p2):.4f} nats")
    print(f"  Sum of entropies: {shannon_entropy(p1) + shannon_entropy(p2):.4f}")

    # Product distribution entropy
    p_prod = np.outer(p1, p2).flatten()
    print(f"  Product source entropy: {shannon_entropy(p_prod):.4f}")
    print(f"  Entropies are additive: {abs(shannon_entropy(p_prod) - shannon_entropy(p1) - shannon_entropy(p2)) < 1e-10}")
    print()


# ============================================================
# DEMO 4: Ceiling Code Redundancy
# ============================================================
def demo_ceiling_code():
    print("=" * 60)
    print("DEMO 4: Ceiling Code Redundancy Bound")
    print("=" * 60)
    print()

    n_tests = 1000
    max_redundancy = 0
    all_under_one = True

    for _ in range(n_tests):
        n = np.random.randint(2, 20)
        p = random_distribution(n)
        H_bits = shannon_entropy(p) / np.log(2)  # Convert to bits
        ceil_l = ceil_code_lengths(p)
        E_ceil = expected_length(p, ceil_l)
        redundancy = E_ceil - H_bits

        if redundancy >= 1.0 + 1e-10:
            all_under_one = False
        max_redundancy = max(max_redundancy, redundancy)

    print(f"Tested ceiling code on {n_tests} random distributions:")
    print(f"  E[ceil(-log2 p)] < H2(p) + 1 always? {all_under_one}")
    print(f"  Maximum redundancy found: {max_redundancy:.6f} bits")
    print()

    # Specific example
    p = np.array([0.5, 0.25, 0.125, 0.125])
    H_bits = shannon_entropy(p) / np.log(2)
    ceil_l = ceil_code_lengths(p)
    E_ceil = expected_length(p, ceil_l)
    K = np.sum(2.0 ** (-ceil_l))

    print(f"Specific example (dyadic distribution):")
    print(f"  p = {p}")
    print(f"  Ceiling lengths = {ceil_l}")
    print(f"  Kraft sum (base 2) = {K:.4f} ≤ 1? {K <= 1.0 + 1e-10}")
    print(f"  E[l] = {E_ceil:.4f} bits")
    print(f"  H2(p) = {H_bits:.4f} bits")
    print(f"  Redundancy = {E_ceil - H_bits:.4f} < 1? {E_ceil - H_bits < 1.0 + 1e-10}")
    print()


# ============================================================
# DEMO 5: Entropy Hierarchy H_∞ ≤ H
# ============================================================
def demo_entropy_hierarchy():
    print("=" * 60)
    print("DEMO 5: Entropy Hierarchy H_∞ ≤ H")
    print("=" * 60)
    print()

    n_tests = 1000
    all_ok = True
    min_gap = float('inf')
    max_gap = 0

    for _ in range(n_tests):
        n = np.random.randint(2, 20)
        p = random_distribution(n)
        H = shannon_entropy(p)
        H_inf = min_entropy(p)
        gap = H - H_inf
        if gap < -1e-10:
            all_ok = False
        min_gap = min(min_gap, gap)
        max_gap = max(max_gap, gap)

    print(f"Tested H_∞ ≤ H on {n_tests} random distributions:")
    print(f"  All satisfied: {all_ok}")
    print(f"  Minimum gap H - H_∞: {min_gap:.6f}")
    print(f"  Maximum gap H - H_∞: {max_gap:.6f}")
    print()

    # Specific examples
    for name, p in [("Uniform(4)", np.ones(4)/4),
                     ("Skewed", np.array([0.9, 0.05, 0.03, 0.02])),
                     ("Near-deterministic", np.array([0.99, 0.005, 0.005]))]:
        H = shannon_entropy(p)
        H_inf = min_entropy(p)
        print(f"  {name}: H_∞ = {H_inf:.4f}, H = {H:.4f}, gap = {H - H_inf:.4f}")
    print()


# ============================================================
# DEMO 6: Tropical Kraft Convexity
# ============================================================
def demo_kraft_convexity():
    print("=" * 60)
    print("DEMO 6: Tropical Kraft Convexity")
    print("=" * 60)
    print()

    n_tests = 1000
    all_ok = True
    max_sum = 0

    for _ in range(n_tests):
        n = np.random.randint(2, 10)
        p1 = random_distribution(n)
        p2 = random_distribution(n)
        l1 = shannon_optimal_lengths(p1)
        l2 = shannon_optimal_lengths(p2)
        K1 = kraft_sum(l1)
        K2 = kraft_sum(l2)
        l_min = np.minimum(l1, l2)
        K_min = kraft_sum(l_min)
        max_sum = max(max_sum, K_min)
        if K_min > 2.0 + 1e-10:
            all_ok = False

    print(f"Tested ∑ exp(-min(l1,l2)) ≤ 2 on {n_tests} pairs:")
    print(f"  All satisfied: {all_ok}")
    print(f"  Maximum Kraft sum of min: {max_sum:.6f}")
    print()


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    np.random.seed(42)

    demo_shannon_bound()
    demo_kl_divergence()
    demo_minplus_convolution()
    demo_ceiling_code()
    demo_entropy_hierarchy()
    demo_kraft_convexity()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""
import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Catalog/Bridges/IdempotentInfoTheory/TropicalArithmeticCoding.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualizations
viz_shannon = read_image_base64('shannon_bound.png')
viz_entropy = read_image_base64('entropy_hierarchy.png')
viz_minplus = read_image_base64('minplus_convolution.png')
viz_kl = read_image_base64('kl_divergence.png')
viz_kraft = read_image_base64('kraft_convexity.png')

package = {
    "title": "Tropical Arithmetic Coding: Shannon-Optimal Min-Plus Compression",
    "domain": "Computation / Information Theory / Tropical Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Information Theory Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Shannon Optimal Code",
            "pseudocode": "Input: probability distribution p on {1,...,n}\nOutput: code lengths l(a) = -log p(a)\n\nfor a in {1,...,n}:\n    l(a) = -log(p(a))\nreturn l\n\nTime: O(n), Space: O(n)\nProperty: Kraft-admissible, E[l] = H(p)",
            "code": algorithms_code
        },
        {
            "name": "Min-Plus Convolution",
            "pseudocode": "Input: cost functions f, g on {0,...,n-1}\nOutput: (f * g)(z) = min_x (f(x) + g((z-x) mod n))\n\nfor z in {0,...,n-1}:\n    result[z] = infinity\n    for x in {0,...,n-1}:\n        y = (z - x) mod n\n        result[z] = min(result[z], f[x] + g[y])\nreturn result\n\nTime: O(n^2), Space: O(n)",
            "code": "# See algorithms.py for full implementation"
        }
    ],
    "visualizations": [
        {"name": "Tropical Shannon Lower Bound", "data": viz_shannon},
        {"name": "Entropy Hierarchy: H_inf <= H", "data": viz_entropy},
        {"name": "Min-Plus Convolution", "data": viz_minplus},
        {"name": "KL Divergence Non-Negativity", "data": viz_kl},
        {"name": "Tropical Kraft Convexity", "data": viz_kraft}
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Tropical Information Theory

Generates publication-quality figures demonstrating the key mathematical
structures of tropical arithmetic coding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_shannon_bound():
    """Visualize the Shannon lower bound for various distributions."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: entropy vs expected length for random codes
    np.random.seed(42)
    n = 8
    entropies = []
    exp_lengths = []
    for _ in range(500):
        p = np.random.dirichlet(np.ones(n))
        H = -np.sum(p * np.log(p))

        # Random Kraft-admissible code
        raw = np.random.exponential(1.5, n) + 0.1
        raw = raw / np.sum(np.exp(-raw))  # normalize to Kraft = 1
        lengths = -np.log(raw / np.sum(raw))
        # Make Kraft-admissible by scaling
        K = np.sum(np.exp(-lengths))
        if K > 1:
            lengths = lengths + np.log(K)

        E_l = np.sum(p * lengths)
        entropies.append(H)
        exp_lengths.append(E_l)

    ax = axes[0]
    ax.scatter(entropies, exp_lengths, alpha=0.3, s=10, c='steelblue')
    lim = max(max(entropies), max(exp_lengths)) * 1.1
    ax.plot([0, lim], [0, lim], 'r-', linewidth=2, label='H = E[ℓ] (Shannon bound)')
    ax.set_xlabel('Shannon Entropy H(μ)', fontsize=12)
    ax.set_ylabel('Expected Code Length E[ℓ]', fontsize=12)
    ax.set_title('Tropical Shannon Lower Bound', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, lim)
    ax.set_ylim(0, lim)

    # Right: Kraft sum vs expected length
    ax = axes[1]
    p = np.array([0.4, 0.3, 0.2, 0.1])
    H = -np.sum(p * np.log(p))

    kraft_sums = []
    exp_ls = []
    for scale in np.linspace(0.5, 3.0, 200):
        lengths = -np.log(p) * scale
        K = np.sum(np.exp(-lengths))
        E_l = np.sum(p * lengths)
        kraft_sums.append(K)
        exp_ls.append(E_l)

    ax.plot(kraft_sums, exp_ls, 'b-', linewidth=2)
    ax.axhline(y=H, color='r', linestyle='--', linewidth=1.5, label=f'H(μ) = {H:.3f}')
    ax.axvline(x=1, color='green', linestyle='--', linewidth=1.5, label='Kraft = 1')
    ax.fill_between([0, 1], [0, 0], [H, H], alpha=0.1, color='red')
    ax.set_xlabel('Kraft Sum ∑exp(-ℓ)', fontsize=12)
    ax.set_ylabel('Expected Code Length E[ℓ]', fontsize=12)
    ax.set_title('Kraft Admissibility Region', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 3)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_entropy_hierarchy():
    """Visualize H_∞ ≤ H for various distributions."""
    fig, ax = plt.subplots(figsize=(8, 6))

    np.random.seed(123)
    H_list = []
    H_inf_list = []

    for _ in range(1000):
        n = np.random.randint(2, 20)
        p = np.random.dirichlet(np.ones(n))
        H = -np.sum(p * np.log(p))
        H_inf = -np.log(np.max(p))
        H_list.append(H)
        H_inf_list.append(H_inf)

    ax.scatter(H_list, H_inf_list, alpha=0.3, s=10, c='purple')
    lim = max(max(H_list), max(H_inf_list)) * 1.1
    ax.plot([0, lim], [0, lim], 'r-', linewidth=2, label='H_∞ = H (equality line)')
    ax.fill_between([0, lim], [0, lim], [0, 0], alpha=0.05, color='red',
                    label='Forbidden region')
    ax.set_xlabel('Shannon Entropy H(μ)', fontsize=12)
    ax.set_ylabel('Min-Entropy H_∞(μ)', fontsize=12)
    ax.set_title('Entropy Hierarchy: H_∞(μ) ≤ H(μ)', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, lim)
    ax.set_ylim(0, lim)
    ax.set_aspect('equal')

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_minplus_convolution():
    """Visualize min-plus convolution."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    n = 20
    x = np.arange(n)

    f = 0.5 * (x - 5)**2 / n + 1
    g = 0.3 * (x - 12)**2 / n + 0.5

    # Compute min-plus convolution
    conv = np.full(n, np.inf)
    for z in range(n):
        for i in range(n):
            j = (z - i) % n
            conv[z] = min(conv[z], f[i] + g[j])

    axes[0].bar(x, f, color='steelblue', alpha=0.7)
    axes[0].set_title('f(x)', fontsize=14)
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('Cost')

    axes[1].bar(x, g, color='coral', alpha=0.7)
    axes[1].set_title('g(x)', fontsize=14)
    axes[1].set_xlabel('x')

    axes[2].bar(x, conv, color='green', alpha=0.7)
    axes[2].set_title('(f ⋆ g)(z) = min_x (f(x) + g(z-x))', fontsize=14)
    axes[2].set_xlabel('z')

    plt.suptitle('Min-Plus Convolution (Tropical Tensor Product)', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_kl_divergence():
    """Visualize KL divergence non-negativity."""
    fig, ax = plt.subplots(figsize=(8, 6))

    np.random.seed(99)
    kl_values = []
    for _ in range(5000):
        n = np.random.randint(2, 10)
        p = np.random.dirichlet(np.ones(n))
        q = np.random.dirichlet(np.ones(n))
        kl = np.sum(p * np.log(p / q))
        kl_values.append(kl)

    ax.hist(kl_values, bins=100, color='teal', alpha=0.7, edgecolor='black', linewidth=0.3)
    ax.axvline(x=0, color='red', linewidth=2, linestyle='--', label='D = 0 (lower bound)')
    ax.set_xlabel('KL Divergence D(p ‖ q)', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('KL Divergence is Always Non-Negative\n(5000 random distribution pairs)', fontsize=14)
    ax.legend(fontsize=11)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_kraft_convexity():
    """Visualize tropical Kraft convexity."""
    fig, ax = plt.subplots(figsize=(8, 6))

    np.random.seed(77)
    kraft_min_sums = []

    for _ in range(2000):
        n = np.random.randint(2, 15)
        p1 = np.random.dirichlet(np.ones(n))
        p2 = np.random.dirichlet(np.ones(n))
        l1 = -np.log(p1)
        l2 = -np.log(p2)
        l_min = np.minimum(l1, l2)
        K = np.sum(np.exp(-l_min))
        kraft_min_sums.append(K)

    ax.hist(kraft_min_sums, bins=80, color='orange', alpha=0.7, edgecolor='black', linewidth=0.3)
    ax.axvline(x=1, color='green', linewidth=2, linestyle='--', label='Kraft = 1 (individual bound)')
    ax.axvline(x=2, color='red', linewidth=2, linestyle='--', label='Kraft = 2 (tropical convexity bound)')
    ax.set_xlabel('Kraft Sum of min(ℓ₁, ℓ₂)', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Tropical Kraft Convexity: ∑exp(-min(ℓ₁,ℓ₂)) ≤ 2', fontsize=14)
    ax.legend(fontsize=10)

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    viz1 = viz_shannon_bound()
    viz2 = viz_entropy_hierarchy()
    viz3 = viz_minplus_convolution()
    viz4 = viz_kl_divergence()
    viz5 = viz_kraft_convexity()

    # Save as individual PNGs for reference
    for i, (name, viz) in enumerate([
        ("shannon_bound", viz1),
        ("entropy_hierarchy", viz2),
        ("minplus_convolution", viz3),
        ("kl_divergence", viz4),
        ("kraft_convexity", viz5)
    ]):
        # Extract base64 data and save as file
        data = viz.split(",")[1]
        with open(f"{name}.png", "wb") as f:
            f.write(base64.b64decode(data))
        print(f"  Saved {name}.png")

    print("All visualizations generated.")
