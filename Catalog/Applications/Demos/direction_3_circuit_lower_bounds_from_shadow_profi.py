"""
Applications of Shadow Complexity

Demonstrates real-world applications of shadow complexity theory:
1. Circuit complexity certification
2. Polynomial identity testing via shadow profiles
3. Support compression analysis
"""

from itertools import permutations, combinations
from typing import Set, Tuple, List, Dict
import math

MultiIndex = Tuple[int, ...]


def lower_shadow(S: Set[MultiIndex]) -> Set[MultiIndex]:
    """Compute the lower shadow ∂(S)."""
    result: Set[MultiIndex] = set()
    for v in S:
        for i in range(len(v)):
            if v[i] > 0:
                w = list(v)
                w[i] -= 1
                result.add(tuple(w))
    return result


def shadow_profile(S: Set[MultiIndex]) -> List[int]:
    """Compute the full shadow profile."""
    if not S:
        return [0]
    profile = []
    current = set(S)
    while current:
        profile.append(len(current))
        current = lower_shadow(current)
    return profile


def shadow_complexity(S: Set[MultiIndex]) -> int:
    """Compute the shadow complexity Σ(S)."""
    return sum(shadow_profile(S))


def minkowski_sum(A: Set[MultiIndex], B: Set[MultiIndex]) -> Set[MultiIndex]:
    """Compute the Minkowski sum A + B."""
    return {tuple(ai + bi for ai, bi in zip(a, b)) for a in A for b in B}


# ============================================================
# Application 1: Circuit Complexity Certification
# ============================================================

def certify_formula_complexity(S: Set[MultiIndex], claimed_size: int) -> Dict:
    """Certify whether a polynomial support is achievable with a formula of given size.

    If Σ(S) > 2^s, then NO formula of size s can compute any polynomial with support S.

    Args:
        S: Support set of the polynomial.
        claimed_size: Claimed formula size s.

    Returns:
        Dictionary with certification result and diagnostics.
    """
    sc = shadow_complexity(S)
    bound = 2 ** claimed_size
    profile = shadow_profile(S)

    result = {
        'support_size': len(S),
        'shadow_complexity': sc,
        'formula_size_bound': claimed_size,
        'bound_value': bound,
        'certified_achievable': sc <= bound,
        'min_formula_size': math.ceil(math.log2(sc)) if sc > 0 else 0,
        'profile': profile,
    }

    if sc > bound:
        result['certificate'] = (
            f"LOWER BOUND: Any formula computing a polynomial with this support "
            f"requires size ≥ {result['min_formula_size']} "
            f"(shadow complexity {sc} > 2^{claimed_size} = {bound})"
        )
    else:
        result['certificate'] = (
            f"CONSISTENT: Shadow complexity {sc} ≤ 2^{claimed_size} = {bound}. "
            f"A formula of size {claimed_size} is not ruled out."
        )

    return result


# ============================================================
# Application 2: Polynomial Distinctness via Shadow Profiles
# ============================================================

def are_shadow_distinct(S1: Set[MultiIndex], S2: Set[MultiIndex]) -> Dict:
    """Check if two polynomial supports are distinguishable by shadow profiles.

    If two polynomials have different shadow profiles, they must be distinct
    (have different supports). This provides a quick identity test.

    Args:
        S1, S2: Support sets of two polynomials.

    Returns:
        Dictionary with distinctness result.
    """
    p1 = shadow_profile(S1)
    p2 = shadow_profile(S2)

    return {
        'profile_1': p1,
        'profile_2': p2,
        'profiles_differ': p1 != p2,
        'complexity_1': sum(p1),
        'complexity_2': sum(p2),
        'supports_equal': S1 == S2,
    }


# ============================================================
# Application 3: Support Compression Analysis
# ============================================================

