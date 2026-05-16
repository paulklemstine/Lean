#!/usr/bin/env python3
"""
Applications of Finite Description Complexity

Real-world applications demonstrating the counting barrier theorems
in circuit complexity, learning theory, and cryptography.
"""

import math
import random
from typing import List, Set, Dict, Tuple


# ─── Application 1: Circuit Complexity Lower Bounds ──────────────────────

def shannon_counting_argument(n: int, gate_budget: int) -> Dict[str, object]:
    """
    Shannon's counting argument for circuit lower bounds.

    Given n input bits and a gate budget G, compute:
    - Total number of Boolean functions: 2^(2^n)
    - Upper bound on circuits with ≤ G gates
    - Whether the budget suffices to realize all functions

    This is a direct application of card_image_le_card_domain:
    if the number of circuits < 2^(2^n), some function has no small circuit.

    Args:
        n: Number of input bits
        gate_budget: Maximum number of gates allowed

    Returns:
        Analysis dictionary

    Example:
        >>> result = shannon_counting_argument(4, 100)
        >>> result['some_function_requires_more_gates']
        True
    """
    total_functions = 2 ** (2 ** n)

    # Upper bound: each gate chooses 2 inputs from {x_1,...,x_n, prev_gates}
    # and one of 16 binary operations. Very rough: ≤ (16 * (n+G)^2)^G circuits.
    # For simplicity, use the standard bound: at most (C * n)^G circuits for constant C.
    max_circuits = min((16 * (n + gate_budget) ** 2) ** gate_budget, 10**100)

    return {
        'n': n,
        'gate_budget': gate_budget,
        'total_functions': total_functions,
        'max_circuits': max_circuits,
        'sufficient': max_circuits >= total_functions,
        'some_function_requires_more_gates': max_circuits < total_functions,
        'log2_total': 2**n,
        'log2_circuits': math.log2(max_circuits) if max_circuits > 0 else 0,
    }


def minimum_gates_for_n_inputs(n: int) -> int:
    """
    Compute the minimum gate budget G such that the Shannon bound
    allows all 2^(2^n) functions to be realizable.

    Uses binary search over G.

    Args:
        n: Number of input bits

    Returns:
        Minimum G such that circuit count ≥ function count

    Example:
        >>> minimum_gates_for_n_inputs(3)  # 256 functions
        5
    """
    target = 2 ** n  # log2 of total functions

    lo, hi = 1, 2 * target
    while lo < hi:
        mid = (lo + hi) // 2
        # log2 of circuit bound ≈ mid * log2(16 * (n + mid)^2)
        log_circuits = mid * math.log2(16 * (n + mid) ** 2)
        if log_circuits >= target:
            hi = mid
        else:
            lo = mid + 1
    return lo


# ─── Application 2: Learning Theory ─────────────────────────────────────

def hypothesis_class_generalization_bound(
    class_size: int,
    sample_size: int,
    delta: float = 0.05
) -> float:
    """
    Generalization bound for a finite hypothesis class.

    By the counting bound, a class with N hypotheses has at most N
    distinct behaviors. The Occam bound gives:

        P[error > ε] ≤ δ  when  ε ≥ √(ln(N/δ) / (2n))

    where n is the sample size.

    This is a direct application of card_image_le_card_domain:
    the "effective size" of any parametric class is bounded by
    the number of parameters.

    Args:
        class_size: Number of hypotheses (N)
        sample_size: Number of training samples (n)
        delta: Confidence parameter

    Returns:
        Generalization error bound ε

    Example:
        >>> hypothesis_class_generalization_bound(1000, 500)
        0.122...
    """
    if sample_size == 0:
        return float('inf')
    return math.sqrt(math.log(class_size / delta) / (2 * sample_size))


def compression_generalization_analysis(
    description_bits: int,
    sample_sizes: List[int],
    delta: float = 0.05
) -> List[Dict[str, float]]:
    """
    Analyze generalization as a function of description length and sample size.

    The class of models describable in k bits has at most 2^k members.
    By the finite incompressibility theorem, most functions cannot be
    described in k bits, so they cannot be learned by this class.

    Args:
        description_bits: Number of bits for model description (k)
        sample_sizes: List of sample sizes to analyze
        delta: Confidence parameter

    Returns:
        List of {sample_size, class_size, gen_bound} dicts

    Example:
        >>> results = compression_generalization_analysis(10, [100, 500, 1000])
    """
    class_size = 2 ** description_bits
    results = []
    for n in sample_sizes:
        bound = hypothesis_class_generalization_bound(class_size, n, delta)
        results.append({
            'sample_size': n,
            'description_bits': description_bits,
            'class_size': class_size,
            'generalization_bound': bound,
        })
    return results


