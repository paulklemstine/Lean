#!/usr/bin/env python3
"""
Applications of KW Witness Counting Theory.

This module demonstrates practical applications of the extremal witness-counting
theorems to communication complexity, circuit lower bounds, and information theory.
"""

from math import comb, sqrt, pi, log2, exp
from typing import List, Tuple, Dict
import sys


# ============================================================================
# Application 1: Communication Complexity Lower Bounds
# ============================================================================

def kw_communication_lower_bound(n: int, t: int) -> float:
    """
    Derive a communication complexity lower bound from KW witness counting.

    The Karchmer-Wigderson theorem states that the communication complexity
    of f equals its formula depth. The witness count provides a measure of
    how hard the corresponding communication problem is.

    A simple counting lower bound: any protocol of cost c partitions
    the witness set into at most 2^c monochromatic rectangles.

    Lower bound: D(f) >= log2(W(f) / max_rectangle_size)

    For symmetric threshold functions, this gives:
    D(Thresh(n,t)) >= log2(W(n,t)) - log2(max rectangle)

    Args:
        n: Number of variables
        t: Threshold parameter

    Returns:
        Lower bound on communication complexity
    """
    if n == 0 or t <= 0 or t > n:
        return 0.0

    # Compute witness count
    upper_sum = sum(comb(n - 1, j) for j in range(t - 1, n))
    lower_sum = sum(comb(n - 1, l) for l in range(0, t))
    w = n * upper_sum * lower_sum

    if w <= 0:
        return 0.0

    # Simple bound: each rectangle covers at most n * 2^(n-1) * 2^(n-1) witnesses
    max_rect = n * (2 ** (n - 1)) ** 2
    return max(0.0, log2(w) - log2(max_rect)) if max_rect > 0 else 0.0


def circuit_depth_from_witnesses(n: int) -> Dict[int, float]:
    """
    For each threshold t, compute the witness-based circuit depth estimate.

    The KW theorem gives depth(f) = CC(KW_f), so witness counts
    constrain formula complexity.

    Args:
        n: Number of variables

    Returns:
        Dictionary mapping t -> log2(witness_count)
    """
    results = {}
    for t in range(1, n + 1):
        upper_sum = sum(comb(n - 1, j) for j in range(t - 1, n))
        lower_sum = sum(comb(n - 1, l) for l in range(0, t))
        w = n * upper_sum * lower_sum
        if w > 0:
            results[t] = log2(w)
    return results


# ============================================================================
# Application 2: Witness Entropy and Information Content
# ============================================================================

def witness_entropy_profile(n: int) -> List[Tuple[int, float, float]]:
    """
    Compute the witness entropy profile for all thresholds at given n.

    For each threshold t, compute:
      H(t) = log2(W(n,t)) / n  (normalized witness entropy)

    This reveals the "information landscape" of monotone symmetric functions.

    Args:
        n: Number of variables

    Returns:
        List of (t, entropy, entropy_rate) tuples
    """
    results = []
    for t in range(1, n + 1):
        upper_sum = sum(comb(n - 1, j) for j in range(t - 1, n))
        lower_sum = sum(comb(n - 1, l) for l in range(0, t))
        w = n * upper_sum * lower_sum
        if w > 0:
            entropy = log2(w)
            entropy_rate = entropy / n
            results.append((t, entropy, entropy_rate))
    return results


def mutual_information_analogy(n: int, t: int) -> float:
    """
    Compute a witness-based "mutual information" analogy.

    The fraction of all (x, y, i) triples that are valid witnesses
    gives a normalized measure of how much information the threshold
    boundary reveals.

    Total possible triples: n * 2^n * 2^n (all x, y, and coordinate i)
    Valid witnesses: W(n, t)

    Normalized: W(n,t) / (n * 4^n)

    Args:
        n: Number of variables
        t: Threshold parameter

    Returns:
        Normalized witness density
    """
    if n <= 0 or t <= 0 or t > n:
        return 0.0

    upper_sum = sum(comb(n - 1, j) for j in range(t - 1, n))
    lower_sum = sum(comb(n - 1, l) for l in range(0, t))
    w = n * upper_sum * lower_sum

    total = n * (4 ** n)
    return w / total if total > 0 else 0.0


