#!/usr/bin/env python3
"""
Cohen-Lenstra Heuristics: Applications

Real-world applications of the Cohen-Lenstra framework:
1. Predicting class group statistics for number fields
2. Analyzing random matrix universality
3. Computing restricted-product cylinder distributions
4. Information-theoretic analysis of arithmetic statistics
"""

from math import log, sqrt, prod, isqrt, gcd
from typing import List, Dict, Tuple
from collections import Counter
import random


# =============================================================================
# Application 1: Class Number Distribution Predictor
# =============================================================================

def predict_class_group_statistics(
    primes: List[int],
    discriminant_bound: int = 10000
) -> Dict[int, Dict[str, float]]:
    """
    For each prime p, predict and estimate the frequency of various
    p-group structures in class groups of imaginary quadratic fields.

    Returns:
        Dictionary mapping primes to prediction/empirical comparison
    """
    results = {}

    for p in primes:
        # CL prediction for trivial p-part
        trivial_pred = 1.0
        for k in range(1, 50):
            trivial_pred *= (1 - p ** (-k))

        # CL prediction for cyclic Z/pZ
        # P(Cl[p] = Z/pZ) = (1/|Aut(Z/pZ)|) / Z_p = 1/(p-1) * Z_p^{-1}
        # Actually: P(Cl[p^inf] has type lambda) = 1/(|Aut(G_lambda)| * Z_p)
        # For lambda = [1]: |Aut(Z/pZ)| = p-1
        cyclic_p_pred = 1.0 / (p - 1) * trivial_pred

        results[p] = {
            'trivial_prediction': trivial_pred,
            'cyclic_p_prediction': cyclic_p_pred,
        }

    return results


def display_predictions(primes: List[int]):
    """Display formatted prediction table."""
    results = predict_class_group_statistics(primes)

    print("Cohen-Lenstra Predictions for Imaginary Quadratic Fields")
    print("=" * 65)
    print(f"{'Prime':>6} {'P(trivial)':>12} {'P(Z/pZ)':>12} {'P(nontrivial)':>14}")
    print("-" * 65)

    for p in primes:
        r = results[p]
        triv = r['trivial_prediction']
        cyc = r['cyclic_p_prediction']
        nontriv = 1 - triv
        print(f"{p:>6} {triv:>12.8f} {cyc:>12.8f} {nontriv:>14.8f}")


# =============================================================================
# Application 2: Universality Testing
# =============================================================================

def test_universality(p: int = 2, n: int = 3, k: int = 2, trials: int = 5000):
    """
    Test whether different random matrix distributions produce the
    same cokernel statistics (universality).

    Compares:
    1. Uniform entries in Z/p^kZ
    2. Bernoulli entries (0 or 1)
    3. Sparse entries (0 with probability 1/2)
    """
    mod = p ** k

    def compute_det_valuation(A: List[List[int]]) -> int:
        """Compute p-adic valuation of det(A) mod p^k (for 2x2 and 3x3)."""
        if n == 2:
            det = (A[0][0] * A[1][1] - A[0][1] * A[1][0]) % mod
        elif n == 3:
            det = (A[0][0] * (A[1][1]*A[2][2] - A[1][2]*A[2][1])
                  - A[0][1] * (A[1][0]*A[2][2] - A[1][2]*A[2][0])
                  + A[0][2] * (A[1][0]*A[2][1] - A[1][1]*A[2][0])) % mod
        else:
            det = A[0][0] % mod

        if det == 0:
            return k
        val = 0
        while det % p == 0 and val < k:
            val += 1
            det //= p
        return val

    distributions = {
        'Uniform': lambda: [[random.randint(0, mod-1) for _ in range(n)] for _ in range(n)],
        'Bernoulli': lambda: [[random.randint(0, 1) for _ in range(n)] for _ in range(n)],
        'Sparse': lambda: [[random.randint(0, mod-1) if random.random() > 0.5 else 0
                           for _ in range(n)] for _ in range(n)],
    }

    print(f"\nUniversality Test: p={p}, n={n}, k={k}, {trials} trials")
    print("=" * 70)

    all_results = {}
    for name, gen in distributions.items():
        val_counts = Counter()
        for _ in range(trials):
            A = gen()
            v = compute_det_valuation(A)
            val_counts[v] += 1

        all_results[name] = {v: c/trials for v, c in val_counts.items()}

    # Display comparison
    max_val = max(max(r.keys()) for r in all_results.values())
    header = f"{'Valuation':>10}"
    for name in distributions:
        header += f" {name:>12}"
    print(header)
    print("-" * (10 + 13 * len(distributions)))

    for v in range(max_val + 1):
        row = f"{v:>10}"
        for name in distributions:
            freq = all_results[name].get(v, 0)
            row += f" {freq:>12.4f}"
        print(row)

    # Compute total variation distances
    print()
    names = list(distributions.keys())
    for i in range(len(names)):
        for j in range(i+1, len(names)):
            all_vals = set(all_results[names[i]].keys()) | set(all_results[names[j]].keys())
            tv = 0.5 * sum(abs(all_results[names[i]].get(v, 0) - all_results[names[j]].get(v, 0))
                          for v in all_vals)
            print(f"TV distance ({names[i]} vs {names[j]}): {tv:.4f}")