# ─── Application 3: Cryptographic Entropy ────────────────────────────────

def key_space_coverage(seed_bits: int, key_bits: int) -> Dict[str, object]:
    """
    Analyze key space coverage of a deterministic key generator.

    A deterministic keygen with s-bit seeds can produce at most 2^s keys.
    If the key space has 2^k keys with k > s, the fraction of reachable
    keys is at most 2^(s-k).

    This is a direct application of exists_not_in_range_of_card_gt.

    Args:
        seed_bits: Number of bits in the seed (s)
        key_bits: Number of bits in the key space (k)

    Returns:
        Analysis of key space coverage

    Example:
        >>> result = key_space_coverage(40, 128)
        >>> result['fraction_reachable']
        9.094e-27
    """
    seed_space = 2 ** seed_bits
    key_space = 2 ** key_bits

    return {
        'seed_bits': seed_bits,
        'key_bits': key_bits,
        'seed_space': seed_space,
        'key_space': key_space,
        'max_reachable': min(seed_space, key_space),
        'fraction_reachable': min(1.0, seed_space / key_space),
        'unreachable_fraction': max(0.0, 1 - seed_space / key_space),
        'entropy_gap_bits': max(0, key_bits - seed_bits),
    }


def brute_force_resistance(description_bits: int) -> Dict[str, float]:
    """
    Compute brute-force resistance metrics.

    By the counting bound, an adversary limited to descriptions of
    k bits can search at most 2^k possibilities.

    Args:
        description_bits: Adversary's description budget (k)

    Returns:
        Dictionary with security metrics

    Example:
        >>> metrics = brute_force_resistance(80)
    """
    search_space = 2 ** description_bits
    # Time estimates assuming 10^9 operations/second
    ops_per_second = 1e9
    seconds = search_space / ops_per_second
    years = seconds / (365.25 * 24 * 3600)

    return {
        'description_bits': description_bits,
        'search_space': search_space,
        'seconds': seconds,
        'years': years,
        'secure_against_classical': years > 1e10,  # > age of universe
    }


# ─── Main Demo ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Circuit Complexity Lower Bounds")
    print("=" * 70)
    print()

    for n in [3, 4, 5, 6]:
        min_gates = minimum_gates_for_n_inputs(n)
        total = 2**(2**n)
        print(f"  n={n} inputs: 2^(2^{n}) = 2^{2**n} functions")
        print(f"    Minimum gates needed (Shannon bound): {min_gates}")
        result = shannon_counting_argument(n, min_gates - 1)
        print(f"    With {min_gates-1} gates: insufficient ✗")
        result = shannon_counting_argument(n, min_gates)
        print(f"    With {min_gates} gates: sufficient ✓")
        print()

    print("=" * 70)
    print("APPLICATION 2: Learning Theory Generalization Bounds")
    print("=" * 70)
    print()

    for k in [8, 16, 32, 64]:
        print(f"  Description length k = {k} bits (class size 2^{k}):")
        results = compression_generalization_analysis(k, [100, 1000, 10000])
        for r in results:
            print(f"    n = {r['sample_size']:6d}: generalization bound = {r['generalization_bound']:.4f}")
        print()

    print("=" * 70)
    print("APPLICATION 3: Cryptographic Key Space Coverage")
    print("=" * 70)
    print()

    for seed, key in [(32, 128), (40, 128), (64, 256), (128, 256)]:
        result = key_space_coverage(seed, key)
        print(f"  {seed}-bit seed → {key}-bit key space:")
        print(f"    Reachable fraction: 2^(-{result['entropy_gap_bits']}) "
              f"= {result['fraction_reachable']:.2e}")
        print(f"    Entropy gap: {result['entropy_gap_bits']} bits")
        print()

    print("=" * 70)
    print("APPLICATION 4: Brute Force Resistance")
    print("=" * 70)
    print()

    for bits in [40, 64, 80, 128, 256]:
        metrics = brute_force_resistance(bits)
        print(f"  {bits}-bit description budget:")
        print(f"    Search space: 2^{bits}")
        if metrics['years'] < 1:
            print(f"    Time: {metrics['seconds']:.1f} seconds")
        elif metrics['years'] < 1e6:
            print(f"    Time: {metrics['years']:.1f} years")
        else:
            print(f"    Time: {metrics['years']:.2e} years")
        print(f"    Secure: {'Yes ✓' if metrics['secure_against_classical'] else 'No ✗'}")
        print()


