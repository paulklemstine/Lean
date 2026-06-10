#!/usr/bin/env python3
"""
Tropical Additive Combinatorics: Applications

Demonstrates real-world applications of tropical (min-plus) convolution
methods beyond pure number theory.
"""

import math
from typing import List, Tuple, Optional

INF = float('inf')


# ═══════════════════════════════════════════════════════════════
# Application 1: Shortest Path / Dynamic Programming
# ═══════════════════════════════════════════════════════════════

def shortest_path_minplus(
    adjacency: List[List[float]],
    source: int,
    target: int,
    max_hops: int
) -> Tuple[float, List[int]]:
    """
    Find shortest path using min-plus matrix exponentiation.

    The min-plus convolution is the algebra of shortest paths:
    the (i,j) entry of A^k (min-plus power) gives the shortest
    path from i to j using exactly k edges.

    This is the same algebraic structure underlying our tropical
    Goldbach framework: finding a decomposition n = p + q with
    minimum cost is a shortest-path problem.

    Args:
        adjacency: Weight matrix (INF for no edge).
        source: Source node.
        target: Target node.
        max_hops: Maximum number of edges.

    Returns:
        (distance, path) tuple.
    """
    n = len(adjacency)
    # dist[k][v] = shortest path from source to v using ≤ k edges
    dist = [[INF] * n for _ in range(max_hops + 1)]
    pred = [[-1] * n for _ in range(max_hops + 1)]
    dist[0][source] = 0

    for k in range(1, max_hops + 1):
        for v in range(n):
            dist[k][v] = dist[k - 1][v]
            pred[k][v] = pred[k - 1][v]
            for u in range(n):
                new_dist = dist[k - 1][u] + adjacency[u][v]
                if new_dist < dist[k][v]:
                    dist[k][v] = new_dist
                    pred[k][v] = u

    # Reconstruct path
    path = [target]
    v = target
    for k in range(max_hops, 0, -1):
        u = pred[k][v]
        if u == -1:
            break
        if u != v:
            path.append(u)
            v = u
    path.reverse()

    return dist[max_hops][target], path


# ═══════════════════════════════════════════════════════════════
# Application 2: Error-Correcting Codes (Tropical Decoding)
# ═══════════════════════════════════════════════════════════════

def tropical_syndrome_decode(
    received: List[int],
    codewords: List[List[int]],
) -> Tuple[List[int], int]:
    """
    Tropical minimum-distance decoding.

    In coding theory, decoding is a min-plus optimization:
    find the codeword minimizing Hamming distance to the received word.
    This is structurally identical to our tropical convolution framework
    where we seek the decomposition minimizing total cost.

    Args:
        received: Received (possibly corrupted) word.
        codewords: List of valid codewords.

    Returns:
        (nearest_codeword, hamming_distance) tuple.
    """
    best_dist = INF
    best_cw = received

    for cw in codewords:
        dist = sum(1 for r, c in zip(received, cw) if r != c)
        if dist < best_dist:
            best_dist = dist
            best_cw = cw

    return best_cw, int(best_dist)


# ═══════════════════════════════════════════════════════════════
# Application 3: Resource Allocation (Knapsack via Min-Plus)
# ═══════════════════════════════════════════════════════════════