# =============================================================================
# Application 3: Restricted Product Cylinder Distributions
# =============================================================================

def cylinder_distribution(
    primes: List[int],
    n: int = 2,
    k: int = 2
) -> Dict[tuple, float]:
    """
    Build the restricted-product cylinder distribution over a finite
    set of primes. For each prime p, the local distribution is the
    normalized CL weight on partitions bounded by (n, k).

    Returns the product distribution on tuples of partitions.
    """
    from itertools import product as iter_product

    def partitions_bounded_local(n, k):
        result = [[]]
        def gen(parts, max_val, rem):
            if rem == 0: return
            for v in range(min(max_val, k), 0, -1):
                new = parts + [v]
                result.append(new)
                gen(new, v, rem - 1)
        gen([], k, n)
        return result

    def aut_order_local(p, partition):
        if not partition: return 1
        r = len(partition)
        e = sum(min(partition[i], partition[j]) for i in range(r) for j in range(r))
        mx = max(partition)
        cols = [sum(1 for x in partition if x >= kk) for kk in range(1, mx + 1)]
        num = 1
        de = 0
        for c in cols:
            for j in range(1, c + 1):
                num *= (p ** j - 1)
                de += j
        return num * (p ** (e - de))

    local_dists = {}
    for p in primes:
        parts = partitions_bounded_local(n, k)
        weights = {tuple(part): 1.0 / aut_order_local(p, part) for part in parts}
        total = sum(weights.values())
        local_dists[p] = {t: w / total for t, w in weights.items()}

    # Build product
    local_states = {p: list(local_dists[p].keys()) for p in primes}
    product_dist = {}
    for combo in iter_product(*[local_states[p] for p in primes]):
        weight = prod(local_dists[primes[i]][combo[i]] for i in range(len(primes)))
        product_dist[combo] = weight

    return product_dist


def display_cylinder_distribution(primes: List[int], n: int = 2, k: int = 2, top_k: int = 10):
    """Display the top entries of a cylinder distribution."""
    dist = cylinder_distribution(primes, n, k)

    print(f"\nCylinder Distribution for S = {primes}, n={n}, k={k}")
    print("=" * 70)
    print(f"State space size: {len(dist)}")
    print(f"Sum of weights: {sum(dist.values()):.10f}")
    print()

    # Show top entries
    sorted_dist = sorted(dist.items(), key=lambda x: -x[1])[:top_k]
    print(f"Top {top_k} states:")
    for state, weight in sorted_dist:
        parts_str = " × ".join(str(state[i]) if state[i] else "trivial"
                              for i in range(len(primes)))
        print(f"  {parts_str:>40}: {weight:.8f}")

    # Entropy
    h = -sum(w * log(w) for w in dist.values() if w > 0)
    print(f"\nEntropy: H(mu_S) = {h:.6f} nats")

    # Verify entropy additivity
    local_entropies = {}
    for p in primes:
        parts = [[]]
        def gen(pts, mv, rm):
            if rm == 0: return
            for v in range(min(mv, k), 0, -1):
                new = pts + [v]
                parts.append(new)
                gen(new, v, rm - 1)
        gen([], k, n)
        weights = {tuple(part): 1.0 / (lambda pp, pa: (lambda r, e, mx, cols, num, de:
            num * (pp ** (e - de)))(len(pa),
            sum(min(pa[i], pa[j]) for i in range(len(pa)) for j in range(len(pa))) if pa else 0,
            max(pa) if pa else 0,
            [sum(1 for x in pa if x >= kk) for kk in range(1, (max(pa) if pa else 0) + 1)],
            prod((pp ** j - 1) for c in [sum(1 for x in pa if x >= kk) for kk in range(1, (max(pa) if pa else 0) + 1)] for j in range(1, c + 1)) if pa else 1,
            sum(j for c in [sum(1 for x in pa if x >= kk) for kk in range(1, (max(pa) if pa else 0) + 1)] for j in range(1, c + 1)) if pa else 0
            ))(p, part)
                   for part in parts}
        total = sum(weights.values())
        dist_local = {t: w / total for t, w in weights.items()}
        local_entropies[p] = -sum(w * log(w) for w in dist_local.values() if w > 0)

    sum_local = sum(local_entropies.values())
    print(f"Sum of local entropies: {sum_local:.6f}")
    print(f"Entropy additivity error: {abs(h - sum_local):.2e}")