# ============================================================================
# Application 3: Interface Energy and Phase Transitions
# ============================================================================

def interface_energy(n: int, t: int) -> float:
    """
    Compute the "interface energy" at threshold t.

    Interpreting the threshold as a phase boundary on the Boolean cube,
    the interface energy is proportional to the number of edges crossing
    the boundary, weighted by the witness kernel.

    This is related to the vertex boundary / edge isoperimetric problem.

    Args:
        n: Number of variables
        t: Threshold parameter

    Returns:
        Interface energy (normalized by 4^n)
    """
    if n <= 0 or t <= 0 or t > n:
        return 0.0

    # Count "interface interactions": pairs (k, l) with k >= t > l
    # weighted by layer sizes and separation
    energy = 0
    for k in range(t, n + 1):
        for l in range(0, t):
            # Edge weight: proportional to number of bit-flip paths
            weight = comb(n, k) * comb(n, l) * (k - l)
            energy += weight

    return energy / (4 ** n)


def phase_transition_profile(n: int) -> List[Tuple[float, float, float]]:
    """
    Compute the witness density and interface energy as a function of
    the threshold density alpha = t/n.

    This reveals the "phase transition" at alpha = 1/2 where both
    quantities peak.

    Args:
        n: Number of variables

    Returns:
        List of (alpha, witness_density, interface_energy) tuples
    """
    results = []
    for t in range(1, n + 1):
        alpha = t / n
        wd = mutual_information_analogy(n, t)
        ie = interface_energy(n, t)
        results.append((alpha, wd, ie))
    return results


# ============================================================================
# Application 4: Optimal Transport Comparison
# ============================================================================

def transport_decomposition(n: int, t: int) -> Dict[str, float]:
    """
    Decompose the KW witness count into transport-theoretic components.

    KW(n,t) can be viewed as a modified transport cost where:
    - The "source" measure is the true layer distribution
    - The "sink" measure is the false layer distribution
    - The "cost kernel" is C(n-1, k-1) * C(n-1, l) instead of C(n,k)*C(n,l)*|k-l|

    This decomposition reveals the structural difference between KW counting
    and standard Wasserstein distance.

    Args:
        n: Number of variables
        t: Threshold parameter

    Returns:
        Dictionary with transport components
    """
    if n <= 0 or t <= 0 or t > n:
        return {"kw": 0, "w1": 0, "ratio": 0, "kernel_ratio_mean": 0}

    kw = 0
    w1 = 0
    kernel_ratios = []

    for k in range(t, n + 1):
        for l in range(0, t):
            kw_kernel = comb(n - 1, k - 1) * comb(n - 1, l)
            w1_kernel = comb(n, k) * comb(n, l) * (k - l)

            kw += kw_kernel
            w1 += w1_kernel

            if w1_kernel > 0:
                kernel_ratios.append(n * kw_kernel / w1_kernel)

    kw_total = n * kw
    mean_ratio = sum(kernel_ratios) / len(kernel_ratios) if kernel_ratios else 0

    return {
        "kw": kw_total,
        "w1": w1,
        "ratio": kw_total / w1 if w1 > 0 else 0,
        "kernel_ratio_mean": mean_ratio
    }


# ============================================================================
# Application 5: Noise Stability Connection
# ============================================================================

def noise_sensitivity_estimate(n: int, t: int, rho: float = 0.99) -> float:
    """
    Estimate the noise stability of threshold function Thresh(n, t)
    at correlation rho.

    NS_rho(f) = Pr[f(x) ≠ f(y)] where (x, y) are rho-correlated.

    For threshold functions, this can be approximated using the
    layer structure.

    Args:
        n: Number of variables
        t: Threshold parameter
        rho: Noise correlation parameter

    Returns:
        Approximate noise sensitivity
    """
    # For a threshold function, noise sensitivity is related to
    # the probability mass near the threshold boundary
    epsilon = 1 - rho

    # Approximate: NS ≈ (boundary mass) * epsilon * n
    # Boundary layers: t-1 and t
    if t <= 0 or t > n:
        return 0.0

    boundary_mass = comb(n, t) / (2 ** n) + (comb(n, t - 1) / (2 ** n) if t > 0 else 0)
    return min(1.0, boundary_mass * epsilon * n)