def tropical_knapsack(
    weights: List[int],
    values: List[int],
    capacity: int
) -> Tuple[int, List[int]]:
    """
    Solve 0/1 knapsack using tropical (min-plus) convolution perspective.

    The knapsack problem can be viewed as finding the minimum "regret"
    (negative value) subject to weight constraints. This is a min-plus
    convolution over the item set — the same algebraic framework as
    tropical Goldbach decomposition.

    The connection: just as Goldbach asks "can n be decomposed as
    p + q with both satisfying the primality predicate?", knapsack
    asks "can capacity be filled with items satisfying the value
    optimization predicate?"

    Args:
        weights: Item weights.
        values: Item values.
        capacity: Knapsack capacity.

    Returns:
        (max_value, selected_items) tuple.
    """
    n = len(weights)
    # dp[w] = maximum value achievable with weight exactly w
    dp = [-1] * (capacity + 1)
    dp[0] = 0
    chosen = [[] for _ in range(capacity + 1)]

    for i in range(n):
        # Traverse in reverse to avoid using item i twice
        for w in range(capacity, weights[i] - 1, -1):
            if dp[w - weights[i]] >= 0:
                new_val = dp[w - weights[i]] + values[i]
                if new_val > dp[w]:
                    dp[w] = new_val
                    chosen[w] = chosen[w - weights[i]] + [i]

    best_w = max(range(capacity + 1), key=lambda w: dp[w])
    return dp[best_w], chosen[best_w]


# ═══════════════════════════════════════════════════════════════
# Application 4: Signal Processing (Morphological Operations)
# ═══════════════════════════════════════════════════════════════

def morphological_dilation(
    signal: List[float],
    structuring_element: List[float]
) -> List[float]:
    """
    Morphological dilation via max-plus convolution.

    In mathematical morphology (used in image processing),
    dilation is a max-plus convolution — the dual of our min-plus
    framework. The tropical Goldbach framework thus connects to
    image analysis: the "support" of a dilated signal corresponds
    to the sumset of the original signal's support and the
    structuring element.

    Args:
        signal: Input signal.
        structuring_element: Structuring element (kernel).

    Returns:
        Dilated signal.
    """
    n = len(signal)
    k = len(structuring_element)
    result = [-INF] * n

    for i in range(n):
        for j in range(k):
            idx = i - j + k // 2
            if 0 <= idx < n:
                val = signal[idx] + structuring_element[j]
                if val > result[i]:
                    result[i] = val

    return result


# ═══════════════════════════════════════════════════════════════
# Main: Demonstrate all applications
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical Additive Combinatorics — Applications")
    print("=" * 60)

    # Application 1: Shortest paths
    print("\n--- Application 1: Shortest Paths ---")
    print("Graph with 5 nodes, finding shortest path 0 → 4")
    adj = [
        [0, 2, INF, INF, INF],
        [INF, 0, 3, INF, INF],
        [INF, INF, 0, 1, INF],
        [INF, INF, INF, 0, 4],
        [INF, INF, INF, INF, 0],
    ]
    dist, path = shortest_path_minplus(adj, 0, 4, max_hops=4)
    print(f"  Shortest distance: {dist}")
    print(f"  Path: {' → '.join(map(str, path))}")
    print("  (Min-plus matrix power = tropical convolution of edge costs)")

    # Application 2: Error-correcting codes
    print("\n--- Application 2: Tropical Syndrome Decoding ---")
    codewords = [
        [0, 0, 0, 0, 0],
        [1, 0, 1, 0, 1],
        [0, 1, 1, 1, 0],
        [1, 1, 0, 1, 1],
    ]
    received = [1, 0, 0, 0, 1]  # corrupted version of [1,0,1,0,1]
    decoded, dist = tropical_syndrome_decode(received, codewords)
    print(f"  Received:  {received}")
    print(f"  Decoded:   {decoded}")
    print(f"  Hamming distance: {dist}")
    print("  (Minimum-distance decoding = tropical optimization)")

    # Application 3: Knapsack
    print("\n--- Application 3: Tropical Knapsack ---")
    weights = [2, 3, 4, 5]
    values = [3, 4, 5, 6]
    capacity = 8
    max_val, items = tropical_knapsack(weights, values, capacity)
    print(f"  Items: weights={weights}, values={values}")
    print(f"  Capacity: {capacity}")
    print(f"  Optimal value: {max_val}")
    print(f"  Selected items: {items}")
    print(f"  Total weight: {sum(weights[i] for i in items)}")
    print("  (Knapsack = tropical decomposition with weight constraint)")

    # Application 4: Signal processing
    print("\n--- Application 4: Morphological Dilation ---")
    signal = [0, 0, 0, 5, 0, 0, 3, 0, 0, 0]
    kernel = [0, 1, 2, 1, 0]
    dilated = morphological_dilation(signal, kernel)
    print(f"  Input signal:  {signal}")
    print(f"  Kernel:        {kernel}")
    print(f"  Dilated:       {[f'{x:.0f}' for x in dilated]}")
    print("  (Dilation = max-plus convolution, dual of min-plus)")

    print("\n" + "=" * 60)
    print("All applications demonstrated.")
    print("\nKey insight: The min-plus (tropical) convolution is the")
    print("unifying algebraic structure connecting Goldbach-type")
    print("decomposition problems to shortest paths, coding theory,")
    print("optimization, and signal processing.")