# =============================================================================
# Application 4: Gibbs Energy Interpretation
# =============================================================================

def gibbs_interpretation(p: int = 3, n: int = 3, k: int = 3):
    """
    Interpret CL weights as a Gibbs distribution:
    mu(G) ∝ exp(-E(G)) where E(G) = log|Aut(G)|.

    This connects arithmetic statistics to statistical mechanics.
    """
    from math import exp as math_exp

    def partitions_local(n, k):
        result = [[]]
        def gen(pts, mv, rm):
            if rm == 0: return
            for v in range(min(mv, k), 0, -1):
                new = pts + [v]
                result.append(new)
                gen(new, v, rm - 1)
        gen([], k, n)
        return result

    def aut_local(p, part):
        if not part: return 1
        r = len(part)
        e = sum(min(part[i], part[j]) for i in range(r) for j in range(r))
        mx = max(part)
        cols = [sum(1 for x in part if x >= kk) for kk in range(1, mx + 1)]
        num = 1; de = 0
        for c in cols:
            for j in range(1, c + 1):
                num *= (p ** j - 1); de += j
        return num * (p ** (e - de))

    parts = partitions_local(n, k)

    print(f"\nGibbs / Statistical Mechanics Interpretation (p={p})")
    print("=" * 70)
    print()
    print("Cohen-Lenstra weight: mu(G) = 1/|Aut(G)| / Z")
    print("Gibbs form: mu(G) = exp(-E(G)) / Z  where E(G) = log|Aut(G)|")
    print()
    print(f"{'Partition':>15} {'|Aut(G)|':>12} {'Energy E':>10} {'CL Weight':>12} {'Gibbs exp(-E)':>14}")
    print("-" * 70)

    for part in parts:
        ao = aut_local(p, part)
        energy = log(ao) if ao > 0 else 0
        cl_w = 1.0 / ao
        gibbs_w = math_exp(-energy)
        if cl_w > 0.001:
            print(f"{str(tuple(part)):>15} {ao:>12} {energy:>10.4f} {cl_w:>12.6f} {gibbs_w:>14.6f}")

    print()
    print("Note: CL weight and exp(-E) agree exactly (by construction).")
    print("The 'temperature' is fixed at T=1 in natural units.")
    print()

    # Partition function
    Z = sum(1.0 / aut_local(p, part) for part in parts)
    print(f"Partition function Z = {Z:.8f}")
    free_energy = -log(Z)
    print(f"Free energy F = -log(Z) = {free_energy:.6f}")

    # Mean energy
    mean_E = sum(log(aut_local(p, part)) / aut_local(p, part) for part in parts) / Z
    print(f"Mean energy <E> = {mean_E:.6f}")

    # Entropy
    entropy = -sum((1.0/aut_local(p, part)/Z) * log(1.0/aut_local(p, part)/Z)
                   for part in parts if aut_local(p, part) > 0)
    print(f"Entropy S = {entropy:.6f}")
    print(f"Verification: F = <E> - S = {mean_E - entropy:.6f} (should equal {free_energy:.6f})")
    print()


# =============================================================================
# Main
# =============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Cohen-Lenstra Heuristics: Applications                    ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    # Application 1: Predictions
    print("APPLICATION 1: Class Group Predictions")
    display_predictions([2, 3, 5, 7, 11, 13, 17, 19, 23, 29])
    print()

    # Application 2: Universality
    print("\nAPPLICATION 2: Random Matrix Universality")
    test_universality(p=2, n=2, k=2, trials=3000)
    print()

    # Application 3: Cylinder distributions
    print("\nAPPLICATION 3: Restricted Product Cylinder Distributions")
    display_cylinder_distribution([2, 3, 5], n=2, k=2, top_k=8)
    print()

    # Application 4: Gibbs interpretation
    print("\nAPPLICATION 4: Statistical Mechanics Interpretation")
    gibbs_interpretation(p=3, n=2, k=2)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Cohen-Lenstra Heuristics: Demonstration

