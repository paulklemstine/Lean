"""
Collatz One-Way Function: Algorithms and Implementations

Type-hinted implementations of the Collatz map as a cryptographic primitive.
"""

from typing import List, Tuple, Dict, Set, Optional


def collatz_step(n: int) -> int:
    """Apply one step of the Collatz map T(n)."""
    if n <= 0:
        return 0
    if n % 2 == 0:
        return n // 2
    else:
        return 3 * n + 1


def collatz_iter(a: int, n: int) -> int:
    """Iterate the Collatz map a times starting from n: T^a(n)."""
    result = n
    for _ in range(a):
        result = collatz_step(result)
    return result


def collatz_owf(a: int, n: int) -> int:
    """One-way function f(a, n) = T^a(n)."""
    return collatz_iter(a, n)


def collatz_trajectory(a: int, n: int) -> List[int]:
    """Return the full trajectory [n, T(n), T^2(n), ..., T^a(n)]."""
    traj = [n]
    current = n
    for _ in range(a):
        current = collatz_step(current)
        traj.append(current)
    return traj


def collatz_hash(a: int, m: int, n: int) -> int:
    """Modular Collatz hash: T^a(n) mod m."""
    return collatz_owf(a, n) % m


def preimage_set(a: int, target: int, bound: int) -> Set[int]:
    """Find all n in {0, ..., bound-1} such that T^a(n) = target."""
    return {n for n in range(bound) if collatz_owf(a, n) == target}


def find_collisions(a: int, bound: int) -> List[Tuple[int, int]]:
    """Find all collision pairs (n1, n2) with n1 < n2 < bound, T^a(n1) = T^a(n2)."""
    image_map: Dict[int, List[int]] = {}
    for n in range(bound):
        val = collatz_owf(a, n)
        if val not in image_map:
            image_map[val] = []
        image_map[val].append(n)

    collisions = []
    for val, preimages in image_map.items():
        for i in range(len(preimages)):
            for j in range(i + 1, len(preimages)):
                collisions.append((preimages[i], preimages[j]))
    return collisions


def image_compression_ratio(a: int, bound: int) -> float:
    """Compute |Image(T^a)| / bound for inputs in {0, ..., bound-1}."""
    image = {collatz_owf(a, n) for n in range(bound)}
    return len(image) / bound


def preimage_density(a: int, m: int, v: int, bound: int) -> float:
    """Fraction of {0, ..., bound-1} mapping to v under collatz_hash(a, m, ·)."""
    count = sum(1 for n in range(bound) if collatz_hash(a, m, n) == v)
    return count / bound


def exponential_preimage_witness(a: int, v: int) -> int:
    """Return the 'all-even-path' preimage: 2^a * v maps to v in a steps."""
    return (2 ** a) * v


def preimage_tree_bfs(target: int, depth: int, max_per_level: int = 1000) -> Dict[int, List[int]]:
    """Build the preimage tree of target up to given depth using BFS.

    Returns a dict mapping each node to its preimages under T.
    """
    tree: Dict[int, List[int]] = {}
    current_level = {target}

    for d in range(depth):
        next_level: Set[int] = set()
        for v in current_level:
            preimages = []
            # Even preimage: 2*v always works
            preimages.append(2 * v)
            # Odd preimage: (v-1)/3 if v ≡ 1 mod 3 and (v-1)/3 is odd
            if v >= 4 and v % 3 == 1:
                candidate = (v - 1) // 3
                if candidate % 2 == 1 and candidate > 0:
                    preimages.append(candidate)
            tree[v] = preimages
            next_level.update(preimages)
            if len(next_level) > max_per_level:
                break
        current_level = next_level

    return tree


def security_gap_analysis(max_a: int, v: int = 7) -> List[Dict[str, int]]:
    """Analyze the security gap between forward cost and backward search space.

    For each iteration count a from 1 to max_a:
    - Forward cost = a (number of Collatz steps)
    - Backward search space = 2^a * v (location of exponential witness)
    - Security ratio = backward / forward
    """
    results = []
    for a in range(1, max_a + 1):
        witness = exponential_preimage_witness(a, v)
        assert collatz_owf(a, witness) == v, f"Witness verification failed for a={a}"
        results.append({
            "iterations": a,
            "forward_cost": a,
            "witness_value": witness,
            "search_space_lower_bound": 2 ** a,
            "security_ratio": 2 ** a // max(a, 1),
        })
    return results


def collision_resistant_hash_test(a: int, m: int, bound: int) -> Dict[str, float]:
    """Test collision resistance of the Collatz hash.

    Returns statistics about the hash distribution.
    """
    hash_counts: Dict[int, int] = {}
    for n in range(bound):
        h = collatz_hash(a, m, n)
        hash_counts[h] = hash_counts.get(h, 0) + 1

    values = list(hash_counts.values())
    avg = sum(values) / len(values) if values else 0
    max_count = max(values) if values else 0
    min_count = min(values) if values else 0

    return {
        "num_buckets_used": len(hash_counts),
        "total_buckets": m,
        "avg_per_bucket": avg,
        "max_per_bucket": max_count,
        "min_per_bucket": min_count,
        "uniformity_ratio": min_count / max_count if max_count > 0 else 0,
    }