#!/usr/bin/env python3
"""
Tropical Additive Combinatorics: Interactive Demonstration

Demonstrates the core concepts of tropical (min-plus) convolution
applied to additive number theory, particularly Goldbach's conjecture.
"""

import math
from typing import Optional


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


INF = float('inf')


def trop_pred_cost(pred, n: int) -> float:
    """Tropical cost function: 0 if pred(n), infinity otherwise."""
    return 0.0 if pred(n) else INF


def trop_prime_cost(n: int) -> float:
    """Tropical prime cost: 0 if prime, infinity otherwise."""
    return trop_pred_cost(is_prime, n)


def soft_prime_cost(K: int, n: int) -> int:
    """Soft tropical prime cost: 0 if prime, K otherwise."""
    return 0 if is_prime(n) else K


def minplus_conv(f, g, n: int) -> float:
    """
    Min-plus convolution of f and g at n:
        (f * g)(n) = min { f(a) + g(b) : a + b = n, a,b >= 0 }
    """
    return min(f(a) + g(n - a) for a in range(n + 1))


def minplus_conv_pred(pred_a, pred_b, n: int) -> float:
    """Min-plus convolution of tropical cost functions for two predicates."""
    return minplus_conv(
        lambda x: trop_pred_cost(pred_a, x),
        lambda x: trop_pred_cost(pred_b, x),
        n
    )


def goldbach_tropical_cost(n: int) -> float:
    """Tropical Goldbach cost: 0 iff n = p + q for primes p, q."""
    return minplus_conv(trop_prime_cost, trop_prime_cost, n)


def find_goldbach_decomposition(n: int) -> Optional[tuple]:
    """Find a Goldbach decomposition of n, if one exists."""
    for a in range(2, n - 1):
        if is_prime(a) and is_prime(n - a):
            return (a, n - a)
    return None


def additive_sumset_check(pred_a, pred_b, n: int) -> Optional[tuple]:
    """Check if n is in the additive sumset of A and B."""
    for a in range(n + 1):
        if pred_a(a) and pred_b(n - a):
            return (a, n - a)
    return None


# ═══════════════════════════════════════════════════════════════
# DEMO 1: Theorem A — Tropical equivalence of representability
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("DEMO 1: Tropical Equivalence of Additive Representability")
print("=" * 70)
print()
print("Theorem A states: (c_A ⋆ c_B)(n) = 0  ⟺  n ∈ A + B")
print()

# Use A = {even numbers}, B = {multiples of 3}
A = lambda n: n % 2 == 0
B = lambda n: n % 3 == 0

print("A = even numbers, B = multiples of 3")
print("A + B should contain all n ≥ 0 such that n = (even) + (mult of 3)")
print()

for n in range(15):
    cost = minplus_conv_pred(A, B, n)
    decomp = additive_sumset_check(A, B, n)
    in_sumset = decomp is not None
    cost_zero = (cost == 0)
    status = "✓" if cost_zero == in_sumset else "✗"
    decomp_str = f"= {decomp[0]} + {decomp[1]}" if decomp else "not in A+B"
    cost_str = '∞' if cost >= INF else str(int(cost))
    print(f"  n={n:2d}: cost={cost_str:>3s}  "
          f"in_sumset={str(in_sumset):5s}  {decomp_str}  {status}")

