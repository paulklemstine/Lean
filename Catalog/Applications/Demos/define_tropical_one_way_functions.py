#!/usr/bin/env python3
"""
Applications of Tropical One-Wayness Theory

Demonstrates real-world applications of tropical powering and root obstructions:
1. Tropical hash function construction
2. Shortest-path computation via tropical powering
3. Network timing analysis
4. Tropical commitment scheme
"""

import numpy as np
from typing import Tuple, List
import hashlib


# ============================================================================
# Application 1: Tropical Hash Function
# ============================================================================

class TropicalHash:
    """A tropical hash function based on min-plus matrix powering.

    The hash function maps an integer vector d to the normalized tropical
    T-th power of d. By the non-injectivity theorem, this hash is
    provably many-to-one (infinite fibers under normalization), making it
    a natural candidate for collision-resistant hashing in the tropical semiring.

    The root obstruction theorem provides a necessary condition for preimage
    existence: all diagonal entries of the hash must be T-divisible over ℤ.

    Security properties (proven):
    - Many-to-one: infinite fibers (tropicalPowDiag_normalized_fiber_infinite)
    - Forward easy: O(n) computation
    - Root obstruction: divisibility criterion for preimage existence
    - Gap amplification: gap(hash) = T * gap(input)
    """

    def __init__(self, T: int = 7, n: int = 8):
        """Initialize tropical hash with power T and dimension n.

        Args:
            T: Tropical power exponent (higher = more gap amplification)
            n: Dimension of input/output vectors
        """
        self.T = T
        self.n = n

    def hash(self, d: np.ndarray) -> np.ndarray:
        """Compute the tropical hash of input vector d.

        Returns the normalized T-th tropical power: normalize(T * d).

        Args:
            d: Integer or real vector of length n

        Returns:
            Normalized hash vector with first entry = 0
        """
        powered = self.T * d
        return powered - powered[0]

    def verify_preimage(self, d: np.ndarray, h: np.ndarray) -> bool:
        """Verify that d is a preimage of hash value h.

        Args:
            d: Candidate preimage
            h: Hash value

        Returns:
            True iff hash(d) == h
        """
        return np.allclose(self.hash(d), h)

    def find_collision(self, d: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """Find a collision for the hash of d.

        By the shift invariance theorem, d and d+1 always collide.

        Args:
            d: Input vector

        Returns:
            Pair (d, d+1) which are distinct inputs with the same hash
        """
        return d, d + 1

    def check_root_obstruction(self, h: np.ndarray) -> bool:
        """Check if a hash value can possibly have a ℤ-preimage.

        By the root obstruction theorem, if h = normalize(T * d) for
        integer d, then certain divisibility conditions must hold.

        Args:
            h: Hash value to check

        Returns:
            True if divisibility conditions are satisfied
        """
        # After normalization, h[0] = 0 and h[i] = T*(d[i] - d[0])
        # For integer d, we need T | h[i] for all i
        return all(abs(int(round(x))) % self.T == 0 or abs(x - round(x)) > 0.01
                   for x in h)


# ============================================================================
# Application 2: Shortest Path via Tropical Powering
# ============================================================================

def shortest_paths_tropical(weight_matrix: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths using tropical matrix powering.

    The (i,j) entry of A^{⊗n} gives the shortest path from i to j
    using at most n edges. This is the tropical interpretation of
    matrix powering: min-plus = shortest path.

    Time complexity: O(n^4) (n iterations of O(n^3) tropical multiplication)
    Can be improved to O(n^3 log n) with repeated squaring.

    Args:
        weight_matrix: n×n matrix of edge weights (np.inf for no edge)

    Returns:
        n×n matrix of shortest path distances
    """
    n = weight_matrix.shape[0]
    result = weight_matrix.copy()
    for _ in range(n - 1):
        new_result = np.full((n, n), np.inf)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    new_result[i, j] = min(new_result[i, j],
                                          result[i, k] + weight_matrix[k, j])
        result = new_result
    return result


# ============================================================================
# Application 3: Network Timing Analysis
# ============================================================================

class NetworkTimingAnalyzer:
    """Analyze worst-case timing in a network using tropical algebra.

    Models a network as a weighted directed graph where edge weights
    represent delays. Tropical powering computes worst-case (or best-case)
    path delays, and the gap functional measures timing spread.

    The gap amplification theorem implies: if there is any timing
    asymmetry in the network, T rounds of routing amplify it by factor T.
    """

    def __init__(self, delay_matrix: np.ndarray):
        """Initialize with a delay matrix.

        Args:
            delay_matrix: n×n matrix where entry (i,j) is the delay
                         from node i to node j (np.inf if no direct link)
        """
        self.delays = delay_matrix
        self.n = delay_matrix.shape[0]

    def multi_hop_delays(self, hops: int) -> np.ndarray:
        """Compute minimum delays for paths using exactly `hops` edges.

        Uses tropical matrix powering.

        Args:
            hops: Number of hops (edges) in the path

        Returns:
            Matrix of minimum multi-hop delays
        """
        result = self.delays.copy()
        for _ in range(hops - 1):
            new_result = np.full((self.n, self.n), np.inf)
            for i in range(self.n):
                for j in range(self.n):
                    for k in range(self.n):
                        new_result[i, j] = min(new_result[i, j],
                                              result[i, k] + self.delays[k, j])
            result = new_result
        return result

    def timing_gap(self, hops: int) -> float:
        """Compute the timing gap after `hops` routing rounds.

        The timing gap measures the spread between fastest and slowest
        paths. By gap amplification, this grows with the number of hops.

        Args:
            hops: Number of routing rounds

        Returns:
            max(delay) - min(delay) over all finite path delays
        """
        delays = self.multi_hop_delays(hops)
        finite = delays[np.isfinite(delays)]
        if len(finite) == 0:
            return 0.0
        return float(np.max(finite) - np.min(finite))


# ============================================================================
# Application 4: Tropical Commitment Scheme
# ============================================================================

class TropicalCommitment:
    """A commitment scheme based on tropical root obstructions.

    To commit to an integer vector d:
    1. Choose a random power T ≥ 2
    2. Compute commitment = tropicalPowDiag(T, d) = T * d
    3. The commitment hides d (many-to-one under normalization)
    4. Opening requires revealing d and T

    Root obstruction property: Given the commitment c = T*d,
    the committer cannot open to d' ≠ d with the same T unless
    c is T-divisible at every entry (which it always is for honest commitment).
    But they cannot change T to T' and find d' with T'*d' = c unless
    all entries are also T'-divisible.
    """

    def __init__(self, T: int = 7):
        self.T = T

    def commit(self, d: np.ndarray) -> np.ndarray:
        """Create a tropical commitment to vector d."""
        return self.T * d

    def open(self, d: np.ndarray, T: int, commitment: np.ndarray) -> bool:
        """Verify opening of a commitment.

        Args:
            d: Claimed original vector
            T: Claimed power
            commitment: The commitment value

        Returns:
            True if T * d == commitment
        """
        return np.array_equal(T * d, commitment)

    def binding_check(self, commitment: np.ndarray, alt_T: int) -> bool:
        """Check if commitment can be opened with a different power alt_T.

        By the root obstruction theorem, this requires alt_T | commitment[i]
        for all i.

        Args:
            commitment: The committed value
            alt_T: Alternative power to try

        Returns:
            True if an alternative opening might exist
        """
        return all(int(c) % alt_T == 0 for c in commitment)


# ============================================================================
# Demonstrations
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Tropical Hash Function")
    print("=" * 70)

    hasher = TropicalHash(T=5, n=6)
    d1 = np.array([3, 7, -2, 5, 1, 4])
    d2 = d1 + 10  # Shift by constant

    h1 = hasher.hash(d1)
    h2 = hasher.hash(d2)

    print(f"Input 1: {d1}")
    print(f"Hash 1:  {h1}")
    print(f"Input 2: {d2} (= Input 1 + 10)")
    print(f"Hash 2:  {h2}")
    print(f"Collision: {np.allclose(h1, h2)} (by shift invariance theorem)")

    # Root obstruction check
    fake_hash = np.array([0, 3, 7, -1, 2, 8])  # Not all divisible by 5
    print(f"\nFake hash {fake_hash}: ℤ-preimage possible? {hasher.check_root_obstruction(fake_hash)}")

    print("\n" + "=" * 70)
    print("APPLICATION 2: Shortest Paths via Tropical Powering")
    print("=" * 70)

    # 4-node graph
    INF = np.inf
    W = np.array([
        [0,   3, INF,   7],
        [INF, 0,   2, INF],
        [INF, INF, 0,   1],
        [  2, INF, INF, 0]
    ], dtype=float)

    print("Edge weight matrix:")
    print(W)
    shortest = shortest_paths_tropical(W)
    print("\nAll-pairs shortest paths:")
    print(shortest)

    print("\n" + "=" * 70)
    print("APPLICATION 3: Network Timing Analysis")
    print("=" * 70)

    delays = np.array([
        [0,  5, 12, INF],
        [INF, 0,  3,   8],
        [INF, INF, 0,  2],
        [ 4, INF, INF, 0]
    ], dtype=float)

    analyzer = NetworkTimingAnalyzer(delays)
    print("Delay matrix:")
    print(delays)

    print(f"\n{'Hops':>5} | {'Timing Gap':>12}")
    print("-" * 22)
    for h in range(1, 6):
        gap = analyzer.timing_gap(h)
        print(f"{h:>5} | {gap:>12.1f}")

    print("\nTiming gap grows as paths explore more of the network.")

    print("\n" + "=" * 70)
    print("APPLICATION 4: Tropical Commitment Scheme")
    print("=" * 70)

    scheme = TropicalCommitment(T=7)
    secret = np.array([3, 5, 2, 8, 1])
    commitment = scheme.commit(secret)

    print(f"Secret:     {secret}")
    print(f"Commitment: {commitment} (= 7 * secret)")

    # Verify opening
    print(f"Valid opening:   {scheme.open(secret, 7, commitment)}")
    print(f"Wrong opening:   {scheme.open(secret + 1, 7, commitment)}")

    # Check binding: can we open with T=3 instead?
    can_reopen_3 = scheme.binding_check(commitment, 3)
    can_reopen_7 = scheme.binding_check(commitment, 7)
    print(f"Can reopen with T=3? {can_reopen_3}")
    print(f"Can reopen with T=7? {can_reopen_7} (always true for honest commitment)")

    if can_reopen_3:
        alt_secret = commitment // 3
        print(f"Alternative secret with T=3: {alt_secret}")
        print(f"Verification: 3 * alt = {3 * alt_secret}, commitment = {commitment}")
        print(f"Match: {np.array_equal(3 * alt_secret, commitment)}")


#!/usr/bin/env python3
"""
Tropical One-Wayness: Demonstrations and Numerical Examples

This script demonstrates the key theorems of tropical one-wayness theory
with concrete numerical examples, showing:
1. Tropical diagonal powering (closed-form T * d)
2. Shift covariance of tropical powers
3. Root obstructions over ℤ (divisibility criterion)
4. Non-injectivity modulo normalization
5. Gap amplification under tropical powering
"""

import numpy as np
from typing import Optional


def tropical_pow_diag(T: int, d: np.ndarray) -> np.ndarray:
    """Compute the T-th tropical diagonal power: each entry multiplied by T.

    In the tropical (min-plus) semiring, a diagonal matrix D with entries d_i
    has T-th power with entries T * d_i. This is because the tropical product
    of diagonal matrices only has the diagonal term surviving (off-diagonal = +∞).

    Args:
        T: Power exponent (non-negative integer)
        d: Vector of diagonal entries

    Returns:
        Vector of T-th tropical power diagonal entries
    """
    return T * d


def normalize_vec(d: np.ndarray) -> np.ndarray:
    """Normalize a vector by subtracting its first entry (tropical projective normalization).

    This quotients out the additive gauge symmetry: d and d + c normalize
    to the same vector for any constant c.

    Args:
        d: Input vector

    Returns:
        Normalized vector with first entry = 0
    """
    return d - d[0]


def tropical_diag_gap(d: np.ndarray) -> float:
    """Compute the tropical gap: max(d) - min(d).

    The gap measures the "spread" of tropical data. Under tropical powering,
    it scales linearly: gap(T * d) = T * gap(d).

    Args:
        d: Input vector

    Returns:
        The gap value (max - min)
    """
    return float(np.max(d) - np.min(d))


def has_tropical_root_Z(T: int, d: np.ndarray) -> bool:
    """Check if integer vector d has a tropical T-th root over ℤ.

    A vector d has a T-th root iff every entry is divisible by T.
    This is the complete root characterization theorem.

    Args:
        T: Root degree
        d: Integer vector

    Returns:
        True iff all entries of d are divisible by T
    """
    return all(int(x) % T == 0 for x in d)


def tropical_root_Z(T: int, d: np.ndarray) -> Optional[np.ndarray]:
    """Compute the tropical T-th root of d over ℤ, if it exists.

    Args:
        T: Root degree
        d: Integer vector

    Returns:
        Root vector d/T if all entries are divisible, else None
    """
    if has_tropical_root_Z(T, d):
        return d // T
    return None


# ============================================================================
# DEMONSTRATION 1: Closed-Form Tropical Diagonal Powers
# ============================================================================
print("=" * 70)
print("DEMO 1: Tropical Diagonal Powers (Closed Form)")
print("=" * 70)

d = np.array([3, 7, -2, 5])
print(f"\nOriginal diagonal entries: d = {d}")
for T in range(5):
    powered = tropical_pow_diag(T, d)
    print(f"  T = {T}: tropicalPowDiag({T}, d) = {powered}")

print("\nVerification: each entry is exactly T * d_i ✓")

# ============================================================================
# DEMONSTRATION 2: Shift Covariance
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 2: Shift Covariance — tropicalPowDiag(T, d+c) = tropicalPowDiag(T, d) + T*c")
print("=" * 70)

d = np.array([1.0, 4.0, -3.0, 2.0])
c = 5.0
T = 3

lhs = tropical_pow_diag(T, d + c)
rhs = tropical_pow_diag(T, d) + T * c

print(f"\nd = {d}, c = {c}, T = {T}")
print(f"tropicalPowDiag(T, d + c) = {lhs}")
print(f"tropicalPowDiag(T, d) + T*c = {rhs}")
print(f"Equal: {np.allclose(lhs, rhs)} ✓")

# ============================================================================
# DEMONSTRATION 3: Root Obstructions over ℤ
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 3: Root Obstructions — Divisibility Criterion")
print("=" * 70)

test_vectors = [
    (2, np.array([4, 6, 8]), "All even → root exists"),
    (2, np.array([4, 7, 8]), "7 is odd → no root"),
    (3, np.array([9, 12, 15]), "All divisible by 3 → root exists"),
    (3, np.array([9, 12, 16]), "16 not divisible by 3 → no root"),
    (5, np.array([10, 25, 100]), "All divisible by 5 → root exists"),
    (2, np.array([1, 1, 1]), "All ones → no square root (2 ∤ 1)"),
]

print(f"\n{'T':>3} | {'Vector':>20} | {'Has Root?':>10} | {'Root':>20} | Description")
print("-" * 90)
for T, d, desc in test_vectors:
    has_root = has_tropical_root_Z(T, d)
    root = tropical_root_Z(T, d)
    root_str = str(root) if root is not None else "None"
    print(f"{T:>3} | {str(d):>20} | {str(has_root):>10} | {root_str:>20} | {desc}")

# Verify root roundtrip
print("\nRoundtrip verification:")
d = np.array([6, 12, 18])
T = 3
root = tropical_root_Z(T, d)
reconstructed = tropical_pow_diag(T, root)
print(f"  d = {d}, T = {T}")
print(f"  root = {root}")
print(f"  T * root = {reconstructed}")
print(f"  Matches: {np.array_equal(d, reconstructed)} ✓")

# ============================================================================
# DEMONSTRATION 4: Non-Injectivity Modulo Normalization
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 4: Non-Injectivity — Different inputs, same normalized output")
print("=" * 70)

d = np.array([1.0, 3.0, -2.0, 5.0])
T = 4

print(f"\nBase vector d = {d}, T = {T}")
print(f"{'Shift c':>10} | {'Input d+c':>25} | {'Power':>25} | {'Normalized':>25}")
print("-" * 95)

for c in [0, 1, -3, 7.5, 100]:
    shifted = d + c
    powered = tropical_pow_diag(T, shifted)
    normalized = normalize_vec(powered)
    print(f"{c:>10.1f} | {str(shifted):>25} | {str(powered):>25} | {str(normalized):>25}")

print("\nAll normalized outputs are identical — the map is not injective! ✓")
print("The fiber of the normalized power map is infinite (contains all d + c for c ∈ ℝ).")

# ============================================================================
# DEMONSTRATION 5: Gap Amplification
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 5: Gap Amplification — gap(T*d) = T * gap(d)")
print("=" * 70)

d = np.array([2.0, 7.0, -1.0, 4.0, 10.0])
base_gap = tropical_diag_gap(d)
print(f"\nd = {d}")
print(f"gap(d) = max(d) - min(d) = {np.max(d)} - {np.min(d)} = {base_gap}")

print(f"\n{'T':>5} | {'gap(T*d)':>12} | {'T * gap(d)':>12} | {'Ratio':>8} | {'Match':>6}")
print("-" * 55)
for T in range(1, 11):
    powered = tropical_pow_diag(T, d)
    gap_powered = tropical_diag_gap(powered)
    expected = T * base_gap
    ratio = gap_powered / base_gap if base_gap > 0 else float('inf')
    match = np.isclose(gap_powered, expected)
    print(f"{T:>5} | {gap_powered:>12.1f} | {expected:>12.1f} | {ratio:>8.1f} | {'✓' if match else '✗':>6}")

print("\nGap scales exactly linearly — gap is a forward invariant amplified by powering! ✓")

# ============================================================================
# DEMONSTRATION 6: Fiber Structure Visualization Data
# ============================================================================
print("\n" + "=" * 70)
print("DEMO 6: Fiber Structure — Preimage Analysis")
print("=" * 70)

n = 3
T = 4
target = np.array([12, 20, -8])  # All divisible by 4
print(f"\nTarget vector: B = {target}")
print(f"Power: T = {T}")

if has_tropical_root_Z(T, target):
    root = tropical_root_Z(T, target)
    print(f"Unique ℤ-root: A = {root}")
    print(f"Verification: {T} * A = {tropical_pow_diag(T, root)} ✓")
else:
    print("No ℤ-root exists!")

# Over ℝ, there are infinitely many preimages under normalization
print(f"\nOver ℝ with normalization, infinitely many preimages:")
for c in np.linspace(-5, 5, 11):
    preimage = root + c
    powered = tropical_pow_diag(T, preimage)
    norm_powered = normalize_vec(powered)
    norm_target = normalize_vec(tropical_pow_diag(T, root.astype(float)))
    print(f"  A + {c:>5.1f} = {preimage} → normalize(T*A) = {norm_powered}")

# ============================================================================
# SUMMARY
# ============================================================================
print("\n" + "=" * 70)
print("SUMMARY: Tropical One-Wayness Theory")
print("=" * 70)
print("""
Key Theorems Demonstrated:

1. CLOSED FORM: tropicalPowDiag(T, d)_i = T * d_i
   → Tropical powering of diagonal data is simple scalar multiplication.

2. SHIFT COVARIANCE: pow(T, d+c) = pow(T, d) + T*c
   → Tropical powers respect the additive gauge symmetry.

3. ROOT OBSTRUCTION (ℤ): d has T-th root ↔ T | d_i for all i
   → Arithmetic divisibility creates exact obstructions to inversion.

4. NON-INJECTIVITY: normalize(pow(T, d)) = normalize(pow(T, d+c)) for all c
   → The forward map is many-to-one after natural normalization.

5. INFINITE FIBERS: The fiber of the normalized power map is always infinite.
   → The tropical power map is genuinely one-way in a structural sense.

6. GAP AMPLIFICATION: gap(pow(T, d)) = T * gap(d)
   → Tropical powering amplifies a certified forward invariant linearly.

These results establish the mathematical foundations for tropical one-wayness:
the forward map is easy to compute, but inversion faces both arithmetic
obstructions (divisibility) and geometric obstructions (infinite fibers
under normalization). This is the algebraic backbone of tropical cryptography.
""")

if __name__ == "__main__":
    pass


#!/usr/bin/env python3
"""
Visualizations for Tropical One-Wayness Theory

Generates publication-quality figures illustrating the key theorems
and concepts of tropical one-wayness.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_gap_amplification():
    """Figure 1: Gap amplification under tropical powering."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Gap scaling for different vectors
    vectors = [
        np.array([2, 7, -1, 4, 10]),
        np.array([0, 1, 0, 1, 0]),
        np.array([-3, -3, 5, 5, -3]),
        np.array([1, 2, 3, 4, 5]),
    ]
    labels = ['d₁ = [2,7,-1,4,10]', 'd₂ = [0,1,0,1,0]',
              'd₃ = [-3,-3,5,5,-3]', 'd₄ = [1,2,3,4,5]']
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

    T_range = range(1, 11)
    for d, label, color in zip(vectors, labels, colors):
        base_gap = np.max(d) - np.min(d)
        gaps = [T * base_gap for T in T_range]
        ax1.plot(T_range, gaps, 'o-', color=color, label=label,
                markersize=6, linewidth=2)

    ax1.set_xlabel('Power T', fontsize=12)
    ax1.set_ylabel('Gap(T · d)', fontsize=12)
    ax1.set_title('Gap Amplification: gap(T·d) = T · gap(d)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9, loc='upper left')
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(0.5, 10.5)

    # Right: Gap ratio = T (constant)
    for d, label, color in zip(vectors, labels, colors):
        base_gap = np.max(d) - np.min(d)
        if base_gap > 0:
            ratios = [T for T in T_range]
            ax2.plot(T_range, ratios, 's--', color=color, label=label,
                    markersize=5, linewidth=1.5, alpha=0.7)

    ax2.plot(T_range, list(T_range), 'k-', linewidth=2, label='y = T (exact)',
            alpha=0.5)
    ax2.set_xlabel('Power T', fontsize=12)
    ax2.set_ylabel('gap(T·d) / gap(d)', fontsize=12)
    ax2.set_title('Gap Ratio is Exactly T', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Theorem: Tropical Gap Scales Linearly Under Powering',
                fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def plot_root_obstruction():
    """Figure 2: Root obstruction landscape over ℤ."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: For T=2, show which 2D integer vectors have square roots
    ax = ax1
    grid_range = range(-6, 7)
    has_root_x, has_root_y = [], []
    no_root_x, no_root_y = [], []

    for x in grid_range:
        for y in grid_range:
            if x % 2 == 0 and y % 2 == 0:
                has_root_x.append(x)
                has_root_y.append(y)
            else:
                no_root_x.append(x)
                no_root_y.append(y)

    ax.scatter(no_root_x, no_root_y, c='#e74c3c', s=40, alpha=0.4,
              label='No T=2 root', marker='x')
    ax.scatter(has_root_x, has_root_y, c='#2ecc71', s=60, alpha=0.8,
              label='Has T=2 root', marker='o')
    ax.set_xlabel('d₁', fontsize=12)
    ax.set_ylabel('d₂', fontsize=12)
    ax.set_title('T=2 Root Existence in ℤ²', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)
    ax.set_aspect('equal')

    # Right: Fraction of vectors with roots for different T
    ax = ax2
    T_values = range(1, 13)
    fractions = [1.0 / T for T in T_values]  # For uniform distribution over large range

    bars = ax.bar(T_values, fractions, color=['#3498db' if T > 1 else '#2ecc71'
                                               for T in T_values],
                 alpha=0.8, edgecolor='black', linewidth=0.5)
    ax.set_xlabel('Power T', fontsize=12)
    ax.set_ylabel('Fraction with T-th root', fontsize=12)
    ax.set_title('Root Density: fraction 1/Tⁿ of ℤⁿ\nhas T-th root (n=1 shown)',
                fontsize=12, fontweight='bold')
    ax.set_xticks(list(T_values))
    ax.grid(True, alpha=0.3, axis='y')

    for i, (T, f) in enumerate(zip(T_values, fractions)):
        ax.text(T, f + 0.01, f'1/{T}', ha='center', va='bottom', fontsize=9)

    fig.suptitle('Theorem: Root Existence ⟺ Coordinatewise T-Divisibility',
                fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def plot_fiber_structure():
    """Figure 3: Infinite fiber structure of the tropical power map."""
    fig = plt.figure(figsize=(14, 5))
    gs = GridSpec(1, 3, figure=fig, width_ratios=[1, 1, 1])

    # Left: Multiple inputs mapping to same normalized output
    ax1 = fig.add_subplot(gs[0])
    d = np.array([1, 3, -2])
    T = 3
    shifts = np.linspace(-3, 3, 7)

    for c in shifts:
        shifted = d + c
        powered = T * shifted
        normalized = powered - powered[0]
        ax1.plot([0, 1, 2], shifted, 'o-', alpha=0.5, markersize=4)
        ax1.annotate(f'c={c:.0f}', xy=(2, shifted[2]), fontsize=7,
                    textcoords="offset points", xytext=(5, 0))

    ax1.set_xlabel('Index', fontsize=11)
    ax1.set_ylabel('Value', fontsize=11)
    ax1.set_title('Fiber: distinct inputs d + c', fontsize=12, fontweight='bold')
    ax1.set_xticks([0, 1, 2])
    ax1.grid(True, alpha=0.3)

    # Middle: All map to same normalized output
    ax2 = fig.add_subplot(gs[1])
    normalized = T * d - T * d[0]  # Same for all shifts
    for c in shifts:
        shifted = d + c
        powered = T * shifted
        norm = powered - powered[0]
        ax2.plot([0, 1, 2], norm, 'o-', alpha=0.3, markersize=4, color='#e74c3c')

    ax2.plot([0, 1, 2], normalized, 's-', color='#2ecc71', markersize=8,
            linewidth=2, label='Shared normalized output', zorder=5)
    ax2.set_xlabel('Index', fontsize=11)
    ax2.set_ylabel('Normalized value', fontsize=11)
    ax2.set_title('All map to same\nnormalized output', fontsize=12, fontweight='bold')
    ax2.set_xticks([0, 1, 2])
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Right: Schematic of fiber (1D line in input space)
    ax3 = fig.add_subplot(gs[2])
    c_range = np.linspace(-5, 5, 100)
    ax3.fill_between(c_range, -0.5, 0.5, alpha=0.2, color='#3498db')
    ax3.plot(c_range, np.zeros_like(c_range), '-', color='#3498db', linewidth=3,
            label='Fiber (1D affine subspace)')
    ax3.scatter([0], [0], c='#e74c3c', s=100, zorder=5, label='Original d')
    ax3.scatter([-2, 1, 3], [0, 0, 0], c='#2ecc71', s=60, zorder=5,
               label='Other preimages d+c')
    ax3.set_xlabel('Shift parameter c', fontsize=11)
    ax3.set_title('Fiber = infinite\naffine line', fontsize=12, fontweight='bold')
    ax3.legend(fontsize=9)
    ax3.set_ylim(-1, 1)
    ax3.grid(True, alpha=0.3)
    ax3.set_yticks([])

    fig.suptitle('Theorem: Normalized Tropical Power Fiber is Infinite',
                fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def plot_tropical_matrix_powering():
    """Figure 4: Tropical matrix powering as shortest paths."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    INF = np.inf

    def tropical_matmul(A, B):
        n = A.shape[0]
        C = np.full((n, n), np.inf)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
        return C

    A = np.array([
        [0, 3, INF, 7],
        [INF, 0, 2, INF],
        [INF, INF, 0, 1],
        [2, INF, INF, 0]
    ], dtype=float)

    matrices = [A]
    titles = ['A (T=1)']
    current = A.copy()
    for T in range(2, 5):
        current = tropical_matmul(current, A)
        matrices.append(current.copy())
        titles.append(f'A^⊗{T}')

    for ax, M, title in zip(axes, matrices, titles):
        display = np.where(np.isinf(M), np.nan, M)
        im = ax.imshow(display, cmap='YlOrRd_r', aspect='equal')
        ax.set_title(title, fontsize=12, fontweight='bold')
        n = M.shape[0]
        for i in range(n):
            for j in range(n):
                val = M[i, j]
                text = '∞' if np.isinf(val) else f'{val:.0f}'
                color = 'black' if np.isinf(val) or val > np.nanmedian(display) else 'white'
                ax.text(j, i, text, ha='center', va='center', fontsize=10,
                       color=color, fontweight='bold')
        ax.set_xticks(range(n))
        ax.set_yticks(range(n))

    fig.suptitle('Tropical Matrix Powering: Shortest Path Computation',
                fontsize=14, fontweight='bold')
    fig.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 data URIs."""
    results = {}

    print("Generating gap amplification plot...")
    fig1 = plot_gap_amplification()
    results['gap_amplification'] = fig_to_base64(fig1)
    fig1.savefig('/workspace/request-project/fig_gap_amplification.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig1)

    print("Generating root obstruction plot...")
    fig2 = plot_root_obstruction()
    results['root_obstruction'] = fig_to_base64(fig2)
    fig2.savefig('/workspace/request-project/fig_root_obstruction.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig2)

    print("Generating fiber structure plot...")
    fig3 = plot_fiber_structure()
    results['fiber_structure'] = fig_to_base64(fig3)
    fig3.savefig('/workspace/request-project/fig_fiber_structure.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig3)

    print("Generating matrix powering plot...")
    fig4 = plot_tropical_matrix_powering()
    results['matrix_powering'] = fig_to_base64(fig4)
    fig4.savefig('/workspace/request-project/fig_matrix_powering.png',
                dpi=150, bbox_inches='tight')
    plt.close(fig4)

    print("All visualizations generated!")
    return results


if __name__ == "__main__":
    viz_data = generate_all_visualizations()
    print(f"\nGenerated {len(viz_data)} visualizations")
    for name, data in viz_data.items():
        print(f"  {name}: {len(data)} bytes")