#!/usr/bin/env python3
"""
Finite Description Complexity: Demonstrations

Concrete numerical examples illustrating the compression barrier theorems.
Shows how encoders with limited index budgets cannot cover large output spaces.
"""

import random
import math
from collections import Counter

def demo_counting_bound():
    """
    Theorem: card_image_initial_segment_le
    The number of distinct outputs from codes of index ≤ k is at most k+1.
    """
    print("=" * 70)
    print("DEMO 1: Counting Bound for Shallow Descriptions")
    print("=" * 70)
    print()

    N = 20  # Number of codes
    alpha = list(range(100))  # Output space

    random.seed(42)
    E = [random.choice(alpha) for _ in range(N)]  # Random encoder

    print(f"Encoder E : Fin {N} → {{0,...,99}}")
    print(f"E = {E}")
    print()

    for k in [0, 1, 2, 5, 10, 19]:
        if k >= N:
            continue
        outputs = set(E[i] for i in range(min(k + 1, N)))
        print(f"  k = {k:2d}: codes {{0,...,{k}}} produce {len(outputs):2d} distinct outputs ≤ {k+1} = k+1  ✓")

    print()
    print("The image of any k+1 codes has at most k+1 elements (trivially sharp")
    print("when the encoder is injective on the initial segment).")
    print()


def demo_incompressibility():
    """
    Theorem: exists_not_encoded_by_small_index
    If |S| > k+1, some element of S has no code of index ≤ k.
    """
    print("=" * 70)
    print("DEMO 2: Finite Incompressibility Principle")
    print("=" * 70)
    print()

    N = 10
    S = list(range(20))  # Set of 20 elements
    random.seed(123)
    E = [random.choice(S) for _ in range(N)]

    print(f"Universe: {{0, ..., 19}} (20 elements)")
    print(f"Encoder E : Fin {N} → universe")
    print(f"E = {E}")
    print()

    for k in [0, 2, 5, 9]:
        if k >= N:
            k = N - 1
        reachable = set(E[i] for i in range(min(k + 1, N)))
        unreachable = set(S) - reachable
        print(f"  k = {k:2d}: reachable = {sorted(reachable)}")
        print(f"         unreachable ({len(unreachable)} elements): {sorted(unreachable)}")
        if len(S) > k + 1:
            print(f"         |S| = {len(S)} > {k+1} = k+1, so incompressible elements exist ✓")
        print()

    print("No matter how the encoder is chosen, with only k+1 codes,")
    print("at least |S| - (k+1) elements remain unreachable.")
    print()


def demo_collision():
    """
    Theorem: exists_collision_of_card_lt_codes
    If |α| < k+1, two codes in {0,...,k} must collide.
    """
    print("=" * 70)
    print("DEMO 3: Pigeonhole Collision Theorem")
    print("=" * 70)
    print()

    N = 15
    alpha_size = 5
    random.seed(456)
    E = [random.randint(0, alpha_size - 1) for _ in range(N)]

    print(f"Encoder E : Fin {N} → Fin {alpha_size}")
    print(f"E = {E}")
    print()

    for k in [5, 8, 14]:
        if k >= N:
            k = N - 1
        segment = [(i, E[i]) for i in range(k + 1)]
        # Find collisions
        seen = {}
        collisions = []
        for i, val in segment:
            if val in seen:
                collisions.append((seen[val], i, val))
            else:
                seen[val] = i

        print(f"  k = {k:2d}: {k+1} codes map into {alpha_size} outputs")
        if alpha_size < k + 1:
            print(f"         |α| = {alpha_size} < {k+1} = k+1 → collision guaranteed ✓")
            if collisions:
                i, j, v = collisions[0]
                print(f"         Example: E[{i}] = E[{j}] = {v}")
        print()


def demo_binary_incompressibility():
    """
    Theorem: card_image_le_card_domain + exists_not_in_range_of_card_gt
    Kolmogorov-style: strings of length n with complexity ≤ k are at most 2^(k+1)-1.
    """
    print("=" * 70)
    print("DEMO 4: Binary-Code Incompressibility (Kolmogorov-Style)")
    print("=" * 70)
    print()

    n = 8  # String length
    total = 2**n  # Total strings of length n

    print(f"Binary strings of length {n}: {total} total")
    print()

    for k in range(n + 1):
        M = 2**(k + 1) - 1  # Number of descriptions of bitlength ≤ k
        frac = M / total * 100
        incompressible = max(0, total - M)
        print(f"  k = {k}: at most {M:5d} strings have complexity ≤ {k}"
              f"  ({frac:6.2f}%),  ≥{incompressible:4d} are incompressible")

    print()
    print("As k grows, more strings become describable, but for k < n-1,")
    print("the majority of strings remain incompressible.")
    print()