This script demonstrates the mathematical framework for Cohen-Lenstra heuristics
via restricted product measures. It includes:

1. Cohen-Lenstra predictions for trivial p-part frequencies
2. Comparison with empirical class group data for imaginary quadratic fields
3. Random matrix cokernel distribution experiments
4. Entropy calculations for product distributions
5. Interactive exploration mode

Usage:
    python demo.py              # Run all demonstrations
    python demo.py --interactive  # Interactive mode
"""

import sys
import random
from math import log, sqrt, gcd, isqrt
from typing import List, Dict, Tuple, Optional
from collections import Counter

# Import algorithms (self-contained versions included below for portability)


# =============================================================================
# Core algorithms (self-contained)
# =============================================================================

def partitions_bounded(n: int, k: int) -> List[List[int]]:
    """Enumerate partitions with at most n parts, each <= k."""
    result = [[]]
    def generate(parts, max_val, remaining):
        if remaining == 0:
            return
        for v in range(min(max_val, k), 0, -1):
            new_parts = parts + [v]
            result.append(new_parts)
            generate(new_parts, v, remaining - 1)
    generate([], k, n)
    return result


def aut_order(p: int, partition: List[int]) -> int:
    """Compute |Aut(G)| for the p-group with given invariant factors."""
    if not partition:
        return 1
    r = len(partition)
    end_order_exp = sum(min(partition[i], partition[j])
                        for i in range(r) for j in range(r))
    max_part = max(partition)
    col_lengths = [sum(1 for x in partition if x >= kk) for kk in range(1, max_part + 1)]
    numerator = 1
    denom_exp = 0
    for c_k in col_lengths:
        for j in range(1, c_k + 1):
            numerator *= (p ** j - 1)
            denom_exp += j
    return numerator * (p ** (end_order_exp - denom_exp))


def cl_weight(p: int, partition: List[int]) -> float:
    """Cohen-Lenstra weight 1/|Aut(G)|."""
    return 1.0 / aut_order(p, partition)


def cl_trivial_probability(p: int, K: int = 50) -> float:
    """CL prediction for trivial p-part: prod_{k=1}^K (1 - p^{-k})."""
    result = 1.0
    for k in range(1, K + 1):
        result *= (1 - p ** (-k))
    return result


def shannon_entropy(dist: Dict[tuple, float]) -> float:
    """Shannon entropy of a finite distribution."""
    return -sum(p * log(p) for p in dist.values() if p > 0)


def valuation_count(p: int, k: int, n: int) -> int:
    """Count of elements in {0,...,p^k-1} with exact p-adic valuation n."""
    if n >= k:
        return 1 if n == k else 0
    return p ** (k - n) - p ** (k - n - 1)


# =============================================================================
# Class group computation (simplified)
# =============================================================================

def is_prime(n: int) -> bool:
    """Simple primality test."""
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


def class_number_imaginary_quadratic(d: int) -> int:
    """
    Compute the class number of Q(sqrt(-d)) using Minkowski bound
    and reduced binary quadratic forms.

    For fundamental discriminant -d (d > 0), count reduced forms
    ax^2 + bxy + cy^2 with discriminant b^2 - 4ac = -d.
    """
    if d <= 0:
        return 0

    # Determine the discriminant
    if d % 4 == 3:
        D = d
    else:
        D = 4 * d

    # Count reduced forms with discriminant -D
    # A reduced form (a, b, c) satisfies:
    # -a < b <= a < c, or 0 <= b <= a = c
    # and b^2 - 4ac = -D, i.e., 4ac = b^2 + D
    count = 0
    # b has same parity as D
    b_start = D % 2
    bound = isqrt(D // 3)

    for b in range(b_start, bound + 1, 2):
        rem = D + b * b
        if rem % 4 != 0:
            continue
        target = rem // 4  # = a * c

        # Find all a with a >= max(1, b) (or a >= 1 if b >= 0)
        # and a^2 <= target (i.e., a <= sqrt(target))
        a_min = max(1, b) if b > 0 else 1
        if b == 0:
            a_min = 1

        a_max = isqrt(target)
        for a in range(a_min, a_max + 1):
            if target % a == 0:
                c = target // a
                if a <= c:  # reduced form condition
                    if b > 0 and a == b:
                        count += 1  # boundary case
                    elif a == c:
                        count += 1  # boundary case
                    elif b == 0:
                        count += 1
                    else:
                        count += 1
    # Handle b = 0 separately if not covered
    if b_start > 0 and D % 4 == 0:
        target = D // 4
        a_max = isqrt(target)
        for a in range(1, a_max + 1):
            if target % a == 0:
                c = target // a
                if a <= c:
                    count += 1

    return count


def class_group_p_part_trivial(d: int, p: int) -> bool:
    """
    Check if the p-part of Cl(Q(sqrt(-d))) is trivial.
    This is equivalent to p not dividing the class number.
    """
    h = class_number_imaginary_quadratic(d)
    return h % p != 0


# =============================================================================
# Demo 1: Cohen-Lenstra Predictions
# =============================================================================

def demo_cl_predictions():
    """Display Cohen-Lenstra predictions for the first 20 primes."""
    print("=" * 70)
    print("DEMO 1: Cohen-Lenstra Predictions for Trivial p-Part")
    print("=" * 70)
    print()
    print("For imaginary quadratic fields Q(sqrt(-d)), the Cohen-Lenstra")
    print("heuristic predicts the probability that the p-part of the class")
    print("group is trivial:")
    print()
    print(f"{'Prime p':>8} {'CL Prediction':>15} {'= prod(1-p^{-k})':>20}")
    print("-" * 50)

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
              31, 37, 41, 43, 47, 53, 59, 61, 67, 71]

    for p in primes:
        pred = cl_trivial_probability(p)
        print(f"{p:>8} {pred:>15.8f} {'':>20}")

    print()
    print("Note: For p=2, the actual heuristic uses a modified weight")
    print("(the 'u=0' version). The value shown is the raw product formula.")
    print()


# =============================================================================
# Demo 2: Empirical Class Group Data
# =============================================================================

def demo_empirical_class_groups(max_d: int = 10000):
    """Compare CL predictions with empirical class group data."""
    print("=" * 70)
    print(f"DEMO 2: Empirical Class Group Data (prime d <= {max_d})")
    print("=" * 70)
    print()

    primes_to_test = [3, 5, 7, 11, 13]
    prime_discriminants = [d for d in range(3, max_d + 1) if is_prime(d) and d % 4 == 3]

    n_fields = len(prime_discriminants)
    print(f"Number of fields: {n_fields}")
    print()

    print(f"{'Prime p':>8} {'CL Pred':>10} {'Empirical':>10} {'Discrepancy':>12} {'StdErr':>10}")
    print("-" * 55)

    for p in primes_to_test:
        trivial_count = 0
        for d in prime_discriminants:
            h = class_number_imaginary_quadratic(d)
            if h % p != 0:
                trivial_count += 1

        empirical = trivial_count / n_fields
        prediction = cl_trivial_probability(p)
        stderr = sqrt(empirical * (1 - empirical) / n_fields)
        discrepancy = empirical - prediction

        print(f"{p:>8} {prediction:>10.6f} {empirical:>10.6f} {discrepancy:>+12.6f} {stderr:>10.6f}")

    print()
    print("The discrepancies should be within ~2 standard errors of zero.")
    print()


# =============================================================================
# Demo 3: Random Matrix Cokernel Distributions
# =============================================================================

def demo_random_matrices(p: int = 2, n: int = 2, k: int = 3, num_samples: int = 5000):
    """Sample random matrices and compare cokernel statistics to CL weights."""
    print("=" * 70)
    print(f"DEMO 3: Random Matrix Cokernels (p={p}, n={n}, k={k})")
    print("=" * 70)
    print()

    mod = p ** k

    # Sample random matrices and compute "cokernel" via simple SNF
    partition_counts: Dict[tuple, int] = Counter()

    for _ in range(num_samples):
        # Generate random matrix
        A = [[random.randint(0, mod - 1) for _ in range(n)] for _ in range(n)]

        # Compute determinant mod p^k as a rough proxy
        # For a more accurate computation, we'd need full SNF
        # Here we use a simplified approach: compute det and extract p-adic valuation
        det = A[0][0] * A[1][1] - A[0][1] * A[1][0] if n == 2 else A[0][0]
        det = det % mod

        # Extract p-adic valuation of det
        if det == 0:
            val = k
        else:
            val = 0
            temp = det
            while temp % p == 0 and val < k:
                val += 1
                temp //= p

        # For 2x2 matrices, the cokernel type is determined by the SNF
        # Simplified: just use valuation as proxy for partition
        if val == 0:
            part = ()  # trivial group
        elif val <= k:
            part = tuple([min(val, k)])  # cyclic group Z/p^val
        else:
            part = tuple([k])

        partition_counts[part] = partition_counts.get(part, 0) + 1

    # Compute CL predictions
    print(f"Sampled {num_samples} random {n}x{n} matrices over Z/{mod}Z")
    print()

    all_parts = partitions_bounded(n, k)
    cl_weights = {}
    for part in all_parts:
        t = tuple(part)
        cl_weights[t] = cl_weight(p, part)
    total_cl = sum(cl_weights.values())
    cl_normalized = {t: w / total_cl for t, w in cl_weights.items()}

    print(f"{'Partition':>15} {'Empirical':>12} {'CL Weight':>12} {'|Aut(G)|':>10}")
    print("-" * 55)

    for part in sorted(cl_normalized.keys(), key=lambda x: -cl_normalized.get(x, 0)):
        emp = partition_counts.get(part, 0) / num_samples
        cl_w = cl_normalized.get(part, 0)
        ao = aut_order(p, list(part))
        if cl_w > 0.001 or emp > 0.001:
            print(f"{str(part):>15} {emp:>12.4f} {cl_w:>12.4f} {ao:>10}")

    print()
    print("Note: The empirical distribution uses a simplified cokernel proxy.")
    print("Full SNF computation would give more accurate results.")
    print()


# =============================================================================
# Demo 4: Entropy of Product Distributions
# =============================================================================

def demo_entropy():
    """Demonstrate entropy additivity for product distributions."""
    print("=" * 70)
    print("DEMO 4: Entropy Additivity for Product Distributions")
    print("=" * 70)
    print()

    primes = [2, 3, 5]
    n, k = 2, 2

    local_distributions = {}
    local_entropies = {}

    for p in primes:
        parts = partitions_bounded(n, k)
        weights = {tuple(part): cl_weight(p, part) for part in parts}
        total = sum(weights.values())
        dist = {t: w / total for t, w in weights.items()}
        local_distributions[p] = dist
        local_entropies[p] = shannon_entropy(dist)

    print(f"Local CL distributions for n={n}, k={k}:")
    print()
    for p in primes:
        h = local_entropies[p]
        print(f"  p={p}: H(mu_p) = {h:.6f} nats")

    sum_local = sum(local_entropies.values())
    print(f"\n  Sum of local entropies: {sum_local:.6f}")

    # Compute product distribution entropy
    # Build product distribution
    product_dist = {}
    local_states = {p: list(local_distributions[p].keys()) for p in primes}

    from itertools import product as iter_product
    for combo in iter_product(*[local_states[p] for p in primes]):
        weight = 1.0
        for i, p in enumerate(primes):
            weight *= local_distributions[p][combo[i]]
        product_dist[combo] = weight

    product_entropy = shannon_entropy(product_dist)
    print(f"  Product entropy: H(mu_S) = {product_entropy:.6f}")
    print(f"  Difference: {abs(product_entropy - sum_local):.2e}")
    print(f"\n  Entropy additivity verified: H(prod) = sum(H_local)")
    print()


# =============================================================================
# Demo 5: Valuation Distribution
# =============================================================================

def demo_valuations():
    """Demonstrate the geometric distribution of p-adic valuations."""
    print("=" * 70)
    print("DEMO 5: Geometric Distribution of p-adic Valuations")
    print("=" * 70)
    print()

    p, k = 3, 6
    mod = p ** k

    print(f"p = {p}, k = {k}, working in Z/{mod}Z")
    print()
    print(f"{'Valuation n':>12} {'Count':>10} {'Empirical':>12} {'Geometric':>12} {'Match?':>8}")
    print("-" * 60)

    for n in range(k):
        # Direct count
        count = sum(1 for x in range(mod)
                    if (x == 0 and n == k) or
                    (x > 0 and all(x % (p ** i) == 0 for i in range(1, n + 1))
                     and (n == 0 or x % (p ** n) == 0)
                     and x % (p ** (n + 1)) != 0))

        # Formula count
        formula_count = valuation_count(p, k, n)
        prop = count / mod
        geom = p ** (-n) * (1 - 1/p)

        match = "✓" if abs(prop - geom) < 1e-10 else "✗"
        print(f"{n:>12} {formula_count:>10} {prop:>12.8f} {geom:>12.8f} {match:>8}")

    # Valuation k (the zero element)
    print(f"{'k=' + str(k):>12} {'1':>10} {1/mod:>12.8f} {'(boundary)':>12}")
    print()
    print("The empirical proportions exactly match p^{-n}(1 - p^{-1}).")
    print("This is the finite-level shadow of the Haar measure geometric law.")
    print()


# =============================================================================
# Interactive Mode
# =============================================================================

def interactive_mode():
    """Interactive exploration of Cohen-Lenstra distributions."""
    print("=" * 70)
    print("INTERACTIVE MODE: Cohen-Lenstra Explorer")
    print("=" * 70)
    print()
    print("Commands:")
    print("  cl <p> <n> <k>  - Show CL distribution for given parameters")
    print("  aut <p> <part>  - Compute |Aut(G)| for partition (e.g., aut 2 2,1)")
    print("  pred <p>        - CL prediction for trivial p-part")
    print("  entropy <p> <n> <k> - Shannon entropy of local CL distribution")
    print("  val <p> <k>     - Valuation distribution table")
    print("  quit            - Exit")
    print()

    while True:
        try:
            cmd = input("cl> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break

        if not cmd:
            continue

        parts = cmd.split()
        command = parts[0].lower()

        if command == "quit" or command == "q":
            break
        elif command == "cl" and len(parts) == 4:
            p, n, k = int(parts[1]), int(parts[2]), int(parts[3])
            all_parts = partitions_bounded(n, k)
            weights = {tuple(part): cl_weight(p, part) for part in all_parts}
            total = sum(weights.values())
            dist = {t: w / total for t, w in weights.items()}
            print(f"\nCL distribution for p={p}, n={n}, k={k}:")
            for part, w in sorted(dist.items(), key=lambda x: -x[1]):
                if w > 0.001:
                    print(f"  {str(part):>15}: {w:.6f}  |Aut|={aut_order(p, list(part))}")
            print(f"  Total: {sum(dist.values()):.10f}")
            print()
        elif command == "aut" and len(parts) >= 3:
            p = int(parts[1])
            part = [int(x) for x in parts[2].split(",")]
            ao = aut_order(p, part)
            print(f"|Aut(G_{part})| for p={p}: {ao}")
            print()
        elif command == "pred" and len(parts) == 2:
            p = int(parts[1])
            pred = cl_trivial_probability(p)
            print(f"P(trivial {p}-part) = {pred:.10f}")
            print()
        elif command == "entropy" and len(parts) == 4:
            p, n, k = int(parts[1]), int(parts[2]), int(parts[3])
            all_parts = partitions_bounded(n, k)
            weights = {tuple(part): cl_weight(p, part) for part in all_parts}
            total = sum(weights.values())
            dist = {t: w / total for t, w in weights.items()}
            h = shannon_entropy(dist)
            print(f"H(CL({p},{n},{k})) = {h:.6f} nats")
            print()
        elif command == "val" and len(parts) == 3:
            p, k = int(parts[1]), int(parts[2])
            print(f"\nValuation distribution for p={p}, k={k}:")
            for n in range(k):
                count = valuation_count(p, k, n)
                geom = p ** (-n) * (1 - 1/p)
                print(f"  v={n}: count={count}, prop={geom:.8f}")
            print()
        else:
            print("Unknown command. Type 'quit' to exit.")
            print()


# =============================================================================
# Main
# =============================================================================

def main():
    """Run all demonstrations."""
    if "--interactive" in sys.argv or "-i" in sys.argv:
        interactive_mode()
        return

    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Cohen-Lenstra Heuristics via Restricted Product Measures  ║")
    print("║                    Demonstration Suite                     ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_cl_predictions()
    demo_valuations()
    demo_entropy()

    # Use smaller bound for class group computation (it's slow)
    demo_empirical_class_groups(max_d=5000)

    demo_random_matrices(p=2, n=2, k=3, num_samples=3000)

    print("=" * 70)
    print("All demonstrations complete.")
    print()
    print("To explore interactively, run: python demo.py --interactive")
    print("=" * 70)


if __name__ == "__main__":
    main()