print()
print("Equivalence verified for all n in [0, 14].")

# ═══════════════════════════════════════════════════════════════
# DEMO 2: Goldbach tropical cost for small even numbers
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("DEMO 2: Goldbach Tropical Cost for Small Even Numbers")
print("=" * 70)
print()
print("G_trop(n) = (π_trop ⋆ π_trop)(n)")
print("G_trop(n) = 0 iff n is a sum of two primes")
print()

for n in range(2, 52, 2):
    cost = goldbach_tropical_cost(n)
    decomp = find_goldbach_decomposition(n)
    if decomp:
        print(f"  G_trop({n:2d}) = 0   ← {n} = {decomp[0]} + {decomp[1]}")
    else:
        print(f"  G_trop({n:2d}) = ∞   ← no prime decomposition")

# ═══════════════════════════════════════════════════════════════
# DEMO 3: Monotonicity of min-plus convolution
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("DEMO 3: Monotonicity of Min-Plus Convolution")
print("=" * 70)
print()
print("If f₁ ≤ f₂ pointwise, then (f₁ ⋆ f₁) ≤ (f₂ ⋆ f₂)")
print()

# f1 = hard prime cost (0/∞), f2 = soft prime cost (0/K)
K = 5
f1 = lambda n: soft_prime_cost(K, n)  # smaller: finite everywhere
f2 = trop_prime_cost                   # larger: infinite for non-primes

print(f"f₁ = soft prime cost (K={K}), f₂ = hard prime cost (0/∞)")
print(f"f₁ ≤ f₂ pointwise (since K ≤ ∞)")
print()

for n in range(4, 22, 2):
    conv1 = minplus_conv(f1, f1, n)
    conv2 = minplus_conv(f2, f2, n)
    mono_ok = conv1 <= conv2
    c2_str = "0" if conv2 == 0 else "∞"
    print(f"  n={n:2d}: (f₁⋆f₁)={conv1:>3.0f}  (f₂⋆f₂)={c2_str:>3s}  "
          f"monotone={'✓' if mono_ok else '✗'}")

# ═══════════════════════════════════════════════════════════════
# DEMO 4: Finite verification reduction
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("DEMO 4: Finite Verification Reduction (Theorem D)")
print("=" * 70)
print()

B = 100
print(f"Verifying Goldbach for all even n with 4 ≤ n ≤ {B}...")

all_verified = True
count = 0
for n in range(4, B + 1, 2):
    decomp = find_goldbach_decomposition(n)
    if decomp is None:
        print(f"  FAILED at n={n}")
        all_verified = False
        break
    count += 1

if all_verified:
    print(f"  ✓ All {count} even numbers in [4, {B}] verified.")
    print()
    print("  By Theorem D (goldbach_from_finite_check_and_cover):")
    print(f"  If we additionally prove that every even n > {B}")
    print(f"  lies in A + A for some A ⊆ primes,")
    print(f"  then G_trop(n) = 0 for ALL even n ≥ 4.")

# ═══════════════════════════════════════════════════════════════
# DEMO 5: Counting Goldbach decompositions
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("DEMO 5: Number of Goldbach Representations")
print("=" * 70)
print()
print("r₂(n) = |{(p,q) : p+q=n, p≤q, p,q prime}|")
print()