def analyze_compression(S: Set[MultiIndex]) -> Dict:
    """Analyze the shadow compression ratio of a support set.

    The compression ratio measures how quickly the shadow profile decays,
    indicating the "compressibility" of the polynomial's support structure.

    Args:
        S: Support set.

    Returns:
        Dictionary with compression analysis.
    """
    profile = shadow_profile(S)
    sc = shadow_complexity(S)
    n = len(next(iter(S))) if S else 0

    # Compression ratio: Σ(S) / (D+1) where D is max total degree
    D = max(sum(v) for v in S) if S else 0
    compression_ratio = sc / (D + 1) if D >= 0 else 0

    # Decay rates between consecutive levels
    decay_rates = []
    for k in range(1, len(profile)):
        if profile[k - 1] > 0:
            decay_rates.append(profile[k] / profile[k - 1])
        else:
            decay_rates.append(0.0)

    return {
        'dimension': n,
        'support_size': len(S),
        'max_degree': D,
        'profile': profile,
        'shadow_complexity': sc,
        'compression_ratio': compression_ratio,
        'decay_rates': decay_rates,
        'avg_decay': sum(decay_rates) / len(decay_rates) if decay_rates else 0,
    }


def demo_applications():
    """Run all application demos."""
    print("=" * 60)
    print("APPLICATION 1: Circuit Complexity Certification")
    print("=" * 60)

    # Test with product polynomial
    for n in range(2, 6):
        S = set()
        for bits in range(2 ** n):
            S.add(tuple((bits >> i) & 1 for i in range(n)))

        result = certify_formula_complexity(S, n + 1)
        print(f"\n∏(1+xᵢ), n={n}:")
        print(f"  {result['certificate']}")
        print(f"  Min formula size: {result['min_formula_size']}")

    # Test with permanent
    print("\n\nPermanent polynomials:")
    for n in range(2, 5):
        S = set()
        for perm in permutations(range(n)):
            v = [0] * (n * n)
            for i in range(n):
                v[i * n + perm[i]] = 1
            S.add(tuple(v))
        result = certify_formula_complexity(S, 2 * n)
        print(f"\nperm_{n}:")
        print(f"  {result['certificate']}")
        print(f"  Shadow complexity: {result['shadow_complexity']}")

    print("\n\n" + "=" * 60)
    print("APPLICATION 2: Polynomial Distinctness")
    print("=" * 60)

    # Compare e₂ and e₃ in 5 variables
    S1 = set()
    for subset in combinations(range(5), 2):
        v = [0] * 5
        for i in subset:
            v[i] = 1
        S1.add(tuple(v))

    S2 = set()
    for subset in combinations(range(5), 3):
        v = [0] * 5
        for i in subset:
            v[i] = 1
        S2.add(tuple(v))

    result = are_shadow_distinct(S1, S2)
    print(f"\ne₂(x₁,...,x₅) vs e₃(x₁,...,x₅):")
    print(f"  Profile e₂: {result['profile_1']}")
    print(f"  Profile e₃: {result['profile_2']}")
    print(f"  Distinguishable: {result['profiles_differ']}")

    print("\n\n" + "=" * 60)
    print("APPLICATION 3: Support Compression Analysis")
    print("=" * 60)

    for n in range(2, 6):
        S = set()
        for bits in range(2 ** n):
            S.add(tuple((bits >> i) & 1 for i in range(n)))
        result = analyze_compression(S)
        print(f"\n∏(1+xᵢ), n={n}:")
        print(f"  Compression ratio: {result['compression_ratio']:.2f}")
        print(f"  Avg decay rate: {result['avg_decay']:.3f}")
        print(f"  Decay rates: {[f'{r:.2f}' for r in result['decay_rates']]}")


if __name__ == "__main__":
    demo_applications()


"""
Shadow Complexity Demo

Interactive demonstration of shadow profiles and shadow complexity
for various polynomial supports. Includes:
1. Shadow profiles for ∏(1+xᵢ), permanent, elementary symmetric
2. Verification of the convolution theorem
3. The x^d counterexample to the original conjecture
4. Random multi-linear polynomial sampling for conjecture testing
"""

from itertools import permutations, combinations
from typing import Set, Tuple, List, Dict
import random
import math

MultiIndex = Tuple[int, ...]