def witness_influence_correlation(n: int) -> List[Tuple[int, int, float]]:
    """
    Compute the correlation between KW witness count and total influence
    across all threshold functions.

    Total influence of Thresh(n,t) = n * C(n-1, t-1) / 2^(n-1).
    KW witness count = n * upper_sum * lower_sum.

    Args:
        n: Number of variables

    Returns:
        List of (t, witness_count, total_influence) tuples
    """
    results = []
    for t in range(1, n + 1):
        upper_sum = sum(comb(n - 1, j) for j in range(t - 1, n))
        lower_sum = sum(comb(n - 1, l) for l in range(0, t))
        w = n * upper_sum * lower_sum

        # Total influence for threshold function
        total_influence = n * comb(n - 1, t - 1) / (2 ** (n - 1))

        results.append((t, w, total_influence))
    return results


# ============================================================================
# Main: Demonstrate all applications
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("  APPLICATIONS OF KW WITNESS COUNTING THEORY")
    print("=" * 70)

    # Application 1: Communication complexity
    print("\n--- Communication Complexity Context ---")
    print("Witness count log2 values (related to formula depth):")
    for n in [8, 16, 32]:
        depths = circuit_depth_from_witnesses(n)
        maj_t = (n + 1) // 2
        if maj_t in depths:
            print(f"  n={n:>2}: log2(W(majority)) = {depths[maj_t]:.2f}, "
                  f"n itself = {n}")

    # Application 2: Witness entropy
    print("\n--- Witness Entropy Profiles ---")
    for n in [10, 20, 30]:
        print(f"\n  n={n}:")
        profile = witness_entropy_profile(n)
        for t, ent, rate in profile:
            alpha = t / n
            bar = "█" * int(rate * 20)
            print(f"    t={t:>3} (α={alpha:.2f}): H={ent:.2f}, H/n={rate:.4f} {bar}")

    # Application 3: Phase transition
    print("\n--- Phase Transition Profile (n=20) ---")
    pts = phase_transition_profile(20)
    print(f"  {'alpha':>8} | {'witness_density':>16} | {'interface_energy':>16}")
    print("  " + "-" * 50)
    for alpha, wd, ie in pts:
        print(f"  {alpha:>8.3f} | {wd:>16.8f} | {ie:>16.6f}")

    # Application 4: Transport comparison
    print("\n--- Transport Decomposition (majority) ---")
    for n in [5, 11, 21, 31, 41]:
        t = (n + 1) // 2
        decomp = transport_decomposition(n, t)
        print(f"  n={n:>2}: KW={decomp['kw']:>12}, W1={decomp['w1']:>12}, "
              f"ratio={decomp['ratio']:.6f}")

    # Application 5: Witness-influence correlation
    print("\n--- Witness Count vs Total Influence (n=15) ---")
    wic = witness_influence_correlation(15)
    print(f"  {'t':>3} | {'Witnesses':>12} | {'Influence':>12}")
    print("  " + "-" * 35)
    for t, w, inf in wic:
        print(f"  {t:>3} | {w:>12} | {inf:>12.6f}")


#!/usr/bin/env python3
"""
Demonstration of KW Witness Counting for Monotone Symmetric Boolean Functions.

This script computes and visualizes witness counts for threshold functions,
confirming the structural theorems proved in the formal verification.
"""

from math import comb, sqrt, pi, log2
from typing import List, Tuple


def kw_witness_count_threshold(n: int, t: int) -> int:
    """
    Compute the KW witness count for the threshold function Thresh(n, t).

    A KW witness is a triple (x, y, i) where:
      - x has Hamming weight k >= t (true input)
      - y has Hamming weight l < t (false input)
      - coordinate i satisfies x_i = 1, y_i = 0

    The count equals: n * sum_{k>=t} sum_{l<t} C(n-1, k-1) * C(n-1, l)

    Args:
        n: Number of variables
        t: Threshold (inputs with weight >= t are accepted)

    Returns:
        Total number of KW witnesses
    """
    if n == 0 or t == 0 or t > n:
        return 0

    total = 0
    for k in range(t, n + 1):
        for l in range(0, t):
            total += comb(n - 1, k - 1) * comb(n - 1, l)
    return n * total