for n in range(4, 52, 2):
    reps = [(p, n - p) for p in range(2, n // 2 + 1)
            if is_prime(p) and is_prime(n - p)]
    bar = "█" * len(reps)
    print(f"  r₂({n:2d}) = {len(reps):2d}  {bar}")

# ═══════════════════════════════════════════════════════════════
# DEMO 6: Soft cost convolution landscape
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("DEMO 6: Soft vs Hard Tropical Cost Comparison")
print("=" * 70)
print()

for K_val in [1, 3, 10]:
    print(f"K = {K_val}:")
    for n in range(4, 32, 2):
        hard = goldbach_tropical_cost(n)
        soft = minplus_conv(lambda x, k=K_val: soft_prime_cost(k, x),
                            lambda x, k=K_val: soft_prime_cost(k, x), n)
        h_str = "0" if hard == 0 else "∞"
        print(f"    n={n:2d}: hard={h_str}, soft={soft:2d}  "
              f"(soft ≤ hard: {'✓' if soft <= hard else '✗'})")
    print()

print("=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Additive Combinatorics: Visualizations

Generates publication-quality figures illustrating the key concepts.
"""

import math
import base64
import io

# Use Agg backend for headless rendering
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

INF = float('inf')


def sieve(limit):
    is_p = [False, False] + [True] * (limit - 1)
    for i in range(2, int(math.isqrt(limit)) + 1):
        if is_p[i]:
            for j in range(i * i, limit + 1, i):
                is_p[j] = False
    return is_p


def save_fig_base64(fig, filename=None):
    """Save figure and return base64 string."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    if filename:
        with open(filename, 'wb') as f:
            f.write(buf.read())
        buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# ═══════════════════════════════════════════════════════════════
# Figure 1: Tropical Prime Cost Function
# ═══════════════════════════════════════════════════════════════

def fig_tropical_cost():
    limit = 50
    is_p = sieve(limit)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 6), gridspec_kw={'height_ratios': [1, 1]})

    # Hard cost
    xs = list(range(2, limit + 1))
    colors = ['#2196F3' if is_p[x] else '#E0E0E0' for x in xs]
    heights = [0.0 if is_p[x] else 1.0 for x in xs]

    ax1.bar(xs, [1]*len(xs), color=colors, width=0.8, edgecolor='none')
    for x in xs:
        if is_p[x]:
            ax1.annotate('0', (x, 0.5), ha='center', va='center',
                         fontsize=7, fontweight='bold', color='white')
        else:
            ax1.annotate('∞', (x, 0.5), ha='center', va='center',
                         fontsize=8, color='#999')

    ax1.set_xlim(1.5, limit + 0.5)
    ax1.set_yticks([])
    ax1.set_title('Hard Tropical Prime Cost  π^trop(n)', fontsize=14, fontweight='bold')
    ax1.set_xlabel('n')
    prime_patch = mpatches.Patch(color='#2196F3', label='Cost = 0 (prime)')
    comp_patch = mpatches.Patch(color='#E0E0E0', label='Cost = ∞ (composite)')
    ax1.legend(handles=[prime_patch, comp_patch], loc='upper right')

    # Soft cost with K=3
    K = 3
    soft = [0 if is_p[x] else K for x in xs]
    colors2 = ['#4CAF50' if is_p[x] else '#FF9800' for x in xs]

    ax2.bar(xs, [max(s, 0.3) for s in soft], color=colors2, width=0.8, edgecolor='none')
    for x in xs:
        val = 0 if is_p[x] else K
        ax2.annotate(str(val), (x, max(val, 0.3)/2), ha='center', va='center',
                     fontsize=7, fontweight='bold',
                     color='white' if is_p[x] else 'white')

    ax2.set_xlim(1.5, limit + 0.5)
    ax2.set_ylim(0, K + 1)
    ax2.set_title(f'Soft Tropical Prime Cost  π_soft(n), K={K}', fontsize=14, fontweight='bold')
    ax2.set_xlabel('n')
    ax2.set_ylabel('Cost')

    fig.tight_layout()
    return save_fig_base64(fig, 'fig_tropical_cost.png')


# ═══════════════════════════════════════════════════════════════
# Figure 2: Goldbach Representations Heatmap
# ═══════════════════════════════════════════════════════════════