def lower_shadow(S: Set[MultiIndex]) -> Set[MultiIndex]:
    result: Set[MultiIndex] = set()
    for v in S:
        for i in range(len(v)):
            if v[i] > 0:
                w = list(v)
                w[i] -= 1
                result.add(tuple(w))
    return result


def shadow_profile(S: Set[MultiIndex]) -> List[int]:
    if not S:
        return [0]
    profile = []
    current = set(S)
    while current:
        profile.append(len(current))
        current = lower_shadow(current)
    return profile


def shadow_complexity(S: Set[MultiIndex]) -> int:
    return sum(shadow_profile(S))


def minkowski_sum(A: Set[MultiIndex], B: Set[MultiIndex]) -> Set[MultiIndex]:
    return {tuple(ai + bi for ai, bi in zip(a, b)) for a in A for b in B}


def support_product_1_plus_xi(n: int) -> Set[MultiIndex]:
    """Support of ∏(1+xᵢ) = full Boolean hypercube {0,1}^n."""
    result: Set[MultiIndex] = set()
    for bits in range(2 ** n):
        result.add(tuple((bits >> i) & 1 for i in range(n)))
    return result


def support_permanent(n: int) -> Set[MultiIndex]:
    """Support of n×n permanent: all permutation matrices as vectors in {0,1}^{n²}."""
    result: Set[MultiIndex] = set()
    for perm in permutations(range(n)):
        v = [0] * (n * n)
        for i in range(n):
            v[i * n + perm[i]] = 1
        result.add(tuple(v))
    return result


def support_elementary_symmetric(n: int, k: int) -> Set[MultiIndex]:
    """Support of eₖ(x₁,...,xₙ)."""
    result: Set[MultiIndex] = set()
    for subset in combinations(range(n), k):
        v = [0] * n
        for i in subset:
            v[i] = 1
        result.add(tuple(v))
    return result


def demo_1_shadow_profiles():
    """Compute shadow profiles for key polynomials."""
    print("=" * 60)
    print("DEMO 1: Shadow Profiles of Important Polynomials")
    print("=" * 60)

    for n in range(2, 6):
        S = support_product_1_plus_xi(n)
        prof = shadow_profile(S)
        sc = shadow_complexity(S)
        print(f"\n∏(1+xᵢ), n={n}:")
        print(f"  |Supp| = {len(S)}")
        print(f"  Profile: {prof}")
        print(f"  Σ(S) = {sc}")
        print(f"  3^n = {3**n}")
        print(f"  Match: {sc == 3**n}")

    print("\n--- Permanent ---")
    for n in range(2, 5):
        S = support_permanent(n)
        prof = shadow_profile(S)
        sc = shadow_complexity(S)
        print(f"\nperm_{n}:")
        print(f"  |Supp| = {len(S)} (= {n}!)")
        print(f"  Profile: {prof}")
        print(f"  Σ(S) = {sc}")

    print("\n--- Elementary Symmetric ---")
    n = 5
    for k in range(1, n + 1):
        S = support_elementary_symmetric(n, k)
        prof = shadow_profile(S)
        sc = shadow_complexity(S)
        print(f"\ne_{k}(x₁,...,x_{n}): |Supp|={len(S)}, Σ={sc}, Profile={prof}")


def demo_2_convolution_verification():
    """Verify the convolution bound for several examples."""
    print("\n" + "=" * 60)
    print("DEMO 2: Convolution Theorem Verification")
    print("=" * 60)

    # Example 1: A = {(1,0), (0,0)}, B = {(0,1), (0,0)}
    A = {(1, 0), (0, 0)}
    B = {(0, 1), (0, 0)}
    _verify_and_print(A, B, "1+x", "1+y")

    # Example 2: Larger sets
    A = {(1, 0, 0), (0, 0, 0)}
    B = {(0, 1, 0), (0, 0, 0)}
    C = {(0, 0, 1), (0, 0, 0)}
    AB = minkowski_sum(A, B)
    _verify_and_print(AB, C, "(1+x₁)(1+x₂)", "1+x₃")

    # Example 3: Self-sum
    A = {(1, 0), (0, 1)}
    _verify_and_print(A, A, "x+y", "x+y")