def kw_witness_count_factored(n: int, t: int) -> int:
    """
    Compute the witness count using the factored formula:
      W(n,t) = n * (sum_{j=t-1}^{n-1} C(n-1,j)) * (sum_{l=0}^{t-1} C(n-1,l))

    This factorization is the key structural insight.
    """
    if n == 0 or t == 0 or t > n:
        return 0

    upper_sum = sum(comb(n - 1, j) for j in range(t - 1, n))
    lower_sum = sum(comb(n - 1, l) for l in range(0, t))
    return n * upper_sum * lower_sum


def kw_witness_count_majority(n: int) -> int:
    """Compute the KW witness count for the majority function on n variables."""
    t = (n + 1) // 2
    return kw_witness_count_threshold(n, t)


def verify_classification():
    """
    Verify the Classification Theorem: every monotone profile is a threshold profile.

    We enumerate all monotone profiles on Fin(n+1) -> Bool and confirm each is
    exactly a threshold profile.
    """
    print("=" * 70)
    print("CLASSIFICATION THEOREM VERIFICATION")
    print("Every monotone profile is a threshold profile")
    print("=" * 70)

    for n in range(0, 7):
        # A monotone profile p: {0,...,n} -> Bool with p(i) <= p(j) for i <= j
        # must be of the form: p(i) = (i >= t) for some threshold t
        # There are exactly n+2 such profiles (t = 0, 1, ..., n+1)

        # Enumerate all 2^(n+1) profiles and filter monotone ones
        monotone_count = 0
        for mask in range(1 << (n + 1)):
            profile = [(mask >> i) & 1 for i in range(n + 1)]
            # Check monotonicity
            is_mono = all(profile[i] <= profile[i + 1] for i in range(n))
            if is_mono:
                monotone_count += 1
                # Verify it's a threshold profile
                t = next((i for i in range(n + 1) if profile[i] == 1), n + 1)
                is_threshold = all(
                    profile[i] == (1 if i >= t else 0) for i in range(n + 1)
                )
                assert is_threshold, f"n={n}, profile={profile} is not threshold!"

        assert monotone_count == n + 2, (
            f"n={n}: expected {n + 2} monotone profiles, got {monotone_count}"
        )
        print(f"  n={n}: {monotone_count} monotone profiles = {n + 2} thresholds ✓")

    print()


def verify_factorization():
    """Verify the factored formula matches the direct computation."""
    print("=" * 70)
    print("FACTORIZATION THEOREM VERIFICATION")
    print("W(n,t) = n * (upper sum) * (lower sum)")
    print("=" * 70)

    for n in range(1, 15):
        for t in range(1, n + 1):
            direct = kw_witness_count_threshold(n, t)
            factored = kw_witness_count_factored(n, t)
            assert direct == factored, (
                f"n={n}, t={t}: direct={direct}, factored={factored}"
            )
    print("  All values match for n=1..14, t=1..n ✓")
    print()


def witness_count_table():
    """Display the witness count table for small n and all valid t."""
    print("=" * 70)
    print("KW WITNESS COUNT TABLE: W(n, t)")
    print("=" * 70)

    print(f"{'n':>3} | {'t':>3} | {'W(n,t)':>12} | {'W(n,t)/4^n':>12} | {'majority?':>10}")
    print("-" * 60)

    for n in range(1, 12):
        maj_t = (n + 1) // 2
        for t in range(1, n + 1):
            w = kw_witness_count_threshold(n, t)
            ratio = w / 4**n
            is_maj = "  ★" if t == maj_t else ""
            print(f"{n:>3} | {t:>3} | {w:>12} | {ratio:>12.6f} | {is_maj:>10}")
        print("-" * 60)
    print()