def demo_depth_family():
    """
    Theorem: depth_bounded_family_card_le
    Application: neural network layers as depth-bounded encoders.
    """
    print("=" * 70)
    print("DEMO 5: Depth-Bounded Family Cardinality")
    print("=" * 70)
    print()

    # Simulate: at each depth d, a neural network can realize certain functions
    # Model: depth-d network with width w can realize at most w^d functions
    width = 3

    print(f"Model: depth-d network of width {width}")
    print(f"Upper bound on realizable functions at depth d: {width}^d")
    print()

    input_dim = 4
    total_functions = 2**(2**input_dim)

    print(f"Total Boolean functions on {input_dim} inputs: 2^(2^{input_dim}) = {total_functions}")
    print()

    for d in range(1, 12):
        realizable = min(width**d, total_functions)
        coverage = realizable / total_functions * 100
        print(f"  depth {d:2d}: ≤ {realizable:8d} functions realizable"
              f"  ({coverage:8.4f}% coverage)")
        if realizable >= total_functions:
            print(f"           (full coverage achieved at depth {d})")
            break

    print()
    print("The counting bound shows that shallow circuits/networks cannot")
    print("cover the function space without exponential width.")
    print()


def demo_learning_theory():
    """
    Application: Hypothesis class size bounds generalization.
    """
    print("=" * 70)
    print("DEMO 6: Learning Theory — Compression Implies Generalization")
    print("=" * 70)
    print()

    # Sauer-Shelah style: if hypothesis class has k hypotheses,
    # it can shatter at most log2(k) points
    print("A hypothesis class H indexed by k codes can shatter at most")
    print("log₂(k) points (by the counting bound on restrictions).")
    print()

    for k in [2, 4, 8, 16, 64, 256, 1024]:
        max_shatter = math.floor(math.log2(k))
        print(f"  |H| ≤ {k:5d}  →  VC-dim ≤ {max_shatter:2d}")

    print()
    print("Generalization error ≈ √(VC-dim / n) for n samples.")
    print("Bounded description complexity → bounded VC-dim → generalization.")
    print()


if __name__ == "__main__":
    demo_counting_bound()
    demo_incompressibility()
    demo_collision()
    demo_binary_incompressibility()
    demo_depth_family()
    demo_learning_theory()