def _verify_and_print(A, B, name_a, name_b):
    AB = minkowski_sum(A, B)
    pa = shadow_profile(A)
    pb = shadow_profile(B)
    pab = shadow_profile(AB)

    max_k = len(pab)
    conv = []
    for k in range(max_k):
        val = sum(pa[i] * pb[k - i] for i in range(k + 1)
                  if i < len(pa) and (k - i) < len(pb))
        conv.append(val)

    holds = all(pab[k] <= conv[k] for k in range(max_k))

    print(f"\n  A = Supp({name_a}), B = Supp({name_b})")
    print(f"  Profile A:   {pa}")
    print(f"  Profile B:   {pb}")
    print(f"  Profile A+B: {pab}")
    print(f"  Conv bound:  {conv}")
    print(f"  Bound holds: {holds}")
    print(f"  Σ(A)={sum(pa)}, Σ(B)={sum(pb)}, Σ(A+B)={sum(pab)}")
    print(f"  Σ(A)·Σ(B)={sum(pa)*sum(pb)} ≥ Σ(A+B)={sum(pab)}: {sum(pa)*sum(pb) >= sum(pab)}")


def demo_3_counterexample():
    """Show the x^d counterexample."""
    print("\n" + "=" * 60)
    print("DEMO 3: The x^d Counterexample")
    print("=" * 60)

    for d in [1, 2, 5, 10, 20, 50, 100]:
        S = {(d,)}
        prof = shadow_profile(S)
        sc = shadow_complexity(S)
        circuit_size = math.ceil(math.log2(d)) + 1 if d > 1 else 1
        bound = 2 ** circuit_size
        print(f"\n  x^{d}:")
        print(f"    Profile: [1] × {len(prof)} (all ones)")
        print(f"    Σ(x^d) = {sc}")
        print(f"    Circuit size (repeated squaring) ≈ {circuit_size}")
        print(f"    2^s = {bound}")
        print(f"    Σ ≤ 2^s: {sc <= bound}")


def demo_4_random_multilinear():
    """Test the refined conjecture via random multi-linear polynomial sampling."""
    print("\n" + "=" * 60)
    print("DEMO 4: Random Multi-linear Polynomial Conjecture Testing")
    print("=" * 60)

    random.seed(42)
    n = 4
    num_trials = 20
    violations = 0

    print(f"\n  Testing refined conjecture for n={n}, {num_trials} random polynomials")
    print(f"  Conjecture: a_k ≥ C(n,k) · |Supp|/2^n")

    for trial in range(num_trials):
        # Random multi-linear polynomial: random subset of {0,1}^n
        num_monomials = random.randint(1, 2 ** n)
        all_vecs = list(support_product_1_plus_xi(n))
        S = set(random.sample(all_vecs, num_monomials))

        prof = shadow_profile(S)
        density = len(S) / (2 ** n)

        trial_ok = True
        for k in range(len(prof)):
            expected = math.comb(n, k) * len(S) / (2 ** n)
            if prof[k] < expected:
                trial_ok = False
                break

        if not trial_ok:
            violations += 1

    print(f"\n  Violations: {violations}/{num_trials}")
    print(f"  Conjecture {'HOLDS' if violations == 0 else 'VIOLATED'} for all trials")

    # Detailed example
    print("\n  Detailed example:")
    S = support_product_1_plus_xi(4)
    prof = shadow_profile(S)
    print(f"  Full hypercube {'{0,1}'}^4:")
    print(f"    |Supp| = {len(S)}")
    print(f"    Profile: {prof}")
    print(f"    Binomial row: {[math.comb(4, k) for k in range(5)]}")
    print(f"    Ratio: {[prof[k]/math.comb(4,k) if math.comb(4,k) > 0 else 'N/A' for k in range(min(5, len(prof)))]}")


if __name__ == "__main__":
    demo_1_shadow_profiles()
    demo_2_convolution_verification()
    demo_3_counterexample()
    demo_4_random_multilinear()