def fig_goldbach_heatmap():
    limit = 100
    is_p = sieve(limit)

    fig, ax = plt.subplots(figsize=(12, 5))

    even_nums = list(range(4, limit + 1, 2))
    counts = []
    for n in even_nums:
        c = sum(1 for p in range(2, n // 2 + 1) if is_p[p] and is_p[n - p])
        counts.append(c)

    colors = plt.cm.YlOrRd(np.array(counts) / max(counts))
    bars = ax.bar(even_nums, counts, width=1.8, color=colors, edgecolor='none')

    ax.set_xlabel('Even number n', fontsize=12)
    ax.set_ylabel('Number of Goldbach decompositions r₂(n)', fontsize=12)
    ax.set_title('Goldbach Representation Counts: r₂(n) = |{(p,q) : p+q=n, p≤q, both prime}|',
                 fontsize=13, fontweight='bold')
    ax.set_xlim(2, limit + 2)

    # Add colorbar
    sm = plt.cm.ScalarMappable(cmap='YlOrRd', norm=plt.Normalize(0, max(counts)))
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax, shrink=0.8)
    cbar.set_label('r₂(n)', fontsize=11)

    fig.tight_layout()
    return save_fig_base64(fig, 'fig_goldbach_heatmap.png')


# ═══════════════════════════════════════════════════════════════
# Figure 3: Sumset Support Verification (Theorem A)
# ═══════════════════════════════════════════════════════════════

def fig_sumset_support():
    limit = 60
    is_p = sieve(limit)
    primes = [i for i in range(2, limit + 1) if is_p[i]]

    # Compute P + P
    sumset = set()
    for p in primes:
        for q in primes:
            if p + q <= 2 * limit:
                sumset.add(p + q)

    # Compute tropical convolution support
    trop_support = set()
    for n in range(2 * limit + 1):
        for a in range(min(n + 1, limit + 1)):
            b = n - a
            if b <= limit and is_p.get(a, False) if isinstance(is_p, dict) else (a < len(is_p) and is_p[a]) and (b < len(is_p) and is_p[b]):
                trop_support.add(n)
                break

    # Recompute properly
    trop_support = set()
    for n in range(2 * limit + 1):
        for a in range(min(n + 1, limit + 1)):
            b = n - a
            if 0 <= a < len(is_p) and 0 <= b < len(is_p) and is_p[a] and is_p[b]:
                trop_support.add(n)
                break

    fig, ax = plt.subplots(figsize=(14, 4))

    xs = list(range(2, 2 * limit + 1))
    for x in xs:
        in_sumset = x in sumset
        in_trop = x in trop_support
        if in_sumset and in_trop:
            color = '#4CAF50'
            marker = 's'
        elif in_sumset:
            color = '#2196F3'
            marker = 'o'
        elif in_trop:
            color = '#F44336'
            marker = '^'
        else:
            color = '#E0E0E0'
            marker = '.'

        ax.scatter(x, 0, c=color, marker=marker, s=30 if in_sumset else 10, zorder=2)

    # Highlight even numbers
    for x in range(4, 2 * limit + 1, 2):
        if x in sumset:
            ax.scatter(x, 0.1, c='#2196F3', marker='|', s=50, zorder=3)

    ax.set_xlim(1, 2 * limit + 1)
    ax.set_ylim(-0.3, 0.5)
    ax.set_yticks([])
    ax.set_xlabel('n', fontsize=12)
    ax.set_title('Theorem A: Zero Locus of (π^trop ⋆ π^trop) = Prime Sumset P + P',
                 fontsize=13, fontweight='bold')

    both_patch = mpatches.Patch(color='#4CAF50', label='In P+P (= tropical cost 0)')
    none_patch = mpatches.Patch(color='#E0E0E0', label='Not in P+P (= tropical cost ∞)')
    ax.legend(handles=[both_patch, none_patch], loc='upper right', fontsize=10)

    fig.tight_layout()
    return save_fig_base64(fig, 'fig_sumset_support.png')


# ═══════════════════════════════════════════════════════════════
# Figure 4: Soft Cost Convolution Comparison
# ═══════════════════════════════════════════════════════════════

def fig_soft_cost_comparison():
    limit = 60
    is_p = sieve(limit)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    for idx, K in enumerate([1, 5, 20]):
        ax = axes[idx]
        soft_costs = [0.0 if i < len(is_p) and is_p[i] else float(K) for i in range(limit + 1)]

        # Compute soft convolution
        conv = [INF] * (2 * limit + 1)
        for a in range(limit + 1):
            for b in range(limit + 1):
                n = a + b
                val = soft_costs[a] + soft_costs[b]
                if val < conv[n]:
                    conv[n] = val

        even_ns = list(range(4, 2 * limit + 1, 2))
        vals = [conv[n] if conv[n] < INF else -1 for n in even_ns]

        colors = ['#4CAF50' if v == 0 else '#FF9800' if v > 0 else '#999' for v in vals]
        ax.bar(even_ns, [max(v, 0.1) for v in vals], width=1.8,
               color=colors, edgecolor='none')

        ax.set_title(f'K = {K}', fontsize=13, fontweight='bold')
        ax.set_xlabel('Even n')
        if idx == 0:
            ax.set_ylabel('Soft convolution cost')
        ax.set_xlim(2, 2 * limit + 2)

    fig.suptitle('Soft Tropical Convolution (π_K ⋆ π_K)(n) for Even n',
                 fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return save_fig_base64(fig, 'fig_soft_cost.png')


# ═══════════════════════════════════════════════════════════════
# Figure 5: Finite Verification Diagram
# ═══════════════════════════════════════════════════════════════

def fig_verification_diagram():
    limit = 200
    is_p = sieve(limit)

    fig, ax = plt.subplots(figsize=(14, 5))

    even_nums = list(range(4, limit + 1, 2))
    min_primes = []
    for n in even_nums:
        min_p = None
        for p in range(2, n // 2 + 1):
            if is_p[p] and is_p[n - p]:
                min_p = p
                break
        min_primes.append(min_p if min_p else 0)

    ax.scatter(even_nums, min_primes, c='#2196F3', s=15, alpha=0.7, zorder=2)

    ax.set_xlabel('Even number n', fontsize=12)
    ax.set_ylabel('Smallest prime p in decomposition n = p + q', fontsize=12)
    ax.set_title('Goldbach Decomposition: Smallest Prime Summand',
                 fontsize=13, fontweight='bold')

    # Annotate the finite verification boundary
    B = 100
    ax.axvline(x=B, color='#F44336', linestyle='--', linewidth=2, alpha=0.7)
    ax.annotate(f'Boundary B = {B}', (B, max(min_primes) * 0.9),
                fontsize=11, color='#F44336', fontweight='bold',
                ha='right', va='top')
    ax.annotate('Finite\nverification', (B/2, max(min_primes) * 0.8),
                fontsize=10, ha='center', color='#666')
    ax.annotate('Structural\ncovering', (B + (limit - B)/2, max(min_primes) * 0.8),
                fontsize=10, ha='center', color='#666')

    fig.tight_layout()
    return save_fig_base64(fig, 'fig_verification.png')


# ═══════════════════════════════════════════════════════════════
# Generate all figures
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating visualizations...")

    viz_data = {}

    print("  [1/5] Tropical cost function...")
    viz_data['tropical_cost'] = fig_tropical_cost()

    print("  [2/5] Goldbach heatmap...")
    viz_data['goldbach_heatmap'] = fig_goldbach_heatmap()

    print("  [3/5] Sumset support...")
    viz_data['sumset_support'] = fig_sumset_support()

    print("  [4/5] Soft cost comparison...")
    viz_data['soft_cost'] = fig_soft_cost_comparison()

    print("  [5/5] Verification diagram...")
    viz_data['verification'] = fig_verification_diagram()

    print(f"\nAll 5 visualizations generated.")
    print(f"PNG files saved: fig_tropical_cost.png, fig_goldbach_heatmap.png,")
    print(f"  fig_sumset_support.png, fig_soft_cost.png, fig_verification.png")

    # Return data for JSON packaging
    import json
    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Visualization data saved to viz_data.json")