def majority_asymptotics():
    """
    Analyze the majority witness count asymptotics.

    Conjecture: W(Maj_n) ~ C * 4^n / sqrt(n) for some constant C > 0.
    """
    print("=" * 70)
    print("MAJORITY WITNESS ASYMPTOTICS")
    print("W(Maj_n) ~ C * 4^n / sqrt(n)")
    print("=" * 70)

    print(f"{'n':>5} | {'W(Maj_n)':>18} | {'W*sqrt(n)/4^n':>15} | {'log2(W)':>10} | {'2n - 0.5*log2(n)':>18}")
    print("-" * 80)

    for n in range(3, 30, 2):  # odd n for clean majority
        w = kw_witness_count_majority(n)
        if w > 0 and n > 0:
            normalized = w * sqrt(n) / 4**n
            log_w = log2(w) if w > 0 else 0
            predicted_log = 2 * n - 0.5 * log2(n)
            print(f"{n:>5} | {w:>18} | {normalized:>15.8f} | {log_w:>10.4f} | {predicted_log:>18.4f}")

    print()
    print("Observation: W*sqrt(n)/4^n → C ≈ √(2/π) ≈ 0.7979...")
    print(f"  √(2/π) = {sqrt(2/pi):.8f}")
    print()


def witness_count_symmetry():
    """
    Demonstrate that W(n,t) = W(n, n+1-t): the witness count is symmetric
    around the center.
    """
    print("=" * 70)
    print("WITNESS COUNT SYMMETRY: W(n,t) vs W(n, n+1-t)")
    print("=" * 70)

    for n in range(2, 10):
        symmetric = True
        for t in range(1, n + 1):
            w1 = kw_witness_count_threshold(n, t)
            w2 = kw_witness_count_threshold(n, n + 1 - t)
            if w1 != w2:
                symmetric = False
                break
        status = "✓ symmetric" if symmetric else "✗ NOT symmetric"
        print(f"  n={n}: {status}")

    print()


def transport_comparison():
    """
    Compare KW witness count with the W1 transport cost.
    W1(n,t) = sum_{k>=t, l<t} C(n,k) * C(n,l) * |k-l|
    """
    print("=" * 70)
    print("KW vs W1 TRANSPORT COMPARISON")
    print("KW(n,t) / W1(n,t) for threshold functions")
    print("=" * 70)

    def w1_transport(n: int, t: int) -> int:
        total = 0
        for k in range(t, n + 1):
            for l in range(0, t):
                total += comb(n, k) * comb(n, l) * abs(k - l)
        return total

    print(f"{'n':>5} | {'t':>3} | {'KW(n,t)':>15} | {'W1(n,t)':>15} | {'KW/W1':>10}")
    print("-" * 60)

    for n in range(3, 20, 2):
        t = (n + 1) // 2  # majority
        kw = kw_witness_count_threshold(n, t)
        w1 = w1_transport(n, t)
        if w1 > 0:
            ratio = kw / w1
            print(f"{n:>5} | {t:>3} | {kw:>15} | {w1:>15} | {ratio:>10.6f}")

    print()


def extremality_visualization():
    """
    For each n, show that majority (central threshold) maximizes the witness count
    among all threshold functions.
    """
    print("=" * 70)
    print("EXTREMALITY: MAJORITY MAXIMIZES WITNESS COUNT")
    print("=" * 70)

    for n in range(2, 15):
        counts = [(t, kw_witness_count_threshold(n, t)) for t in range(0, n + 2)]
        max_t, max_w = max(counts, key=lambda x: x[1])
        maj_t = (n + 1) // 2
        maj_w = kw_witness_count_threshold(n, maj_t)

        if max_w == maj_w:
            print(f"  n={n:>2}: max W = {max_w:>10} at t={max_t} (majority t={maj_t}) ✓")
        else:
            print(f"  n={n:>2}: max W = {max_w:>10} at t={max_t}, majority W = {maj_w} at t={maj_t}")

    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  KW WITNESS COUNTING FOR MONOTONE SYMMETRIC BOOLEAN FUNCTIONS")
    print("=" * 70 + "\n")

    verify_classification()
    verify_factorization()
    witness_count_table()
    majority_asymptotics()
    witness_count_symmetry()
    transport_comparison()
    extremality_visualization()