"""
Visualization: Shadow Complexity Heatmap

Displays a heatmap of shadow complexity for subsets of {0,1}^n
organized by support size and structural properties.
Shows how shadow complexity varies across different polynomial supports.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import Set, Tuple, List
import math

MultiIndex = Tuple[int, ...]


def lower_shadow(S: Set[MultiIndex]) -> Set[MultiIndex]:
    result: Set[MultiIndex] = set()
    for v in S:
        for i in range(len(v)):
            if v[i] > 0:
                w = list(v)
                w[i] -= 1
                result.add(tuple(w))
    return result


def shadow_profile(S: Set[MultiIndex]) -> List[int]:
    if not S:
        return [0]
    profile = []
    current = set(S)
    while current:
        profile.append(len(current))
        current = lower_shadow(current)
    return profile


def shadow_complexity(S: Set[MultiIndex]) -> int:
    return sum(shadow_profile(S))


# Generate all subsets of {0,1}^4 by size
n = 4
all_vecs = []
for bits in range(2 ** n):
    all_vecs.append(tuple((bits >> i) & 1 for i in range(n)))

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Shadow complexity distribution by support size
ax = axes[0]
size_to_complexities = {}
for size in range(1, 2 ** n + 1):
    complexities = []
    # Sample subsets of given size (enumerate for small n)
    count = 0
    for subset in combinations(range(2 ** n), size):
        S = {all_vecs[i] for i in subset}
        complexities.append(shadow_complexity(S))
        count += 1
        if count >= 200:  # Cap for larger sizes
            break
    size_to_complexities[size] = complexities

positions = []
data = []
labels = []
for size in range(1, min(2 ** n + 1, 12)):
    if size in size_to_complexities and size_to_complexities[size]:
        positions.append(size)
        data.append(size_to_complexities[size])
        labels.append(str(size))

bp = ax.boxplot(data, positions=positions, widths=0.6, patch_artist=True)
for patch, pos in zip(bp['boxes'], positions):
    shade = pos / max(positions)
    patch.set_facecolor(plt.cm.viridis(shade))
    patch.set_alpha(0.7)

ax.set_xlabel('Support size |S|')
ax.set_ylabel('Shadow complexity Σ(S)')
ax.set_title(f'Shadow Complexity Distribution (n={n})')

# Add theoretical bounds
sizes = range(1, 2 ** n + 1)
# Upper bound: each element contributes at most n+1 to shadow complexity
upper = [(n + 1) * s for s in sizes]
ax.plot(sizes, upper, 'r--', alpha=0.5, label=f'Upper: (n+1)·|S|')
ax.legend()

# Plot 2: Heatmap of shadow profiles by support size
ax = axes[1]

# Collect average profiles by support size
max_depth = n + 1
avg_profiles = np.zeros((2 ** n, max_depth))
counts = np.zeros(2 ** n)

for size in range(1, 2 ** n + 1):
    count = 0
    for subset in combinations(range(2 ** n), size):
        S = {all_vecs[i] for i in subset}
        prof = shadow_profile(S)
        for k in range(min(len(prof), max_depth)):
            avg_profiles[size - 1, k] += prof[k]
        count += 1
        if count >= 100:
            break
    if count > 0:
        avg_profiles[size - 1] /= count
    counts[size - 1] = count

# Normalize rows for visualization
norm_profiles = np.zeros_like(avg_profiles)
for i in range(avg_profiles.shape[0]):
    row_sum = avg_profiles[i].sum()
    if row_sum > 0:
        norm_profiles[i] = avg_profiles[i] / row_sum

im = ax.imshow(norm_profiles.T, aspect='auto', cmap='YlOrRd',
               origin='lower', interpolation='nearest')
ax.set_xlabel('Support size |S|')
ax.set_ylabel('Shadow depth k')
ax.set_title(f'Normalized Shadow Profile Heatmap (n={n})')
plt.colorbar(im, ax=ax, label='Normalized profile weight')

# Mark specific polynomials
# e_k polynomials
for k in range(1, n + 1):
    size = math.comb(n, k)
    ax.plot(size - 1, k, 'w*', markersize=12, markeredgecolor='black')
    ax.annotate(f'e_{k}', (size - 1, k), color='white',
                fontsize=7, ha='center', va='bottom',
                fontweight='bold',
                path_effects=[
                    __import__('matplotlib.patheffects', fromlist=['withStroke']).withStroke(
                        linewidth=2, foreground='black'
                    )
                ])

plt.tight_layout()
plt.savefig('complexity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved complexity_heatmap.png")


"""
Visualization: Convolution Theorem Illustration