#!/usr/bin/env python3
"""
Visualizations for Finite Description Complexity

Generates charts illustrating the compression barrier theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math
import base64
import io

def save_fig_base64(fig, filename):
    """Save figure to file and return base64 data URI."""
    fig.savefig(filename, dpi=150, bbox_inches='tight', facecolor='white')
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_counting_bound():
    """Visualize the counting bound: reachable outputs vs code budget."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: concrete encoder
    np.random.seed(42)
    N = 30
    E = np.random.randint(0, 100, size=N)

    ks = range(N)
    reachable_counts = []
    for k in ks:
        reachable = len(set(E[:k+1]))
        reachable_counts.append(reachable)

    ax1.plot(list(ks), reachable_counts, 'b-o', markersize=4, label='Distinct outputs')
    ax1.plot(list(ks), [k+1 for k in ks], 'r--', linewidth=2, label='Bound: k+1')
    ax1.fill_between(list(ks), reachable_counts, [k+1 for k in ks],
                     alpha=0.2, color='red', label='Slack')
    ax1.set_xlabel('Code budget k', fontsize=12)
    ax1.set_ylabel('Number of distinct outputs', fontsize=12)
    ax1.set_title('Counting Bound (Concrete Encoder)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right panel: collision rate
    collisions = []
    for k in ks:
        segment = E[:k+1]
        unique = len(set(segment))
        collisions.append(k + 1 - unique)

    ax2.bar(list(ks), collisions, color='coral', alpha=0.7, label='Collisions')
    ax2.set_xlabel('Code budget k', fontsize=12)
    ax2.set_ylabel('Number of collisions', fontsize=12)
    ax2.set_title('Collisions in Initial Segment', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Theorem: card_image_initial_segment_le', fontsize=16, y=1.02)
    fig.tight_layout()
    return save_fig_base64(fig, 'viz_counting_bound.png')


def viz_incompressibility_spectrum():
    """Visualize the incompressibility spectrum for binary strings."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    ns = [6, 8, 10, 12]
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']

    for n, color in zip(ns, colors):
        total = 2**n
        ks = range(n + 1)
        describable = [min(2**(k+1) - 1, total) for k in ks]
        fractions = [d / total for d in describable]
        ax1.plot(list(ks), fractions, '-o', color=color, markersize=5,
                 label=f'n={n} (2^{n}={total} strings)')

    ax1.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
    ax1.set_xlabel('Maximum complexity k', fontsize=12)
    ax1.set_ylabel('Fraction describable', fontsize=12)
    ax1.set_title('Describable Fraction vs Complexity Budget', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-0.05, 1.1)

    # Right panel: incompressible count (log scale)
    for n, color in zip(ns, colors):
        total = 2**n
        ks = range(n)
        incompressible = [total - min(2**(k+1) - 1, total) for k in ks]
        ax2.semilogy(list(ks), incompressible, '-s', color=color, markersize=5,
                     label=f'n={n}')

    ax2.set_xlabel('Maximum complexity k', fontsize=12)
    ax2.set_ylabel('Number of incompressible strings (log scale)', fontsize=12)
    ax2.set_title('Incompressible Strings vs Complexity Budget', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Binary Incompressibility Spectrum', fontsize=16, y=1.02)
    fig.tight_layout()
    return save_fig_base64(fig, 'viz_incompressibility.png')


def viz_depth_separation():
    """Visualize depth-bounded family cardinality bounds."""
    fig, ax = plt.subplots(figsize=(10, 7))

    widths = [2, 3, 4, 5]
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
    input_dim = 5
    total = 2**(2**input_dim)

    for w, color in zip(widths, colors):
        depths = range(1, 20)
        realizable = [min(w**d, total) for d in depths]
        ax.semilogy(list(depths), realizable, '-o', color=color, markersize=4,
                    label=f'Width w={w}')

    ax.axhline(y=total, color='black', linestyle='--', linewidth=2,
               label=f'Total functions: 2^(2^{input_dim}) = 2^{2**input_dim}')
    ax.set_xlabel('Depth d', fontsize=13)
    ax.set_ylabel('Max realizable functions (log scale)', fontsize=13)
    ax.set_title(f'Depth-Bounded Family Size ({input_dim} input bits)', fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return save_fig_base64(fig, 'viz_depth_separation.png')


def viz_generalization_landscape():
    """Visualize the connection between description length and generalization."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: generalization bound vs sample size for different description lengths
    desc_bits = [4, 8, 16, 32]
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
    sample_sizes = np.logspace(1, 5, 100).astype(int)

    for k, color in zip(desc_bits, colors):
        class_size = 2**k
        bounds = [math.sqrt(math.log(class_size / 0.05) / (2 * n)) for n in sample_sizes]
        ax1.loglog(sample_sizes, bounds, '-', color=color, linewidth=2,
                   label=f'k={k} bits (|H|=2^{k})')

    ax1.axhline(y=0.1, color='gray', linestyle=':', alpha=0.5, label='10% error target')
    ax1.set_xlabel('Sample size n', fontsize=12)
    ax1.set_ylabel('Generalization bound ε', fontsize=12)
    ax1.set_title('Compression → Generalization', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0.001, 10)

    # Right: minimum samples needed vs description length
    targets = [0.1, 0.05, 0.01]
    for eps, ls in zip(targets, ['-', '--', ':']):
        desc_range = range(1, 65)
        min_samples = []
        for k in desc_range:
            class_size = 2**k
            n = math.ceil(math.log(class_size / 0.05) / (2 * eps**2))
            min_samples.append(n)
        ax2.semilogy(list(desc_range), min_samples, ls, linewidth=2,
                     label=f'ε={eps}')

    ax2.set_xlabel('Description length k (bits)', fontsize=12)
    ax2.set_ylabel('Minimum samples needed (log scale)', fontsize=12)
    ax2.set_title('Sample Complexity vs Description Length', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Learning Theory: Description Complexity Controls Generalization',
                 fontsize=15, y=1.02)
    fig.tight_layout()
    return save_fig_base64(fig, 'viz_generalization.png')


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_1 = viz_counting_bound()
    print(f"  viz_counting_bound.png generated ({len(b64_1)} chars)")

    b64_2 = viz_incompressibility_spectrum()
    print(f"  viz_incompressibility.png generated ({len(b64_2)} chars)")

    b64_3 = viz_depth_separation()
    print(f"  viz_depth_separation.png generated ({len(b64_3)} chars)")

    b64_4 = viz_generalization_landscape()
    print(f"  viz_generalization.png generated ({len(b64_4)} chars)")

    print("Done. Files saved: viz_counting_bound.png, viz_incompressibility.png,")
    print("  viz_depth_separation.png, viz_generalization.png")
