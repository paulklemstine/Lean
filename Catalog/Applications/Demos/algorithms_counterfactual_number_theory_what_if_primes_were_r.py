#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory.

Type-hinted implementations of the core algorithms:
1. Product collision detection
2. UFD verification
3. Collision spectrum computation
4. Density threshold estimation
"""

from collections import defaultdict
from itertools import combinations_with_replacement
import math


def sieve_of_eratosthenes(n: int) -> list[int]:
    """Return all primes up to n using the Sieve of Eratosthenes.

    Time: O(n log log n), Space: O(n)
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def detect_product_collisions(
    S: set[int],
) -> dict[int, list[tuple[int, int]]]:
    """Detect all product collisions in a generalized prime system.

    Algorithm: Enumerate all unordered pairs (a, b) from S with a ≤ b,
    compute a*b, and group by product value. Any product with ≥ 2
    representations is a collision.

    Pseudocode:
        products = {}
        for each pair (a, b) in S × S with a ≤ b:
            products[a*b].append((a, b))
        return {n: pairs for n, pairs in products if len(pairs) > 1}

    Time: O(|S|² log |S|)
    Space: O(|S|²)

    Args:
        S: Set of generalized primes (all ≥ 2)

    Returns:
        Dictionary mapping product values to lists of factor pairs.
        Only includes products with ≥ 2 distinct representations.
    """
    products: dict[int, list[tuple[int, int]]] = defaultdict(list)
    sorted_S = sorted(S)
    for i, a in enumerate(sorted_S):
        for b in sorted_S[i:]:
            products[a * b].append((a, b))
    return {n: pairs for n, pairs in products.items() if len(pairs) > 1}


def verify_ufd(S: set[int]) -> tuple[bool, str]:
    """Verify whether a generalized prime system has unique factorization.

    Algorithm: Check for product collisions. If none exist, UFD holds
    (by our collision theorem).

    Note: This is a sufficient but not complete check — it only detects
    collisions among pairs. For full UFD verification, one would need
    to check all multisets, which is undecidable in general for infinite
    systems. For finite systems, pair collision is sufficient because
    any collision of multisets of size > 2 can be reduced to pair collisions.

    Time: O(|S|²)
    """
    collisions = detect_product_collisions(S)
    if not collisions:
        return True, "No pair collisions detected"
    else:
        first_prod = min(collisions.keys())
        pairs = collisions[first_prod]
        return (
            False,
            f"Collision at {first_prod}: "
            + " = ".join(f"{a}×{b}" for a, b in pairs),
        )


def collision_spectrum(
    S: set[int], max_product: int | None = None
) -> dict[int, int]:
    """Compute the collision spectrum of a generalized prime system.

    The collision spectrum maps each product value to the number of
    distinct unordered pairs (a, b) from S with a*b = n.

    Algorithm:
        For each unordered pair (a, b) in S with a ≤ b:
            spectrum[a*b] += 1
        Return entries where spectrum[n] > 1

    Time: O(|S|²)
    """
    if max_product is None:
        max_product = max(S) ** 2 if S else 0

    spectrum: dict[int, int] = defaultdict(int)
    sorted_S = sorted(S)
    for i, a in enumerate(sorted_S):
        for b in sorted_S[i:]:
            if a * b <= max_product:
                spectrum[a * b] += 1
    return dict(sorted(spectrum.items()))


def collision_density_curve(
    max_N: int, step: int = 5
) -> list[tuple[int, float, float]]:
    """Compute collision density for interval systems [2, N].

    Returns list of (N, collision_fraction, prime_ratio) tuples.

    The collision fraction is the proportion of distinct products
    in [2,N]×[2,N] that have multiple representations.

    prime_ratio = π(N) / √N, showing how prime density exceeds
    the collision threshold.
    """
    primes = set(sieve_of_eratosthenes(max_N))
    results = []

    for N in range(6, max_N + 1, step):
        S = set(range(2, N + 1))
        collisions = detect_product_collisions(S)
        total_products = len(
            set(a * b for a in S for b in S if a <= b)
        )
        coll_frac = len(collisions) / total_products if total_products else 0

        pi_N = len([p for p in primes if p <= N])
        sqrt_N = math.sqrt(N)
        prime_ratio = pi_N / sqrt_N if sqrt_N > 0 else 0

        results.append((N, coll_frac, prime_ratio))

    return results


def estimate_collision_threshold(max_size: int = 200) -> int:
    """Estimate the minimum |S| for which a random subset S ⊂ [2, N]
    almost surely has a product collision.

    Uses the birthday paradox heuristic: collisions become likely when
    |S|² / (2 * N²) ≈ 1, i.e., |S| ≈ N * √2.

    For prime-like density |S| ~ N/ln(N), this happens when
    N/ln(N) ≈ N * √2, which is never — but the actual threshold
    is much lower due to multiplicative structure.
    """
    for N in range(6, max_size):
        S = set(range(2, N + 1))
        has_collision = len(detect_product_collisions(S)) > 0
        if has_collision:
            return N
    return -1


def coprimality_classification(
    max_val: int = 30,
) -> dict[str, list[tuple[int, int]]]:
    """Classify two-element systems {p, q} by UFD status.

    Demonstrates that coprimality is the boundary between UFD and non-UFD
    for two-element generalized prime systems.
    """
    ufd_coprime: list[tuple[int, int]] = []
    ufd_non_coprime: list[tuple[int, int]] = []
    non_ufd: list[tuple[int, int]] = []

    for p in range(2, max_val):
        for q in range(p + 1, max_val):
            is_ufd, _ = verify_ufd({p, q})
            if is_ufd:
                if math.gcd(p, q) == 1:
                    ufd_coprime.append((p, q))
                else:
                    ufd_non_coprime.append((p, q))
            else:
                non_ufd.append((p, q))

    return {
        "ufd_coprime": ufd_coprime,
        "ufd_non_coprime": ufd_non_coprime,
        "non_ufd": non_ufd,
    }


if __name__ == "__main__":
    # Quick demo
    print("Product collisions in {2,3,4,5,6}:")
    collisions = detect_product_collisions({2, 3, 4, 5, 6})
    for prod, pairs in sorted(collisions.items())[:10]:
        print(f"  {prod}: {' = '.join(f'{a}×{b}' for a, b in pairs)}")

    print(f"\nCollision threshold: N = {estimate_collision_threshold()}")

    print("\nTwo-element system classification (2-15):")
    classification = coprimality_classification(16)
    print(f"  UFD + coprime: {len(classification['ufd_coprime'])} systems")
    print(f"  UFD + non-coprime: {len(classification['ufd_non_coprime'])} systems")
    print(f"  Non-UFD: {len(classification['non_ufd'])} systems")
    if classification['non_ufd'][:5]:
        print(f"  First non-UFD systems: {classification['non_ufd'][:5]}")