Visualizes the shadow convolution inequality for Minkowski sums:
shows the actual shadow profile of A+B compared to the convolution
bound Σᵢ aᵢ^A · a_{k-i}^B. The gap between the two curves
represents the "slack" in the convolution bound.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import Set, Tuple, List

MultiIndex = Tuple[int, ...]


def lower_shadow(S: Set[MultiIndex]) -> Set[MultiIndex]:
    result: Set[MultiIndex] = set()
    for v in S:
        for i in range(len(v)):
            if v[i] > 0:
                w = list(v)
                w[i] -= 1
                result.add(tuple(w))
    return result


def shadow_profile(S: Set[MultiIndex]) -> List[int]:
    if not S:
        return [0]
    profile = []
    current = set(S)
    while current:
        profile.append(len(current))
        current = lower_shadow(current)
    return profile


def minkowski_sum(A: Set[MultiIndex], B: Set[MultiIndex]) -> Set[MultiIndex]:
    return {tuple(ai + bi for ai, bi in zip(a, b)) for a in A for b in B}


def convolve_profiles(pa: List[int], pb: List[int]) -> List[int]:
    length = len(pa) + len(pb) - 1
    conv = []
    for k in range(length):
        val = sum(pa[i] * pb[k - i] for i in range(k + 1)
                  if i < len(pa) and (k - i) < len(pb))
        conv.append(val)
    return conv


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Example 1: (1+x)(1+y) decomposition
A1 = {(1, 0, 0), (0, 0, 0)}
B1 = {(0, 1, 0), (0, 0, 0)}

# Example 2: larger sets
A2 = {(1, 0, 0), (0, 1, 0), (0, 0, 0)}
B2 = {(0, 0, 1), (0, 0, 0)}

# Example 3: self-sum
A3 = {(1, 0), (0, 1)}
B3 = {(1, 0), (0, 1)}

# Example 4: elementary symmetric
A4 = set()
for subset in combinations(range(3), 1):
    v = [0] * 3
    for i in subset:
        v[i] = 1
    A4.add(tuple(v))
B4 = set(A4)

examples = [
    (A1, B1, "A={e₁, 0}, B={e₂, 0}"),
    (A2, B2, "A={e₁, e₂, 0}, B={e₃, 0}"),
    (A3, B3, "A=B={e₁, e₂}"),
    (A4, B4, "A=B=Supp(e₁(x₁,x₂,x₃))"),
]

for idx, (A, B, title) in enumerate(examples):
    ax = axes[idx // 2][idx % 2]

    AB = minkowski_sum(A, B)
    pa = shadow_profile(A)
    pb = shadow_profile(B)
    pab = shadow_profile(AB)
    conv = convolve_profiles(pa, pb)

    max_k = max(len(pab), len(conv))
    pab_ext = pab + [0] * (max_k - len(pab))
    conv_ext = conv + [0] * (max_k - len(conv))

    x = np.arange(max_k)
    width = 0.35

    ax.bar(x - width / 2, pab_ext, width, label='Actual |∂ᵏ(A+B)|',
           color='steelblue', alpha=0.8)
    ax.bar(x + width / 2, conv_ext, width, label='Conv bound',
           color='coral', alpha=0.8)

    # Highlight slack
    for k in range(max_k):
        if conv_ext[k] > pab_ext[k]:
            ax.annotate('', xy=(k + width / 2, pab_ext[k]),
                        xytext=(k + width / 2, conv_ext[k]),
                        arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))

    ax.set_xlabel('k')
    ax.set_ylabel('Count')
    ax.set_title(title, fontsize=10)
    ax.legend(fontsize=8)

    # Add complexity info
    sc_ab = sum(pab)
    sc_a = sum(pa)
    sc_b = sum(pb)
    ax.text(0.95, 0.95, f'Σ(A+B)={sc_ab}\nΣ(A)·Σ(B)={sc_a * sc_b}',
            transform=ax.transAxes, ha='right', va='top',
            fontsize=8, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Shadow Convolution Inequality: Actual vs Bound', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('convolution_theorem.png', dpi=150, bbox_inches='tight')
print("Saved convolution_theorem.png")


"""
Visualization: Shadow Profile Decay Curves

Visualizes the shadow profiles of key polynomials (∏(1+xᵢ), permanent,
elementary symmetric) as bar charts / line plots, showing how the
iterated shadow sizes decay. The shape of these curves is the
"fingerprint" that constrains circuit complexity.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, combinations
from typing import Set, Tuple, List

MultiIndex = Tuple[int, ...]


def lower_shadow(S: Set[MultiIndex]) -> Set[MultiIndex]:
    result: Set[MultiIndex] = set()
    for v in S:
        for i in range(len(v)):
            if v[i] > 0:
                w = list(v)
                w[i] -= 1
                result.add(tuple(w))
    return result


def shadow_profile(S: Set[MultiIndex]) -> List[int]:
    if not S:
        return [0]
    profile = []
    current = set(S)
    while current:
        profile.append(len(current))
        current = lower_shadow(current)
    return profile


def support_product(n):
    result = set()
    for bits in range(2 ** n):
        result.add(tuple((bits >> i) & 1 for i in range(n)))
    return result


def support_permanent(n):
    result = set()
    for perm in permutations(range(n)):
        v = [0] * (n * n)
        for i in range(n):
            v[i * n + perm[i]] = 1
        result.add(tuple(v))
    return result


def support_elem_sym(n, k):
    result = set()
    for subset in combinations(range(n), k):
        v = [0] * n
        for i in subset:
            v[i] = 1
        result.add(tuple(v))
    return result


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: ∏(1+xᵢ) for various n
ax = axes[0]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, 4))
for idx, n in enumerate([2, 3, 4, 5]):
    prof = shadow_profile(support_product(n))
    ax.bar(np.arange(len(prof)) + idx * 0.18 - 0.27, prof,
           width=0.17, color=colors[idx], label=f'n={n}', alpha=0.85)
ax.set_xlabel('Shadow iteration k')
ax.set_ylabel('|∂ᵏ(S)|')
ax.set_title('Shadow Profiles of ∏(1+xᵢ)')
ax.legend()
ax.set_yscale('log')

# Plot 2: Permanent for n=2,3,4
ax = axes[1]
colors2 = plt.cm.plasma(np.linspace(0.2, 0.8, 3))
for idx, n in enumerate([2, 3, 4]):
    prof = shadow_profile(support_permanent(n))
    ax.plot(range(len(prof)), prof, 'o-', color=colors2[idx],
            label=f'perm_{n}', markersize=6, linewidth=2)
ax.set_xlabel('Shadow iteration k')
ax.set_ylabel('|∂ᵏ(S)|')
ax.set_title('Shadow Profiles of Permanent')
ax.legend()

# Plot 3: Elementary symmetric polynomials
ax = axes[2]
n = 6
colors3 = plt.cm.coolwarm(np.linspace(0.1, 0.9, n))
for k in range(1, n + 1):
    prof = shadow_profile(support_elem_sym(n, k))
    ax.plot(range(len(prof)), prof, 's-', color=colors3[k-1],
            label=f'e_{k}', markersize=5, linewidth=1.5)
ax.set_xlabel('Shadow iteration k')
ax.set_ylabel('|∂ᵏ(S)|')
ax.set_title(f'Shadow Profiles of eₖ(x₁,...,x₆)')
ax.legend(ncol=2, fontsize=8)

plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
